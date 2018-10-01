package it.unibo.boomparty.agents;


import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import jade.domain.DFService;
import jade.domain.FIPAException;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;
import jade.gui.GuiAgent;

public abstract class BaseGuiAgent extends GuiAgent implements IBaseAgent {

    private static final long serialVersionUID = 1405882603898476866L;
    private static Logger log = LogManager.getLogger();

    @Override
    protected void setup() {
        super.setup();
    }

    @Override
    protected void takeDown() {
        //destroyDFService();
        super.takeDown();
    }

    protected void registerDFService(String serviceType) {
        registerDFService(serviceType, null, null);
    }

    protected void registerDFService(String serviceType, String owner, String serviceName) {
        try {
            DFAgentDescription dfd = new DFAgentDescription();
            dfd.setName(getAID());

            ServiceDescription sd = new ServiceDescription();
            sd.setType(serviceType);
            sd.setName(serviceName);
            if(owner != null) {
                sd.setOwnership(owner);
            }
            dfd.addServices(sd);

            DFService.register(this, dfd);
        } catch (FIPAException fe) {
            log.error("errore durante la registrazione del DF: " + fe.getMessage());
        }
    }

    protected void destroyDFService() {
        try {
            DFService.deregister(this);
        } catch (FIPAException fe) {
            log.error("errore durante la deregistrazione del DF: " + fe.getMessage());
        }
    }
}
