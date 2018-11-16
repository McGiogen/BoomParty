package it.unibo.boomparty;

import it.unibo.boomparty.service.SimulationService;
import it.unibo.boomparty.service.model.SimulationArgs;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Main {

    private static Logger log = LogManager.getRootLogger();

    public static void main(String[] args) {

        SimulationArgs simArgs = new SimulationArgs();
        simArgs.setDebug(true);
        simArgs.setPlayers(9);

        // start sim
        SimulationService sim = new SimulationService();
        sim.startSimulation(simArgs);
    }
}
