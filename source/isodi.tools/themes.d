module isodi.tools.themes;

import glui;

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

void loadThemes() {

    theme = [

        &GluiFrame.styleKey: style!q{

            backgroundColor = Color(0xff, 0xff, 0xff, 0xff);

        },

    ];

    emptyTheme = [

        &GluiFrame.styleKey: style!q{ },

    ];

    tooltipTheme = [

        &GluiFrame.styleKey: style!q{

            backgroundColor = Color(0, 0, 0, 0xaa);

        },

        &GluiLabel.styleKey: style!q{

            textColor = Color(0xff, 0xff, 0xff, 0xff);

        },

    ];

    dropdownTheme = [

        &GluiFrame.styleKey: style!q{

            backgroundColor = Color(0xcc, 0xcc, 0xcc, 0xff);

        },

        &GluiLabel.styleKey: style!q{

            textColor = Color(0x00, 0x00, 0x00, 0xff);

        },

    ];

    debug debugTheme = [

        &GluiFrame.styleKey: style!q{

            backgroundColor = Color(0xff, 0xaa, 0xaa, 0xff);

        },

    ];

}
