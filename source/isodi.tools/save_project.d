module isodi.tools.save_project;

import rcdata.bin;
import rcdata.utils;

import std.file;
import std.array;
import std.algorithm;

import isodi.tilemap;

import isodi.tools.project;

enum FileVersion : ubyte {
    major = 0,
    minor = 1,
    patch = 0,
}

/// Save the project.
/// Params:
///     project = Project to save.
///     path    = Path to the target file, optional.
/// Returns:
///     If `path` is given, saves to the said file and is `void`. If not, returns an array of bytes for the file
///     content.
void saveProject(Project project, string path) {

    auto data = saveProject(project);

    write(path, data);

}

/// Ditto.
ubyte[] saveProject(Project project) {

    auto buffer = appender!(ubyte[]);
    auto bin = rcbinSerializer(buffer);

    // Encode header
    bin.get("isodiproject".staticArray);

    // Add version number of the file format
    bin.get(FileVersion.major)
       .get(FileVersion.minor)
       .get(FileVersion.patch);

    // Save settings
    bin.get(project.settings);

    // Save pack list
    // TODO: save pack name and have a program-global registry of packs
    // Would allow downloading assets like in the main client and easily transfering projects between different devices
    bin.get(project.display.packs.map!"a.path".array);

    // Save the project as a huge tilemap
    // Note: chunking does not apply here, but on export
    saveTilemap(project.display, buffer);

    return buffer[];

}
