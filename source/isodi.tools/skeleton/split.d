module isodi.tools.skeleton.split;

import isodi;
import raylib;

import isodi.tools.skeleton.utils;


@safe:


alias BoneResource = Pack.Resource!string;

/// Replace the bone textures, cropping each angle to given size and setting it at given position.
void splitBone(BoneResource resource, Vector2 size, Vector2[] anglePositions) @trusted
in(resource.options.angles == anglePositions.length)
do {

    import std.conv, std.string;

    auto image  = LoadImage(resource.match.toStringz);
    auto result = GenImageColor(size.x.to!int * anglePositions.length.to!int, size.y.to!int, Colors.BLANK);

    foreach (i, position; anglePositions) {

    }

}
