package it.unibo.boomparty.utils;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import alice.logictuple.TupleArgument;

public class TupleUtils {

    private static Logger log = LogManager.getLogger();

    /**
     * Gestisce i null
     *
     * @param arg
     * @return
     */
    public static Double doubleValue(TupleArgument arg) {
        return arg.isDouble() ? arg.doubleValue() : null;
    }

    /**
     * Gestisce i null
     *
     * @param arg
     * @return
     */
    public static Integer intValue(TupleArgument arg) {
        return arg.isInt() ? arg.intValue() : null;
    }

    /**
     * Gestisce i numeri da leggere come stringhe, getName non funziona in quel
     * caso.
     *
     * @param name
     * @return
     */
    public static String stringValue(TupleArgument arg) {
        if (arg.isStruct() || arg.isVar()) {
            return arg.getName();
        }
        if (arg.isDouble()) {
            return String.valueOf(arg.doubleValue());
        }
        if (arg.isFloat()) {
            return String.valueOf(arg.floatValue());
        }
        if (arg.isInt() || arg.isInteger()) {
            return String.valueOf(arg.intValue());
        }
        log.error("Impossibile trasformare in stringa l'argomento " + arg.toString());
        return null;
    }

}

