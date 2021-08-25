module isodi.tools.skeleton.construct;

import raylib;

import std.file;
import std.path;
import std.string;

import isodi;
import isodi.resource;

import isodi.tools.skeleton.utils;
import isodi.tools.skeleton.structs;


@safe:


/// Construct a new skeleton from images.
/// Params:
///     pack       = Pack to load the bones into.
///     boneImages = Images to create bones from.
SkeletonNode[] constructSkeleton(Pack pack, const ConstructedBone[] bones) @trusted {

    SkeletonNode[] nodes = [

        {
            hidden: true,
            name: "root",
            id: "root",
            variants: [""],
            boneEnd: [0, 1, 0],
        }

    ];

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

            boneStart: [0, image.height - opaquePart.y, 0],
            boneEnd: [0, opaquePart.h, 0],
            texturePosition: [-opaquePart.w/2, 0, 0],
        };

        nodes ~= node;

        // Ensure the path exists
        const exportPath = pack.path.buildPath(bone.packPath);
        mkdirRecurse(exportPath.dirName);

        // Output the image
        ExportImage(result, exportPath.toStringz);

    }

    return nodes;

}

/// Crop each angle to remove unnecessary transparency.
private Image angleCrop(ref Image image, ConstructedBone bone, Rectangle opaquePart) @trusted {

    // Create a new canvas for the image
    auto result = GenImageColor(cast(int) opaquePart.width * bone.angles, cast(int) opaquePart.height, Colors.BLANK);

    // Add each angle in
    foreach (angle; 0..bone.angles) {

        const angleRect = image.angleRect(angle, bone.angles);
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
        auto part = ImageFromImage(image, image.angleRect(angle, bone.angles));

        // Find the opaque part
        const border = GetImageAlphaBorder(part, 0);

        if (result.x.isNaN || border.x < result.x) result.x = border.x;
        if (result.y.isNaN || border.y < result.y) result.y = border.y;
        if (border.w > result.w) result.w = border.w;
        if (border.h > result.h) result.h = border.h;

    }

    return result;

}
