module isodi.tools.skeleton.crop_ui;

import glui;
import raylib;

import isodi;
import isodi.resource;

import std.traits;

import isodi.tools.themes;
import isodi.tools.project;
import isodi.tools.skeleton.crop;
import isodi.tools.skeleton.utils;
import isodi.tools.skeleton.structs;


@safe:


/// A window for cropping bones into multiple ones. For example, a pair of hands could be imported as a single bone,
/// which is unwanted in the final model. This tool will allow cropping that bone into two.
GluiFrame cropBoneWindow(Project project, BoneResource resource, SkeletonNode bone, string variant = null) {
    // TODO: variant argument

    import std.array, std.range, std.algorithm;

    GluiFrame root;

    auto targetBoneInput = textInput("");
    auto targetVariantInput = textInput("");
    auto wInput = textInput("");
    auto hInput = textInput("");

    targetBoneInput.value = bone.name;
    targetVariantInput.value = bone.variants[0];  // TODO

    auto table = vframe();
    CropBoneRow[] angles;

    const angleCount = resource.options.angles;

    foreach (i; 0..angleCount) {

        auto row = new CropBoneRow(resource, i, wInput, hInput);

        table.children ~= row;
        angles ~= row;

    }

    // Number of angles is even
    if (resource.options.angles % 2 == 0) {

        const halfLength = angleCount/2;

        foreach (i; 0..halfLength) {

            auto a = angles[i];
            auto b = angles[i+halfLength];

            a.setOpposite(b);
            b.setOpposite(a);

        }

    }

    root = vscrollFrame(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Crop bone"),

        vframe(
            hspace(
                label("New bone name: "),
                targetBoneInput,
            ),
            hspace(
                label("New bone variant: "),
                targetVariantInput,
            ),
            hspace(
                label("New bone size: "),
                wInput,
                label("x"),
                hInput,
            ),
        ),

        label("Pick bone parts to use in the new bone:"),

        table,

        hframe(
            .layout!"end",
            button("Cancel", () => root.remove()),
            button("Perform the crop", {

                import std.conv;

                try {

                    const pack = project.display.packs[0];
                    const size = Vector2(wInput.value.to!int, hInput.value.to!int);
                    const positions = angles.map!"a.chosenPosition".array;

                    project.showModal = confirmCropWindow(root, project, targetBoneInput.value,
                        targetVariantInput.value, resource, size, positions);

                }
                catch (ConvException) {
                    // TODO error message
                }

            }),
        ),
    );

    return root;

}

private class CropBoneRow : GluiFrame {

    // TODO: unload texture
    Texture texture;
    HighlightedImageView canvas;
    GluiTextInput xInput, yInput, wInput, hInput;
    CropBoneRow opposite;

    // Internal
    GluiFrame inputsFrame;

    /// Params:
    ///     resource = Bone resource to load.
    ///     angle    = Angle to diplay.
    ///     wInput   = Input for the box width.
    ///     hInput   = Input for the box height.
    ///     opposite = Row representing the opposite angle, if present.
    this(BoneResource resource, uint angle, GluiTextInput wInput, GluiTextInput hInput) {

        import std.conv;

        this.texture = angleTexture(resource, angle);
        this.wInput = wInput;
        this.hInput = hInput;
        this.opposite = opposite;

        auto nullDelegate = delegate { };

        super(
            .layout!"fill",
            canvas = new HighlightedImageView(.layout!"fill", texture, Vector2(0, 100)),

            inputsFrame = hframe(
                label("Position: "),
                xInput = textInput("0"),
                label(" "),
                yInput = textInput("0"),
            ),
        );

        // yeah we only have canvas access here, hence we're setting this for every angle; we should be passed an Image
        // instead
        wInput.value = canvas.texture.width.to!string;
        hInput.value = canvas.texture.height.to!string;

    }

    /// Set the opposite row
    void setOpposite(CropBoneRow value) {

        assert(opposite is null);  // can't set twice
        assert(value !is null);

        opposite = value;

        inputsFrame ~= button("Auto", {

            import std.conv;

            auto oppositeRect = opposite.chosenArea;
            xInput.value = (texture.width - oppositeRect.x - oppositeRect.w).to!string;
            yInput.value = oppositeRect.y.to!string;

        });

    }

