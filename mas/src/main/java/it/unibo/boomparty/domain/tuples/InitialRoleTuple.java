package it.unibo.boomparty.domain.tuples;

import alice.logictuple.LogicTuple;
import alice.logictuple.exceptions.InvalidLogicTupleException;
import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;

import java.util.List;

public class InitialRoleTuple extends BaseTuple {

    public static final String TEMPLATE = asTupleString("GT", "GB", "GT");

    private List<ROLE_PLAYER> redTeam;
    private List<ROLE_PLAYER> blueTeam;
    private List<ROLE_PLAYER> greyTeam;

    public InitialRoleTuple(List<ROLE_PLAYER> redTeam, List<ROLE_PLAYER> blueTeam, List<ROLE_PLAYER> greyTeam) {
        super();

        this.redTeam = redTeam;
        this.blueTeam = blueTeam;
        this.greyTeam = greyTeam;
    }

    @Override
    public LogicTuple toTuple() throws InvalidLogicTupleException {
        return toTuple(null, null, null);
    }

    public LogicTuple toTuple(String tRedTeam, String tBlueTeam, String tGreyTeam) throws InvalidLogicTupleException {
        String redTAt = toProlog(this.getRedTeam().toString(), tRedTeam);
        String blueTAt = toProlog(this.getBlueTeam().toString(), tBlueTeam);
        String greyTAt = toProlog(this.getGreyTeam().toString(), tGreyTeam);

        return LogicTuple.parse(asTupleString(redTAt, blueTAt, greyTAt));
    }

    public static String asTupleString(String redTeam, String blueTeam, String greyTeam) {
        return ("initialRole(redTeam(" + redTeam + "), blueTeam(" + blueTeam + "), greyTeam(" + greyTeam + "))").replaceAll("\\s+", "");
    }

    @Override
    public void fillFromTuple(LogicTuple tuple) {
        // TODO LUCA
        /*
        this.redTeam = new ArrayList<ROLE_PLAYER>();
        TupleArgument redArrT = tuple.getArg("redTeam");
        TupleArgument ar = redArrT.getArg(0);
        ar.toArray();
        Struct.
        /*
        for(Term term : redArrT) {
            redTeam.add(ROLE_PLAYER.byCodice(term.toString()));
        }/*
        this.redTeam = TupleUtils.stringValue(tuple.getArg("name").getArg(0));
        this.blueTeam = TupleUtils.stringValue(tuple.getArg("room").getArg(0));
        this.greyTeam = ;*/
    }

    @Override
    public String getTemplate() {
        return TEMPLATE;
    }

    public List<ROLE_PLAYER> getRedTeam() {
        return this.redTeam;
    }
    public void setRedTeam(List<ROLE_PLAYER> redTeam) {
        this.redTeam = redTeam;
    }
    public List<ROLE_PLAYER> getBlueTeam() {
        return this.blueTeam;
    }
    public void setBlueTeam(List<ROLE_PLAYER> blueTeam) {
        this.blueTeam = blueTeam;
    }
    public List<ROLE_PLAYER> getGreyTeam() {
        return this.greyTeam;
    }
    public void setGreyTeam(List<ROLE_PLAYER> greyTeam) {
        this.greyTeam = greyTeam;
    }
}
