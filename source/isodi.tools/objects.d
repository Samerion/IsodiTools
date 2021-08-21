module isodi.tools.objects;

import glui;
import raylib;

import std.conv;
import std.path;
import std.array;
import std.format;

import isodi.tools.themes;
import isodi.tools.project;


@safe:


/// This struct is used to manage objects within an Isodi display.
struct Objects {

    public {

        /// Frame containing the object manager.
        GluiFrame rootFrame;

        /// List of models in the project.
        GluiFrame modelList;

    }

    private {

        Project project;

        GluiFrame objectList, toolOptions, skeletonEditor;

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

                objectList = vscrollFrame(
                    .layout!(1, "fill"), objectTabTheme,
                ),

            ),

            // Skeleton editor
            makeTab("Skeleton editor",

                skeletonEditor = vscrollFrame(
                    .layout!(1, "fill"), objectTabTheme,
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
                    label("Brush size:"),
                    brushSizeInput = textInput("", () {

                        try project.brushSize = brushSizeInput.value.to!uint;
                        catch (ConvException) { }

                    }),
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

        auto projectNode = addNode("Project",

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

                project.optionsFrame.show();
                project.optionsFrame.updateSize();

            },

            "Export tilemaps", () {

                if (!requireFilename) return;

                import isodi.tools.save_tilemap;

                project.exportTilemaps();


            },

            //"Normalize tilemap", () { },
        );

        modelList = addNode(projectNode, "Models");

        // TODO add a proper layer support, this is fake
        addNode(projectNode, "Layer 1",
            //"Export layer tilemap", () { },
            //"Normalize layer tilemap", () { },
            //"Group", () { },
            //"Merge down", () { },
            //"Move", () { },
        );

    }

    /// Add a node to the object tree.
    /// Params:
    ///     parent  = Parent object. Adds to root if not present.
    ///     name    = Name of the object.
    ///     options = Context menu options defined by a list of pairs `(string, void delegate())` representing option
    ///               name and a trigger on picking.
    GluiFrame addNode(Ts...)(string name, Ts options) {

        return addNode(objectList, name, options);

    }

    /// Ditto
    GluiFrame addNode(Ts...)(GluiFrame parent, string name, Ts options) {

        import std.format : format;
        import std.functional : toDelegate;

        auto fillH = layout!("fill", "start");

        GluiFrame result, dropdown;

        // Create the node
        parent ~= result = vframe(
            fillH,
            parent is objectList
                ? theme
                : objectChildTheme,

            // Add a button
            button(fillH, name, () {

                // Toggle the dropdown
                dropdown.toggleShow();
                dropdown.updateSize();

            }),

            // And a dropdown
            dropdown = vframe(fillH, dropdownTheme),
        );

        // Hide the dropdown
        dropdown.hide();

        // Add options
        static foreach (i, T; Ts) {

            // Ignore odd indexes
            static if (i % 2 == 0) {

                static assert(is(T == string), format!"T argument %s must be a string, got %s"(i, typeid(T)));
                static assert((i + 1) < Ts.length, "There must be an even number of T arguments");

                // Add an option
                dropdown ~= button(fillH, options[i], options[i+1].toDelegate);

            }

        }

        return result;

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

                    // Update button text
                    collapseButton.text = content.hidden ? "+" : "-";

                }),
            ),

            // Content
            content,

        );

    }

}
