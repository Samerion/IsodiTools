module isodi.tools.skeleton.bone_ui;

import glui;

import isodi;
import isodi.resource;
import isodi.raylib.model;

import isodi.tools.skeleton.structs;


@safe:


final class BoneEditor : GluiSpace {

    public {

        GluiLabel idLabel;

    }

    private {

        Model editedModel;
        size_t editedIndex;
        SkeletonNode* editedNode;

        GluiTextInput typeInput, idInput;
        GluiLabel errorLabel;

        Vector3Editor boneStartInput, boneEndInput, texturePosInput;
        GluiButton!() mirrorButton;

    }

    this() {

        super(
            .layout!(1, "fill"),

            vframe(
                .layout!"fill",

                label("Node type"),
                typeInput = textInput(""),

                label("Node ID"),
                idInput = textInput(""),

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

                    updateMirrorButton();

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
        errorLabel.text = "";

        // Update positions
        boneStartInput.floatValue = editedNode.boneStart;
        boneEndInput.floatValue = editedNode.boneEnd;
        texturePosInput.floatValue = editedNode.texturePosition;

        // Update buttons
        updateMirrorButton();

    }

    void clearTarget() {

        // If there's a model assigned
        if (auto model = cast(RaylibModel) model) {

            // Clear node debug
            model.nodeBoneDebug(editedIndex) = false;

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

    private void applyInfo() {

        import std.exception;

        bool isValidName(string name) {

            import std.uni, std.algorithm;

            return name.all!(a => a.isAlphaNum || a == '_' || a == '-' || a == '.');

        }

        enum validCharactersMsg = "alphanumeric characters, underscores (_), dashes (-) and dots (.)";

        try {

            // Update type
            if (editedNode.name != typeInput.value) {

                enforce(isValidName(typeInput.value), "Node type must only contain " ~ validCharactersMsg);

                // Create a new node
                auto newNode = *editedNode;
                newNode.name = typeInput.value;

                // Check if the bone exists
                enforce(!collectException(model.getBone(newNode)), "No bone of this type exists");

                // Replace the old one
                model.replaceNode(newNode, editedIndex);
                editedNode = model.getNode(editedIndex);

            }

            // Update ID
            if (editedNode.id != idInput.value) {

                enforce(isValidName(idInput.value), "Node ID must only contain " ~ validCharactersMsg);
                enforce(!model.getNode(idInput.value), "This ID already exists");

                // Create a new node
                auto newNode = *editedNode;
                newNode.id = idInput.value;

                // Replace the old one
                model.replaceNode(newNode, editedIndex);
                editedNode = model.getNode(editedIndex);

                // Update the tree label
                if (idLabel) idLabel.text = idInput.value;

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

    private void updateMirrorButton() {

        mirrorButton.text = editedNode.mirror
            ? "Unflip node"
            : "Flip node";

        updateSize();

    }

}
