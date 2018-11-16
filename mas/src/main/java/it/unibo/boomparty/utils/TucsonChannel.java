package it.unibo.boomparty.utils;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;
import alice.tucson.api.*;
import alice.tucson.asynchSupport.AsynchOpsHelper;
import alice.tucson.asynchSupport.actions.AbstractTucsonAction;
import alice.tuplecentre.api.exceptions.InvalidOperationException;
import alice.tuplecentre.core.AbstractTupleCentreOperation;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.lang.reflect.InvocationTargetException;

/**
 * Apre un canale di comunicazione verso il tuple centre
 */
public class TucsonChannel {

    private static Logger log = LogManager.getLogger();

    private TucsonTupleCentreId ttci;
    private EnhancedACC eACC;
    private AsynchOpsHelper asyncHelper;

    public TucsonChannel(String channelName, TucsonTupleCentreId ttci) {

        TucsonAgentId taid = null;
        try {
            taid = new TucsonAgentId(channelName);
            NegotiationACC nACC = TucsonMetaACC.getNegotiationContext(taid);

            eACC = nACC.playDefaultRole();
            this.ttci = ttci;
            //this.ttci = new TucsonTupleCentreId("default", "localhost", "20504");
            asyncHelper = new AsynchOpsHelper("'helper4" + taid + "'");

            // eACC.exit();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public ITucsonOperation actionSynch(Class<? extends AbstractTucsonAction> actionClass, String tuple) {
        try {
            LogicTuple lt = LogicTuple.parse(tuple);
            return actionSynch(actionClass, lt);
        } catch (InvalidLogicTupleException e) {
            e.printStackTrace();
            log.error("Errore durante il parse della tupla > " + tuple);
        }
        return null;
    }

    public ITucsonOperation actionSynch(Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt) {
        try {
            AbstractTucsonAction action = instantiateAction(ttci, actionClass, lt);
            ITucsonOperation tucsonOperation;
            if (action != null) {
                tucsonOperation = action.executeSynch(eACC, null);
                return tucsonOperation;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void actionAsync(Class<? extends AbstractTucsonAction> actionClass, String tuple) {
        try {
            LogicTuple lt = LogicTuple.parse(tuple);
            actionAsync(actionClass, lt);
        } catch (InvalidLogicTupleException e) {
            e.printStackTrace();
            log.error("Errore durante il parse della tupla > " + tuple);
        }
    }

    public void actionAsync(Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt) {
        AbstractTucsonAction action = instantiateAction(ttci, actionClass, lt);
        asyncHelper.enqueue(action, new TucsonOperationCompletionListener() {

            @Override
            public void operationCompleted(ITucsonOperation iTucsonOperation) {

            }

            @Override
            public void operationCompleted(AbstractTupleCentreOperation op) {
                if (op.isResultSuccess()) {
                    try {
                        LogicTuple res = (LogicTuple)op.getTupleResult();
                        //int res = Integer.parseInt(var2.getArg(0).toString());
                        log.info("Async op terminated successfully..");
                    } catch (NumberFormatException | InvalidOperationException e) {
                        e.printStackTrace();
                    }
                } else {
                    log.info("Async op isResultSuccess false..");
                }
            }
        });
    }

    private AbstractTucsonAction instantiateAction(TucsonTupleCentreId ttci, Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt) {
        try {
            return actionClass
                    .getConstructor(TucsonTupleCentreId.class, LogicTuple.class)
                    .newInstance(ttci, lt);
        } catch (InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException
                | NoSuchMethodException | SecurityException e) {
            log.error("Errore istanziazione AbstractTucsonAction " + e.getMessage());
            return null;
        }
    }

}
