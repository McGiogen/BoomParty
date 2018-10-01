package it.unibo.boomparty;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.boomparty.agents.impl.SettingsAgent;
import it.unibo.boomparty.utils.JadeUtils;
import it.unibo.boomparty.utils.TucsonUtils;
import jade.wrapper.AgentContainer;
import jade.wrapper.AgentController;
import jade.wrapper.StaleProxyException;

public class Bootstrap {

    private static Logger log = LogManager.getLogger();
    private AgentContainer mainContainer;
    private String tname;

    public Bootstrap() {
        init();
        startAgents();
    }

    private void init() {
        // Tucson Node Service
        this.tname = TucsonUtils.startNS();
        log.info("Istanziato Tucson: " + tname);

        this.mainContainer = JadeUtils.startMainContainer();
    }

    private void startAgents() {
        try {
            // Avvio l'agente che gestisce le configurazioni del sistema
            AgentController agSetting = this.mainContainer.createNewAgent(
                    "settingsAgent",
                    SettingsAgent.class.getName(),
                    new Object[] { tname }
            );
            agSetting.start();
        } catch (StaleProxyException e) {
            log.error("Errore durante creazione agenti: " + e.getMessage());
        }
    }
}

