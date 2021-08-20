module isodi.tools.save_project;

import rcdata.bin;
import rcdata.utils;

import std.file;
import std.array;
import std.traits;
import std.string;
import std.algorithm;
import std.exception;

import isodi.tilemap;

import isodi.tools.project;


@safe:


enum FileHeader = "isodiproject".staticArray;
alias FileHeaderType = Unqual!(typeof(FileHeader));

struct FileVersion {

    ubyte major, minor, patch;

    static FileVersion current = {
        major: 0,
        minor: 1,
        patch: 0,
    };

    string toString() {

        return format!"%s.%s.%s"(major, minor, patch);

    }

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
ubyte[] saveProject(Project project) @trusted {

    auto buffer = appender!(ubyte[]);
    auto bin = rcbinSerializer(buffer);

    // Encode header
    bin.get(FileHeader);

    // Add version number of the file format
    bin.get(FileVersion.current);

    // Save options
    bin.get(project.options);

    // Save pack list
    // TODO: save pack name and have a program-global registry of packs
    // Would allow downloading assets like in the main client and easily transfering projects between different devices
    const packs = project.display.packs[].map!"a.path".array;
    bin.get(packs);

    // Save the project as a huge tilemap
    // Note: chunking does not apply here, but on export
    saveTilemap(project.display, buffer);

    return buffer[];

}

/// Load a project from file.
Project loadProject(string filename) @trusted {

    auto project = loadProject(cast(ubyte[]) read(filename));
    project.filename = filename;
    return project;


}

/// Load a project from data.
Project loadProject(ubyte[] data) @trusted {

    auto bin = rcbinParser(data);

    // Check the header
    {

        const header = bin.read!FileHeaderType;
        enforce(header == FileHeader, "Given file is not a project file.");

        const ver = bin.read!FileVersion;
        const current = FileVersion.current;

        const error = format!"Project version %s can't be read, "(ver);

        enforce(
            ver.major == current.major,
            error ~ format!"supported major is %s.x.x"(current.major),
        );
        enforce(
            ver.minor <= current.minor,
            error ~ format!"supporting up to %s.%s.x, please update Isodi Tools!"(current.major, current.minor),
        );
        enforce(
            ver.minor < current.minor || ver.patch <= current.patch,
            error ~ format!"supporting up to %s, please update Isodi Tools!"(current),
        );

    }

    // Load the project
    auto project = new Project;

    // Get the options
    bin.get(project.options);

    // TODO: if failed to load a tile or pack, make a prompt to add more packs

    // Load packs
    auto packs = bin.read!(string[]);
    project.packs.addPack(packs);

    // Load the rest as a tilemap
    project.display.loadTilemap(data);

    return project;

}
