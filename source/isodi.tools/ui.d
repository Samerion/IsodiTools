module isodi.tools.ui;

import glui;

import isodi.tools.tabs;
import isodi.tools.themes;
import isodi.tools.open_file;

/// Create the UI.
GluiFrame createUI(ref Tabs tabs) {

    GluiFrame mainSpace, drawingSpace, statusBar;
    GluiLabel statusRight;

    // Prepare the UI
    auto result = vframe(
        layout!(1, "fill"),

        // Tab bar
        tabs.getUI,

        // Main space
        mainSpace = hframe(
            layout!(1, "fill"),

            // Left sidebar (placeholder)
            vframe(),

            // Drawing space
            drawingSpace = frameHoverButton(
                layout!(1, "fill"),

                vframe(),

                statusBar = hframe(
                    layout!(1, "fill", "end"),
                    tooltipTheme,

                    label(),  // (placeholder)

                    statusRight = label(
                        layout!(1, "end"),
                    ),
                ),

                () {

                    import std.format : format;

                    // Ignore if there is a popup visible
                    if (!tabs.frames.options.hidden) return;

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
    tabs.frames.palette = cast(GluiFrame*) &mainSpace.children.childRef(0);
    tabs.frames.objects = cast(GluiFrame*) &mainSpace.children.childRef(2);

    tabs.frames.status  = cast(GluiLabel*) &statusBar.children.childRef(0);
    tabs.frames.options = cast(GluiFrame*) &drawingSpace.children.childRef(0);

    return onionFrame(
        layout!"fill",
        emptyTheme,

        // Main window
        result,

        // File pickers
        tabs.frames.fileOpener = filePicker(
            theme,
            "Load a file...",
            () => tabs.forwardFile(tabs.frames.fileOpener.value),
        ),
        // TODO tabs.frames.fileSaver, (placeholder below)
        vframe(),

    );

}
