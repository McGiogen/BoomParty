package it.unibo.boomparty.constants;

import java.awt.*;

public class GameConstans {

    public static enum TEAM_PLAYER {
        ROSSO("Rosso", "rosso", Color.red),
        BLU("Blu", "blu", Color.blue),
        GRIGIO("Grigio", "grigio", Color.gray);

        private String value;
        private String codice;
        private Color colore;

        private TEAM_PLAYER(String v, String c, Color col) {
            value = v;
            codice = c;
            colore = col;
        }

        @Override
        public String toString(){
            return value;
        }
        public String getValue(){
            return value;
        }
        public String getCodice(){
            return codice;
        }
        public Color getColore(){
            return colore;
        }

        public static TEAM_PLAYER byCodice(String codice) {
            for(TEAM_PLAYER enumItem : values()) {
                if(enumItem.getCodice() == null) {
                    if(codice == null) {
                        return enumItem;
                    }
                }else if(enumItem.getCodice().equals(codice)) {
                    return enumItem;
                }
            }
            return null;
        }
    }

    public static enum ROLE_PLAYER {
        PRESIDENTE("Presidente", "pres", "P"),
        BOMBAROLO("Bombarolo", "bomb", "B"),
        BASE("Base", "base", "s"),
        MOGLIE_PRESIDENTE("Moglie del presidente", "mogpres", "mp"),
        AMANTE_PRESIDENTE("Amante del presidente", "amapres", "ap"),
        NATO_LEADER("Nato leader", "natoleader", "nl");

        private String value;
        private String codice;
        private String sigla;

        private ROLE_PLAYER(String v, String c, String s) {
            value = v;
            codice = c;
            sigla = s;
        }

        @Override
        public String toString(){
            return codice;
        }
        public String getValue(){
            return value;
        }
        public String getCodice(){
            return codice;
        }
        public String getSigla(){
            return sigla;
        }

        public static ROLE_PLAYER byCodice(String codice) {
            for(ROLE_PLAYER enumItem : values()) {
                if(enumItem.getCodice() == null) {
                    if(codice == null) {
                        return enumItem;
                    }
                }else if(enumItem.getCodice().equals(codice)) {
                    return enumItem;
                }
            }
            return null;
        }
    }
}
