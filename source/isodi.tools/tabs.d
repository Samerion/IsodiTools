///
module isodi.tools.tabs;

import glui;

import isodi.tools.themes;
import isodi.tools.project;

public import std.typecons : Flag, Yes, No;

/// This struct manages all tabs and open projects within a window.
struct Tabs {

    private struct Frames {

        private GluiFrame tabsRoot;

        /// UI for the tabs.
        private GluiFrame tabs;

        /// Frame for the palette/left sidebar.
        GluiFrame* palette;

        /// Frame for object management.
        GluiFrame* objects;

        /// Status label
        GluiLabel* status;

    }

    /// All open projects.
    Project[] projects;

    /// Currently open/focused project.
    Project openProject;

    /// Special frames shared across projects.
    Frames frames;

    /// Get the UI.
    GluiFrame getUI() {

        // Exists, return it.
        if (frames.tabsRoot) return frames.tabsRoot;

        // Root
        return frames.tabsRoot = hframe(
            theme,
            layout(NodeAlign.fill),

            // Tab list
            frames.tabs = hframe(),

            // New tab
            label("+"),
        );

    }

    /// Switch to another project
    void switchTo(Project project) {

        // Update the frames
        *frames.palette = project.packs.rootFrame;
        *frames.objects = project.objects.rootFrame;
        *frames.status = project.status;
        frames.palette.updateSize();

        // Set the project
        openProject = project;

    }

    /// Add a project to the list
    void addProject(Project project, Flag!"switchAfter" switchAfter = Yes.switchAfter) {

        import std.path : baseName;

        projects ~= project;
        frames.tabs ~= label(project.filename ? project.filename.baseName : "project");

        // todo: double click to rename file

        // Switch to the project
        if (switchAfter) switchTo(project);

    }

}