    /// Get the area chosen by the user.
    Rectangle chosenArea() {

        import std.array, std.algorithm;
        import std.conv, std.math, std.exception;

        int[4] values = [xInput, yInput, wInput, hInput]

            // Read the value
            .map!(a => a.value.to!int.ifThrown(0))
            .array;

        // Check texture size
        values[0] = min(values[0], texture.width);
        values[1] = min(values[1], texture.height);

        return Rectangle(
            values[0], values[1],
            values[2], values[3],
        );

    }

    Vector2 chosenPosition() {

        const rect = chosenArea();

        return Vector2(rect.x, rect.y);

    }

    override void drawImpl(Rectangle paddingBox, Rectangle contentBox) {

        super.drawImpl(paddingBox, contentBox);

        canvas.highlightedPart = chosenArea;

    }

}

private class HighlightedImageView : GluiImageView {

    Rectangle highlightedPart;

    this(T...)(T args) { super(args); }

    override void drawImpl(Rectangle paddingBox, Rectangle contentBox) {

        super.drawImpl(paddingBox, contentBox);

        // Get the highlighted area within the target
        const scaleX = targetArea.width / texture.width;
        const scaleY = targetArea.height / texture.height;

        // Scale the highlight to target area
        const scaled = Rectangle(
            highlightedPart.x * scaleX,
            highlightedPart.y * scaleY,
            highlightedPart.width * scaleX,
            highlightedPart.height * scaleY,
        );

        // Get the 4 rectangles to draw
        auto above = targetArea;
        above.height = scaled.y;

        auto left = targetArea;
        left.y += scaled.y;
        left.width = scaled.x;
        left.height = scaled.height;

        auto right = targetArea;
        right.x += scaled.x + scaled.width;
        right.y += scaled.y;
        right.width -= scaled.x + scaled.width;
        right.height = scaled.height;

        auto below = targetArea;
        below.y += scaled.y + scaled.height;
        below.height -= scaled.y + scaled.height;

        auto inside = cast() scaled;
        inside.x += targetArea.x;
        inside.y += targetArea.y;

        auto middleTop    = Vector2(inside.x + inside.w/2, inside.y);
        auto middleBottom = Vector2(middleTop.x, middleTop.y + inside.h);
        auto middleLeft   = Vector2(inside.x, inside.y + inside.h/2);
        auto middleRight  = Vector2(middleLeft.x + inside.w, middleLeft.y);

        // Draw a rectangle above the selection
        const bg = Color(0, 0, 0, 0x88);

        () @trusted {

            DrawRectangleRec(above, bg);
            DrawRectangleRec(left, bg);
            DrawRectangleRec(right, bg);
            DrawRectangleRec(below, bg);
            DrawRectangleLinesEx(inside, 1, Color(0, 0, 0, 0x44));

            DrawLineEx(middleTop, middleBottom, 1, Colors.RED);
            DrawLineEx(middleLeft, middleRight, 1, Colors.RED);

        }();

    }

}

private Texture angleTexture(BoneResource resource, uint angle) @trusted {

    import std.string;

    auto image = LoadImage(resource.match.toStringz);

    const rect = image.angleRect(angle, resource.options.angles);

    // Crop the image to fit the angle
    image = ImageFromImage(image, rect);

    return LoadTextureFromImage(image);

}

private GluiFrame confirmCropWindow(GluiFrame parentModal, Project project, string type, string variant,
    Parameters!cropBone params)
do {

    import std.file, std.path, std.format;

    const pack = project.display.packs[0];
    const path = bonePath(pack, type, variant);
    const boneExistsWarning = path.exists
        ? "Warning: This will replace an existing bone and cannot be undone."
        : "";

    GluiFrame root;

    return root = vframe(
        .layout!(1, "center"),
        .modalTheme,

        label(.layout!"center", "Confirm crop?"),
        label(format!"The cropped bone %s/%s will be placed in pack %s."(type, variant, pack.name)),
        label(boneExistsWarning),

        hframe(
            .layout!"end",
            button("Cancel", () => root.remove()),
            button("Perform the crop", {

                makeCroppedBone(path, params);

                // Close the modals
                parentModal.remove();
                root.remove();

                // Reload resources
                project.display.reloadResources();

                // Add a status bar info
                project.status.text = format!"Bone exported to pack %s"(pack.name);
                project.status.updateSize();

            }),
        ),
    );

}
