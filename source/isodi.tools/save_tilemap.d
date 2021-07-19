module isodi.tools.save_tilemap;

import std.file;
import std.path;
import std.math;
import std.array;
import std.format;

import isodi.cell;
import isodi.tilemap;

import isodi.tools.project;

private struct ChunkPosition {

    int x, y;

}

void exportTilemaps(ref Project project) {

    // Chunking
    if (int chunkSize = project.options.chunkSize) {

        Cell[][ChunkPosition] chunks;

        // Put cells into chunks
        foreach (cell; project.display.cells) {

            auto position = ChunkPosition(
                cast(int) floor(1.0 * cell.position.x / chunkSize),
                cast(int) floor(1.0 * cell.position.y / chunkSize),
            );

            chunks.require(position) ~= cell;

        }

        const basePath = project.filename.stripExtension;

        // Check each chunk
        foreach (key, chunk; chunks) {

            const path = format!"%s_%s_%s.isodi"(basePath, key.x, key.y);
            exportTilemap(chunk, path);

        }

        // Set status text
        project.status.text = format!"Exported %s chunks to %s/"(chunks.length, basePath.dirName);
        project.status.updateSize();

    }

    // No chunking, export as a single tilemap
    else {

        const path = project.filename.setExtension("isodi");

        // Export the tilemap
        exportTilemap(project.display.cells.array, path);

        // Add a status text
        project.status.text = format!"Exported to %s"(path);
        project.status.updateSize();

    }

}

/// Export a tilemap to the given file.
private void exportTilemap(Cell[] cells, string path) {

    // Write to a buffer
    auto appn = appender!(ubyte[]);
    saveTilemap(cells, appn);

    // Save the data
    write(path, appn[]);

}
