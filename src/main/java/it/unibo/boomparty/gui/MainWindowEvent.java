package it.unibo.boomparty.gui;

public enum MainWindowEvent {
    SIM_PARAMS_CHANGED,
    CLOSE_GUI;

    private int value;

    public int getValue() {
        return value;
    }

    private void setValue(int v) {
        this.value = v;
    }

    public boolean equals(int value) {
        return this.getValue() == value;
    }

    public static MainWindowEvent byValue(int value) {
        for (MainWindowEvent enumItem : values()) {
            if (enumItem.equals(value)) {
                return enumItem;
            }
        }
        return null;
    }

    /**
     * Assegno un valore univoco ad ogni enumeratore.
     * @see https://stackoverflow.com/a/536461/3687018
     */
    static
    {
        int nextValue = 1;
        for (MainWindowEvent enumItem: values()) {
            enumItem.setValue(nextValue);
            nextValue++;
        }
    }
}


