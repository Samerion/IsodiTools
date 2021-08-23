module isodi.tools.skeleton.construct;

import std.path;

import isodi;
import isodi.resource;

import isodi.tools.skeleton.structs;


@safe:


/// Construct a new skeleton from images.
/// Params:
///     model      = Model to load the skeleton into.
///     pack       = Pack to load the bones into.
///     boneImages = Images to create bones from.
void constructSkeleton(Model model, Pack pack, const ConstructedBone[] boneImages) {

    SkeletonNode[] nodes;

    // TODO: Ensure each image has the same size
    // TODO: Ensure no bone would get overriden

    // Load each bone
    foreach (image; boneImages) {

        nodes ~= constructBone(image);

    }

}

private SkeletonNode constructBone(ConstructedBone boneImage) {

    cropImage(boneImage);

    SkeletonNode node = {
        name: boneImage.bone,
        id: boneImage.bone,
        variants: [boneImage.variant],

        // TODO boneStart, boneEnd, texturePosition

    };

    return node;

}

/// Crop the bone image to remove unnecessary transparency.
private void cropImage(ConstructedBone bone) @trusted {

    import std.math, std.string;
    import raylib;

    // Load the image
    auto image = LoadImage(bone.imagePath.toStringz);
    scope (exit) UnloadImage(image);

    const sideWidth = image.width / bone.angles;

    // Expected crop of each side
    auto result = Rectangle(float.nan, float.nan, 0, 0);

    // Check each angle to find how much space each one occupies
    foreach (angle; 0..bone.angles) {

        // Get the image part
        const rect = Rectangle(
            angle * sideWidth, 0,
            sideWidth, image.height,
        );
        auto part = ImageFromImage(image, rect);

        // Find the opaque part
        const border = GetImageAlphaBorder(part, 0);

        if (result.x.isNaN || border.x < result.x) result.x = border.x;
        if (result.y.isNaN || border.y < result.y) result.y = border.y;
        if (border.w > result.w) result.w = border.w;
        if (border.h > result.h) result.h = border.h;

    }

    import std.stdio;
    writeln(bone, result);

}
