module isodi.tools.skeleton.utils;

import isodi;
import raylib;

import std.string;
import std.traits;


@safe:


/// Get the rectangle of given angle image.
package Rectangle angleRect(ref const Image image, uint angle, uint angleCount) {

    const sideWidth = image.width / angleCount;

    return Rectangle(
        angle * sideWidth, 0,
        sideWidth, image.height,
    );

}

// Those should be a part of Isodi...

alias bonePath = absolutePackPath!relativeBonePath;
alias skeletonPath = absolutePackPath!relativeSkeletonPath;

string absolutePackPath(alias fun)(const Pack pack, Parameters!fun args) {

    import std.path;

    const relative = fun(args);
    return pack.path.buildPath(relative);

}

string relativeBonePath(string bone, string variant) {

    return format!"models/bone/%s/%s.png"(bone, variant);

}

string relativeSkeletonPath(string skeleton) {

    return format!"models/skeleton/%s.json"(skeleton);

}
