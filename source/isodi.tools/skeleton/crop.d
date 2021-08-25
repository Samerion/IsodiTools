module isodi.tools.skeleton.crop;

import isodi;
import raylib;

import std.traits;

import isodi.tools.skeleton.utils;
import isodi.tools.skeleton.structs;


@safe:


alias BoneResource = Pack.Resource!string;

/// Create a new bone texture, cropping each angle to given size and setting it at given position.
/// Returns: the resulting bone texture.
Image cropBone(BoneResource resource, Vector2 size, Vector2[] anglePositions) @trusted
in(resource.options.angles == anglePositions.length)
do {

    import std.conv, std.string;

    const angleCount = resource.options.angles;

    auto image  = LoadImage(resource.match.toStringz);
    auto result = GenImageColor(size.x.to!int * angleCount.to!int, size.y.to!int, Colors.BLANK);

    foreach (i, position; anglePositions) {

        const sourceRect = Rectangle(position.x, position.y, size.x, size.y);
        const targetRect = result.angleRect(i.to!uint, angleCount);

        ImageDraw(&result, image, sourceRect, targetRect, Colors.WHITE);

    }

    return image;

}

/// Create a new bone as a crop of another bone.
void makeCroppedBone(ConstructedBone bone, Parameters!cropBone params) @trusted
do {

    import std.stdio;

    // Crop the bone
    auto image = cropBone(params);

    // Save the bone
    ExportImage(image, bone.packPath.toStringz);

}
