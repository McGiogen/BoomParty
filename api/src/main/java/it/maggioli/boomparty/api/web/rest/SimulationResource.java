package it.maggioli.boomparty.api.web.rest;

import it.maggioli.boomparty.api.domain.StartSimArgs;
import it.maggioli.boomparty.api.service.SimulationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/sim")
public class SimulationResource {

    @Autowired
    private SimulationService simulationService;

    @PostMapping("/start")
    public void start(@RequestBody StartSimArgs args) {
        simulationService.startSim(args);
    }
}