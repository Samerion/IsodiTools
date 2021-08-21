module isodi.tools.themes;

import glui;


@safe:


immutable {

    /// Main theme of the program, applied to every root widget.
    Theme theme;

    /// Theme applied to the root node only so there is an empty space.
    Theme emptyTheme;

    /// Theme applied to tooltips — white text on a half-transparent black background.
    Theme tooltipTheme;

    /// Theme for dropdowns and context menus, eg. in the object manager.
    Theme dropdownTheme;

    /// Theme for object manager tree children to have them indented.
    Theme objectChildTheme;

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

        };

    };

    emptyTheme = theme.makeTheme!q{

        GluiFrame.styleAdd!q{

            backgroundColor = Color(0, 0, 0, 0);

        };

    };

    tooltipTheme = theme.makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0, 0, 0, 0xaa);
        GluiLabel.styleAdd.textColor = Color(0xff, 0xff, 0xff, 0xff);

    };

    dropdownTheme = theme.makeTheme!q{

        GluiButton!().styleAdd.backgroundColor = Color(0xee, 0xee, 0xee, 0xff);

    };

    objectChildTheme = theme.makeTheme!q{

        GluiFrame.styleAdd.padding.sideLeft = 12;

    };

    objectTabBarTheme = theme.makeTheme!q{

        backgroundColor = Color(0xdd, 0xdd, 0xdd, 0xff);

        GluiFrame.styleAdd.padding.sideX = 4;
        GluiButton!().styleAdd!q{

            padding.sideX = 8;

            hoverStyleAdd.backgroundColor = Color(0xbb, 0xbb, 0xbb, 0xff);
            focusStyleAdd.backgroundColor = Color(0xcc, 0xcc, 0xcc, 0xff);
            pressStyleAdd.backgroundColor = Color(0xaa, 0xaa, 0xaa, 0xff);

        };

    };

    objectTabTheme = theme.makeTheme!q{

        GluiFrame.styleAdd.padding = 6;

    };

    debug debugTheme = makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0xff, 0xaa, 0xaa, 0xff);

    };

}
