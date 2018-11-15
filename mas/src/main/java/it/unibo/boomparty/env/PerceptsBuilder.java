package it.unibo.boomparty.env;

import jason.asSyntax.*;
import jason.environment.grid.Location;
import jason.util.Pair;

import java.util.List;
import java.util.stream.Collectors;

public class PerceptsBuilder {
    // belief literals

    /**
     * @param value name value
     * @return literal name("value")
     */
    public static Literal name(String value) {
        LiteralImpl name = new LiteralImpl("name");
        name.addTerm(new StringTermImpl(value));
        return name;
    }

    /**
     * @param atom role atom
     * @return literal team(atom)
     */
    public static Literal team(String atom) {
        LiteralImpl team = new LiteralImpl("team");
        team.addTerm(new Atom(atom));
        return team;
    }

    /**
     * @param atom role atom
     * @return literal role(atom)
     */
    public static Literal role(String atom) {
        LiteralImpl role = new LiteralImpl("role");
        role.addTerm(new Atom(atom));
        return role;
    }

    /**
     * Returns the literal to tell the area in which an agent is.
     * @param atom name of a place (roomA, roomB, hallway)
     * @return literal area(atom)
     */
    public static Literal area(String atom) {
        LiteralImpl area = new LiteralImpl("area");
        area.addTerm(new Atom(atom));
        return area;
    }

    /**
     * @param location position
     * @return literal position(x,y)
     */
    public static Literal position(Location location) {
        LiteralImpl position = new LiteralImpl("position");
        position.addTerms(
            new NumberTermImpl(location.x),
            new NumberTermImpl(location.y)
        );
        return position;
    }

    /**
     * @param value integer percent of confidence
     * @return literal confidence(value)
     */
    public static Literal confidence(int value) {
        LiteralImpl confidence = new LiteralImpl("confidence");
        confidence.addTerm(new NumberTermImpl(value));
        return confidence;
    }

    /**
     * @param playersList list of all players
     * @param world world model
     * @return literal players([ player( ... ), ... ])
     */
    public static Literal players(List<HumanModel> playersList, WorldModel world) {
        LiteralImpl players = new LiteralImpl("players");

        List<Literal> literals = playersList.stream()
                .map(p -> player(p, world))
                .collect(Collectors.toList());

        ListTermImpl array = new ListTermImpl();
        array.addAll(literals);
        players.addTerm(array);

        return players;
    }

    /**
     * Returns the literal to tell the neighbors of a player.
     * @param playersList list of player's names
     * @return literal neighbors([ name1, name2, name3, ... ])
     */
    public static Literal neighbors(List<String> playersList) {
        LiteralImpl neighbors = new LiteralImpl("neighbors");

        List<Term> terms = playersList.stream()
                .map(StringTermImpl::new)
                .collect(Collectors.toList());

        ListTermImpl array = new ListTermImpl();
        array.addAll(terms);
        neighbors.addTerm(array);

        return neighbors;
    }

    /**
     * @param playersList list of visible players
     * @return literal visible_players([ name1, name2, name3, ... ])
     */
    public static Literal visible_players(List<Pair<String, Integer>> playersList) {
        LiteralImpl visible_players = new LiteralImpl("visible_players");

        List<Term> terms = playersList.stream()
                .map(Pair::getFirst)
                .map(StringTermImpl::new)
                .collect(Collectors.toList());

        ListTermImpl array = new ListTermImpl();
        array.addAll(terms);
        visible_players.addTerm(array);

        return visible_players;
    }

    /**
     * @param model model of the player
     * @param world world model
     * @return literal player( name(N), role(R), team(T) area(A), position(X,Y), confidence(C) )
     */
    private static Literal player(HumanModel model, WorldModel world) {
        LiteralImpl player = new LiteralImpl("player");

        Location location = world.getAgPos(model.getIndex());
        String area = WorldUtils.getAreaName(world, location);
        player.addTerms(
            name(model.getName()),
            team("null"),    // TODO
            role("null"),    // TODO
            area(area),
            position(location),
            confidence(0)    // TODO
        );

        return player;
    }
}
