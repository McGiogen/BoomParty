package it.unibo.boomparty.utils;

import alice.logictuple.LogicTuple;
import alice.logictuple.Value;
import alice.tucson.api.TucsonAgentId;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.api.exceptions.TucsonInvalidAgentIdException;
import alice.tucson.api.exceptions.TucsonInvalidTupleCentreIdException;
import alice.tucson.asynchSupport.actions.specification.SetS;
import alice.tucson.introspection.tools.InspectorGUI;
import alice.tucson.service.TucsonNodeService;
import alice.tucson.utilities.Utils;
import it.unibo.boomparty.service.Settings;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Classe di Util per la gestione del node service
 *
 */
public class TucsonUtils {

    private static Logger log = LogManager.getLogger();
    private static Map<Integer, TucsonNodeService> tnsMap;

    /**
     * Avvia il tucson node service su localhost
     * The listening port for the TuCSoN Node service is read from Settings
     * @return String l'identificatore del tucson node service
     */
    public static TucsonTupleCentreId startTucsonNS(int port) {

        if (tnsMap == null) {
            tnsMap = new HashMap<>();
        }

        if (tnsMap.containsKey(port)) {
            log.warn("Un altro tns potrebbe essere attivo su questa porta..");
            // ci proviamo lo stesso
        }

        try {
            TucsonNodeService ns = new TucsonNodeService(port);
            ns.install();

            // Aspetto che il node service sia effettivamente installato
            while (!TucsonNodeService.isInstalled(port, 5000)) {
                Thread.sleep(1000L);
            }

            tnsMap.put(port, ns);
        } catch (Exception e) {
            // E.g. another TuCSoN Node is running on same port.
            e.printStackTrace();
            return null;
        }

        log.info("TNS avviato correttamente sulla porta " + port);

        TucsonTupleCentreId tid;
        try {
            tid = new TucsonTupleCentreId("default", "localhost", String.valueOf(port));
        } catch (TucsonInvalidTupleCentreIdException e) {
            e.printStackTrace();
            tid = null;
        }
        return tid;
    }

    /**
     * Stoppa il node service sulla porta specificata
     *
     * @param port
     *            the listening port for the TuCSoN Node service
     * @return boolean indicante il successo dell'operazione
     */
    public static void stopNS(int port) {

        if (tnsMap != null) {
            if (tnsMap.containsKey(port)) {
                tnsMap.get(port).shutdown();
                tnsMap.remove(port);
            } else {
                log.warn("Node service non found for port: " + port);
            }
        }
    }

    /**
     * Stoppa tutti i node service
     */
    public static void stopAll() {
        if (tnsMap != null) {
            for (int nodePort : tnsMap.keySet()) {
                stopNS(nodePort);
            }
        }
    }

    /**
     * Avvia un tucson inspector sulla porta di default
     */
    public static void launchInspector() {
        //SwingUtilities.invokeLater(() -> {
//        new Thread(() -> {
//        EventQueue.invokeLater(new Runnable() {
//            @Override
//            public void run() {
//                try {
//                    new InspectorGUI(
//                            new TucsonAgentId("myInspector"),
//                            new TucsonTupleCentreId(Settings.TNS_NAME, Settings.getTNSServer(), String.valueOf(Settings.TNS_PORT)));
//                } catch (TucsonInvalidAgentIdException | TucsonInvalidTupleCentreIdException e) {
//                    e.printStackTrace();
//                }
//            }
//        });
//            try {
//                new InspectorGUI(
//                        new TucsonAgentId("myInspector"),
//                        new TucsonTupleCentreId(Settings.TNS_NAME, Settings.getTNSServer(), String.valueOf(Settings.TNS_PORT)));
//            } catch (TucsonInvalidAgentIdException | TucsonInvalidTupleCentreIdException e) {
//                e.printStackTrace();
//            }
//        }).start();
        // {-tname tuple centre name} {-netid ip address} {-portno listening port number} {-aid agent identifier} {-?}
//        SwingUtilities.invokeLater(() -> {
//        new Runnable(() -> {
//                InspectorGUI.main(new String[]{"-tname", Settings.TNS_NAME, "-netip", Settings.getTNSServer(), "-portno", String.valueOf(Settings.TNS_PORT), "-aid", "myInspector"});
//        }));

//        Class klass = InspectorGUI.class;
//        String javaHome = System.getProperty("java.home");
//        String javaBin = javaHome + File.separator + "bin" + File.separator + "java";
//        String classpath = System.getProperty("java.class.path");
//        String className = klass.getCanonicalName();
//
//        ProcessBuilder builder = new ProcessBuilder(javaBin, "-cp", classpath, className);
//
//        try {
//            Process process = builder.start();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
        //return;

//        new Thread(() -> {
//            try {
//                new InspectorGUI(
//                    new TucsonAgentId("myInspector"),
//                    new TucsonTupleCentreId(Settings.TNS_NAME, Settings.getTNSServer(), String.valueOf(Settings.TNS_PORT)));
//            } catch (TucsonInvalidAgentIdException | TucsonInvalidTupleCentreIdException e) {
//                e.printStackTrace();
//            }
//        }).start();

        try {
            new InspectorGUI(
                    new TucsonAgentId("myInspector"),
                    new TucsonTupleCentreId(Settings.TNS_NAME, Settings.getTNSServer(), String.valueOf(Settings.TNS_PORT)));
        } catch (TucsonInvalidAgentIdException | TucsonInvalidTupleCentreIdException e) {
            e.printStackTrace();
        }

    }

    public static String buildNSId(String nsname, String ip, int port) {
        return nsname + "@" + ip + ":" + port;
    }

    public static String buildNSId(TucsonTupleCentreId ttci) {
        return ttci.getName() + "@" + ttci.getNode() + ":" + ttci.getPort();
    }

    /**
     * Carica le reaction da un file
     */
    public static void loadReactionFromFile(TucsonChannel tc, String path){
        try {
            String utility = Utils.fileToString(path);
            LogicTuple specT = new LogicTuple("spec", new Value(utility));
            tc.actionSynch(SetS.class, specT);
        } catch (IOException e) {
            log.error("Errore durante caricamento reactions: " + e.getMessage());
        }
    }

}
