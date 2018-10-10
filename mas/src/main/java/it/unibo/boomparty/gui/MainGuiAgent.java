package it.unibo.boomparty.gui;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.boomparty.agents.TucsonGuiAgent;
import jade.gui.GuiEvent;
import jade.wrapper.AgentContainer;

public class MainGuiAgent extends TucsonGuiAgent implements IMainGuiController {

    private static final long serialVersionUID = 7459623051523250299L;
    private MainWindow mainWindow;
    private static Logger log = LogManager.getLogger();

    public MainGuiAgent() {
        this.mainWindow = new MainWindow(this);
//        this.addBehaviour(new ReadRoomsBehaviour(this::updateRoomsTable));
    }

    /*
     * Automagically called by JADE platform to handle GUI-generated events. In
     * particular, it is called right after method <postGuiEvent()> returns.
     */
    @Override
    protected void onGuiEvent(GuiEvent e) {

    }

//    private void updateRoomsTable(List<RoomDAO> rooms) {
//        this.mainWindow.getRoomsManagerPane().setRooms(rooms);
//    }

    @Override
    public AgentContainer getMainAgentContainer() {
        return this.getContainerController();
    }
}

