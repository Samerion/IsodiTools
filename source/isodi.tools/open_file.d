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

        forwardFile(project, path);

    }

}

/// Forward files to the correct function by type
void forwardFile(Project project, string path) {

    // Unrecognized file, we should ignore it for now
    if (!path.exists) return;

    // Case 1: directory
    if (path.isDir) {

        // If there is a filename chosen for the project
        if (project.filename.length) {

            // Move it to the directory
            project.filename = path.buildPath(project.filename.baseName);

        }

        // Set the default filename
        else project.filename = path.buildPath("project.isotools");

        project.status.text = format!"Save directory updated to %s"(path);

    }

    // Case 2: pack file
    else if (path.isFile && path.baseName == "pack.json") {

        // Add it
        project.packs.addPack(path);

        project.status.text = format!"Added pack %s"(path);

    }

    // Update status bar size
    project.status.updateSize();

}
