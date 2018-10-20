package it.unibo.boomparty.constants;

public class Settings {

    //---- TUCSON NODE SERVICE ----
    public static final String TNS_NAME = "default";
    public static final String TNS_SERVER_DEFAULT = "localhost";
    public static final int TNS_PORT = 20504;

    //---- REACTIONS FILE ----
    public static final String UTILITY_REACTION_FILE = "reactions/utility.rsp";
    public static final String UNIQUE_ID_REACTION_FILE = "reactions/uniqueId.rsp";

    //---- JADE ----
    public static final String MC_HOST = "localhost";	//main container server
    public static final int MC_PORT = 2500; // main container port

    //---- AGENT ----
    public static final long TICK_TIME_SLOW = 5000L;
    public static final long TICK_TIME_STD = 1000L;
    public static final long TICK_TIME_FAST = 500L;
    public static final long TICK_TIME_ULTRA = 50L;


    //---- TNS SERVER ----
    private static String tnsServer = null;

    public static String getTNSServer() {
        if (Settings.tnsServer == null) {
            return TNS_SERVER_DEFAULT;
        }
        return Settings.tnsServer;
    }

    public static void setTNSServer(String tnsServer) {
        Settings.tnsServer = tnsServer;
    }
}

