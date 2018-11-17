package it.unibo.boomparty;

import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;
import it.unibo.boomparty.service.SimulationService;
import it.unibo.boomparty.service.model.SimulationArgs;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

public class Main {

    private static Logger log = LogManager.getRootLogger();

    public static void main(String[] args) {

        SimulationArgs simArgs = new SimulationArgs();
        simArgs.setDebug(true);
        simArgs.setPlayers(9);

        Map<TEAM_PLAYER, ROLE_PLAYER[]> carte = new HashMap<TEAM_PLAYER, ROLE_PLAYER[]>();
        ROLE_PLAYER[] rolRed = {ROLE_PLAYER.BOMBAROLO, ROLE_PLAYER.BASE,  ROLE_PLAYER.BASE};
        carte.put(TEAM_PLAYER.ROSSO, rolRed);
        ROLE_PLAYER[] rolBlu = {ROLE_PLAYER.PRESIDENTE, ROLE_PLAYER.BASE,  ROLE_PLAYER.BASE};
        carte.put(TEAM_PLAYER.BLU, rolBlu);
        ROLE_PLAYER[] rolGrig = {ROLE_PLAYER.AMANTE_PRESIDENTE, ROLE_PLAYER.MOGLIE_PRESIDENTE,  ROLE_PLAYER.MAMMA_BOMBAROLO};
        carte.put(TEAM_PLAYER.GRIGIO, rolGrig);
        simArgs.setCarteRuolo(carte);

        // start sim
        SimulationService sim = new SimulationService();
        sim.startSimulation(simArgs);
    }
}
