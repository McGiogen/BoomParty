package it.maggioli.boomparty.api.service;

import it.maggioli.boomparty.api.domain.StartSimArgs;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class SimulationService {

    private final Logger log = LoggerFactory.getLogger(SimulationService.class);

    public void startSim(StartSimArgs args) {
        log.info("Simulation started");
    }

}
