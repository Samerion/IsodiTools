///
module isodi.tools.input;

import glui;
import raylib;

import std.algorithm;

import isodi.raylib.camera;

import isodi.tools.tabs;
import isodi.tools.project;
import isodi.tools.open_file;


@safe:


private extern (C) int GetCharPressed() nothrow @nogc @trusted;

// Create camera keybinds
CameraKeybindings keybinds = {

    zoomIn:  KeyboardKey.KEY_EQUAL,
    zoomOut: KeyboardKey.KEY_MINUS,

    rotateLeft:  KeyboardKey.KEY_Q,
    rotateRight: KeyboardKey.KEY_E,
    rotateUp:    KeyboardKey.KEY_T,
    rotateDown:  KeyboardKey.KEY_G,

    moveLeft:  KeyboardKey.KEY_A,
    moveRight: KeyboardKey.KEY_D,
    moveDown:  KeyboardKey.KEY_S,
    moveUp:    KeyboardKey.KEY_W,
    //moveAbove: KeyboardKey.KEY_R,  // implemented manually
    //moveBelow: KeyboardKey.KEY_F,

};

/// Process miscellaneous input.
void processInput(GluiNode uiRoot, ref Tabs tabs) {

    auto project = tabs.openProject;
    auto camera = &project.display.camera;

    const holdingShift = (() @trusted => IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT))();
    const changeDepth = !project.lockDepth || holdingShift;

    // Get dropped files
    forwardDroppedFiles(tabs);

    // Change movement speed if holding shift
    keybinds.movementSpeed = holdingShift ? 10 : 6;

    // Keybinds: Stop if input was already handled
    if (uiRoot.tree.keyboardHandled) return;

    // Update the camera
    project.display.camera.updateCamera(keybinds);

    // Process escape key
    processEscape(project);

    // Other shortcuts
    loop: while (true) {

        const getChar = () @trusted => GetCharPressed;

        // Read characters — let the system implement repeating keys
        // TODO: implement repeat manually, characters have limitations when it comes to certain modifiers, eg. alt
        switch (getChar()) {

            // Block up
            case 'r', 'R':

                if (!holdingShift) camera.offset.height += project.heightSnap;
                if (changeDepth)   project.brushDepth   += project.heightSnap;

                break;


            // Block down
            case 'f', 'F':

                if (!holdingShift) camera.offset.height -= project.heightSnap;
                if (changeDepth)   project.brushDepth    = max(0, project.brushDepth - project.heightSnap);

                break;

            // End of input
            case 0: break loop;

            // Unknown character, ignore
            default: break;

        }

    }

}

private void processEscape(Project project) @trusted {

    if (!IsKeyReleased(KeyboardKey.KEY_ESCAPE)) return;

    // Modal open
    if (project.modalsSpace.children.length) {

        // Remove last modal
        project.modalsSpace.children[$-1].remove();

    }

}
