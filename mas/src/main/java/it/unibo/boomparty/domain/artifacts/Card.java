package it.unibo.boomparty.domain.artifacts;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;

public class Card extends Artifact {

    private String role = null;

    void init(String role) {
        this.role = role;
    }

    @OPERATION
    void getRole(OpFeedbackParam<String> role) {
        role.set(this.role);
    }
}
