package it.unibo.boomparty;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.boomparty.gui.MainGuiAgent;
import it.unibo.boomparty.utils.JadeUtils;
import it.unibo.boomparty.utils.TucsonUtils;
import jade.wrapper.AgentContainer;
import jade.wrapper.AgentController;
import jade.wrapper.StaleProxyException;

public class Main {

    private static Logger log = LogManager.getRootLogger();

    public static void main(String[] args) {
//        ProgramArgumentsHelper pa = new ProgramArgumentsHelper(args);

//        Main.setupSettings(pa);
        Main.startProgram(/*pa*/);
    }

//    private static void setupSettings(ProgramArgumentsHelper pa) {
//        // Se viene specificato l'indirizzo del tuple center lo prendo, altrimenti uso il default
//        if (pa.getTC() != null) {
//            Settings.setTNSServer(pa.getTC());
//        }
//    }

    private static void startProgram(/*ProgramArgumentsHelper pa*/) {
        String tname = TucsonUtils.getNSId();

        // Avvio il main se richiesto
//        if (pa.isMain()) {
            new Bootstrap();
//        }

        // Avvio un device se richiesto
//        if (pa.getDevice() != null) {
//            DeviceUtils.createInstance(pa.getDevice(), tname);
//        }

        // Avvio la gui e il relativo agente se richiesto
//        if (pa.isGui()) {
            try {
                AgentContainer agentContainer = JadeUtils.startPeripheralContainer();
                AgentController agGui = JadeUtils.createNewAgent(
                        agentContainer,
                        "mainGuiAgent",
                        MainGuiAgent.class,
                        new Object[] { tname }
                );
                agGui.start();
            } catch (StaleProxyException e) {
                log.error("Errere set up sistema: " + e.getMessage());
            }
//        }
    }
}
