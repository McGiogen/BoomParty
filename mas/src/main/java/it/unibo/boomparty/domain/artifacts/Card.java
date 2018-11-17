package it.unibo.boomparty.domain.artifacts;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;

public class Card extends Artifact {

    private ROLE_PLAYER role;
    private TEAM_PLAYER team;


    void init(String team, String role) {
        this.team = TEAM_PLAYER.byCodice(team);
        this. role = ROLE_PLAYER.byCodice(role);
    }

    @OPERATION
    void getRole(OpFeedbackParam<String> role) {
        role.set(this.role.getCodice());
    }

    @OPERATION
    void getTeam(OpFeedbackParam<String> role) {
        role.set(this.team.getCodice());
    }
}
