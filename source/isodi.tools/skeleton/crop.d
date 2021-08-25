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
Image cropBone(BoneResource resource, Vector2 size, const Vector2[] anglePositions) @trusted
in (resource.options.angles == anglePositions.length)
do {

    import std.conv, std.string;

    const angleCount = resource.options.angles;

    auto image  = LoadImage(resource.match.toStringz);
    auto result = GenImageColor(size.x.to!int * angleCount.to!int, size.y.to!int, Colors.BLANK);

    foreach (i, position; anglePositions) {

        const angle = i.to!uint;
        const sourceAngle = image.angleRect(angle, angleCount);
        const sourceRect = Rectangle(sourceAngle.x + position.x, position.y, size.x, size.y);
        const targetRect = result.angleRect(angle, angleCount);

        ImageDraw(&result, image, sourceRect, targetRect, Colors.WHITE);

    }

    return result;

}

/// Create a new bone as a crop of another bone.
void makeCroppedBone(string path, Parameters!cropBone params) @trusted {

    import std.file, std.path, std.string;

    // Crop the bone
    auto image = cropBone(params);

    // Create the directory
    mkdirRecurse(path.dirName);

    // Save the bone
    ExportImage(image, path.toStringz);

}
