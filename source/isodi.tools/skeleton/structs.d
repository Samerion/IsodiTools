module isodi.tools.skeleton.structs;

import glui;
import raylib;
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

class Vector3Editor : GluiSpace {

    GluiTextInput xInput, yInput, zInput;

    this(T...)(T args) {

        super(
            args,

            hspace(
                label("x "),
                xInput = textInput(""),
            ),
            hspace(
                label("y "),
                yInput = textInput(""),
            ),
            hspace(
                label("z "),
                zInput = textInput(""),
            ),
        );

    }

    Vector3 value() const {

        import std.conv, std.exception;

        return Vector3(
            xInput.value.to!float.ifThrown(0),
            yInput.value.to!float.ifThrown(0),
            zInput.value.to!float.ifThrown(0),
        );

    }

    float[3] floatValue() const {

        import std.conv, std.exception;

        auto val = value();

        return [val.x, val.y, val.z];

    }

    Vector3 value(Vector3 vec) {

        import std.conv;

        xInput.value = vec.x.to!string;
        yInput.value = vec.y.to!string;
        zInput.value = vec.z.to!string;

        return vec;

    }

    float[3] floatValue(float[3] arr) {

        value = Vector3(arr[0], arr[1], arr[2]);
        return arr;

    }

}
