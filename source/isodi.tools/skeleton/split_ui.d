module isodi.tools.skeleton.split_ui;

import glui;
import raylib;

import isodi;
import isodi.resource;

import isodi.tools.themes;
import isodi.tools.skeleton.utils;


@safe:


alias BoneResource = Pack.Resource!string;


/// A window for spliting bones into multiple ones. For example, a pair of hands could be imported as a single bone,
/// which is unwanted in the final model. This tool will allow splitting that bone into two.
GluiFrame splitBoneWindow(BoneResource resource, SkeletonNode bone) {

    import std.array, std.range, std.algorithm;

    GluiFrame root;
    GluiTextInput targetCountInput;

    auto rows = iota(resource.options.angles)
        .map!(a => cast(GluiNode) new SplitBoneRow(resource, a))
        .array;

    return root = vscrollFrame(
        .modalTheme,

        label(.layout!"center", "Split bone"),

        hframe(
            label("Number of bones to split into: "),
            targetCountInput = textInput("", delegate { }),
        ),

        label("Pick bone parts to use in the new bone:"),

        vframe(rows),

        hframe(
            .layout!"end",
            button("Cancel", () => root.remove()),
            button("Perform the split", delegate { }),
        ),
    );

}

private class SplitBoneRow : GluiFrame {

    // TODO: cleanup
    Texture texture;
    HighlightedImageView canvas;
    GluiTextInput haInput, hbInput, vaInput, vbInput;

    this(BoneResource resource, uint angle) {

        auto nullDelegate = delegate { };

        this.texture = angleTexture(resource, angle);

        super(
            .layout!"fill",
            canvas = new HighlightedImageView(.layout!"fill", texture, Vector2(0, 100)),

            hframe(
                label("Horizontal part: "),
                haInput = textInput("", nullDelegate),
                label("/"),
                hbInput = textInput("", nullDelegate),
            ),
            hframe(
                label("Vertical part: "),
                vaInput = textInput("", nullDelegate),
                label("/"),
                vbInput = textInput("", nullDelegate),
            ),
        );

        haInput.value = "1";
        hbInput.value = "1";
        vaInput.value = "1";
        vbInput.value = "1";

    }

    /// Get the area chosen by the user.
    Rectangle chosenArea() {

        import std.array, std.algorithm;
        import std.conv, std.exception;

        uint[4] values = [haInput, hbInput, vaInput, vbInput]

            // Read the value
            .map!(a => a.value.to!uint.ifThrown(1))

            // Prevent negative values
            .map!(a => a == 0 ? 1 : a)
            .array;

        values[0] = min(values[0], values[1]);
        values[2] = min(values[2], values[3]);

        return Rectangle(
            texture.width * (values[0]-1) / values[1], texture.height * (values[2]-1) / values[3],
            texture.width * values[0]     / values[1], texture.height * values[2]     / values[3],
        );

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

        // Draw a rectangle above the selection
        const bg = Color(0, 0, 0, 0x88);

        () @trusted {

            DrawRectangleRec(above, bg);
            DrawRectangleRec(left, bg);
            DrawRectangleRec(right, bg);
            DrawRectangleRec(below, bg);

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
