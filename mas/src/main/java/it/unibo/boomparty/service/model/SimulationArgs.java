package it.unibo.boomparty.service.model;

public class SimulationArgs {

    private boolean debug;
    private boolean isDistributed;
    private int players;

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
}
