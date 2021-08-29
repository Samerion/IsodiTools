module isodi.tools.skeleton.bone_ui;

import glui;

import isodi;
import isodi.resource;
import isodi.raylib.model;

import isodi.tools.skeleton.structs;
import isodi.tools.skeleton.editor_ui;


@safe:


final class BoneEditor : GluiSpace {

    enum validCharactersMsg = "alphanumeric characters, underscores (_), dashes (-) and dots (.)";

    public {

        GluiLabel idLabel;

    }

    private {

        SkeletonEditor skeletonEditor;

        // Editor state
        Model editedModel;
        size_t editedIndex;
        SkeletonNode* editedNode;

        // Data inputs
        GluiTextInput typeInput, idInput;
        GluiLabel errorLabel;

        // Visibility
        GluiButton!() visibilityButton;
        bool nodeHidden;

        // Variants
        GluiSpace variantSpace;

        // Position
        Vector3Editor boneStartInput, boneEndInput, texturePosInput;
        GluiButton!() mirrorButton;

    }

    this(SkeletonEditor editor) {

        this.skeletonEditor = editor;

        super(
            .layout!(1, "fill"),

            vframe(
                .layout!"fill",

                label("Node type"),
                typeInput = textInput(""),

                label("Node ID"),
                idInput = textInput(""),

                visibilityButton = button("Node visible", {

                    nodeHidden = !nodeHidden;
                    applyInfo();
                    updateButtons();

                }),

                hframe(
                    .layout!(1, "fill"),
                    errorLabel = label(.layout!(1, "fill")),
                ),

            ),

            vframe(
                .layout!"fill",

                label(.layout!"fill", "Default node variants"),
                variantSpace = vspace(.layout!"fill")

            ),

            vframe(
                .layout!"fill",

                label("Bone start"),
                boneStartInput = new Vector3Editor,

                label("Bone end"),
                boneEndInput = new Vector3Editor,

                label("Texture position"),
                texturePosInput = new Vector3Editor,

            ),

            vframe(
                .layout!"fill",

                mirrorButton = button(.layout!"fill", "Flip bone", {

                    editedNode.mirror = !editedNode.mirror;
                    // TODO: recursive?

                    updateButtons();

                }),

                button(.layout!"fill", "Invert bone ends", {

                    float[3] sum(float[3] a, float[3] b) {

                        return [a[0] + b[0], a[1] + b[1], a[2] + b[2]];

                    }

                    float[3] invert(float[3] a) {

                        return [-a[0], -a[1], -a[2]];

                    }

                    auto node = editedNode;

                    // Invert bone start/end
                    boneStartInput.floatValue = node.boneStart = sum(node.boneStart, node.boneEnd);
                    boneEndInput.floatValue = node.boneEnd = invert(node.boneEnd);

                    // Update textre position
                    texturePosInput.floatValue = node.texturePosition = sum(node.texturePosition, node.boneEnd);

                }),

                button(.layout!"fill", "Replace parent", () @trusted {

                    import std.algorithm;

                    // Require there to be a parent
                    // TODO: error message?
                    if (editedIndex == 0) return;

                    // Get this node
                    auto model = editedModel;
                    const thisNode = *editedNode;
                    const thisIndex = editedIndex;
                    const parent = model.getNode(thisNode.parent);

                    // Clear the target, since the index will change
                    clearTarget();

                    // Remove this node from the tree
                    auto removedNodes = model.removeNodes(thisNode.id);

                    // Create a copy of this node to replace the parent
                    auto newNode = cast() thisNode;
                    newNode.parent = parent.parent;
                    model.replaceNode(newNode, thisNode.parent);

                    // Push children of this node into the tree
                    size_t[] newIndexes = [thisNode.parent];

                    foreach (node; removedNodes[1..$]) {

                        // Update the parent
                        node.parent = newIndexes[node.parent];

                        // Add this node
                        newIndexes ~= model.addNode(node);

                    }

                    // Recreate the tree
                    skeletonEditor.makeTree();

                }),

                label("Test rotation"),
                hframe(
                    button("X", () => testBone(0)),
                    button("Y", () => testBone(1)),
                    button("Z", () => testBone(2)),
                ),
                label("Note: rotation is currently extremely broken in Isodi. Use with care."),

            ),

        );

        // Set callbacks
        addCallbacks();

    }

