module isodi.tools.tree;

import glui;

import isodi.tools.themes;


@safe:


/// A Glui node representing a tree.
class Tree : GluiSpace {

    enum specialChildrenCount = 2;

    private GluiFrame openDropdown;

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
    GluiFrame addNode(Ts...)(GluiSpace parent, string name, Ts options) {

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

                // This dropdown is open
                if (dropdown is openDropdown) {

                    // Close it
                    dropdown.hide();
                    openDropdown = null;
                    return;

                }

                // If there is a different open dropdown, hide it
                if (openDropdown) openDropdown.hide();

                // Toggle the dropdown
                dropdown.show();
                openDropdown = dropdown;

            }),

            // And a dropdown
            dropdown = vframe(fillH, dropdownTheme),
        );

        assert(result.children.length == specialChildrenCount);

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

    /// Sort nodes of the tree alphabetically.
    /// Params:
    ///     parent = Sort starting from a parent.
    void sortNodes(GluiSpace parent = null) {

        import std.array, std.algorithm;

        // Get the children to sort; skip first two
        auto toSort = parent is null
            ? this.children
            : parent.children[specialChildrenCount..$];

        string nodeText(GluiNode node) {

            if (auto space = cast(GluiSpace) node) {
                if (auto label = cast(GluiLabel) space.children[0]) {
                    return label.text;
                }
            }

            return "";

        }

        // Skip first two children
        toSort.schwartzSort!nodeText.moveAll(toSort);

        // Sort recursively
        foreach (child; toSort) {

            if (auto space = cast(GluiSpace) child) {

                sortNodes(space);

            }

        }

    }

}
