module isodi.tools.options;

import glui;

import std.conv;
import std.exception;

import isodi.tools.themes;
import isodi.tools.project;

/// Saved options for the project.
struct ProjectOptions {

    uint chunkSize = 0;

}

/// Get UI for the project's options
GluiFrame projectOptionsUI(Project project) {

    auto options = &project.options;

    GluiFrame ret;
    GluiTextInput chunkSizeInput;

    ret = vframe(

        theme,
        layout!(1, "center"),

        label(
            layout!"center",
            "Project options",
        ),

        vframe(
            label(
                "Enable automatic chunking"
            ),
            label(
                "Chunks will always be square. To enable chunking, specify square length in the field below. "
                ~ "Chunks will automatically be exported to separate files on tilemap export. Set to 0 to disable."
            ),
            chunkSizeInput = textInput(
                layout!"fill",
                "Chunk size",
                () {
                    project.options.chunkSize = chunkSizeInput.value.to!int.ifThrown(0);
                }
            ),
        ),

        button(
            layout!(1, "center"),
            "Close",
            { ret.hide(); },
        ),

    );

    ret.hide();

    return ret;

}
