/// UI components for managing skeletons.
module isodi.tools.skeleton.editor_ui;

import glui;
import isodi;
import isodi.resource;

import isodi.tools.tree;
import isodi.tools.themes;
import isodi.tools.project;

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

        // Get the parent
        auto parent = i == 0
            ? tree
            : nodes[bone.parent];

        nodes ~= tree.addNode(parent, bone.id);

    }

    tree.updateSize();

}
