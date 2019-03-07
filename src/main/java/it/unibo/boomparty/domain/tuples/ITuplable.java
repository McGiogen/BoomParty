package it.unibo.boomparty.domain.tuples;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;

public interface ITuplable {

    LogicTuple toTuple() throws InvalidLogicTupleException;

    void fillFromTuple(LogicTuple tuple);

    String getTemplate();
}
