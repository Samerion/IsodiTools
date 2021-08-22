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

    // TODO: How to name the bones? Should the `%s_%s.png` format be enforced?
    // TODO: Ensure each image has the same size
    // TODO: Ensure no bone would get overriden

    // Load each bone
    foreach (image; boneImages) {

    }

}

private void constructBone(ConstructedBone boneImage) {

}
