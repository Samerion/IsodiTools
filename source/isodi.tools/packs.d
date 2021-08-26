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


@safe:


/// This struct is used to load and manage packs within a project. It is also used to display the palette.
struct Packs {

    /// Frame containing the palette for this project.
    GluiFrame rootFrame;

    private {

        Project project;

        // Tab spaces and contents
        GluiSpace packsSpace, tilesSpace, skeletonsSpace;
        GluiSpace packsContent, tilesContent, skeletonsContent;

        // Current tab
        GluiSpace openTabSpace;

    }

    @disable this();

    this(Project project) {

        this.project = project;

        const fill = layout!(1, "fill");

        // Make the frame
        rootFrame = vframe(
            theme,
            layout!("start", "fill"),

            // Tab switcher
            hframe(
                button("Packs", () => switchTab(packsSpace)),
                button("Tiles", () => switchTab(tilesSpace)),
                button("Skeletons", () => switchTab(skeletonsSpace)),
            ),

            // Content
            // onionFrame as a workaround for https://github.com/Samerion/Glui/issues/24
            onionFrame(fill,
                packsSpace = packsContent = vscrollFrame(fill),
                tilesSpace = tilesContent = vscrollFrame(fill),
                skeletonsSpace = vspace(fill,
                    skeletonsContent = vscrollFrame(fill),
                    button(
                        .layout!"fill",
                        "Empty skeleton",
                        () => setModelBrush(null),
                    ),
                ),
            ),
        );

        // Set the active tabs
        openTabSpace = packsSpace;
        tilesSpace.hide();
        skeletonsSpace.hide();

    }

    /// Switch to a different tab.
    void switchTab(GluiSpace newTab) {

        openTabSpace.hide();
        openTabSpace = newTab;
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
        packsSpace.children.insertInPlace(index, nodes);

        reload();

    }

    /// Ditto
    void addPack(string[] paths...) {

        addPack(-1, paths);

    }

    /// Reload the packs and update the UI.
    void reload() {

        // Get the pack list
        auto packList = project.display.packs;
        packList.clearCache();

        // Add tiles
        tilesContent.children = packList.listCells[]
            .map!(type => cast(GluiNode) button(type, () => setCellBrush(type)))
            .array;

        // Add skeletons
        skeletonsContent.children = packList.listSkeletons[]
            .map!(type => cast(GluiNode) button(type, () => setModelBrush(type)))
            .array;

        // Resize the tree
        rootFrame.updateSize();

    }

    /// Assign a new cell for brush.
    private void setCellBrush(string cellType) {

        import isodi.raylib.cell : RaylibCell;

        /// Create the brush
        auto cell = new RaylibCell(project.display, position(0, 0, Height(0, 0)), cellType);
        cell.color = Color(0xcc, 0xaa, 0xff, 0xee);

        project.brush = cell;

    }

    /// Assign a new model as a brush.
    private void setModelBrush(string skeletonType) {

        import isodi.raylib.model : RaylibModel;

        // Fail if there are no packs
        if (project.display.packs.length == 0) {

            project.status.text = "Can't create a model, project has no packs!";
            project.status.updateSize();
            return;

        }

        // Create the model
        auto model = new RaylibModel(project.display, skeletonType);
        model.positionRef.height.depth = 0;
        model.boneDebug = true;

        project.brush = model;

    }

}
