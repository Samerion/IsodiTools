module isodi.tools.ui;

import glui;

import isodi.tools.tabs;
import isodi.tools.themes;

/// Create the UI.
GluiFrame createUI(ref Tabs tabs) {

    GluiFrame mainSpace, statusBar;
    GluiLabel statusRight;

    // Prepare the UI
    auto result = vframe(
        emptyTheme,
        layout(1, NodeAlign.fill),

        // Tab bar
        tabs.getUI,

        // Main space
        mainSpace = hframe(
            layout(1, NodeAlign.fill),

            // Left sidebar (placeholder)
            vframe(),

            // Main space
            // TODO: make a custom button to support filling by dragging
            // while the mouse is down, it should expand the preview cells and only apply them when up; 2nd mouse
            // button or Esc should cancel the operation.
            frameHoverButton(
                layout(1, NodeAlign.fill),

                statusBar = hframe(
                    layout(1, NodeAlign.fill, NodeAlign.end),
                    tooltipTheme,

                    label(),  // (placeholder)

                    statusRight = label(
                        layout(1, NodeAlign.end)
                    ),
                ),

                () {

                    import std.format : format;

                    // Update the brush
                    tabs.openProject.updateBrush();
                    const brush = tabs.openProject.brush;

                    // If there isn't one, stop
                    if (brush is null) return;

                    // Update the status bar
                    const position = brush.visualPosition;
                    statusRight.text = format!"(%s, %s, %s)"(position.x, position.y, position.height.top);
                    statusRight.updateSize();
                    // Glui note: unnecessary traversal of the whole tree, since the parent doesn't shrink

                },
            ),

            // Right sidebar (placeholder)
            vframe(),

        ),

    );

    // Save pointers
    tabs.frames.palette = cast(GluiFrame*) &mainSpace.children[0];
    tabs.frames.objects = cast(GluiFrame*) &mainSpace.children[2];

    tabs.frames.status  = cast(GluiLabel*) &statusBar.children[0];

    return result;

}
