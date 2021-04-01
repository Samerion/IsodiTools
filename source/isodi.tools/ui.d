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

            // Main space
            // TODO: make a custom button to support filling by dragging
            // while the mouse is down, it should expand the preview cells and only apply them when up; 2nd mouse
            // button or Esc should cancel the operation.
            hoverButton(
                layout(1, NodeAlign.fill),
                () => tabs.openProject.updateBrush(),
            ),
        ),

    );

    // Save pointers
    tabs.paletteFrame = cast(GluiFrame*) &mainSpace.children[0];

    return result;

}
