module isodi.tools.input;

import isodi.tools.tabs;
import isodi.tools.open_file;

/// Process user input other than through GUI.
void processInput(ref Tabs tabs) {

    // Read dropped files
    forwardDroppedFiles(tabs.openProject);

    // TODO fill for cells by dragging

}
