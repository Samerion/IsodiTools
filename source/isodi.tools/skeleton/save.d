module isodi.tools.skeleton.save;

import std.json;
import isodi.resource;

import isodi.tools.exception;
// rcdata.json writing support?


@safe:


/// Save skeleton of the given model.
/// Params:
///     path     = Path to save to.
///     skeleton = Skeleton to save.
void saveSkeleton(string path, SkeletonNode[] skeleton) {

    import std.file;

    // Target path can't be a directory
    enforce!FailureException(!path.exists || !path.isDir, "Cannot write, target is a directory.");

    // Create the JSON
    JSONValue root;
    JSONValue*[] output;

    // Add each node
    foreach (i, node; skeleton) {

        auto outputNode = [
            "name": JSONValue(node.name),
            "variants": JSONValue(node.variants),
            "boneEnd": JSONValue(node.boneEnd),
            "texturePosition": JSONValue(node.texturePosition),
            "nodes": JSONValue((JSONValue[]).init),
        ];

        if (node.id != node.name) {

            outputNode["id"] = node.id;

        }

        outputNode.addOptional("boneStart", node.boneStart);
        outputNode.addOptional("rotation", node.rotation);
        outputNode.addOptional("hidden", node.hidden);
        outputNode.addOptional("mirror", node.mirror);

        () @trusted {

            // This node has a parent
            if (i) {

                // Add as child
                output[node.parent].object["nodes"].array ~= JSONValue(outputNode);
                output ~= &output[node.parent].object["nodes"].array[$-1];
                // I hate std.json! I hate std.json!

            }

            // Set as root
            else {

                root = JSONValue(outputNode);
                output ~= &root;

            }

        }();

    }

    // Ask before overwriting stuff
    NeedsConfirmException.enforce(!path.exists, "File already exists. Overwrite?", {

        write(path, root.toJSON(true));

    });

}

/// Add a JSONValue to an AA if it's set to non-default.
private void addOptional(T)(JSONValue[string] aa, string key, T item) {

    if (item != T.init) aa[key] = JSONValue(item);

}