    @property
    inout(Model) model() inout {
        return editedModel;
    }

    @property
    size_t node() {
        return editedIndex;
    }

    void setTarget(Model model, size_t nodeIndex, GluiLabel idLabel) {

        clearTarget();

        this.editedModel = model;
        this.editedIndex = nodeIndex;
        this.editedNode = model.getNode(nodeIndex);
        this.idLabel = idLabel;

        // Enable bone debug
        if (auto rlmodel = cast(RaylibModel) model) {

            rlmodel.nodeBoneDebug(editedIndex) = true;

        }

        // Set data
        typeInput.value = editedNode.name;
        idInput.value = editedNode.id;
        nodeHidden = editedNode.hidden;
        errorLabel.text = "";

        // Load variants
        loadVariants();

        // Update positions
        boneStartInput.floatValue = editedNode.boneStart;
        boneEndInput.floatValue = editedNode.boneEnd;
        texturePosInput.floatValue = editedNode.texturePosition;

        // Update buttons
        updateButtons();

    }

    void clearTarget() {

        // If there's a model assigned
        if (auto model = cast(RaylibModel) model) {

            // Clear node debug
            model.nodeBoneDebug(editedIndex) = false;

        }

        editedModel = null;
        editedNode = null;
        editedIndex = 0;

    }

    private void loadVariants() {

        const variants = editedNode.variants;

        // Prepare space for the variants + one more box to allow adding new variants
        variantSpace.children.length = variants.length + 1;

        // Iterate on the text inputs to fill them with data
        foreach (i, ref child; variantSpace.children[]) {

            // Get each text input
            auto input = cast(GluiTextInput) child;

            // No input here? Create a new one
            if (!input) input = variantTextInput();

            // Set its value to a variant, except for the last one
            input.value = i < variants.length
                ? variants[i]
                : "";

            // Replace the old node
            child = input;

        }

    }

    private void addCallbacks() {

        // Update node info
        typeInput.changed = &applyInfo;
        idInput.changed = &applyInfo;

        // Update bone ends
        boneStartInput.changed = &applyPosition;
        boneEndInput.changed = &applyPosition;
        texturePosInput.changed = &applyPosition;

    }

    private bool isValidName(string name) {

        import std.uni, std.algorithm;

        return name.all!(a => a.isAlphaNum || a == '_' || a == '-' || a == '.');

    }

    private void applyInfo() {

        import std.exception;

        try {

            const visibilityChanged = editedNode.hidden != nodeHidden;
            const typeChanged = editedNode.name != typeInput.value
                || visibilityChanged;

            auto newNode = *editedNode;

            // Update type
            if (typeChanged) {

                enforce(isValidName(typeInput.value), "Node type must only contain " ~ validCharactersMsg);

                // Update the name
                newNode.name = typeInput.value;

                // Check if the bone exists (or node is hidden)
                enforce(nodeHidden || !collectException(model.getBone(newNode)), "No bone of this type exists");

            }

            // Update ID
            if (editedNode.id != idInput.value) {

                enforce(isValidName(idInput.value), "Node ID must only contain " ~ validCharactersMsg);
                enforce(!model.getNode(idInput.value), "This ID already exists");

                // Update the ID
                newNode.id = idInput.value;

                // Update the tree label
                if (idLabel) idLabel.text = idInput.value;

            }

            // Update visibility
            if (visibilityChanged) {

                // Checks the same as "type", if visibile
                newNode.hidden = nodeHidden;

            }

            // Replace the old one
            model.replaceNode(newNode, editedIndex);
            editedNode = model.getNode(editedIndex);

            if (auto rlmodel = cast(RaylibModel) model) {

                rlmodel.nodeBoneDebug(editedIndex) = true;

            }

        }

        catch (Exception exc) {

            showError(exc.msg);
            return;

        }

        errorLabel.text = "";
        errorLabel.updateSize();

    }

