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

    emptyTheme = makeTheme!q{

        GluiFrame.styleAdd!q{

            backgroundColor = Color(0, 0, 0, 0);

        };

    };

    tooltipTheme = makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0, 0, 0, 0xaa);
        GluiLabel.styleAdd.textColor = Color(0xff, 0xff, 0xff, 0xff);

    };

    dropdownTheme = makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0xcc, 0xcc, 0xcc, 0xff);

    };

    debug debugTheme = makeTheme!q{

        GluiFrame.styleAdd.backgroundColor = Color(0xff, 0xaa, 0xaa, 0xff);

    };

}
