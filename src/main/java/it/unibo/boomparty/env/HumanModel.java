package it.unibo.boomparty.env;

import it.unibo.boomparty.constants.GameConstans.TEAM;
import it.unibo.boomparty.constants.GameConstans.ROLE;

public class HumanModel {

    private final String name;
    private final int index;
    private PathFinder.Path path;
    private TEAM team;
    private ROLE ruolo;
    private boolean isLeader;

    public HumanModel(String name, int index) {
        this.name = name;
        this.index = index;
        this.isLeader = false;
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

    public ROLE getRuolo() {
        return ruolo;
    }

    public void setRuolo(ROLE ruolo) {
        this.ruolo = ruolo;
    }

    public TEAM getTeam() {
        return team;
    }

    public void setTeam(TEAM team) {
        this.team = team;
    }

    public boolean isLeader() {
        return isLeader;
    }

    public void setLeader(boolean leader) {
        isLeader = leader;
    }
}
