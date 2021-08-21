module isodi.tools.tree;

import glui;

import isodi.tools.themes;


@safe:


/// A Glui node representing a tree.
class Tree : GluiScrollFrame {

    this(T...)(T args) {

        super(args);

    }

    /// Add a node to the tree.
    /// Params:
    ///     parent  = Parent object. Adds to root if not present.
    ///     name    = Name of the object.
    ///     options = Context menu options defined by a list of pairs `(string, void delegate())` representing option
    ///               name and a trigger on picking.
    GluiFrame addNode(Ts...)(string name, Ts options) {

        return addNode(this, name, options);

    }

    /// Ditto
    GluiFrame addNode(Ts...)(GluiFrame parent, string name, Ts options) {

        import std.format : format;
        import std.functional : toDelegate;

        auto fillH = .layout!("fill", "start");

        GluiFrame result, dropdown;

        // Create the node
        parent ~= result = vframe(
            fillH,
            parent is this
                ? .theme
                : treeChildTheme,

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
