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
        .map!(a => cast(GluiNode) splitBoneRow(resource, a))
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

private GluiFrame splitBoneRow(BoneResource resource, uint angle) {

    return vframe(
        .layout!"fill",
        imageView(.layout!"fill", angleTexture(resource, angle), Vector2(0, 100)),

        hframe(
            label("Horizontal part: "),
            textInput("", delegate { }),
            label("/"),
            textInput("", delegate { }),
        ),
        hframe(
            label("Vertical part: "),
            textInput("", delegate { }),
            label("/"),
            textInput("", delegate { }),
        ),

    );

}

private Texture angleTexture(BoneResource resource, uint angle) @trusted {

    import std.string;

    auto image = LoadImage(resource.match.toStringz);

    const rect = image.angleRect(angle, resource.options.angles);

    // Crop the image to fit the angle
    image = ImageFromImage(image, rect);

    return LoadTextureFromImage(image);

}
