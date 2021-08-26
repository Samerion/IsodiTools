module isodi.tools.skeleton.structs;

import glui;
import isodi.pack;

import std.path;
import std.string;
import std.exception;

import isodi.tools.skeleton.utils;


@safe:


class SkeletonException : Exception {

    mixin basicExceptionCtors;

}

/// Represents a bone to be constructed.
struct ConstructedBone {

    /// Path to the source image of the bone.
    string imagePath;

    /// Type of the bone, ex. "knee".
    string bone;

    /// Bone variant, name of this bone "style".
    string variant;

    /// Number of angles/perspectives provided in the source.
    uint angles;

    /// Path to the image within the pack.
    string packPath() const {

        return relativeBonePath(bone, variant);

    }

}

/// Represents a row in the bone editor.
struct BoneEditorRow {

    string imagePath;
    Pack targetPack;

    GluiFrame root;
    GluiTextInput boneInput, variantInput;

    this(string path, ref Pack pack) {
        // ref to avoid copying for the constructor

        import std.algorithm;

        const base = path.baseName(".png");
        const segments = base.findSplit("_");

        imagePath = path;
        targetPack = pack;

        root = hframe(
            .layout!"fill",
            label(.layout!2, path.baseName),
            boneInput    = textInput(.layout!1, "Bone type", delegate { }),
            variantInput = textInput(.layout!1, "Variant", delegate { }),
        );

        boneInput.value    = segments ? segments[2] : base;
        variantInput.value = segments ? segments[0] : "";

    }

    ConstructedBone result() const {

        alias enforcex = enforce!SkeletonException;

        const path = imagePath.baseName;

        // Get the values
        ConstructedBone result;
        result.imagePath = imagePath;
        result.bone      = boneInput.value;
        result.variant   = variantInput.value;

        // Check them
        enforcex(result.bone.length,    path.format!"Lacking bone type for image %s");
        enforcex(result.variant.length, path.format!"Lacking bone variant for image %s");

        // Find out angle number for the bone
        const options = targetPack.getOptions(format!"models/bone/%s/%s.png"(result.bone, result.variant));

        result.angles = options.angles;

        return result;

    }

}
