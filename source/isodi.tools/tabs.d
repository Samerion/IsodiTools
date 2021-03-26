///
module isodi.tools.tabs;

import glui;

import isodi.tools.themes;
import isodi.tools.project;

/// This struct manages all tabs and open projects within a window.
struct Tabs {

    /// UI for the manager.
    private GluiFrame frame;

    /// All open projects.
    Project[] projects;

    /// Currently open/focused project.
    Project openProject;

    /// Get the UI.
    GluiFrame getUI() {

        // Exists, return it.
        if (frame) return frame;

        // Root
        return frame = hframe(
            theme,
            layout(NodeAlign.fill),

            // Tab list
            hframe(
                label("New project"),
            ),

            // New tab
            label("+"),
        );

    }

}
