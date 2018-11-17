package it.unibo.tucson4jason.architecture;

import alice.tucson.asynchSupport.AsynchOpsHelper;
import alice.tucson.asynchSupport.actions.AbstractTucsonOrdinaryAction;
import it.unibo.tucson4jason.architecture.T4JnArch;
import it.unibo.tucson4jason.architecture.T4JnArchImpl;
import it.unibo.tucson4jason.architecture.TucsonResultsHandler;
import it.unibo.tucson4jason.operations.TucsonResult;
import jaca.CAgentArch;
import jason.architecture.AgArch;
import jason.asSemantics.ActionExec;
import jason.asSemantics.Intention;
import jason.asSemantics.TransitionSystem;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Logger;

/**
 * Architettura personalizzata per permettere agli agenti di lavorare sia con
 * gli artefatti che col tuple space
 */
public class BoomPartyAgentArch extends CAgentArch implements T4JnArch {

    private static final String VERSION = "TuCSoN4Jason-1.0";
    private static AtomicBoolean first = new AtomicBoolean(true);
    private final boolean logEnabled = true;
    private final Logger logger = Logger.getLogger(this.getClass().getSimpleName());
    private long counter;
    private AsynchOpsHelper helper;
    private Map<Long, TucsonResult> results;
    private Map<Long, Intention> suspendedIntentions;
    private Lock mutex;

    public BoomPartyAgentArch() {}

    @Override
    public void init() throws Exception {
        // Init di CAgentArch
        super.init();

        if (first.compareAndSet(true, false)) {
            this.logHeader();
        }

        this.counter = 0L;
        this.helper = new AsynchOpsHelper("helper4" + this.getAgName());
        this.results = new HashMap();
        this.suspendedIntentions = new HashMap();
        this.mutex = new ReentrantLock(true);
    }

    public final long addTucsonOperationRequest(AbstractTucsonOrdinaryAction var1) {
        AsynchOpsHelper var10000 = this.helper;
        long var10004 = this.counter;
        AsynchOpsHelper var10005 = this.helper;
        Map var10006 = this.results;
        Map var10007 = this.suspendedIntentions;
        Lock var10008 = this.mutex;
        TransitionSystem var10009 = this.getTS();
        this.getClass();
        var10000.enqueue(var1, new TucsonResultsHandler(var10004, var10005, var10006, var10007, var10008, var10009, true));
        return (long)(this.counter++);
    }

    private void logHeader() {
        this.log("--------------------------------------------------------------------------------");
        this.log("Welcome to the TuCSoN4Jason (t4jn) bridge :)");
        this.log("  t4jn version " + getVersion());
        this.log((new Date()).toString());
        this.log("--------------------------------------------------------------------------------");
    }

    public final Map<Long, TucsonResult> getResults() {
        return this.results;
    }

    public final Map<Long, Intention> getSuspendedIntentions() {
        return this.suspendedIntentions;
    }

    public final Lock getMutex() {
        return this.mutex;
    }

    private static String getVersion() {
        return "TuCSoN4Jason-1.0";
    }

    private final void log(String var1) {
        this.getClass();
        this.logger.info(var1);
    }

    public void act(ActionExec action) {
        AgArch successor = this.getNextAgArch();
        if (successor != null) {
            successor.act(action);
        }
        super.act(action);
    }
}
