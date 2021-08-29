module isodi.tools.exception;

import glui;
import core.thread;

import isodi.tools.themes;
import isodi.tools.project;

public import std.exception;


@safe:


abstract class IsodiToolsException : Exception {

    mixin basicExceptionCtors;

}

/// An exception that should result in showing a failure window to the user.
class FailureException : IsodiToolsException {

    mixin basicExceptionCtors;

    GluiFrame errorWindow() const {

        GluiFrame root;
        return root = vframe(
            .layout!(1, "center"),
            .modalTheme,

            label(.layout!"center", "Operation failed"),
            label(msg),
            button(.layout!"end", "OK", { root.remove(); })
        );

    }

    static void handle(Project project, void delegate() @safe handleIn) {

        try handleIn();

        // An exception that can be ignored
        catch (NeedsConfirmException exc) {

            // Handle recursively
            handle(project, {

                scope (success) exc.proceedToAll = false;

                // User decided to ignore exceptions
                if (exc.proceedToAll) exc.proceed();

                // No? Show a window
                else project.showModal = exc.errorWindow();

            });

        }

        catch (FailureException exc) {

            // Show a window
            project.showModal = exc.errorWindow();

        }

    }

}

/// A failure exception which should show an error to the user, but with a "proceed" button that lets the user continue
/// as if it didn't occur.
class NeedsConfirmException : FailureException {

    static bool proceedToAll;

    void delegate() @safe proceedCb;

    mixin basicExceptionCtors;

    static void enforce(T)(T condition, lazy string msg, lazy void delegate() @safe proceedCb) {

        if (!condition) {

            auto exc = new NeedsConfirmException(msg);
            exc.proceedCb = proceedCb;
            throw exc;

        }

        else proceedCb();

    }

    static void enforceFibered(T)(T condition, lazy string msg) @trusted {

        auto thisFiber = Fiber.getThis;
        assert(thisFiber, "Not in a fiber.");

        if (!condition) {

            auto exc = new NeedsConfirmException(msg);
            exc.proceedCb = () @trusted { thisFiber.call(); };
            Fiber.yieldAndThrow(exc);

        }

    }

    void proceed() const {

        assert(proceedCb, "Attempted to proceed, but proceedCb is null");
        proceedCb();

    }

    override GluiFrame errorWindow() const {

        GluiFrame root;
        return root = vframe(
            .layout!(1, "center"),
            .modalTheme,

            label(.layout!"center", "Confirm action?"),
            label(msg),
            hframe(
                .layout!"end",
                button("Proceed to all", {
                    root.remove();
                    proceedToAll = true;
                    scope (success) proceedToAll = false;
                    proceed();
                }),
                button("Cancel", { root.remove(); }),
                button("Continue", { root.remove(); proceed(); }),
            ),
        );

    }

}
