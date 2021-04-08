module isodi.tools.project;

import glui;
import raylib;

import std.math;
import std.traits;

import isodi;
import isodi.object3d;
import isodi.raylib.anchor;
import isodi.raylib.display;

import isodi.tools.packs;
import isodi.tools.objects;

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

    /// Object manager.
    Objects objects;

    /// Status label for the project.
    GluiLabel status;
    // TODO custom label to erase own text after 3 seconds
    // or maybe, a better idea, a TickTimer node in glui to handle timing

    /// Height of the brush in Isodi (1 = tile size).
    float brushHeight = 0;

    /// Height to snap new cells to.
    float heightSnap = 0.1;

    private {

        /// Current brush object.
        Object3D _brush;

        /// Anchor holding the brush.
        RaylibAnchor _brushAnchor;

        /// If true, painting is locked until the brush changes. Used to prevent repeatedly applying the same paint
        /// over and over.
        bool paintLocked;

    }

    this() {

        import isodi.camera : Camera;

        display = new RaylibDisplay;
        display.camera.offset = Camera.Offset(0, 0, 0);
        display.camera.follow = display.addAnchor({

            rlPushMatrix();
            scope (exit) rlPopMatrix();

            // Move to camera
            const campos = display.snapWorldPosition(display.raylibCamera.position);
            rlTranslatef(campos.x, brushHeight * display.cellSize, campos.z);

            // Draw the grid
            //DrawGrid(10, display.cellSize);

        });

        _brushAnchor = cast(RaylibAnchor) display.addAnchor({ });

        packs = Packs(this);
        objects = Objects(this);
        status = label();

    }

    /// Set the new brush object.
    /// Params:
    ///     obj = Object to use. Must be casted to a class from the Raylib binds to work properly.
    @property
    void brush(T : Object3D)(T obj)
    if (is(typeof(&obj.draw) : void delegate())) {

        paintLocked = false;
        _brush = obj;
        _brushAnchor.callback = {

            // Update height
            brushHeight = round(display.camera.offset.height / heightSnap) * heightSnap;

            // Get the brush position
            auto position = brushPosition;


            // The object supports offset (assuming constant position)
            static if (hasMember!(T, "offset")) obj.offset = position;

            // It doesn't (assuming dynamic position)
            else obj.position = position;


            // If the position changed
            if (_brushAnchor.position != position) {

                // Unlock the brush
                paintLocked = false;

            }

            // Update the anchor position
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

    /// Take input and update brush status, assuming the project space is hovered/active.
    void updateBrush() {

        // Ignore if there is no brush
        if (!_brush) return;

        // RMB: erase
        if (IsMouseButtonDown(MouseButton.MOUSE_RIGHT_BUTTON)) {

            erase(brush.visualPosition);

        }

        // LMB: paint
        else {

            // Ignore if not holding left button down
            if (!IsMouseButtonDown(MouseButton.MOUSE_LEFT_BUTTON)) return;

            // Ignore if painting is locked
            if (paintLocked) return;

            // Lock the paint
            paintLocked = true;

            // Paint
            paint(brush.visualPosition);

        }

    }

    /// Paint the current brush at set position
    protected void paint(Position position) {

        // Painting cells
        if (auto cell = cast(Cell) _brush) {

            display.addCell(position, cell.type);

        }

    }

    /// Erase objects matching brush type.
    protected void erase(Position position) {

        // Cells
        if (cast(Cell) _brush) {

            display.removeCell(position.toUnique);

        }

    }

    /// Get the position of the brush.
    protected Position brushPosition() const {

        const groundHeight = brushHeight * display.cellSize;

        // Get mouse position in the world
        auto mouseHit = GetCollisionRayGround(display.mouseRay(false), groundHeight);

        // Didn't hit, retry inverted
        if (!mouseHit.hit) mouseHit = GetCollisionRayGround(display.mouseRay(true), groundHeight);

        return display.isodiPosition(mouseHit.position);

    }

    // Animation playback instructions for movies.
    // TODO
    // auto animationPlan;

}
