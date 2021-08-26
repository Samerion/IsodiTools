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


void skeletonEditor(Project project, ref Tree tree, Model model) {

    tree.children = [
        button("Construct new", {

            project.showModal = project.constructSkeletonWindow(tree, model);

        }),
        button("Save", {

            project.showModal = project.saveSkeletonWindow(model);

        }),
        label(),
    ];

    GluiFrame[] nodes;

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

        nodes ~= tree.addNode(parent, bone.id,

            "Crop bone", makeFunc(bone),

        );

    }

    tree.updateSize();

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
