///
module isodi.tools.project.packs;

import std.array;

import glui;
import isodi.pack;

import isodi.tools.themes;
import isodi.tools.project;

/// This struct is used to load and manage packs within a project. It is also used to display the palette.
struct Packs {

    /// Frame containing the palette for this project.
    GluiFrame rootFrame;

    private {

        Project project;

        // Frames
        GluiFrame packsFrame, tilesFrame, skeletonsFrame;

    }

    @disable this();

    this(Project project) {

        this.project = project;

        rootFrame = vframe(
            theme,
            layout(0, NodeAlign.start, NodeAlign.fill),

            // Tab switcher
            hframe(
                label("Packs"),
                label("Tiles"),
                label("Skeletons"),
            ),

            // Content
            packsFrame = vframe(),
            tilesFrame = vframe(),
            skeletonsFrame = vframe(),

        );

        //packsFrame.hide();
        tilesFrame.hide();
        skeletonsFrame.hide();

    }

    /// Load a new pack to the project.
    /// Params:
    ///     path = Path to the `pack.json` file of the pack.
    ///     index = Index to insert the pack at. If outside of array boundaries, inserts at the end.
    void addPack(string path, size_t index = -1) {

        auto packList = project.display.packs;

        // Load the pack
        auto pack = getPack(path);
        auto node = label(pack.name);

        // Append
        if (index >= packList.length) {

            packList ~= pack;
            packsFrame ~= node;

        }

        // Insert
        else {

            packList.insertInPlace(index, pack);
            packsFrame.children.insertInPlace(index, node);

        }

        // Clear cache
        packList.clearCache();

        // Resize the tree
        packsFrame.updateSize();

    }

}
