///
module isodi.tools.packs;

import std.array;
import std.typecons;
import std.algorithm;

import glui;
import raylib;

import isodi;
import isodi.pack;

import isodi.tools.themes;
import isodi.tools.project;

/// This struct is used to load and manage packs within a project. It is also used to display the palette.
struct Packs {

    /// Frame containing the palette for this project.
    GluiFrame rootFrame;

    private {

        Project project;

        // Tab contents
        GluiFrame packsFrame, tilesFrame, skeletonsFrame;

        // Current tab
        GluiFrame openTabFrame;

        // Hint for the current palette
        GluiLabel hintLabel;

    }

    @disable this();

    this(Project project) {

        this.project = project;

        // Make the frame
        rootFrame = vframe(
            theme,
            layout(NodeAlign.start, NodeAlign.fill),

            // Tab switcher
            hframe(
                button("Packs", () => switchTab(packsFrame)),
                button("Tiles", () => switchTab(tilesFrame)),
                button("Skeletons", () => switchTab(skeletonsFrame)),
            ),

            // Content
            packsFrame = vframe(),
            tilesFrame = vframe(),
            skeletonsFrame = vframe(),

            // Hint
            hintLabel = label(),

        );

        // Set the active tabs
        openTabFrame = packsFrame;
        tilesFrame.hide();
        skeletonsFrame.hide();

    }

    /// Switch to a different tab.
    void switchTab(GluiFrame newTab) {

        openTabFrame.hide();
        openTabFrame = newTab;
        newTab.show();
        newTab.updateSize();

    }

    /// Load new packs to the project.
    /// Params:
    ///     paths = Array of paths to `pack.json` files of added packs.
    ///     index = Index to insert the packs on. If outside of array boundaries, inserts at the end.
    void addPack(size_t index, string[] paths...) {

        auto packList = project.display.packs;

        // Load the packs and create nodes to represent each
        auto packs = paths.map!getPack.array;
        auto nodes = packs.map!(a => label(a.name));

        // Limit index
        index = min(index, packList.length);

        // Append
        packList.insertInPlace(index, packs);
        packsFrame.children.insertInPlace(index, nodes);

        reload();

    }

    /// Ditto
    void addPack(string[] paths...) {

        addPack(-1, paths);

    }

    /// Reload the packs and update the UI.
    private void reload() {

        auto packList = project.display.packs;

        // Add tiles
        tilesFrame.children = cast(GluiNode[]) packList.listCells[]
            .map!(type => button(type, () => setCellBrush(type)))
            .array;

        // Clear cache
        packList.clearCache();

        // Resize the tree
        packsFrame.updateSize();

    }

    /// Assign a new cell for brush.
    private void setCellBrush(string cellType) {

        import isodi.raylib.cell : RaylibCell;

        /// Create the brush
        auto cell = new RaylibCell(project.display, Position(), cellType);
        cell.color = Color(0xcc, 0xaa, 0xff, 0xee);

        project.brush = cell;

    }

}
