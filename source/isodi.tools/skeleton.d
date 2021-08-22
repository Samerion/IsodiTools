module isodi.tools.skeleton;

import glui;
import isodi;
import isodi.resource;

import std.string;

import isodi.tools.tree;
import isodi.tools.themes;
import isodi.tools.project;


@safe:


void makeSkeletonEditor(Project project, ref Tree tree, Model model) {

    tree.children = [
        button("Construct new", {

            project.showModal = project.constructSkeletonWindow(model);

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

private GluiFrame constructSkeletonWindow(Project project, Model model) {

    GluiFrame root;
    GluiFilePicker imagePicker;
    GluiLabel summaryLabel;

    string[] bonePaths;

    const pickerText = "Select directory with PNG images to import";
    enum boneCountText = "Will create a skeleton with %s bones.";

    imagePicker = filePicker(.modalTheme, pickerText, () @trusted {

        import std.file, std.path, std.array, std.algorithm;

        const path = imagePicker.value;

        // The path must be a directory
        if (!path.exists || !path.isDir) {

            // It's not, show a warning
            summaryLabel.text = "Given path is not a directory.";
            return;

        }

        // Find bone textures
        bonePaths = dirEntries(path, SpanMode.shallow)
            .map!"a.name"
            .filter!(a => a.extension == ".png")
            .array;

        summaryLabel.text = format!boneCountText(bonePaths.length);


    });

    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Construct a new skeleton"),
        label("Note: This feature requires detailed documentation, which it currently lacks."),

        button(pickerText, { project.showModal = imagePicker; }),

        summaryLabel = label(format!boneCountText(0)),

        hframe(
            .layout!"end",
            button("Cancel", { root.remove(); }),
            button("Save", {

                project.showModal = project.confirmConstructionWindow(model, bonePaths);

            }),
        ),

    );

}

private GluiFrame confirmConstructionWindow(Project project, Model model, string[] bonePaths) {

    GluiFrame root;
    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Confirm construction?"),
        label("Existing skeleton assigned to the model, will be replaced with the constructed one."),
        label(format!"%s bones will be removed and %s bones will be added."(
            model.skeletonBones.length, bonePaths.length
        )),

        hframe(
            .layout!"end",
            button("Go back", { root.remove(); }),
            button("Replace", { root.remove(); }),
        ),

    );

}
