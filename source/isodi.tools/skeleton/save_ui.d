module isodi.tools.skeleton.save_ui;

import glui;
import isodi;

import isodi.tools.themes;
import isodi.tools.project;

import isodi.tools.skeleton.save;
import isodi.tools.skeleton.utils;


@safe:


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
