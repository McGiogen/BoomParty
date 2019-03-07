package it.unibo.boomparty.service.model;

import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;

import java.util.List;
import java.util.Map;

public class SimulationArgs {

    private boolean debug;
    private boolean isDistributed;
    private int players;
    Map<TEAM_PLAYER, List<ROLE_PLAYER>> carteRuolo;

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

    public Map<TEAM_PLAYER, List<ROLE_PLAYER>> getCarteRuolo() {
        return carteRuolo;
    }

    public void setCarteRuolo(Map<TEAM_PLAYER, List<ROLE_PLAYER>> carte) {
        this.carteRuolo = carte;
    }
}
