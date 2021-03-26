module isodi.tools.ui;

import glui;

import isodi.tools.tabs;
import isodi.tools.themes;

/// Create the UI.
GluiFrame createUI(ref Tabs tabs) {

    GluiFrame mainSpace;

    // Prepare the UI
    auto result = vframe(
        emptyTheme,
        layout(1, NodeAlign.fill),

        // Tab bar
        tabs.getUI,

        // Main space
        mainSpace = hframe(
            layout(1, NodeAlign.fill),

            // Left sidebar
            vframe(),
        ),

    );

    // Save pointers
    tabs.paletteFrame = cast(GluiFrame*) &mainSpace.children[0];

    return result;

}
