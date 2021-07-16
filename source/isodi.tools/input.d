///
module isodi.tools.input;

import glui;
import raylib;

import std.algorithm;

import isodi.raylib.camera;

import isodi.tools.tabs;
import isodi.tools.open_file;

private extern (C) int GetCharPressed() nothrow @nogc;

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

    const holdingShift = IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT);
    const changeDepth = !project.lockDepth || holdingShift;

    // Get dropped files
    forwardDroppedFiles(tabs);

    // Change movement speed if holding shift
    keybinds.movementSpeed = holdingShift ? 10 : 6;

    // Keybinds: Stop if something has focus
    if (uiRoot.tree.focus !is null) return;

    // Update the camera
    tabs.openProject.display.camera.updateCamera(keybinds);

    // Nothing is focused
    loop: while (true) {

        // Read characters — let the system implement repeating keys
        // TODO: implement repeat manually, characters have limitations when it comes to certain modifiers, eg. alt
        switch (GetCharPressed) {

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
