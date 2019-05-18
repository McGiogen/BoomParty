package it.unibo.boomparty.service.model;

import it.unibo.boomparty.constants.GameConstans.ROLE;
import it.unibo.boomparty.constants.GameConstans.TEAM;

import java.util.List;
import java.util.Map;

public class SimulationArgs {

    private boolean debug;

    // controlla il tipo di simulazione
    private boolean isDistributed;
    private String jadeHost = "localhost";
    private int jadePort = 1099;

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

    public String getJadeHost() {
        return jadeHost;
    }

    public void setJadeHost(String jadeHost) {
        this.jadeHost = jadeHost;
    }

    public int getJadePort() {
        return jadePort;
    }

    public void setJadePort(int jadePort) {
        this.jadePort = jadePort;
    }
}
