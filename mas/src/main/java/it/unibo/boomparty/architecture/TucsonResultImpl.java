package it.unibo.boomparty.architecture;

import alice.tuplecentre.api.Tuple;
import it.unibo.tucson4jason.operations.TucsonResult;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Copia di TucsonResultImpl di t4jn
 */
public class TucsonResultImpl implements TucsonResult {
    private List<Tuple> tuples;
    private Tuple tuple;

    public TucsonResultImpl(List<Tuple> var1) {
        this.tuples = var1;
        this.tuple = null;
    }

    public TucsonResultImpl(Tuple var1) {
        this.tuple = var1;
        this.tuples = null;
    }

    public final List<Tuple> getTuples() {
        return this.tuples;
    }

    public final Tuple getTuple() {
        return this.tuple;
    }

    public final boolean isList() {
        return this.tuples != null;
    }

    public String toString() {
        return this.isList() ? (String)this.tuples.stream().map((var0) -> {
            return var0.toString();
        }).collect(Collectors.joining(", ", "[ ", " ]")) : this.tuple.toString();
    }
}
