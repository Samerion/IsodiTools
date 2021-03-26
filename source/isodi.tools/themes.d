module isodi.tools.themes;

import glui;

/// Main theme of the program, applied to every root widget.
Theme theme;

/// Theme applied to the root node only so there is an empty space.
Theme emptyTheme;

/// Theme for debugging stuff.
debug Theme debugTheme;

static this() {

    theme = [

        &GluiFrame.styleKey: style!q{

            backgroundColor = Color(0xff, 0xff, 0xff, 0xff);

        },

    ];

    emptyTheme = [

        &GluiFrame.styleKey: style!q{ },

    ];

    debug debugTheme = [

        &GluiFrame.styleKey: style!q{

            backgroundColor = Color(0xff, 0xaa, 0xaa, 0xff);

        },

    ];

}
