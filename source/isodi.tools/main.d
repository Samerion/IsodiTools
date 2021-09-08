module isodi.tools.main;

import glui;
import raylib;

import std.conv;

import core.time;
import core.thread;

import isodi.raylib.bind;
import isodi.raylib.camera;

import isodi.tools.ui;
import isodi.tools.tabs;
import isodi.tools.input;
import isodi.tools.themes;
import isodi.tools.project;
import isodi.tools.open_file;
import isodi.tools.exception;


@safe:


void main(string[] argv) @trusted {

    const waitTime = 1.seconds / 60;

    // Prepare the window
    SetTraceLogLevel(TraceLogType.LOG_WARNING);
    SetConfigFlags(ConfigFlag.FLAG_WINDOW_RESIZABLE);
    InitWindow(1600, 900, "Isodi Tools");
    SetWindowMinSize(800, 600);
    SetExitKey(0);
    scope (exit) CloseWindow();

    // Prepare tabs
    Tabs tabs;
    auto ui = createUI(tabs);

    // Create the first project
    tabs.addProject(new Project);

    foreach (arg; argv[1..$]) {

        forwardFile(tabs, arg);

    }

    // Run the editor
    while (!WindowShouldClose) {

        // We're asserting there's always a project, since we can't open or close them now
        // In the future, a new project should be created in this case.
        assert(tabs.projects.length, "No projects open, somehow");

        // Begin drawing the frame
        BeginDrawing();
        scope (exit) EndDrawing();

        // Clear the background
        ClearBackground(Colors.BLACK);

        // Draw the active project
        tabs.openProject.draw();

        // Handle failure windows
        FailureException.handle(tabs.openProject, {

            // Draw the UI
            ui.draw();

        });

        // Process general input
        processInput(ui, tabs);

        // Wait some time to reduce FPS
        // Should wait a while less if last frame took too long to render
        const time = waitTime*2 - to!long(GetFrameTime*1000).msecs;
        if (time > 0.seconds) Thread.sleep(time);

    }

}
