module isodi.tools.themes;

import glui;


@safe:


immutable {

    /// Main theme of the program, applied to every root widget.
    Theme theme;

    /// Theme applied to the root node only so there is an empty space.
    Theme emptyTheme;

    /// Theme for modals in the program.
    Theme modalTheme;

    /// Theme applied to tooltips — white text on a half-transparent black background.
    Theme tooltipTheme;

    /// Theme for dropdowns and context menus, eg. in the object manager.
    Theme dropdownTheme;

    /// Theme for tree children to have them indented.
    Theme treeChildTheme;

    /// Theme for object manager tab bar.
    Theme objectTabBarTheme;

    /// Theme for object manager tab content.
    Theme objectTabTheme;

    /// Theme for debugging stuff.
    debug Theme debugTheme;

}

shared static this() {

    theme = makeTheme!q{

        GluiButton!().styleAdd!q{

            backgroundColor = Colors.WHITE;
            margin.sideY = 0;
            padding.sideY = 0;

        };

        GluiTextInput.styleAdd!q{

            margin.sideY = 0;

            backgroundColor = Color(0xee, 0xee, 0xee, 0xff);

            emptyStyleAdd.textColor = Color(0, 0, 0, 0xaa);
            focusStyleAdd.backgroundColor = Color(0xdd, 0xdd, 0xdd, 0xff);

        };

    };

    emptyTheme = theme.makeTheme!q{

        GluiFrame.styleAdd!q{

            backgroundColor = Color(0, 0, 0, 0);

        };

    };

    // TODO
    modalTheme = theme.makeTheme!q{

        GluiFrame.styleAdd.padding = 6;
        GluiButton!().styleAdd!q{

            backgroundColor = Color(0xee, 0xee, 0xee, 0xff);

            margin.sideX = 4;
            padding.sideX = 6;

        };

    };

    tooltipTheme = theme.makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0, 0, 0, 0xaa);
        GluiLabel.styleAdd.textColor = Color(0xff, 0xff, 0xff, 0xff);

    };

    dropdownTheme = theme.makeTheme!q{

        GluiButton!().styleAdd!q{

            padding.sideLeft = 12;
            backgroundColor = Color(0xee, 0xee, 0xee, 0xff);

        };

    };

    treeChildTheme = theme.makeTheme!q{

        GluiFrame.styleAdd!q{

            backgroundColor = Color(0, 0, 0, 0x11);
            padding.sideLeft = 8;

        };

    };

    objectTabBarTheme = theme.makeTheme!q{

        backgroundColor = Color(0xdd, 0xdd, 0xdd, 0xff);

        GluiFrame.styleAdd.padding.sideLeft = 4;
        GluiButton!().styleAdd!q{

            padding.sideX = 10;
            margin.sideLeft = 8;

            hoverStyleAdd.backgroundColor = Color(0xbb, 0xbb, 0xbb, 0xff);
            focusStyleAdd.backgroundColor = Color(0xcc, 0xcc, 0xcc, 0xff);
            pressStyleAdd.backgroundColor = Color(0xaa, 0xaa, 0xaa, 0xff);

        };

    };

    objectTabTheme = theme.makeTheme!q{

        import isodi.tools.tree;

        // Add some padding
        GluiFrame.styleAdd.padding = 6;

        // Exclude it from scroll frames and trees
        GluiScrollFrame.styleAdd.padding = 0;
        Tree.styleAdd.padding = 0;

    };

    debug debugTheme = makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0xff, 0xaa, 0xaa, 0xff);

    };

}
