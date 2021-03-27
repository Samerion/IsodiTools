module isodi.tools.project;

import isodi;
import isodi.object3d;
import isodi.raylib.anchor;
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

    private {

        /// Current brush object.
        Object3D _brush;

        /// Anchor holding the brush.
        RaylibAnchor _brushAnchor;

    }

    this() {

        display = new RaylibDisplay;
        display.camera.follow = display.addAnchor({ });

        _brushAnchor = cast(RaylibAnchor) display.addAnchor({ });

        packs = Packs(this);

    }

    /// Set the new brush object.
    /// Params:
    ///     obj = Object to use. Must be casted to a class from the Raylib binds to work properly.
    @property
    void brush(T : Object3D)(T obj)
    if (is(typeof(&obj.draw) : void delegate())) {

        _brush = obj;
        _brushAnchor.callback = &obj.draw;

    }

    /// Get the current paint object
    @property
    inout(Object3D) brush() inout {

        return _brush;

    }

    // Animation playback instructions for movies.
    // TODO
    // auto animationPlan;

}
