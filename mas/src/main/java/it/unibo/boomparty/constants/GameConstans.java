package it.unibo.boomparty.constants;

public class GameConstans {

    public static enum TEAM_PLAYER {
        ROSSO("Rosso"),
        BLU("Blu"),
        GRIGIO("Grigio");

        private String value;

        private TEAM_PLAYER(String v) {
            value = v;
        }

        @Override
        public String toString(){
            return value;
        }
        public String getValue(){
            return value;
        }

        public static TEAM_PLAYER byValue(String value) {
            for(TEAM_PLAYER enumItem : values()) {
                if(enumItem.getValue() == null) {
                    if(value == null) {
                        return enumItem;
                    }
                }else if(enumItem.getValue().equals(value)) {
                    return enumItem;
                }
            }
            return null;
        }
    }

    public static enum ROLE_PLAYER {
        PRESIDENTE("Presidente"),
        BOMBAROLO("Bombarolo"),
        BASE("Base"),
        MOGLIE_PRESIDENTE("Moglie del presidente"),
        AMANTE_PRESIDENTE("Amante del presidente"),
        MAMMA_BOMBAROLO("Mamma del bombarolo");

        private String value;

        private ROLE_PLAYER(String v) {
            value = v;
        }

        @Override
        public String toString(){
            return value;
        }
        public String getValue(){
            return value;
        }

        public static ROLE_PLAYER byValue(String value) {
            for(ROLE_PLAYER enumItem : values()) {
                if(enumItem.getValue() == null) {
                    if(value == null) {
                        return enumItem;
                    }
                }else if(enumItem.getValue().equals(value)) {
                    return enumItem;
                }
            }
            return null;
        }
    }
}
