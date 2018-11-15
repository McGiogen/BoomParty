package it.unibo.boomparty.domain.tuples;

import alice.logictuple.LogicTuple;

import java.util.Optional;

public abstract class BaseTuple implements ITuplable {

    public BaseTuple() {}

    public BaseTuple(LogicTuple tuple) {
        fillFromTuple(tuple);
    }

    protected String toProlog(String text, String token) {
        String prologValue = text != null ? "'" + text + "'" : "null";
        return toPrologBase(prologValue, token);
    }

    protected String toProlog(Integer value, String token) {
        String prologValue = String.valueOf(value);
        return toPrologBase(prologValue, token);
    }

    protected String toProlog(Double value, String token) {
        String prologValue = String.valueOf(value);
        return toPrologBase(prologValue, token);
    }

    private String toPrologBase(String prologValue, String token) {
        return Optional.ofNullable(token).orElse(prologValue);
    }
}
