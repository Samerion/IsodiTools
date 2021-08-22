module isodi.tools.objects;

import glui;
import raylib;

import std.conv;
import std.path;
import std.array;
import std.format;

import isodi : Model;
import isodi.tools.tree;
import isodi.tools.themes;
import isodi.tools.project;


@safe:


/// This struct is used to manage objects within an Isodi display.
struct Objects {

    public {

        /// Frame containing the object manager.
        GluiFrame rootFrame;

        /// Main object list.
        Tree objectList;

        /// List of models in the project.
        GluiFrame modelList;

        /// The skeleton editor node
        Tree skeletonEditor;

    }

    private {

        Project project;
        GluiFrame toolOptions;

    }

    @disable this();

    this(Project project) {

        this.project = project;

        GluiTextInput brushSizeInput;
        GluiButton!GluiLabel depthLockInput;

        // Make the frame
        rootFrame = vframe(
            theme,
            layout!("end", "fill"),

            // Object list
            makeTab("Objects",

                objectList = new Tree(
                    .layout!(1, "fill"), objectTabTheme,
                ),

            ),

            // Skeleton editor
            makeTab("Skeleton editor",

                skeletonEditor = new Tree(
                    .layout!(1, "fill"), objectTabTheme,

                    label("Pick a model to\nedit its skeleton..."),
                ),

            ),

            // Tool options
            makeTab("Tool options", toolOptions = vframe(

                .layout!(1, "fill"), objectTabTheme,

                // Toggle depth locking
                depthLockInput = button("Lock depth", () {

                    project.lockDepth = !project.lockDepth;
                    depthLockInput.text = project.lockDepth
                        ? "Unlock depth"
                        : "Lock depth";
                    rootFrame.updateSize();

                }),

                // Brush size control
                hframe(
                    .layout!"fill",
                    label("Brush size:"),
                    brushSizeInput = textInput(
                        .layout!(1, "fill"), "",
                        () {

                            try project.brushSize = brushSizeInput.value.to!uint;
                            catch (ConvException) { }

                        }
                    ),
                ),

            )),

        );

        brushSizeInput.size = Vector2(25, 0);
        brushSizeInput.value = "1";

        bool requireFilename() {

            // temporary: later use a file picker

            // Check if the project has a filename
            if (!project.filename.length) {

                project.status.text = "Drop a folder into the window to pick a save location and retry";
                project.status.updateSize();
                return false;

            }

            return true;

        }

        auto projectNode = objectList.addNode("Project",

            "Save", () {

                if (!requireFilename) return;

                import isodi.tools.save_project;

                const path = project.filename.setExtension("isotools");

                // Save the project
                project.saveProject(path);

                // Add a status text
                project.status.text = format!"Saved to %s"(path);
                project.status.updateSize();


            },

            "Options", () {

                project.showModal(project.optionsFrame);

            },

            "Export tilemaps", () {

                if (!requireFilename) return;

                import isodi.tools.save_tilemap;

                project.exportTilemaps();


            },

            //"Normalize tilemap", () { },
        );

        modelList = objectList.addNode(projectNode, "Models");

        // TODO add a proper layer support, this is fake
        objectList.addNode(projectNode, "Layer 1",
            //"Export layer tilemap", () { },
            //"Normalize layer tilemap", () { },
            //"Group", () { },
            //"Merge down", () { },
            //"Move", () { },
        );

    }

    private GluiFrame makeTab(string name, GluiNode content) {

        GluiButton!() collapseButton;
        GluiFrame result;

        content.layout = layout!(1, "fill");

        return result = vframe(
            .layout!(1, "fill"),

            // Top bar
            hframe(
                .layout!("fill", "start"),
                objectTabBarTheme,

                label(.layout!1, name),
                collapseButton = button("-", {

                    // Toggle content visibility
                    content.toggleShow();

                    // Expand the tab if hidden
                    result.layout.expand = !content.hidden;
                    result.updateSize();

                    // Update button text
                    collapseButton.text = content.hidden ? "+" : "-";

                }),
            ),

            // Content
            content,

        );

    }

}
