module isodi.tools.skeleton.construct;

import raylib;

import std.path;
import std.string;

import isodi;
import isodi.resource;

import isodi.tools.skeleton.structs;


@safe:


/// Construct a new skeleton from images.
/// Params:
///     model      = Model to load the skeleton into.
///     pack       = Pack to load the bones into.
///     boneImages = Images to create bones from.
void constructSkeleton(isodi.Model model, Pack pack, const ConstructedBone[] bones) @trusted {

    SkeletonNode[] nodes;

    // TODO: Ensure each image has the same size
    // TODO: Ensure no bone would get overriden

    // Load each bone
    foreach (bone; bones) {

        // Load the image
        auto image = LoadImage(bone.imagePath.toStringz);
        scope (exit) UnloadImage(image);

        // Get the opaque parts of the image
        const opaquePart = anglesOpaqueRect(image, bone);

        // Crop the image to those parts
        auto result = image.angleCrop(bone, opaquePart);

        SkeletonNode node = {
            name: bone.bone,
            id: bone.bone,
            variants: [bone.variant],

            // TODO boneStart, boneEnd, texturePosition

        };

        nodes ~= node;

        // Output the image
        ExportImage(result, pack.path.buildPath(bone.packPath).toStringz);

    }

}

/// Crop each angle to remove unnecessary transparency.
private Image angleCrop(ref Image image, ConstructedBone bone, Rectangle opaquePart) @trusted {

    // Create a new canvas for the image
    auto result = GenImageColor(cast(int) opaquePart.width * bone.angles, cast(int) opaquePart.height, Colors.BLANK);

    // Add each angle in
    foreach (angle; 0..bone.angles) {

        const angleRect = image.angleRect(angle, bone);
        const sourceRect = Rectangle(
            opaquePart.x + angleRect.x,
            opaquePart.y + angleRect.y,
            opaquePart.w,
            opaquePart.h
        );
        const targetRect = Rectangle(
            opaquePart.w * angle, 0,
            opaquePart.w, opaquePart.h,
        );

        ImageDraw(&result, image, sourceRect, targetRect, Colors.WHITE);

    }

    return result;

}

/// Get the rectangle covering opaque parts of all angles in the image.
private Rectangle anglesOpaqueRect(ref Image image, ConstructedBone bone) @trusted {

    import std.math;

    // Expected crop of each side
    auto result = Rectangle(float.nan, float.nan, 0, 0);

    // Check each angle to find how much space each one occupies
    foreach (angle; 0..bone.angles) {

        // Get the image part
        auto part = ImageFromImage(image, image.angleRect(angle, bone));

        // Find the opaque part
        const border = GetImageAlphaBorder(part, 0);

        if (result.x.isNaN || border.x < result.x) result.x = border.x;
        if (result.y.isNaN || border.y < result.y) result.y = border.y;
        if (border.w > result.w) result.w = border.w;
        if (border.h > result.h) result.h = border.h;

    }

    return result;

}

/// Get the rectangle of given angle image.
private Rectangle angleRect(ref Image image, uint angle, ConstructedBone bone) {

    const sideWidth = image.width / bone.angles;

    return Rectangle(
        angle * sideWidth, 0,
        sideWidth, image.height,
    );

}
