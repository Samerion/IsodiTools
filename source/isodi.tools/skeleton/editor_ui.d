/// UI components for managing skeletons.
module isodi.tools.skeleton.editor_ui;

import glui;
import isodi;
import isodi.resource;

import isodi.tools.tree;
import isodi.tools.themes;
import isodi.tools.project;

import isodi.tools.skeleton.crop_ui;
import isodi.tools.skeleton.structs;
import isodi.tools.skeleton.construct_ui;


@safe:


void skeletonEditor(Project project, ref Tree tree, Model model) {

    tree.children = [
        button("Construct new", {

            project.showModal = project.constructSkeletonWindow(tree, model);

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
            project.showModal = cropBoneWindow(options, localBone);

        };

        nodes ~= tree.addNode(parent, bone.id,

            "Crop bone", makeFunc(bone),

        );

    }

    tree.updateSize();

}
