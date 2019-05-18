package it.unibo.boomparty.domain.artifacts;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import it.unibo.boomparty.constants.GameConstans.ROLE;
import it.unibo.boomparty.constants.GameConstans.TEAM;

public class Card extends Artifact {

    private ROLE role;
    private TEAM team;


    void init(String team, String role) {
        this.team = TEAM.byCodice(team);
        this.role = ROLE.byCodice(role);
    }

    @OPERATION
    void getRole(OpFeedbackParam<String> role) {
        role.set(this.role.getCodice());
    }

    @OPERATION
    void getTeam(OpFeedbackParam<String> team) {
        team.set(this.team.getCodice());
    }
}
