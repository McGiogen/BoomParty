package it.unibo.boomparty.agents.architecture;

import alice.tucson.asynchSupport.actions.AbstractTucsonOrdinaryAction;
import it.unibo.tucson4jason.architecture.T4JnArch;
import it.unibo.tucson4jason.architecture.T4JnArchImpl;
import it.unibo.tucson4jason.operations.TucsonResult;
import jaca.CAgentArch;
import jason.asSemantics.Intention;

import java.util.Map;
import java.util.concurrent.locks.Lock;

/**
 * Architettura personalizzata per permettere agli agenti di lavorare sia con
 * gli artefatti che col tuple space
 */
public class BoomPartyAgentArch extends CAgentArch implements T4JnArch {

    // t4jn arch
    private T4JnArchImpl internalT4JnArch;

    public BoomPartyAgentArch() {
        internalT4JnArch = new T4JnArchImpl();
    }

    @Override
    public void init() throws Exception {
        // Init di CAgentArch
        super.init();

        // t4jn init
        internalT4JnArch.init();
    }


    // T4Jn Specification

    public final long addTucsonOperationRequest(AbstractTucsonOrdinaryAction var1) {
        return internalT4JnArch.addTucsonOperationRequest(var1);
    }

    public final Map<Long, TucsonResult> getResults() {
        return internalT4JnArch.getResults();
    }

    public final Map<Long, Intention> getSuspendedIntentions() {
        return internalT4JnArch.getSuspendedIntentions();
    }

    public final Lock getMutex() {
        return internalT4JnArch.getMutex();
    }

}
