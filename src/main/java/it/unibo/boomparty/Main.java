package it.unibo.boomparty;

import it.unibo.boomparty.constants.GameConstans.ROLE;
import it.unibo.boomparty.constants.GameConstans.TEAM;
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
        simArgs.setPlayers(13);

        Map<TEAM, List<ROLE>> teamRuoliMap = new HashMap<>();
        List<ROLE> ruoliInRedTeam = new ArrayList<ROLE>();
        List<ROLE> ruoliInBluTeam = new ArrayList<ROLE>();
        List<ROLE> ruoliInGreyTeam = new ArrayList<ROLE>();

        ruoliInRedTeam.add(ROLE.BOMBAROLO);
        ruoliInRedTeam.add(ROLE.BASE);
        ruoliInRedTeam.add(ROLE.BASE);
        ruoliInRedTeam.add(ROLE.BASE);
        ruoliInRedTeam.add(ROLE.BASE);
        ruoliInBluTeam.add(ROLE.PRESIDENTE);
        ruoliInBluTeam.add(ROLE.BASE);
        ruoliInBluTeam.add(ROLE.BASE);
        ruoliInBluTeam.add(ROLE.BASE);
        ruoliInBluTeam.add(ROLE.BASE);
        ruoliInGreyTeam.add(ROLE.AMANTE_PRESIDENTE);
        ruoliInGreyTeam.add(ROLE.MOGLIE_PRESIDENTE);
        ruoliInGreyTeam.add(ROLE.NATO_LEADER);

        teamRuoliMap.put(TEAM.ROSSO, ruoliInRedTeam);
        teamRuoliMap.put(TEAM.BLU, ruoliInBluTeam);
        teamRuoliMap.put(TEAM.GRIGIO, ruoliInGreyTeam);
        simArgs.setRuoliInTeamMapping(teamRuoliMap);

        // start sim
        SimulationService sim = new SimulationService();
        sim.startSimulation(simArgs);
    }
}
