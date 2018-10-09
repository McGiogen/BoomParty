package it.unibo.boomparty.gui;

import jade.gui.GuiEvent;
import jade.wrapper.AgentContainer;

public interface IMainGuiController {

    /*
     * Already present in JADE GuiAgent class, used by the GUI.
     */
    void postGuiEvent(GuiEvent e);

    AgentContainer getMainAgentContainer();
}
