/// UI components for managing skeletons.
module isodi.tools.skeleton.editor_ui;

import glui;
import raylib;

import isodi;
import isodi : Model;
import isodi.resource;
import isodi.raylib.model;

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
        SkeletonNode[] nodeClipboard;

        // Bone editor
        size_t editedNode;
        GluiLabel nodeIDLabel;
        Vector3Editor boneStartInput, boneEndInput, texturePosInput;
        GluiButton!() backButton;
        GluiButton!() mirrorButton;

    }

    this(Project project) {

        this.project = project;

        // Create the main layout
        super(
            .layout!(1, "fill"),
            objectTabTheme,

            inactiveSpace = vframe(
                label("Pick a model to\nedit its skeleton..."),
            ),

            // Main skeleton display
            treeEditor = vscrollFrame(
                .layout!(1, "fill"),

                // Skeleton options
                vframe(
                    .layout!"fill",
                    button(.layout!"fill", "Construct new", {

                        project.showModal = project.constructSkeletonWindow(this.model);

                    }),
                    button(.layout!"fill", "Save", {

                        project.showModal = project.saveSkeletonWindow(this.model);

                    }),
                ),

                // The node tree
                tree = new Tree(.layout!"fill")

            ),

            boneEditor = vspace(
                .layout!(1, "fill"),

                vscrollFrame(
                    .layout!(1, "fill"),

                    vframe(
                        .layout!(1, "fill"),

                        nodeIDLabel = label("Bone"),

                        label("Bone start"),
                        boneStartInput = new Vector3Editor,

                        label("Bone end"),
                        boneEndInput = new Vector3Editor,

                        label("Texture position"),
                        texturePosInput = new Vector3Editor,

                        mirrorButton = button(.layout!"fill", "Flip bone", {

                            auto node = model.getNode(editedNode);
                            node.mirror = !node.mirror;
                            // TODO: recursive?

                            updateMirrorButton(node);

                        }),

                        button(.layout!"fill", "Invert bone ends", {

                            float[3] sum(float[3] a, float[3] b) {

                                return [a[0] + b[0], a[1] + b[1], a[2] + b[2]];

                            }

                            float[3] invert(float[3] a) {

                                return [-a[0], -a[1], -a[2]];

                            }

                            auto node = model.getNode(editedNode);

                            // Invert bone start/end
                            boneStartInput.floatValue = node.boneStart = sum(node.boneStart, node.boneEnd);
                            boneEndInput.floatValue = node.boneEnd = invert(node.boneEnd);

                            // Update textre position
                            texturePosInput.floatValue = node.texturePosition = sum(node.texturePosition, node.boneEnd);

                        }),

                    ),

                ),

                backButton = button(
                    .layout!"fill",
                    "Back", { showTree(); }
                ),

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

            import isodi.raylib.model : RaylibModel;

            // Special case: null
            if (value is null) {

                nullify();
                return null;

            }

            _model = value;

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

        hideBoneEditor();
        treeEditor.hide();

        _model = null;
        inactiveSpace.show();

    }

    void showTree() {

        hideBoneEditor();
        treeEditor.show();

        inactiveSpace.hide();

    }

    void showBoneEditor(size_t nodeIndex) {

        import std.format;

        auto node = model.getNode(nodeIndex);

        // Set the bone
        editedNode = nodeIndex;

        // Enable bone debug
        if (auto rlmodel = cast(RaylibModel) model) {

            rlmodel.nodeBoneDebug(editedNode) = true;

        }

        // Set ID
        nodeIDLabel.text = format!"Bone %s"(node.id);

        // Update positions
        boneStartInput.floatValue = node.boneStart;
        boneEndInput.floatValue = node.boneEnd;
        texturePosInput.floatValue = node.texturePosition;

        // Update buttons
        updateMirrorButton(node);

        // Show the editor
        inactiveSpace.hide();

        boneEditor.show();
        backButton.show();

        treeEditor.hide();

    }

    private void hideBoneEditor() {

        // Ignore if the editor isn't visible
        // Below code assumes it is and will crash otherwise
        if (boneEditor.hidden) return;

        // Hide the editor
        boneEditor.hide();
        backButton.hide();

        // If there's a model assigned
        if (auto model = cast(RaylibModel) _model) {

            // Clear node debug
            model.nodeBoneDebug(editedNode) = false;

        }

    }

    /// Add a new node to the skeleton.
    /// Returns: Index of the node.
    size_t addBoneNode(SkeletonNode newNode) {

        assert(newNode.parent < nodes.length, "Structure mismatch; parent not in editor tree");

        auto newIndex = model.addNode(newNode);
        auto parent = nodes[newNode.parent];

        // Add a bone to the tree
        addBoneNode(parent, newIndex, newNode);
        tree.sortNodes(parent);

        return newIndex;

    }

    protected override void drawImpl(Rectangle paddingBox, Rectangle contentBox) {

        super.drawImpl(paddingBox, contentBox);

        if (!boneEditor.hidden) {

            auto node = model.getNode(editedNode);
            node.boneStart = boneStartInput.floatValue;
            node.boneEnd = boneEndInput.floatValue;
            node.texturePosition = texturePosInput.floatValue;

        }

    }

    private void addBoneNode(GluiSpace parent, size_t boneIndex, SkeletonNode bone) {

        import std.meta;

        GluiFrame thisNode;

        // Menu for the node
        alias Menu = AliasSeq!(

            "Edit node", {

                showBoneEditor(boneIndex);

            },

            "Duplicate", {

                // TODO: duplicate recursively

                // Create the node
                auto newNode = *model.getNode(boneIndex);
                newNode.id = uniqueBoneID(bone.id);

                // Add to the tree
                addBoneNode(newNode);

            },

            "Cut node", {

                import std.format;

                // Move the node to the clipboard
                auto node = model.getNode(boneIndex);
                nodeClipboard = model.removeNodes(node.id);

                makeTree();

                // Show in status bar
                project.status.text = format!"Node %s moved to clipboard"(node.id);
                project.status.updateSize();

            },

            "Paste node", {

                import std.conv, std.format;

                // Nothing in the clipboard!
                if (nodeClipboard.length == 0) {

                    project.status.text = "Can't paste, clipboard is empty";
                    project.status.updateSize();
                    return;

                }

                // Get the node
                auto newNodes = nodeClipboard;

                size_t[] newIndexes;
                newIndexes.reserve(nodeClipboard.length);

                // Reset root parent and start
                newNodes[0].boneStart = [0, 0, 0];

                foreach (i, newNode; nodeClipboard) {

                    // Ensure unique IDs
                    newNode.id = uniqueBoneID(newNode.id);

                    // Find parent index — inherit current bone index for root
                    newNode.parent = i
                        ? newIndexes[newNode.parent]
                        : boneIndex;

                    // Paste it in the tree
                    newIndexes ~= addBoneNode(newNode);

                }

            }

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
        thisNode = bone.hidden
            ? tree.addNode(parent, bone.id, Menu)
            : tree.addNode(parent, bone.id, Menu, MenuVisisble);

        assert(boneIndex == nodes.length, "Structure mismatch; wrong node count");
        nodes ~= thisNode;

        updateSize();

    }

    private string uniqueBoneID(string baseID) {

        import std.conv;
        import std.array, std.ascii, std.algorithm, std.range;

        string targetID = baseID;

        // Repeat if the ID is occupied
        while (model.getNode(targetID)) {

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

        return targetID;

    }

    private void updateMirrorButton(const SkeletonNode* node) {

        mirrorButton.text = node.mirror
            ? "Unflip node"
            : "Flip node";

        updateSize();

    }

}
