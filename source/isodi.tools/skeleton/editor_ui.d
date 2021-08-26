/// UI components for managing skeletons.
module isodi.tools.skeleton.editor_ui;

import glui;
import isodi;
import isodi.resource;

import isodi.tools.tree;
import isodi.tools.themes;
import isodi.tools.project;

import isodi.tools.skeleton.save;
import isodi.tools.skeleton.utils;
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
        GluiSpace inactiveSpace, treeEditor, boneEditor;
        GluiButton!() backButton;

        Tree tree;

        Vector3Editor nodeStartInput, nodeEndInput, texturePosInput;

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

                    label("Node start"),
                    nodeStartInput = new Vector3Editor,

                    label("Node end"),
                    nodeEndInput = new Vector3Editor,

                    label("Position texture"),
                    texturePosInput = new Vector3Editor,
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

    void showBoneEditor(size_t boneIndex) {

        inactiveSpace.hide();

        boneEditor.show();
        backButton.show();

        treeEditor.hide();

    }

    private void addBoneNode(GluiSpace parent, size_t boneIndex, SkeletonNode bone) {

        import std.meta;

        alias Menu = AliasSeq!(

            "Edit bone", {

                showBoneEditor(boneIndex);

            },

        );

        // Hidden? Don't add options requiring a texture
        if (bone.hidden) {

            nodes ~= tree.addNode(parent, bone.id, Menu);

        }

        // Add all options otherwise
        else nodes ~= tree.addNode(parent, bone.id, Menu,

            "Crop bone", {

                // TODO: read the exact variant used in the model
                const options = model.getBone(bone);
                project.showModal = cropBoneWindow(project, options, bone);

            },

        );

    }

}

GluiFilePicker saveSkeletonWindow(Project project, Model model) {

    import std.format;
    import std.file, std.path;

    const pack = project.display.packs[0];

    // Create a file picker for the skeleton
    GluiFilePicker picker;
    picker = filePicker(
        .modalTheme,
        "Pick a filename to save the skeleton as",
        {

            // Save the skeleton
            saveSkeleton(picker.value, model.skeletonBones);

            // Confirm the change
            project.status.text = format!"Skeleton saved to %s"(picker.value);
            project.status.updateSize();

            // Reload the resource list sidebar
            project.packs.reload();

        }
    );

    // Go to the pack directory
    picker.value = pack.skeletonPath("").dirName ~ dirSeparator;
    mkdirRecurse(picker.value);

    return picker;

}
