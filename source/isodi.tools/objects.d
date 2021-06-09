module isodi.tools.objects;

import glui;
import raylib;

import std.path;
import std.array;
import std.format;
import fs = std.file;

import isodi.tilemap;

import isodi.tools.themes;
import isodi.tools.project;

/// This struct is used to manage objects within an Isodi display.
struct Objects {

    /// Frame containing the object manager
    GluiFrame rootFrame;

    private {

        Project project;
        GluiFrame objectList, toolOptions;

    }

    @disable this();

    this(Project project) {

        this.project = project;

        GluiTextInput brushSizeInput;

        // Make the frame
        rootFrame = vframe(
            theme,
            layout(NodeAlign.end, NodeAlign.fill),

            // Object list
            objectList = vframe(
                layout(1),
            ),

            // Tool options
            toolOptions = vframe(
                hframe(
                    label("Brush size:"),
                    brushSizeInput = textInput("", () {

                        import std.conv : to, ConvException;
                        try project.brushSize = brushSizeInput.value.to!uint;

                        // Failed, ignore
                        catch (ConvException) { }

                    }),
                )
            ),


        );

        brushSizeInput.size = Vector2(25, 0);
        brushSizeInput.value = "1";

        auto projectNode = addNode("Project",

            "Export tilemap", () {

                // temporary: later use a file picker

                // Check if the project has a filename
                if (!project.filename.length) {

                    project.status.text = "Drop a folder into the window to pick a save location and retry";
                    project.status.updateSize();
                    return;

                }

                const path = project.filename.setExtension("isodi");

                // Write to a buffer
                auto appn = appender!(ubyte[]);
                project.display.saveTilemap(appn);

                // Save the data
                fs.write(path, appn[]);

                // Add a status text
                project.status.text = format!"Saved to %s"(path);
                project.status.updateSize();

            },

            //"Normalize tilemap", () { },
        );

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

        auto fillH = layout(NodeAlign.fill, NodeAlign.start);

        GluiFrame result, dropdown;

        // Create the node
        parent ~= result = vframe(
            fillH,

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

}
