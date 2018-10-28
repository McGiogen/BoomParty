package it.unibo.boomparty;

import jason.asSyntax.Literal;
import jason.environment.grid.Location;

import java.util.List;

public class PerceptsBuilder {
    // belief literals

    /**
     * Returns the literal to tell the area in which an agent is.
     * @param place name of a place (roomA, roomB, hallway)
     * @return The literal "area(place)"
     */
    public static Literal area(String place) {
        return Literal.parseLiteral("area(" + place + ")");
    }

    public static Literal position(Location position) {
        return Literal.parseLiteral("position(" + position.x + "," + position.y + ")");
    }

    public static Literal players(List<String> playersList) {
        String players = listToString(playersList);
        return Literal.parseLiteral("players(" + players + ")");
    }

    /**
     * Returns the literal to tell the neighbors of a player.
     * @param playersList list of player's names
     * @return The literal "neighbors([name1,name2,name3,...])"
     */
    public static Literal neighbors(List<String> playersList) {
        String players = listToString(playersList);
        return Literal.parseLiteral("neighbors(" + players + ")");
    }

    public static Literal visible_players(List<String> playersList) {
        String players = listToString(playersList);
        return Literal.parseLiteral("visible_players(" + players + ")");
    }

    private static String listToString(List<String> list) {
        return "[" + String.join(",", list) + "]";
    }
}
