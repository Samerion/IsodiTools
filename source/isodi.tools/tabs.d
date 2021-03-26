///
module isodi.tools.tabs;

import glui;

import isodi.tools.themes;
import isodi.tools.project;

public import std.typecons : Flag, Yes, No;

/// This struct manages all tabs and open projects within a window.
struct Tabs {

    /// UI for the tabs.
    private GluiFrame tabFrame;

    /// All open projects.
    Project[] projects;

    /// Currently open/focused project.
    Project openProject;

    // (no docs) Frame for the palette/left sidebar.
    GluiFrame* paletteFrame;

    /// Get the UI.
    GluiFrame getUI() {

        // Exists, return it.
        if (tabFrame) return tabFrame;

        // Root
        return hframe(
            theme,
            layout(NodeAlign.fill),

            // Tab list
            tabFrame = hframe(),

            // New tab
            label("+"),
        );

    }

    /// Switch to another project
    void switchTo(Project project) {

        // Update the frames
        *paletteFrame = project.packs.rootFrame;

        // Set the project
        openProject = project;

    }

    /// Add a project to the list
    void addProject(Project project, Flag!"switchAfter" switchAfter = Yes.switchAfter) {

        projects ~= project;
        tabFrame ~= label(project.filename ? project.filename : "New project");

        // Switch to the project
        if (switchAfter) switchTo(project);

    }

}
