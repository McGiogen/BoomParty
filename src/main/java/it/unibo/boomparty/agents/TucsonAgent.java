package it.unibo.boomparty.agents;

import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import alice.logictuple.LogicTuple;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.api.exceptions.TucsonInvalidAgentIdException;
import alice.tucson.api.exceptions.TucsonInvalidTupleCentreIdException;
import alice.tucson.asynchSupport.actions.AbstractTucsonAction;
import alice.tuprolog.InvalidTermException;
import it.unibo.boomparty.dao.ITuplable;
import it.unibo.boomparty.handlers.IHandlerOpCompletion;
import it.unibo.boomparty.utils.TucsonOpUtils;
import it.unibo.tucson.jade.coordination.AsynchTucsonOpResult;
import it.unibo.tucson.jade.exceptions.CannotAcquireACCException;
import it.unibo.tucson.jade.glue.BridgeToTucson;
import it.unibo.tucson.jade.service.TucsonHelper;
import it.unibo.tucson.jade.service.TucsonService;
import jade.core.ServiceException;
import jade.core.behaviours.Behaviour;

public abstract class TucsonAgent extends BaseAgent implements ITucsonAgent {

    private static final long serialVersionUID = -8428212545646326170L;
    private static Logger log = LogManager.getLogger();

    /* -- Tucson Interaction -- */
    private BridgeToTucson bridge;
    private TucsonHelper helper;

    /*
     * ID of tuple centre used for objective coordination
     */
    private TucsonTupleCentreId tcid;

    @Override
    protected void setup() {
        super.setup();
        bootstrapTucsonInteraction();
    }

    /**
     * Abilita la comunicazione con tucson
     */
    protected void bootstrapTucsonInteraction() {
        try {

            /*
             * build the tuple centre id
             */
            this.tcid = new TucsonTupleCentreId(getTucsonNode());

            /*
             * First of all, get the helper for the service you want to exploit
             */
            this.helper = (TucsonHelper) this.getHelper(TucsonService.NAME);

            /*
             * Obtain ACC (which is actually given to the bridge, not directly
             * to your agent)
             */
            this.helper.acquireACC(this, tcid.getNode(), tcid.getPort());

            /*
             * Get the univocal bridge for the agent. Now, mandatory, set-up
             * actions have been carried out and you are ready to coordinate
             */
            this.bridge = this.helper.getBridgeToTucson(this);

        } catch (final ServiceException e) {
            log.error(">>> No TuCSoN service active, reboot JADE with -services it.unibo.tucson.jade.service.TucsonService option <<<");
            this.doDelete();
        } catch (final TucsonInvalidAgentIdException | InvalidTermException e) {
            log.error(">>> TuCSoN Agent ids should be compliant with Prolog sytnax (start with lowercase letter, no special symbols), choose another agent id <<<");
            this.doDelete();
        } catch (final TucsonInvalidTupleCentreIdException e) {
            // should not happen
            log.error("Errore: " + e.getMessage());
            log.debug(e.getStackTrace());
            this.doDelete();
        } catch (final CannotAcquireACCException e) {
            // should not happen
            log.error("Errore: " + e.getMessage());
            log.debug(e.getStackTrace());
            this.doDelete();
        }
    }

    public BridgeToTucson getBridge() {
        return bridge;
    }

    protected String getTucsonNode() {
        return (String) getArguments()[0];
    }

    public TucsonTupleCentreId getTucsonTupleCentreId() {
        return tcid;
    }

    // TUCSON OP METHODS

    @Override
    public void actionSync(Class<? extends AbstractTucsonAction> actionClass, List<? extends ITuplable> daoList, IHandlerOpCompletion hand, Behaviour beha) {
        TucsonOpUtils.actionSync(daoList, actionClass, beha, hand, this, log);
    }

    @Override
    public AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, List<? extends ITuplable> daoList) {
        return TucsonOpUtils.actionAsync(daoList, actionClass, this, log);
    }

    @Override
    public void actionSync(Class<? extends AbstractTucsonAction> actionClass, ITuplable dao, IHandlerOpCompletion hand, Behaviour beha) {
        TucsonOpUtils.actionSync(dao, actionClass, beha, hand, this, log);
    }

    @Override
    public AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, ITuplable dao) {
        return TucsonOpUtils.actionAsync(dao, actionClass, this, log);
    }

    @Override
    public void actionSync(Class<? extends AbstractTucsonAction> actionClass, String tuple, IHandlerOpCompletion hand, Behaviour beha) {
        TucsonOpUtils.actionSync(tuple, actionClass, beha, hand, this, log);
    }

    @Override
    public AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, String tuple) {
        return TucsonOpUtils.actionAsync(tuple, actionClass, this, log);
    }

    @Override
    public void actionSync(Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt, IHandlerOpCompletion hand, Behaviour beha) {
        TucsonOpUtils.actionSync(lt, actionClass, beha, hand, this, log);
    }

    @Override
    public AsynchTucsonOpResult actionAsync(Class<? extends AbstractTucsonAction> actionClass, LogicTuple lt) {
        return TucsonOpUtils.actionAsync(lt, actionClass, this, log);
    }
}
