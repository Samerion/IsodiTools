module isodi.tools.options;

import glui;

import std.conv;
import std.exception;

import isodi.tools.themes;
import isodi.tools.project;


@safe:


/// Saved options for the project.
struct ProjectOptions {

    uint chunkSize = 0;

}

// TODO: this code could be simplified

class ProjectOptionsFrame : GluiFrame {

    Project project;
    GluiTextInput chunkSizeInput;

    alias hidden = GluiFrame.hidden;

    @property
    override bool hidden(bool value) {

        // Update values before showing again
        if (value == false) updateValues();

        return super.hidden = value;

    }

    this(Project project) {

        this.project = project;

        // Create the node
        super(
            .layout!(1, "center"),
            .modalTheme,

            label(
                .layout!"center",
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
                    .layout!"fill",
                    "Chunk size",
                    () {
                        project.options.chunkSize = chunkSizeInput.value.to!int.ifThrown(0);
                    }
                ),
            ),

            button(
                .layout!"end",
                "Close",
                { remove(); },
            ),

        );
        hide();

    }

    void updateValues() {

        auto options = &project.options;

        chunkSizeInput.value = options.chunkSize.to!string;

    }

}
