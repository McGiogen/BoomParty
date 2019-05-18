package it.unibo.boomparty.service.model;

import it.unibo.boomparty.constants.GameConstans.ROLE;
import it.unibo.boomparty.constants.GameConstans.TEAM;

import java.util.List;
import java.util.Map;

public class SimulationArgs {

    private boolean debug;
    private boolean isDistributed;
    private int players;
    private Map<TEAM, List<ROLE>> ruoliInTeamMapping;

    public boolean isDebug() {
        return debug;
    }

    public void setDebug(boolean debug) {
        this.debug = debug;
    }

    public int getPlayers() {
        return players;
    }

    public void setPlayers(int players) {
        this.players = players;
    }

    public boolean isDistributed() {
        return isDistributed;
    }

    public void setDistributed(boolean distributed) {
        isDistributed = distributed;
    }

    public Map<TEAM, List<ROLE>> getRuoliInTeamMapping() {
        return ruoliInTeamMapping;
    }

    public void setRuoliInTeamMapping(Map<TEAM, List<ROLE>> carte) {
        this.ruoliInTeamMapping = carte;
    }
}