    /// Apply inputted variants.
    private void applyVariants() {

        import std.string;

        editedNode.variants.length = 0;
        editedNode.variants.reserve = variantSpace.children.length;

        // Check each variant
        foreach (i, child; variantSpace.children) {

            auto input = cast(GluiTextInput) child;

            const lastInput = i+1 == variantSpace.children.length;

            // Input empty
            if (input.value == "") {

                // Ignore if focused or it's the last input field
                if (input.isFocused || lastInput) continue;

                // Remove the child
                input.remove();
                updateSize();
                continue;

            }

            // Invalid text
            if (!isValidName(input.value)) {

                showError(format!"Variant name %s is invalid, it should only contain %s"(
                    input.value, validCharactersMsg
                ));

                updateSize();
                return;

            }

            // Add the node
            editedNode.variants ~= input.value;

            // This is the last input, we need to add another one
            if (lastInput) {

                variantSpace.children ~= variantTextInput();
                updateSize();

            }

        }

        // Try to reload the bone
        try {

            // Check if the variants exist
            auto boneExists = editedModel.getBone(*editedNode);

            // Load the bone
            editedModel.replaceNode(*editedNode, editedIndex);

        }

        catch (Exception exc) {

            showError(exc.msg);
            return;

        }

        // Clear errors on success
        errorLabel.text = "";
        errorLabel.updateSize();

    }

    /// Run a test on the bone.
    /// Params:
    ///     axis = Axis to test. 0=x, 1=y, 2=z
    private void testBone(ubyte axis)
    in (axis <= 2, "Invalid axis")
    do {

        import core.time;
        import std.typecons;

        // Another axis to affect to emphasis the other one
        const otherAxis = (axis + 1) % 3;

        // Create an animation for the bone with 2 parts
        AnimationPart[] parts;
        parts.length = 6;

        // Rotate the bone on another axis to 45°
        float[3] rotationA = 0;
        rotationA[otherAxis % 3] = 45;

        parts[0].length = 1;
        parts[0].bone.require(editedNode.id).rotate = rotationA.nullable;

        // Rotate on this axis by 90° four times to make a circle
        foreach (i; 0..4) {

            float[3] rotationB = 0;
            rotationB[axis] = 90 + i*90;
            rotationB[otherAxis] = 45;

            parts[i+1].length = i+1;  // Bug in isodi
            parts[i+1].bone.require(editedNode.id).rotate = rotationB.nullable;

        }

        float[3] rotationC = 0;
        parts[5].length = 5;
        parts[5].bone.require(editedNode.id).rotate = rotationC.nullable;

        // Run the animation
        model.animate(parts, 5.seconds);

    }

    /// Apply inputted node changes.
    private void applyPosition() {

        editedNode.boneStart = boneStartInput.floatValue;
        editedNode.boneEnd = boneEndInput.floatValue;
        editedNode.texturePosition = texturePosInput.floatValue;

    }

    private void updateButtons() {

        visibilityButton.text = nodeHidden
            ? "Node hidden"
            : "Node visible";

        mirrorButton.text = editedNode.mirror
            ? "Unflip node"
            : "Flip node";

        updateSize();

    }

    /// Create a text input for altering variants
    private GluiTextInput variantTextInput() {

        auto newInput = textInput(.layout!"fill", "Add a new variant...");
        newInput.changed = &applyVariants;
        return newInput;

    }

    /// Show an error message.
    ///
    /// Note this is pretty annoying and breaks scroll on long messages. It would be helpful to introduce a different
    /// error system for the inputs, but I have no idea what it should be.
    private void showError(string msg) {

        import std.conv;
        import std.algorithm;

        // Remove duplicate spaces; workaround for https://github.com/Samerion/Glui/issues/26
        msg = msg.uniq!q{ a == ' ' && b == ' ' }.text;

        // Set the message
        errorLabel.text = msg;
        errorLabel.updateSize();

    }

}
