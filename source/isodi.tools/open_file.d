/// Open the file.
module isodi.tools.open_file;

import std.file;
import std.path;
import std.string;

import raylib;

import isodi.tools.project;

/// Read dropped files if any and forward them further.
void forwardDroppedFiles(Project project) {

    // Get the dropped files
    int fileCount;
    auto droppedFiles = GetDroppedFiles(&fileCount);
    scope (exit) ClearDroppedFiles();

    // Check each file
    foreach (index; 0 .. fileCount) {

        auto path = cast(string) droppedFiles[index].fromStringz.dup;

        // We don't trust the system
        if (!path.exists) continue;

        // Case 1: pack file
        if (path.isFile && path.baseName == "pack.json") {

            // Add it
            project.packs.addPack(path);

        }

    }

}
