module isodi.tools.save_model;

import rcdata.bin;

import std.array;
import std.range;

import isodi;
import isodi.resource;

/// Save model to the given output range.
void saveModel(T)(Model model, T output)
if (isOutputRange!(T, ubyte))
do {

    auto bin = rcbinSerializer(output);

    // Put the position and attached bones
    bin.getPosition(model.positionRef);
    bin.get(model.skeletonBones);

}

/// Load the model into the display.
Model loadModel(T)(Display display, ref T input)
if (isInputRange!T)
do {

    auto bin = rcbinParser(input);

    // Read model position
    Position position;
    bin.getPosition(position);
    auto model = display.addModel(position);

    // Read model bones
    auto skeleton = bin.read!(SkeletonNode[]);

    // Apply them to the model
    model.changeSkeleton(skeleton);

    return model;

}

/// Load or save position from the bin.
private void getPosition(T)(T bin, ref Position position) {

    static foreach (field; Position.fieldNames) {

        // Load the field
        bin.get(mixin("position." ~ field));

    }

}
