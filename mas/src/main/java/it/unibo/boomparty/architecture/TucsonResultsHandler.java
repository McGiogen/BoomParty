package it.unibo.boomparty.architecture;

import alice.logictuple.LogicTuple;
import alice.tucson.api.ITucsonOperation;
import alice.tucson.api.TucsonOperationCompletionListener;
import alice.tucson.asynchSupport.AsynchOpsHelper;
import alice.tuplecentre.core.AbstractTupleCentreOperation;
import it.unibo.tucson4jason.operations.TucsonResult;
import jason.asSemantics.Circumstance;
import jason.asSemantics.Intention;
import jason.asSemantics.TransitionSystem;
import jason.asSyntax.*;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.logging.Logger;

/**
 * Copia di TucsonResultsHandler di t4jn
 */
public class TucsonResultsHandler implements TucsonOperationCompletionListener {
    private boolean logEnabled = true;
    private final Logger logger = Logger.getLogger(this.getClass().getSimpleName());
    private long actionId;
    private AsynchOpsHelper helper;
    private Map<Long, TucsonResult> results;
    private Map<Long, Intention> suspendedIntentions;
    private Lock mutex;
    private TransitionSystem ts;

    public TucsonResultsHandler(long var1, AsynchOpsHelper var3, Map<Long, TucsonResult> var4, Map<Long, Intention> var5, Lock var6, TransitionSystem var7, boolean var8) {
        this.actionId = var1;
        this.helper = var3;
        this.results = var4;
        this.suspendedIntentions = var5;
        this.mutex = var6;
        this.ts = var7;
        this.logEnabled = var8;
    }

    public final void operationCompleted(AbstractTupleCentreOperation var1) {
        TucsonResultImpl var2;
        if (var1.getTupleListResult() == null) {
            var2 = new TucsonResultImpl(var1.getTupleResult());
        } else {
            ArrayList var3 = new ArrayList();
            var3.addAll(var1.getTupleListResult());
            var2 = new TucsonResultImpl(var3);
        }

        this.log("Operation #" + this.actionId + " completed with result: " + var2);
        this.helper.getCompletedOps().removeOpById(var1.getId());
        this.mutex.lock();
        if (!this.suspendedIntentions.containsKey(this.actionId)) {
            this.results.put(this.actionId, var2);
            this.mutex.unlock();
        } else {
            Intention var10 = (Intention)this.suspendedIntentions.remove(this.actionId);
            this.mutex.unlock();
            Object var4;
            if (!var2.isList()) {
                LogicTuple var5 = (LogicTuple)var2.getTuple();
                Literal var6 = Literal.parseLiteral(var5.toString());
                var4 = var6;
            } else {
                ListTerm var11 = ListTermImpl.parseList(var2.getTuples().toString());
                var4 = var11;
            }

            Circumstance var12 = this.ts.getC();
            Iterator var13 = var12.getPendingIntentions().keySet().iterator();

            while(var13.hasNext()) {
                String var7 = (String)var13.next();
                if (var7.startsWith("suspended-")) {
                    Intention var8 = (Intention)var12.getPendingIntentions().get(var7);
                    if (var8.equals(var10)) {
                        var8.setSuspended(false);
                        var13.remove();
                        if (var7.startsWith("suspended-self-")) {
                            Structure var9 = (Structure)var8.peek().removeCurrentStep();
                            var8.peek().getUnif().unifies(var9.getTerm(1), (Term)var4);
                        }

                        if (!var12.getPendingActions().containsKey(var8.getId())) {
                            var12.resumeIntention(var8);
                        }
                    }
                }
            }
        }

    }

    public void operationCompleted(ITucsonOperation var1) {
    }

    protected final void log(String var1) {
        if (this.logEnabled) {
            this.logger.info(var1);
        }

    }
}
