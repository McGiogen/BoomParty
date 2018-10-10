package it.unibo.boomparty.utils;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import alice.tucson.api.TucsonAgentId;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.api.exceptions.TucsonInvalidAgentIdException;
import alice.tucson.api.exceptions.TucsonInvalidTupleCentreIdException;
import alice.tucson.introspection.tools.InspectorGUI;
import alice.tucson.service.TucsonNodeService;
import it.unibo.boomparty.constants.Settings;

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
    public static String startNS() {

        if (tnsMap == null) {
            tnsMap = new HashMap<Integer, TucsonNodeService>();
        }

        int port = Settings.TNS_PORT;

        if (tnsMap.containsKey(port)) {
            log.warn("Un altro tns potrebbe essere attivo su questa porta..");
            // ci proviamo lo stesso
        }

        try {
            TucsonNodeService ns = new TucsonNodeService(port);
            ns.install();
            tnsMap.put(port, ns);
        } catch (Exception e) {
            // E.g. another TuCSoN Node is running on same port.
            e.printStackTrace();
            return null;
        }

        log.info("TNS avviato correttamente sulla porta " + port);

        return TucsonUtils.getLocalNSId();
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
        try {
            new InspectorGUI(
                    new TucsonAgentId("myInspector"),
                    new TucsonTupleCentreId(Settings.TNS_NAME, Settings.getTNSServer(), String.valueOf(Settings.TNS_PORT))
            );
        } catch (TucsonInvalidAgentIdException | TucsonInvalidTupleCentreIdException e) {
            e.printStackTrace();
        }
    }

    private static String getLocalNSId() {
        String currentHostname = "localhost";

        try {
            currentHostname = InetAddress.getLocalHost().getHostAddress();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        return TucsonUtils.buildNSId(Settings.TNS_NAME, currentHostname, Settings.TNS_PORT);
    }

    public static String getNSId() {
        return TucsonUtils.buildNSId(Settings.TNS_NAME, Settings.getTNSServer(), Settings.TNS_PORT);
    }

    public static String buildNSId(String nsname, String ip, int port) {
        return nsname + "@" + ip + ":" + port;
    }
}
