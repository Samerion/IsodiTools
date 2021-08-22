module isodi.tools.skeleton.structs;

import glui;

import std.path;
import std.string;
import std.exception;


@safe:


class SkeletonException : Exception {

    mixin basicExceptionCtors;

}

/// Represents a bone to be constructed.
struct ConstructedBone {

    string imagePath;
    string bone;
    string variant;

}

/// Represents a row in the bone editor.
struct BoneEditorRow {

    string imagePath;
    GluiFrame root;
    GluiTextInput boneInput, variantInput;

    this(string path) {

        import std.algorithm;

        const base = path.baseName(".png");
        const segments = base.findSplit("_");

        imagePath = path;

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

        enforcex(boneInput.value.length,    path.format!"Lacking bone type for image %s");
        enforcex(variantInput.value.length, path.format!"Lacking bone variant for image %s");

        return ConstructedBone(imagePath, boneInput.value, variantInput.value);

    }

}
