module isodi.tools.project;

import raylib;
import std.traits;

import isodi;
import isodi.object3d;
import isodi.raylib.anchor;
import isodi.raylib.display;

import isodi.tools.packs;

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

    /// Height of the brush in Raylib.
    float brushHeight = 0;

    private {

        /// Current brush object.
        Object3D _brush;

        /// Anchor holding the brush.
        RaylibAnchor _brushAnchor;

    }

    this() {

        display = new RaylibDisplay;
        display.camera.follow = display.addAnchor({

            rlPushMatrix();
            scope (exit) rlPopMatrix();

            // Move to camera
            const campos = display.snapWorldPosition(display.raylibCamera.position);
            rlTranslatef(campos.x, brushHeight * display.cellSize, campos.z);

            // Draw the grid
            DrawGrid(10, display.cellSize);

        });

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
        _brushAnchor.callback = {

            // Get mouse position in the world
            auto mouseHit = GetCollisionRayGround(display.mouseRay(false), brushHeight);

            // Didn't hit, retry inverted
            if (!mouseHit.hit) mouseHit = GetCollisionRayGround(display.mouseRay(true), brushHeight);

            const position = display.isodiPosition(mouseHit.position);

            // The object supports offset (assuming constant position)
            static if (hasMember!(T, "offset")) obj.offset = position;

            // It doesn't (assuming dynamic position)
            else obj.position = position;

            // Also update the anchor position
            _brushAnchor.position = position;

            // Draw the object
            obj.draw();

        };

    }

    /// Get the current paint object
    @property
    inout(Object3D) brush() inout {

        return _brush;

    }

    /// Paint a single object to the project using the current brush.
    void paint() {

        // Ignore if there is no brush
        if (!_brush) return;

        // Painting cells
        if (auto cell = cast(Cell) _brush) {

            display.addCell(cell.visualPosition, cell.type);

        }


    }

    // Animation playback instructions for movies.
    // TODO
    // auto animationPlan;

}
