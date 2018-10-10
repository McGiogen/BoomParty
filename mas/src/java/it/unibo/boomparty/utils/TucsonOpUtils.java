package it.unibo.boomparty.utils;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.Logger;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.asynchSupport.actions.AbstractTucsonAction;
import alice.tucson.service.TucsonOpCompletionEvent;
import it.unibo.boomparty.agents.ITucsonAgent;
import it.unibo.boomparty.dao.ITuplable;
import it.unibo.boomparty.handlers.IHandlerOpCompletion;
import it.unibo.tucson.jade.coordination.AsynchTucsonOpResult;
import jade.core.ServiceException;
import jade.core.behaviours.Behaviour;

public class TucsonOpUtils {

    public static void actionSync(List<? extends ITuplable> daoList, Class<? extends AbstractTucsonAction> actionClass, Behaviour beha, IHandlerOpCompletion hand, ITucsonAgent agent, Logger log) {
        LogicTuple lt = daoListToLogicTuple(daoList, log);
        if (lt == null) {
            return;
        }
        actionSync(lt, actionClass, beha, hand, agent, log);
    }

    public static AsynchTucsonOpResult actionAsync(List<? extends ITuplable> daoList, Class<? extends AbstractTucsonAction> actionClass, ITucsonAgent agent, Logger log) {
        LogicTuple lt = daoListToLogicTuple(daoList, log);
        if (lt == null) {
            return null;
        }
        return actionAsync(lt, actionClass, agent, log);
    }

    public static void actionSync(ITuplable dao, Class<? extends AbstractTucsonAction> actionClass, Behaviour beha, IHandlerOpCompletion hand, ITucsonAgent agent, Logger log) {
        LogicTuple lt = daoToLogicTuple(dao, log);
        if (lt == null) {
            return;
        }
        actionSync(lt, actionClass, beha, hand, agent, log);
    }

    public static AsynchTucsonOpResult actionAsync(ITuplable dao, Class<? extends AbstractTucsonAction> actionClass, ITucsonAgent agent, Logger log) {
        LogicTuple lt = daoToLogicTuple(dao, log);
        if (lt == null) {
            return null;
        }
        return actionAsync(lt, actionClass, agent, log);
    }

    public static void actionSync(String tuple, Class<? extends AbstractTucsonAction> actionClass, Behaviour beha, IHandlerOpCompletion hand, ITucsonAgent agent, Logger log) {
        LogicTuple lt = stringToLogicTuple(tuple, log);
        if (lt == null) {
            return;
        }
        actionSync(lt, actionClass, beha, hand, agent, log);
    }

    public static AsynchTucsonOpResult actionAsync(String tuple, Class<? extends AbstractTucsonAction> actionClass, ITucsonAgent agent, Logger log) {
        LogicTuple lt = stringToLogicTuple(tuple, log);
        if (lt == null) {
            return null;
        }
        return actionAsync(lt, actionClass, agent, log);
    }

    public static void actionSync(LogicTuple lt, Class<? extends AbstractTucsonAction> actionClass, Behaviour beha, IHandlerOpCompletion hand, ITucsonAgent agent, Logger log) {
        AbstractTucsonAction action = instantiateAction(lt, actionClass, agent, log);
        if (action == null) {
            return;
        }
        actionSync(action, beha, hand, agent, log);
    }

    public static AsynchTucsonOpResult actionAsync(LogicTuple lt, Class<? extends AbstractTucsonAction> actionClass, ITucsonAgent agent, Logger log) {
        AbstractTucsonAction action = instantiateAction(lt, actionClass, agent, log);
        if (action == null) {
            return null;
        }
        return actionAsync(action, agent, log);
    }

    public static void actionSync(AbstractTucsonAction action, Behaviour beha, IHandlerOpCompletion hand, ITucsonAgent agent, Logger log) {
        try {
            TucsonOpCompletionEvent res = agent.getBridge().synchronousInvocation(action, Long.MAX_VALUE, beha);
            if (res != null) {
                if (hand != null) {
                    hand.handle(res);
                    agent.getBridge().clearTucsonOpResult(beha);
                }
            } else {
                log.debug("Operazione sincrona in attesa...");
                beha.block();
            }
        } catch (ServiceException e) {
            log.error("Errore esecuzione durante l'esecuzione dell'azione sincrona " + e.getMessage());
        }
    }

    public static AsynchTucsonOpResult actionAsync(AbstractTucsonAction action, ITucsonAgent agent, Logger log) {
        AsynchTucsonOpResult res = null;
        try {
            res = agent.getBridge().asynchronousInvocation(action);
        } catch (ServiceException e) {
            log.error("Errore esecuzione durante l'esecuzione dell'azione asincrona " + e.getMessage());
        }
        return res;
    }

    /***************** PRIVATE METHODS *****************/

    private static LogicTuple stringToLogicTuple(String tuple, Logger log) {
        try {
            return LogicTuple.parse(tuple);
        } catch (InvalidLogicTupleException e) {
            log.error("Errore parsing tupla " + e.getMessage());
            return null;
        }
    }

    private static LogicTuple daoListToLogicTuple(List<? extends ITuplable> daoList, Logger log) {
        try {
            List<LogicTuple> tupleList = new ArrayList<>(daoList.size());
            for (int i = 0; i < daoList.size(); i++) {
                tupleList.add(daoList.get(i).toTuple());
            }
            return LogicTuple.parse(tupleList.toString());
        } catch (InvalidLogicTupleException e) {
            log.error("Errore creazione tupla da dao " + e.getMessage());
            return null;
        }
    }

    private static LogicTuple daoToLogicTuple(ITuplable dao, Logger log) {
        try {
            return dao.toTuple();
        } catch (InvalidLogicTupleException e) {
            log.error("Errore creazione tupla da dao " + e.getMessage());
            return null;
        }
    }

    private static AbstractTucsonAction instantiateAction(LogicTuple lt, Class<? extends AbstractTucsonAction> actionClass, ITucsonAgent agent, Logger log) {
        try {
            return actionClass
                    .getConstructor(TucsonTupleCentreId.class, LogicTuple.class)
                    .newInstance(agent.getTucsonTupleCentreId(), lt);
        } catch (InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException
                | NoSuchMethodException | SecurityException e) {
            log.error("Errore istanziazione AbstractTucsonAction " + e.getMessage());
            return null;
        }
    }
}
