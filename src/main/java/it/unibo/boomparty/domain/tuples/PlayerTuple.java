package it.unibo.boomparty.domain.tuples;

import it.unibo.boomparty.utils.TupleUtils;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;

public class PlayerTuple extends BaseTuple {

    public static final String TEMPLATE = asTupleString("X", "Y");

    private String name;
    private String room;

    public PlayerTuple(String name, String room) {
        super();

        this.name = name;
        this.room = room;
    }

    @Override
    public LogicTuple toTuple() throws InvalidLogicTupleException {
        return toTuple(null, null);
    }

    public LogicTuple toTuple(String tName, String tRoom) throws InvalidLogicTupleException {
        String name = toProlog(this.getName(), tName);
        String room = toProlog(this.getRoom(), tRoom);

        return LogicTuple.parse(asTupleString(name, room));
    }

    public static String asTupleString(String name, String room) {
        return "player(name(" + name + "),room(" + room + "))";
    }

    @SuppressWarnings("unchecked")
    @Override
    public void fillFromTuple(LogicTuple tuple) {
        this.name = TupleUtils.stringValue(tuple.getArg("name").getArg(0));
        this.room = TupleUtils.stringValue(tuple.getArg("room").getArg(0));
    }

    @Override
    public String getTemplate() {
        return TEMPLATE;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRoom() {
        return room;
    }

    public void setRoom(String room) {
        this.room = room;
    }

}
