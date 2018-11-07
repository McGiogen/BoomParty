package it.unibo.boomparty;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Main {

    private static Logger log = LogManager.getRootLogger();

    public static void main(String[] args) {
        Bootstrap.bootMasProject(false);
    }
}
