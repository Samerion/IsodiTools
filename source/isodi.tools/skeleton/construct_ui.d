module isodi.tools.skeleton.construct_ui;

import glui;
import isodi;

import std.string;

import isodi.tools.themes;
import isodi.tools.project;

import isodi.tools.skeleton.structs;
import isodi.tools.skeleton.construct;
import isodi.tools.skeleton.editor_ui;

@safe:

GluiFrame constructSkeletonWindow(Project project, Model model) {

    GluiFrame root;
    GluiFilePicker imagePicker;
    GluiLabel summaryLabel;
    GluiFrame boneEditor;
    BoneEditorRow[] boneEditorRows;

    const pickerText = "Select directory with PNG images to import";
    enum boneCountText = "Will create a skeleton with %s bones. ";
    enum targetPackText = "Bones will be exported to the first pack in the list, %s.";

    // Fail if there's no packs
    if (project.display.packs.length == 0) {

        return failConstruction("Constructing skeletons requires at least one pack in the project.");

    }

    auto pack = project.display.packs[0];

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
        boneEditorRows = dirEntries(path, SpanMode.shallow)
            .map!"a.name"
            .filter!(a => a.extension == ".png")
            .map!(a => BoneEditorRow(a, pack))
            .array;

        boneEditor.children = boneEditorRows
            .map!(a => cast(GluiNode) a.root)
            .array;

        summaryLabel.text = format!boneCountText(boneEditorRows.length)
            ~ format!targetPackText(pack.name);

        root.updateSize();


    });

    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Construct a new skeleton"),
        label("Note: This feature requires detailed documentation, which it currently lacks."),

        button(pickerText, { project.showModal = imagePicker; }),

        summaryLabel = label(format!boneCountText(0)),
        boneEditor = vframe(),

        hframe(
            .layout!"end",
            button("Cancel", { root.remove(); }),
            button("Save", {

                import std.array, std.algorithm;

                try {

                    // Get each bone
                    const bones = boneEditorRows.map!"a.result".array;
                    project.showModal = project.confirmConstructionWindow(root, model, bones[]);

                }

                // Failed, something's wrong with the bones
                catch (SkeletonException exc) {

                    project.showModal = failConstruction(exc.msg);

                }

            }),
        ),

    );

}

private GluiFrame confirmConstructionWindow(Project project, GluiFrame parentModal, Model model,
    const ConstructedBone[] bones)
do {

    GluiFrame root;
    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Confirm construction?"),
        label("Existing skeleton assigned to the model, will be replaced with the constructed one."),
        label(format!"%s bones will be removed and %s bones will be added."(
            model.skeletonBones.length, bones.length
        )),

        hframe(
            .layout!"end",
            button("Go back", { root.remove(); }),
            button("Replace", {

                auto targetPack = project.display.packs[0];

                // Perform the action
                auto nodes = constructSkeleton(targetPack, bones);
                model.changeSkeleton(nodes);

                // Rebuild the skeleton editor
                project.objects.skeletonEditor.makeTree();

                // Close the modals
                root.remove();
                parentModal.remove();

                // Add a status bar info
                project.status.text = format!"Images exported to pack %s"(targetPack.name);
                project.status.updateSize();

            }),
        ),

    );

}

private GluiFrame failConstruction(string message) {

    GluiFrame root;
    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(message),
        button(.layout!"end", "Close", { root.remove(); }),
    );

}
