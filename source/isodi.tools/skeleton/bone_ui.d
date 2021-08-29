module isodi.tools.skeleton.bone_ui;

import glui;

import isodi;
import isodi.resource;
import isodi.raylib.model;

import isodi.tools.skeleton.structs;
import isodi.tools.skeleton.editor_ui;


@safe:


final class BoneEditor : GluiSpace {

    public {

        GluiLabel idLabel;

    }

    private {

        SkeletonEditor skeletonEditor;

        Model editedModel;
        size_t editedIndex;
        SkeletonNode* editedNode;

        GluiTextInput typeInput, idInput;
        GluiLabel errorLabel;

        Vector3Editor boneStartInput, boneEndInput, texturePosInput;
        GluiButton!() mirrorButton;

        GluiButton!() visibilityButton;
        bool nodeHidden;

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

                errorLabel = label(),

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

    private void addCallbacks() {

        // Update node info
        typeInput.changed = &applyInfo;
        idInput.changed = &applyInfo;

        // Update bone ends
        boneStartInput.changed = &applyPosition;
        boneEndInput.changed = &applyPosition;
        texturePosInput.changed = &applyPosition;

    }

    private void applyInfo() {

        import std.exception;

        bool isValidName(string name) {

            import std.uni, std.algorithm;

            return name.all!(a => a.isAlphaNum || a == '_' || a == '-' || a == '.');

        }

        enum validCharactersMsg = "alphanumeric characters, underscores (_), dashes (-) and dots (.)";

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

            errorLabel.text = exc.msg;
            errorLabel.updateSize();
            return;

        }

        errorLabel.text = "";
        errorLabel.updateSize();

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

}
