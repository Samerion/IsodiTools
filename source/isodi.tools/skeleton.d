module isodi.tools.skeleton;

import glui;
import isodi;

import isodi.tools.tree;
import isodi.tools.themes;


@safe:


void makeSkeletonEditor(ref Tree tree, Model model) {

    tree.children = [
        button("Construct new", delegate { }),
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
