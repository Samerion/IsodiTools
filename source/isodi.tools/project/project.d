///
module isodi.tools.project.project;

import isodi;

/// Represents an open project.
class Project {

    /// Path to the file.
    string filename;

    /// True if there are any unsaved changes to the project.
    bool unsaved;

    /// The Isodi display for the project.
    Display display;

    // Animation playback instructions for movies.
    // TODO
    // auto animationPlan;

}
