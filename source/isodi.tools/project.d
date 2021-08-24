module isodi.tools.project;

import glui;
import raylib;

import std.conv;
import std.math;
import std.path;
import std.string;
import std.traits;

import isodi;
import isodi.object3d;
import isodi.raylib.anchor;
import isodi.raylib.display;

import isodi.tools.packs;
import isodi.tools.objects;
import isodi.tools.options;
import isodi.tools.skeleton;


@safe:


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

    /// Project options.
    ProjectOptions options;

    /// Modal list.
    GluiSpace modalsSpace;

    /// UI for the options modal.
    GluiFrame optionsFrame;

    /// Radius of the area to be filled with given paint.
    uint brushSize = 1;

    /// Height of the brush in Isodi (1 = tile size).
    float brushHeight = 0;

    /// Lock the depth, preventing it to change with height.
    bool lockDepth;

    /// Depth of the brush in Isodi.
    float brushDepth = 1;

    /// Height to snap new cells to.
    float heightSnap = 0.1;

    private {

        /// Current brush object.
        Object3D _brush;

        /// Anchor holding the brush.
        RaylibAnchor brushAnchor;

        /// Anchor for the overlay.
        RaylibAnchor overlayAnchor;

        /// If true, painting is locked until the brush changes. Used to prevent repeatedly applying the same paint
        /// over and over.
        bool paintLocked;

    }

    this() {

        import isodi.camera : Camera;

        display = new RaylibDisplay;
        display.camera.offset = Camera.Offset(0, 0, 0);
        display.camera.follow = display.addAnchor({ });

        // Add an anchor for drawing the overlay
        overlayAnchor = display.addAnchor(&drawOverlay);
        overlayAnchor.drawOrder = RaylibAnchor.DrawOrder.last;

        brushAnchor = cast(RaylibAnchor) display.addAnchor({ });

        packs = Packs(this);
        objects = Objects(this);
        status = label();

        // Modals
        modalsSpace = onionFrame(.layout!(1, "center"));
        optionsFrame = new ProjectOptionsFrame(this);

    }

    /// Draw the project display.
    void draw() {

        // Update brush position
        auto pos = brushPosition;
        pos.height.depth = brushDepth;

        // If the position changed
        if (brushAnchor.position != pos) {

            // Unlock the brush
            paintLocked = false;

            // Update the brush anchor
            brushAnchor.position = pos;

        }

        // Update overlay anchor position
        const cameraOffset = display.camera.offset;
        overlayAnchor.position = position(cameraOffset.x.to!int, cameraOffset.y.to!int);

        // Finally, draw the display
        display.draw();

    }

    /// Show a modal in the project window.
    void showModal(GluiNode modalNode) {

        modalsSpace.children ~= modalNode;
        modalsSpace.updateSize();
        modalNode.toRemove = false;  // TODO: correct this in Glui
        modalNode.show();

    }

    /// Set the new brush object.
    /// Params:
    ///     obj = Object to use. Must be casted to a class from the Raylib binds to work properly.
    @property
    void brush(T : Object3D)(T obj)
    if (is(typeof(&obj.draw) : void delegate()))
    in(obj.position.height.depth == 0, "Brush object must be flat (depth=0).")
    do {

        paintLocked = false;
        _brush = obj;
        brushAnchor.callback = {

            // Update height
            brushHeight = round(display.camera.offset.height / heightSnap) * heightSnap;

            // Get the brush position
            auto position = brushPosition;
            position.height.depth = brushDepth;

            void setPosition(Position pos) {

                // The object supports offset (assuming constant position)
                static if (hasMember!(T, "offset")) obj.offset = pos;

                // It doesn't (assuming dynamic position)
                else obj.position = pos;

            }

            foreach (pos; CircleIterator(position, brushSize - 1)) {

                // Draw the object
                setPosition(pos);
                obj.draw();

            }

            setPosition(position);

        };

    }

    /// Get the current paint object
    @property
    inout(Object3D) brush() inout {

        return _brush;

    }

    /// Take input and update brush status, assuming the project space is hovered/active.
    void updateBrush() @trusted {

        // Ignore if there is no brush
        if (!_brush) return;

        const iterator = CircleIterator(brushAnchor.position, brushSize - 1);

        // RMB: erase
        if (IsMouseButtonDown(MouseButton.MOUSE_RIGHT_BUTTON)) {

            foreach (pos; iterator) erase(pos);

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
            foreach (pos; iterator) paint(pos);

        }

    }

    /// Paint the current brush at set position
    protected void paint(Position position) {

        // Painting cells
        if (auto cell = cast(Cell) _brush) {

            display.addCell(position, cell.type);

        }

        // Painting models
        else if (auto model = cast(isodi.Model) _brush) {

            import isodi.raylib.model : RaylibModel;

            auto newModel = cast(RaylibModel) display.addModel(position);
            newModel.copySkeleton(model);
            newModel.boneDebug = true;

            objects.objectList.addNode(objects.modelList, format!"Model %s"(newModel.id),

                "Edit skeleton", () => this.makeSkeletonEditor(objects.skeletonEditor, newModel),

            );

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
    protected Position brushPosition() const @trusted {

        const groundHeight = brushHeight * display.cellSize;

        // Get mouse position in the world
        auto mouseHit = GetCollisionRayGround(display.mouseRay(false), groundHeight);

        // Didn't hit, retry inverted
        if (!mouseHit.hit) mouseHit = GetCollisionRayGround(display.mouseRay(true), groundHeight);

        auto position = display.isodiPosition(mouseHit.position);
        position.height.depth = 0;
        return position;

    }

    protected void drawOverlay() @trusted {

        import isodi.camera : Camera;

        // If chunking enabled
        if (!options.chunkSize) return;

        rlPushMatrix();
        scope (exit) rlPopMatrix();

        const size = cast(int) options.chunkSize;
        const name = filename.baseName(".isotools");
        const cellSize = display.cellSize;
        const distance = to!int(250 / size);

        // Get current chunk relative to camera
        Camera.Offset chunkOffset = display.camera.offset;
        chunkOffset.x = floor(1.0 * chunkOffset.x / size);
        chunkOffset.y = floor(1.0 * chunkOffset.y / size);

        // Get tile position for the chunk
        auto offset = chunkOffset;
        offset.x *= size;
        offset.y *= size;

        // Place a grid
        rlTranslatef(offset.x * cellSize, brushHeight * cellSize, offset.y * cellSize);
        DrawGrid(distance, options.chunkSize * display.cellSize);

        // Caption each chunk
        foreach (i; -distance/2 .. distance/2)
        foreach (j; -distance/2 .. distance/2) {

            rlPushMatrix();
            scope (exit) rlPopMatrix();

            const caption = format!"%s_%s_%s.isodi"(name, chunkOffset.x + i, chunkOffset.y + j);
            rlTranslatef(i * cellSize * size, 0, j * cellSize * size);
            rlRotatef(90, 1, 0, 0);
            DrawText(caption.toStringz, 0, 0, 48, Colors.WHITE);

        }

    }

    // Animation playback instructions for movies.
    // TODO
    // auto animationPlan;

}

private struct CircleIterator {

    Position from, to, middle;
    uint radius;

    this(Position middle, uint radius) {

        this.middle = middle;
        this.radius = radius;

        from = middle;
        from.x -= radius;
        from.y -= radius;

        to = middle;
        to.x += radius;
        to.y += radius;

    }

    // iterate on a square filtered to a circle, consider midpoint circle algorithm in the future
    int opApply(scope int delegate(Position) @trusted dg) const {

        auto now = from;
        auto rad2 = radius*radius;

        Position pos = from;
        for (pos.y = from.y; pos.y <= to.y; pos.y++)
        for (pos.x = from.x; pos.x <= to.x; pos.x++) {

            const distance = (pos.x - middle.x)^^2 + (pos.y - middle.y)^^2;

            // Point out of circle, ignore it
            if (distance > rad2) {

                // Won't draw anything in this row
                if (pos.x > middle.x) break;
                continue;

            }

            // Found a point, call the delegate
            auto result = dg(pos);
            if (result) return result;

        }

        return 0;

    }

}
