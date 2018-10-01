package it.unibo.boomparty.agents;

import java.util.List;

import alice.logictuple.LogicTuple;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.asynchSupport.actions.AbstractTucsonAction;
import it.unibo.boomparty.dao.ITuplable;
import it.unibo.boomparty.handlers.IHandlerOpCompletion;
import it.unibo.tucson.jade.coordination.AsynchTucsonOpResult;
import it.unibo.tucson.jade.glue.BridgeToTucson;
import jade.core.behaviours.Behaviour;

public interface ITucsonAgent extends IBaseAgent {
    BridgeToTucson getBridge();
    TucsonTupleCentreId getTucsonTupleCentreId();

    void actionSync(Class<? extends AbstractTucsonAction> actionClass, List<? extends ITuplable> daoList, IHandlerOpCompletion hand, Behaviour beha);
    AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, List<? extends ITuplable> daoList);
    void actionSync(Class<? extends AbstractTucsonAction> actionClass, ITuplable dao, IHandlerOpCompletion hand, Behaviour beha);
    AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, ITuplable dao);
    void actionSync(Class<? extends AbstractTucsonAction> actionClass, String tuple, IHandlerOpCompletion hand, Behaviour beha);
    AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, String tuple);
    void actionSync(Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt, IHandlerOpCompletion hand, Behaviour beha);
    AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt);
}

