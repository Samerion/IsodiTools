///
module isodi.tools.input;

import glui;

import isodi.tools.tabs;
import isodi.tools.open_file;

private extern (C) int GetCharPressed() nothrow @nogc;

/// Process miscellaneous input.
void processInput(GluiNode uiRoot, ref Tabs tabs) {

    auto project = tabs.openProject;

    // Get dropped files
    forwardDroppedFiles(tabs.openProject);

    // Nothing is focused
    loop: while (uiRoot.tree.focus is null) {

        // Read characters — let the system implement repeating keys
        switch (GetCharPressed) {

            // Camera up
            case 'r', 'R':

                project.display.camera.offset.height += project.heightSnap;
                break;


            // Camera down
            case 'f', 'F':

                project.display.camera.offset.height -= project.heightSnap;
                break;

            // End of input
            case 0: break loop;

            // Unknown character, ignore
            default: break;

        }

    }

}
