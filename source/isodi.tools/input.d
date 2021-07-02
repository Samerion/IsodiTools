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

    const holdingShift = IsKeyDown(KeyboardKey.KEY_LEFT_SHIFT);

    auto project = tabs.openProject;
    auto camera = &project.display.camera;

    // Get dropped files
    forwardDroppedFiles(project);

    // Change movement speed if holding shift
    keybinds.movementSpeed = holdingShift ? 10 : 6;

    // Nothing is focused
    loop: while (uiRoot.tree.focus is null) {

        // Read characters — let the system implement repeating keys
        // TODO: implement repeat manually, characters have limitations when it comes to certain modifiers, eg. alt
        switch (GetCharPressed) {

            // Block up
            case 'r', 'R':

                if (!holdingShift) camera.offset.height += project.heightSnap;
                project.brushDepth += project.heightSnap;

                break;


            // Block down
            case 'f', 'F':

                if (!holdingShift) camera.offset.height -= project.heightSnap;
                project.brushDepth = max(0, project.brushDepth - project.heightSnap);

                break;

            // End of input
            case 0: break loop;

            // Unknown character, ignore
            default: break;

        }

    }

}
