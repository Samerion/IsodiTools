module isodi.tools.skeleton;

import glui;
import isodi;

import isodi.tools.tree;
import isodi.tools.themes;


@safe:


void makeSkeletonEditor(ref Tree tree) {

    GluiTextInput skeletonInput;

    tree.children = [
        skeletonInput = textInput(
            .layout!"fill",
            "Skeleton type...", delegate { }
        ),
        hframe(
            .layout!(1, "fill"),
            theme,
            button(.layout!(1, "center"), "Load", delegate { }),
            button(.layout!(1, "center"), "Save", delegate { }),
        ),
    ];

    skeletonInput.size.x = 100;

    tree.updateSize();

}
