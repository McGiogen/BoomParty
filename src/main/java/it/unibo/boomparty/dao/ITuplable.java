package it.unibo.boomparty.dao;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;

public interface ITuplable {

    public LogicTuple toTuple() throws InvalidLogicTupleException;

    public void fillFromTuple(LogicTuple tuple);

    public String getTemplate();
}
