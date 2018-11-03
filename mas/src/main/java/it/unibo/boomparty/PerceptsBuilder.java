package it.unibo.boomparty;

import it.unibo.boomparty.env.HumanModel;
import it.unibo.boomparty.env.WorldModel;
import it.unibo.boomparty.env.WorldUtils;
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
        Structure name = new Structure("name");
        name.addTerm(new StringTermImpl(value));
        return name;
    }

    /**
     * @param atom role atom
     * @return literal team(atom)
     */
    public static Literal team(String atom) {
        Structure team = new Structure("team");
        team.addTerm(new Atom(atom));
        return team;
    }

    /**
     * @param atom role atom
     * @return literal role(atom)
     */
    public static Literal role(String atom) {
        Structure role = new Structure("role");
        role.addTerm(new Atom(atom));
        return role;
    }

    /**
     * Returns the literal to tell the area in which an agent is.
     * @param atom name of a place (roomA, roomB, hallway)
     * @return literal area(atom)
     */
    public static Literal area(String atom) {
        Structure area = new Structure("area");
        area.addTerm(new Atom(atom));
        return area;
    }

    /**
     * @param location position
     * @return literal position(x,y)
     */
    public static Literal position(Location location) {
        Structure position = new Structure("position");
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
        Structure confidence = new Structure("confidence");
        confidence.addTerm(new NumberTermImpl(value));
        return confidence;
    }

    /**
     * @param playersList list of all players
     * @param world world model
     * @return literal players([ player( ... ), ... ])
     */
    public static Literal players(List<HumanModel> playersList, WorldModel world) {
        Structure players = new Structure("players");

        List<Literal> terms = playersList.stream()
                .map(p -> player(p, world))
                .collect(Collectors.toList());

        ListTermImpl array = new ListTermImpl();
        array.addAll(terms);
        players.addTerm(array);

        return players;
    }

    /**
     * Returns the literal to tell the neighbors of a player.
     * @param playersList list of player's names
     * @return literal neighbors([ name1, name2, name3, ... ])
     */
    public static Literal neighbors(List<String> playersList) {
        String players = listToString(playersList);
        return Literal.parseLiteral("neighbors(" + players + ")");
    }

    /**
     * @param playersList list of visible players
     * @return literal visible_players([ name1, name2, name3, ... ])
     */
    public static Literal visible_players(List<Pair<String, Integer>> playersList) {
        List<String> stringList = playersList.stream().map(Pair::getFirst).collect(Collectors.toList());
        String players = listToString(stringList);
        return Literal.parseLiteral("visible_players(" + players + ")");
    }

    private static String listToString(List<String> list) {
        return list.size() == 0 ? "[]" : "[\"" + String.join("\",\"", list) + "\"]";
    }

    /**
     * @param model model of the player
     * @param world world model
     * @return literal player( name(N), role(R), team(T) area(A), position(X,Y), confidence(C) )
     */
    private static Literal player(HumanModel model, WorldModel world) {
        Structure player = new Structure("player");

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
