package it.unibo.boomparty;

import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;
import it.unibo.boomparty.service.SimulationService;
import it.unibo.boomparty.service.model.SimulationArgs;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Main {

    private static Logger log = LogManager.getRootLogger();

    public static void main(String[] args) {

        SimulationArgs simArgs = new SimulationArgs();
        simArgs.setDebug(true);
        simArgs.setPlayers(9);

        Map<TEAM_PLAYER, List<ROLE_PLAYER>> carte = new HashMap<TEAM_PLAYER, List<ROLE_PLAYER>>();
        List<ROLE_PLAYER> rolRed = new ArrayList<ROLE_PLAYER>();
        List<ROLE_PLAYER> rolBlu = new ArrayList<ROLE_PLAYER>();
        List<ROLE_PLAYER> rolGrig = new ArrayList<ROLE_PLAYER>();

        rolRed.add(ROLE_PLAYER.BOMBAROLO);
        rolRed.add(ROLE_PLAYER.BASE);
        rolRed.add(ROLE_PLAYER.BASE);
        rolBlu.add(ROLE_PLAYER.PRESIDENTE);
        rolBlu.add(ROLE_PLAYER.BASE);
        rolBlu.add(ROLE_PLAYER.BASE);
        rolGrig.add(ROLE_PLAYER.AMANTE_PRESIDENTE);
        rolGrig.add(ROLE_PLAYER.MOGLIE_PRESIDENTE);
        rolGrig.add(ROLE_PLAYER.MAMMA_BOMBAROLO);

        carte.put(TEAM_PLAYER.ROSSO, rolRed);
        carte.put(TEAM_PLAYER.BLU, rolBlu);
        carte.put(TEAM_PLAYER.GRIGIO, rolGrig);
        simArgs.setCarteRuolo(carte);

        // start sim
        SimulationService sim = new SimulationService();
        sim.startSimulation(simArgs);
    }
}
