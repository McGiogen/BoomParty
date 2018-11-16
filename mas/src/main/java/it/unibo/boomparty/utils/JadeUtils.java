package it.unibo.boomparty.utils;

import it.unibo.boomparty.service.Settings;
import jade.core.Profile;
import jade.core.ProfileImpl;
import jade.wrapper.AgentContainer;
import jade.wrapper.AgentController;
import jade.wrapper.ControllerException;
import jade.wrapper.StaleProxyException;

public class JadeUtils {

    /**
     * Avvia l'RMA.
     * JADE offers a graphical interface to platform administration through its RMA agent;
     * this agent shows the state of the Agent Platform it belongs to (agent and agent containers)
     * and offers various tools to request administrative operations from the AMS agent and to debug and test JADE-based applications.
     * @see http://jade.tilab.com/documentation/tutorials-guides/jade-rma/introduction-to-the-rma/
     *
     * Nota: l'RMA viene automaticamente istanziato quando il mainContainer viene avviato con l'opzione "-gui"
     */
    public static void launchRMA(AgentContainer container) {
        try {
            AgentController rma = container.createNewAgent(
                "rma",
                jade.tools.rma.rma.class.getName(),
                new Object[0]
            );
            rma.start();
        } catch (StaleProxyException e) {
            e.printStackTrace();
        }
    }

    /**
     * Il jade main container è il container master sulla quale si registrano i vari container distribuiti.
     *
     * Besides the ability of accepting registrations from other containers, a main container differs from
     * normal containers as it holds two special agent (automatically started when the main container is
     * launched).
     *
     * The AMS (Agent Management System) that provides the naming service (i.e. ensures that each agent in
     * the platform has a unique name) and represents the authority in the platform (for instance it is possible to
     * create/kill agent on remote containers by requesting that to the AMS).
     *
     * The DF (Directory Facilitator) that provides a Yellow Pages service by means of which an agent can
     * find other agent providing the services he requires in order
     */
    public static AgentContainer startMainContainer() {
        // Jade Platform
        jade.core.Runtime rt = jade.core.Runtime.instance();

        Profile profile = new ProfileImpl(Settings.MC_HOST, Settings.MC_PORT, null);

        // Tucson4Jade
        profile.setParameter(Profile.SERVICES, "it.unibo.tucson.jade.service.TucsonService;jade.core.event.NotificationService");

        // DF e AMS sono gia' inclusi
        return rt.createMainContainer(profile);
    }

    /**
     * Nel caso si volessero distribuire gli agenti Jade, basterebbe richiamare questo metodo specificando
     * l'indirizzo del Main Container
     */
    public static AgentContainer startPeripheralContainer(String mainContainerHost, int mainContainerPort) {
        // Jade Platform
        jade.core.Runtime rt = jade.core.Runtime.instance();

        Profile profile = new ProfileImpl(mainContainerHost, mainContainerPort, null);

        // Tucson4Jade
        profile.setParameter(Profile.SERVICES, "it.unibo.tucson.jade.service.TucsonService;jade.core.event.NotificationService");

        return rt.createAgentContainer(profile);
    }

    /**
     * Helper per la creazione di un agente. L'agente viene creato aggiungendo un suffisso
     * al nome in modo che sia il piu' possibile univoco. Per ora e' univoco solo tra container diversi.
     * @param container container in cui creare l'agente
     * @param agentName nome semplice dell'agente
     * @param agentClass classe dell'agente da reare
     * @param inputData dati da passare come input all'agente
     * @return il controller dell'agente creato
     * @throws StaleProxyException
     */
    public static AgentController createNewAgent(AgentContainer container, String agentName, Class agentClass, Object[] inputData) throws StaleProxyException {
        try {
            agentName += "-" + container.getContainerName();
        } catch (ControllerException e1) {}

        // Tolgo alcuni caratteri speciali che potrebbero causare errori in Jade o (soprattutto) in Tucson
        agentName = agentName.replaceAll("[-_ ]", "");

        return container.createNewAgent(agentName, agentClass.getName(), inputData);
    }

}

