module isodi.tools.project;

import isodi.raylib.display;

public {

    import isodi.tools.project.packs;

}

/// Represents an open project.
class Project {

    /// Path to the file.
    string filename;

    /// True if there are any unsaved changes to the project.
    bool unsaved;

    /// The Isodi display for the project.
    RaylibDisplay display;

    /// Pack manager.
    Packs packs;

    this() {

        display = new RaylibDisplay;
        display.camera.follow = display.addAnchor({ });

        packs = Packs(this);

    }

    // Animation playback instructions for movies.
    // TODO
    // auto animationPlan;

}
