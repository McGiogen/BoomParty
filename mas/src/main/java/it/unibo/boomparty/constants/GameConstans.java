package it.unibo.boomparty.constants;

public class GameConstans {

    public static enum TEAM_PLAYER {
        ROSSO("Rosso", "rosso"),
        BLU("Blu", "blu"),
        GRIGIO("Grigio", "grigio");

        private String value;
        private String codice;

        private TEAM_PLAYER(String v, String c) {
            value = v;
            codice = c;
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

        public static TEAM_PLAYER byCodice(String codice) {
            for(TEAM_PLAYER enumItem : values()) {
                if(enumItem.getValue() == null) {
                    if(codice == null) {
                        return enumItem;
                    }
                }else if(enumItem.getValue().equals(codice)) {
                    return enumItem;
                }
            }
            return null;
        }
    }

    public static enum ROLE_PLAYER {
        PRESIDENTE("Presidente", "pres"),
        BOMBAROLO("Bombarolo", "bomb"),
        BASE("Base", "base"),
        MOGLIE_PRESIDENTE("Moglie del presidente", "mogpres"),
        AMANTE_PRESIDENTE("Amante del presidente", "amapres"),
        MAMMA_BOMBAROLO("Mamma del bombarolo", "mamma");

        private String value;
        private String codice;

        private ROLE_PLAYER(String v, String c) {
            value = v;
            codice = c;
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

        public static ROLE_PLAYER byCodice(String codice) {
            for(ROLE_PLAYER enumItem : values()) {
                if(enumItem.getValue() == null) {
                    if(codice == null) {
                        return enumItem;
                    }
                }else if(enumItem.getValue().equals(codice)) {
                    return enumItem;
                }
            }
            return null;
        }
    }
}
