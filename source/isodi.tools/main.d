module isodi.tools.main;

import glui;
import raylib;

import isodi.raylib.bind;

import isodi.tools.ui;
import isodi.tools.tabs;
import isodi.tools.project;
import isodi.tools.open_file;

void main() {

    // Prepare the window
    SetTraceLogLevel(TraceLogType.LOG_WARNING);
    SetConfigFlags(ConfigFlag.FLAG_WINDOW_RESIZABLE);
    SetTargetFPS(60);
    InitWindow(1600, 900, "Isodi Tools");
    SetWindowMinSize(800, 600);
    SetExitKey(0);
    scope (exit) CloseWindow();

    // Create the UI
    Tabs tabs;
    auto ui = createUI(tabs);

    // Create the first project
    tabs.addProject(new Project);

    // Run the editor
    while (!WindowShouldClose) {

        // We're asserting there's always a project, since we can't open or close them now
        // In the future, a new project should be created in this case.
        assert(tabs.projects.length, "No projects open, somehow");

        // Begin drawing the frame
        BeginDrawing();
        scope (exit) EndDrawing();

        // Set the mouse cursor
        SetMouseCursor(MouseCursor.MOUSE_CURSOR_DEFAULT);

        // Clear the background
        ClearBackground(Colors.BLACK);

        // Read dropped files
        forwardDroppedFiles(tabs.openProject);

        // Draw the active display
        tabs.openProject.display.draw();

        // Draw the UI
        ui.draw();

    }


}
