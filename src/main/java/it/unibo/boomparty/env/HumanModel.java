package it.unibo.boomparty.env;

import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;
import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;

public class HumanModel {

    private final String name;
    private final int index;
    private PathFinder.Path path;
    private TEAM_PLAYER team;
    private ROLE_PLAYER ruolo;

    public HumanModel(String name, int index) {
        this.name = name;
        this.index = index;
    }

    public PathFinder.Path getPath() {
        return path;
    }

    public void setPath(PathFinder.Path path) {
        this.path = path;
    }

    public String getName() {
        return name;
    }

    public int getIndex() {
        return index;
    }

    public ROLE_PLAYER getRuolo() {
        return ruolo;
    }

    public void setRuolo(ROLE_PLAYER ruolo) {
        this.ruolo = ruolo;
    }

    public TEAM_PLAYER getTeam() {
        return team;
    }

    public void setTeam(TEAM_PLAYER team) {
        this.team = team;
    }
}
