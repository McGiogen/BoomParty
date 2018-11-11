package t4jn.api;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.asynchSupport.actions.AbstractTucsonOrdinaryAction;
import alice.tucson.asynchSupport.actions.ordinary.In;
import alice.tucson.asynchSupport.actions.ordinary.uniform.Uin;
import jason.asSyntax.Term;

public class uin extends TucsonInternalActionImpl {

    private static final long serialVersionUID = 1L;
    protected static final int RESULT_ARG_INDEX = 4;
    protected static final int TUPLE_ARG_INDEX = 3;

    public uin() {
    }

    protected final AbstractTucsonOrdinaryAction generateTucsonOperation(Term[] var1, TucsonTupleCentreId var2) throws InvalidLogicTupleException {
        LogicTuple var3 = LogicTuple.parse(var1[3].toString());
        return new Uin(var2, var3);
    }

    protected final int getNumberOfArguments() {
        return 5;
    }

    protected final int getResultArgumentIndex() {
        return 4;
    }
}
