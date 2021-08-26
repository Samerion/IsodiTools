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
import isodi.tools.skeleton.crop_ui;
import isodi.tools.skeleton.construct_ui;


@safe:


class SkeletonEditor : GluiScrollFrame {

    public {

        Project project;
        Tree tree;

        GluiFrame[] nodes;

    }

    private {

        Model _model;
        GluiSpace inactiveSpace, activeSpace;

    }

    this(Project project) {

        this.project = project;
        this.tree = new Tree(.layout!"fill");

        // Create the main layout
        super(
            inactiveSpace = vframe(
                objectTabTheme,
                label("Pick a model to\nedit its skeleton..."),
            ),

            activeSpace = vspace(
                .layout!"fill",
                objectTabTheme,

                vframe(
                    button("Construct new", {

                        project.showModal = project.constructSkeletonWindow(this.model);

                    }),
                    button("Save", {

                        project.showModal = project.saveSkeletonWindow(this.model);

                    }),
                ),
                tree,

            )
        );

        activeSpace.hide();

    }

    @property {

        inout(Model) model() inout {

            return _model;

        }

        Model model(Model value) {

            this._model = value;

            makeTree();
            inactiveSpace.hide();
            activeSpace.show();

            return value;

        }

    }

    void makeTree() {

        // Reset this tree
        tree.children = [];
        nodes = [];

        // Add the bones
        foreach (i, bone; model.skeletonBones) {

            import std.functional : partial;

            // Get the parent
            auto parent = i == 0
                ? tree
                : nodes[bone.parent];

            auto makeFunc = (SkeletonNode localBone) => delegate {

                // TODO: read the exact variant used in the model
                const options = model.getBone(localBone);
                project.showModal = cropBoneWindow(project, options, localBone);

            };

            // Hidden? Don't add options requiring a texture
            if (bone.hidden) {

                nodes ~= tree.addNode(parent, bone.id);

            }

            // Add all options otherwise
            else nodes ~= tree.addNode(parent, bone.id,

                "Crop bone", makeFunc(bone),

            );

        }

        tree.updateSize();

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
