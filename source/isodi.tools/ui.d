module isodi.tools.ui;

import glui;

import isodi.tools.tabs;
import isodi.tools.themes;

/// Create the UI.
GluiFrame createUI() {

    Tabs tabs;

    return vframe(
        emptyTheme,
        layout(1, NodeAlign.fill),

        // Tab bar
        tabs.getUI,

        // Main space
        hframe(

            // Left sidebar

        ),


    );

}
