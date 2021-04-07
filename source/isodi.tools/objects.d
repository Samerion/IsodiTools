module isodi.tools.objects;

import glui;

import isodi.tools.themes;
import isodi.tools.project;

/// This struct is used to manage objects within an Isodi display.
struct Objects {

    /// Frame containing the object manager
    GluiFrame rootFrame;

    private {

        Project project;
        GluiFrame objectList;

    }

    @disable this();

    this(Project project) {

        this.project = project;

        // Make the frame
        rootFrame = vframe(
            theme,
            layout(NodeAlign.end, NodeAlign.fill),

            // Object list
            objectList = vframe(),

        );

        auto projectNode = addNode("Project",
            "Export tilemap", () { },
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
