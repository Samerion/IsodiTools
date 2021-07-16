/// Open the file.
module isodi.tools.open_file;

import std.file;
import std.path;
import std.string;

import raylib;

import isodi.tilemap;

import isodi.tools.tabs;
import isodi.tools.save_project;

/// Read dropped files if any and forward them further.
void forwardDroppedFiles(ref Tabs tabs) {

    // Get the dropped files
    int fileCount;
    auto droppedFiles = GetDroppedFiles(&fileCount);
    scope (exit) ClearDroppedFiles();

    // Check each file
    foreach (index; 0 .. fileCount) {

        auto path = cast(string) droppedFiles[index].fromStringz.dup;

        forwardFile(tabs, path);

    }

}

/// Forward files to the correct function by type
void forwardFile(ref Tabs tabs, string path) {

    // Get the current project
    auto project = tabs.openProject;

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

    // TODO: check next cases by content

    // Case 3: tilemap file
    else if (path.isFile && path.extension == ".isodi") {

        // TODO add onto a new layer
        auto file = cast(ubyte[]) read(path);
        project.display.loadTilemap(file);

    }

    // Case 3: project file
    else if (path.isFile && path.extension == ".isdproj") {

        // Load the project
        tabs.addProject(loadProject(path));

    }

    else {

        project.status.text = format!"Unknown file type %s"(path.extension);

    }

    // Update status bar size
    project.status.updateSize();

}
