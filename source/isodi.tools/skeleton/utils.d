module isodi.tools.skeleton.utils;

import raylib;

/// Get the rectangle of given angle image.
package Rectangle angleRect(ref const Image image, uint angle, uint angleCount) {

    const sideWidth = image.width / angleCount;

    return Rectangle(
        angle * sideWidth, 0,
        sideWidth, image.height,
    );

}
