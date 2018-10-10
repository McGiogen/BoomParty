package it.unibo.boomparty.utils;

import it.unibo.boomparty.agents.IBaseAgent;
import it.unibo.boomparty.constants.Settings;
import jade.core.Profile;
import jade.core.ProfileImpl;
import jade.wrapper.AgentContainer;
import jade.wrapper.AgentController;
import jade.wrapper.ControllerException;
import jade.wrapper.StaleProxyException;

public class JadeUtils {

    /**
     * Avvia l'RMA
     * @see http://jade.tilab.com/documentation/tutorials-guides/jade-rma/introduction-to-the-rma/
     */
    public static void launchRMA(AgentContainer container) {
        try {
            AgentController rma = container.createNewAgent("rma", jade.tools.rma.rma.class.getName(),
                    new Object[0]);
            rma.start();
        } catch (StaleProxyException e) {
            e.printStackTrace();
        }
    }

    public static AgentContainer startMainContainer() {
        // Jade Platform
        jade.core.Runtime rt = jade.core.Runtime.instance();

        Profile profile = new ProfileImpl(Settings.MC_HOST, Settings.MC_PORT, null);

        // Tucson4Jade
        profile.setParameter(Profile.SERVICES, "it.unibo.tucson.jade.service.TucsonService;jade.core.event.NotificationService");

        // DF e AMS sono già inclusi
        return rt.createMainContainer(profile);
    }

    public static AgentContainer startPeripheralContainer() {
        // Jade Platform
        jade.core.Runtime rt = jade.core.Runtime.instance();

        Profile profile = new ProfileImpl(Settings.MC_HOST, Settings.MC_PORT, null);
        profile.setParameter(Profile.MAIN_HOST, Settings.getTNSServer());
        profile.setParameter(Profile.MAIN_PORT, String.valueOf(Settings.MC_PORT));

        // Tucson4Jade
        profile.setParameter(Profile.SERVICES, "it.unibo.tucson.jade.service.TucsonService;jade.core.event.NotificationService");

        // DF e AMS sono già inclusi
        return rt.createAgentContainer(profile);
    }

    /**
     * Helper per la creazione di un agente. L'agente viene creato aggiungendo un suffisso
     * al nome in modo che sia il più possibile univoco. Per ora è univoco solo tra container diversi.
     * @param container container in cui creare l'agente
     * @param agentName nome semplice dell'agente
     * @param agentClass classe dell'agente
     * @param inputData dati da passare come input all'agente
     * @return il controller dell'agente creato
     * @throws StaleProxyException
     */
    public static AgentController createNewAgent(AgentContainer container, String agentName, Class<? extends IBaseAgent> agentClass, Object[] inputData) throws StaleProxyException {
        try {
            agentName += "-" + container.getContainerName();
        } catch (ControllerException e1) {}

        // Tolgo alcuni caratteri speciali che potrebbero causare errori in Jade o (soprattutto) in Tucson
        agentName = agentName.replaceAll("[-_ ]", "");

        return container.createNewAgent(agentName, agentClass.getName(), inputData);
    }
}

