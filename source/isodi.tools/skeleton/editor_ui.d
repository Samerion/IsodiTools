/// UI components for managing skeletons.
module isodi.tools.skeleton.editor_ui;

import glui;
import raylib;

import isodi;
import isodi : Model;
import isodi.resource;

import isodi.tools.tree;
import isodi.tools.themes;
import isodi.tools.project;

import isodi.tools.skeleton.utils;
import isodi.tools.skeleton.save_ui;
import isodi.tools.skeleton.structs;
import isodi.tools.skeleton.crop_ui;
import isodi.tools.skeleton.construct_ui;


@safe:


class SkeletonEditor : GluiSpace {

    public {

        Project project;

        GluiFrame[] nodes;

    }

    private {

        Model _model;

        // Spaces
        GluiSpace inactiveSpace, treeEditor, boneEditor;

        // Tree editor
        Tree tree;

        // Bone editor
        size_t editedNode;
        GluiLabel nodeIDLabel;
        Vector3Editor nodeStartInput, nodeEndInput, texturePosInput;
        GluiButton!() backButton;
        GluiButton!() mirrorButton;

    }

    this(Project project) {

        this.project = project;

        // Create the main layout
        super(
            vscrollFrame(
                .layout!(1, "fill"),

                inactiveSpace = vframe(
                    objectTabTheme,
                    label("Pick a model to\nedit its skeleton..."),
                ),

                treeEditor = vspace(
                    .layout!"fill",
                    objectTabTheme,

                    vframe(
                        .layout!"fill",
                        button(.layout!"fill", "Construct new", {

                            project.showModal = project.constructSkeletonWindow(this.model);

                        }),
                        button(.layout!"fill", "Save", {

                            project.showModal = project.saveSkeletonWindow(this.model);

                        }),
                    ),
                    tree = new Tree(.layout!"fill")
                ),

                boneEditor = vframe(
                    .layout!"fill",
                    objectTabTheme,

                    nodeIDLabel = label("Bone"),

                    label("Bone start"),
                    nodeStartInput = new Vector3Editor,

                    label("Bone end"),
                    nodeEndInput = new Vector3Editor,

                    label("Texture position"),
                    texturePosInput = new Vector3Editor,

                    mirrorButton = button(.layout!"fill", "Flip bone", {

                        auto node = model.getNode(editedNode);
                        node.mirror = !node.mirror;

                        updateMirrorButton(node);

                    }),

                    button(.layout!"fill", "Remove bone", {

                        auto node = model.getNode(editedNode);

                        // TODO: confirm button
                        model.removeNodes(node.id);
                        makeTree();

                    }),

                ),

            ),

            backButton = button(
                .layout!"fill",
                "Back", { showTree(); }
            ),

        );

        // Empty the tree
        nullify();

    }

    @property {

        inout(Model) model() inout {

            return _model;

        }

        Model model(Model value) {

            // Special case: null
            if (value is null) {

                nullify();
                return null;

            }

            this._model = value;

            makeTree();

            return value;

        }

    }

    void makeTree() {

        // Reset this tree
        tree.children = [];
        nodes = [];

        // Show the tree
        showTree();

        // Add the bones
        foreach (i, bone; model.skeletonBones) {

            // Get the parent
            auto parent = i == 0
                ? tree
                : nodes[bone.parent];

            addBoneNode(parent, i, bone);

        }

        // Sort the nodes
        tree.sortNodes();

        tree.updateSize();

    }

    void nullify() {

        _model = null;
        inactiveSpace.show();

        boneEditor.hide();
        backButton.hide();

        treeEditor.hide();

    }

    void showTree() {

        inactiveSpace.hide();

        boneEditor.hide();
        backButton.hide();

        treeEditor.show();

    }

    void showBoneEditor(size_t nodeIndex) {

        import std.format;

        auto node = model.getNode(nodeIndex);

        // Set the bone
        editedNode = nodeIndex;

        // Set ID
        nodeIDLabel.text = format!"Bone %s"(node.id);

        // Update positions
        nodeStartInput.floatValue = node.boneStart;
        nodeEndInput.floatValue = node.boneEnd;
        texturePosInput.floatValue = node.texturePosition;

        // Update buttons
        updateMirrorButton(node);

        // Show the editor
        inactiveSpace.hide();

        boneEditor.show();
        backButton.show();

        treeEditor.hide();

    }

    protected override void drawImpl(Rectangle paddingBox, Rectangle contentBox) {

        super.drawImpl(paddingBox, contentBox);

        if (!boneEditor.hidden) {

            auto node = model.getNode(editedNode);
            node.boneStart = nodeStartInput.floatValue;
            node.boneEnd = nodeEndInput.floatValue;
            node.texturePosition = texturePosInput.floatValue;

        }

    }

    private void addBoneNode(GluiSpace parent, size_t boneIndex, SkeletonNode bone) {

        import std.meta;

        // Menu for the node
        alias Menu = AliasSeq!(

            "Edit node", {

                showBoneEditor(boneIndex);

            },

            "Duplicate", {

                // Add a new bone to the skeleton
                auto newNode = *model.getNode(boneIndex);
                newNode.id = uniqueBoneID(bone.id);
                auto newIndex = model.addNode(newNode);

                // Add a bone to the tree
                addBoneNode(parent, newIndex, newNode);
                tree.sortNodes(parent);

            },

        );

        // Menu for the node, if node isn't hidden
        alias MenuVisisble = AliasSeq!(

            "Crop bone", {

                // TODO: read the exact variant used in the model
                const options = model.getBone(bone);
                project.showModal = cropBoneWindow(project, options, bone);

            },

        );

        // Hidden? Don't add options requiring a texture
        nodes ~= bone.hidden
            ? tree.addNode(parent, bone.id, Menu)
            : tree.addNode(parent, bone.id, Menu, MenuVisisble);

        updateSize();

    }

    private string uniqueBoneID(string baseID) {

        import std.conv;
        import std.array, std.ascii, std.algorithm, std.range;

        string targetID = baseID;

        do {

            // Get the number the bone ends with
            auto seq = targetID
                .retro.until!(a => !a.isDigit)
                .array.reverse;

            // There is a sequence number assigned already
            if (seq.length) {

                // Increment the sequence number
                auto seqNum = seq.to!int + 1;

                // Add to the bone ID
                targetID = targetID[0 .. $-seq.length] ~ seqNum.to!string;

            }

            // Append a `-2` number
            else targetID ~= "-2";

        }

        // Repeat if the ID is occupied
        while (model.getNode(targetID));

        return targetID;

    }

    private void updateMirrorButton(const SkeletonNode* node) {

        mirrorButton.text = node.mirror
            ? "Unflip node"
            : "Flip node";

        updateSize();

    }

}
