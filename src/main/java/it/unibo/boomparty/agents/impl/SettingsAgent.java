package it.unibo.boomparty.agents.impl;

import java.io.IOException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import alice.logictuple.LogicTuple;
import alice.logictuple.Value;
import alice.tucson.asynchSupport.actions.specification.SetS;
import alice.tucson.utilities.Utils;
import it.unibo.boomparty.agents.TucsonAgent;
import it.unibo.boomparty.constants.Settings;
import jade.core.ServiceException;

/**
 * Avvio
 */
public class SettingsAgent extends TucsonAgent {

    private static final long serialVersionUID = 1L;

    private static Logger log = LogManager.getLogger();

    @Override
    protected void setup() {

        // 1. init tucson interaction
        super.setup();

        // 2. load reactions
        loadReaction();
        log.info("Reactions loaded successfully");

        // 3. load default settings
        loadDefaultSettings();
        log.info("Default config loaded successfully");
    }

    /**
     * Carica le configurazioni di default
     */
    private void loadDefaultSettings() {
        // TODO
    }

    /**
     * Carica le reaction della simulazione
     */
    private void loadReaction(){
        try {
            String utility = Utils.fileToString(Settings.UTILITY_REACTION_FILE);
            String uniqueId = Utils.fileToString(Settings.UNIQUE_ID_REACTION_FILE);

            String value = utility + uniqueId;

            final LogicTuple specT = new LogicTuple("spec", new Value(value));
            SetS op = new SetS(getTucsonTupleCentreId(), specT);
            SettingsAgent.this.getBridge().asynchronousInvocation(op);

        } catch (ServiceException | IOException e) {
            log.error("Errore durante caricamento reactions: " + e.getMessage());
        }
    }

}
