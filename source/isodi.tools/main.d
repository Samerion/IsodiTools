module isodi.tools.main;

import raylib;

import isodi.tools.ui;

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
    auto ui = createUI();

    // Run the editor
    while (!WindowShouldClose) {

        // Begin drawing the frame
        BeginDrawing();
        scope (exit) EndDrawing();

        // Clear the background
        ClearBackground(Colors.BLACK);

        // Draw the UI
        ui.draw();

    }


}
