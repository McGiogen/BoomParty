package it.unibo.boomparty.dao;

import java.io.Serializable;
import java.util.Optional;

import alice.logictuple.LogicTuple;

public abstract class BaseDAO implements Serializable, ITuplable {
    private static final long serialVersionUID = -3131477869418759018L;

    public BaseDAO() {}

    public BaseDAO(LogicTuple tuple) {
        fillFromTuple(tuple);
    }

    protected static String toProlog(String text, String token) {
        String prologValue = text != null ? "'" + text + "'" : "null";
        return toPrologBase(prologValue, token);
    }

    protected static String toProlog(Integer value, String token) {
        String prologValue = String.valueOf(value);
        return toPrologBase(prologValue, token);
    }

    protected static String toProlog(Double value, String token) {
        String prologValue = String.valueOf(value);
        return toPrologBase(prologValue, token);
    }

    private static String toPrologBase(String prologValue, String token) {
        return Optional.ofNullable(token).orElse(prologValue);
    }
}
