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

        imagePicker.remove();

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
            .map!((a) {
                auto row = new BoneEditorRow(a, pack);
                boneEditor.children ~= row;
                return row;
            })
            .array;

        summaryLabel.text = format!boneCountText(boneEditorRows.length)
            ~ format!targetPackText(pack.name);

        root.updateSize();


    });

    // If cancelled, we need to remove the picker so it isn't drawn multiple times
    imagePicker.cancelled = () {
        imagePicker.remove();
    };

    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Construct a new skeleton"),
        label("Note: This feature requires detailed documentation, which it currently lacks."),

        button(pickerText, { project.showModal = imagePicker; }),

        summaryLabel = label(format!boneCountText(0)),
        boneEditor = vframe(
            .layout!"fill",
        ),

        hframe(
            .layout!"end",
            button("Cancel", { root.remove(); }),
            button("Save", {

                import std.array, std.algorithm;

                try {

                    import std.range, std.stdio;

                    // Get each bone
                    const bones = boneEditorRows
                        .filter!"!a.excluded"
                        .map!"a.result"
                        .array;

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

/// Represents a row in the bone editor.
private class BoneEditorRow : GluiFrame {

    string imagePath;
    Pack targetPack;
    bool excluded;

    GluiTextInput boneInput, variantInput;
    GluiButton!() excludedInput;

    this(string path, ref Pack pack) {
        // ref to avoid copying for the constructor

        import std.path;
        import std.algorithm;

        const base = path.baseName(".png");
        const segments = base.findSplit("_");

        imagePath = path;
        targetPack = pack;

        super(
            .layout!"fill",
            label(.layout!2, path.baseName),
            boneInput     = textInput(.layout!1, "Bone type", delegate { }),
            variantInput  = textInput(.layout!1, "Variant", delegate { }),
            excludedInput = button(.layout!1, "Included", {

                excluded = !excluded;
                excludedInput.text = excluded
                    ? "Excluded"
                    : "Included";

            }),
        );

        directionHorizontal = true;

        boneInput.value    = segments ? segments[2] : base;
        variantInput.value = segments ? segments[0] : "";

    }

    ConstructedBone result() const {

        import std.path;
        import std.exception;

        alias enforcex = enforce!SkeletonException;

        const path = imagePath.baseName;

        // Get the values
        ConstructedBone result;
        result.imagePath = imagePath;
        result.bone      = boneInput.value;
        result.variant   = variantInput.value;

        // Check them
        enforcex(result.bone.length,    path.format!"Lacking bone type for image %s");
        enforcex(result.variant.length, path.format!"Lacking bone variant for image %s");

        // Find out angle number for the bone
        const options = targetPack.getOptions(format!"models/bone/%s/%s.png"(result.bone, result.variant));

        result.angles = options.angles;

        return result;

    }

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
            button("Replace", () @trusted {

                import core.thread;

                // Perform the operation in a fiber
                new Fiber(() @safe {

                    auto targetPack = project.display.packs[0];

                    // Perform the action
                    auto nodes = constructSkeleton(targetPack, bones);
                    model.changeSkeleton(nodes);

                    // Rebuild the skeleton editor
                    project.objects.skeletonEditor.makeTree();

                    // Reload resources
                    project.display.reloadResources();

                    // Close the modals
                    root.remove();
                    parentModal.remove();

                    // Add status bar info
                    project.status.text = format!"Images exported to pack %s"(targetPack.name);
                    project.status.updateSize();

                }).call();

            }),
        ),

    );

}
