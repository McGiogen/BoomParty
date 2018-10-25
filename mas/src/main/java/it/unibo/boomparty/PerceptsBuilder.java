package it.unibo.boomparty;

import jason.asSyntax.Literal;

import java.util.List;

public class PerceptsBuilder {
    // belief literals

    /**
     * Returns the literal to tell the area in which an agent is.
     * @param place name of a place (roomA, roomB, hallway)
     * @return The literal "at(place)"
     */
    public static Literal at(String place) {
        return Literal.parseLiteral("at(" + place + ")");
    }

    /**
     * Returns the literal to tell the neighbors of a player.
     * @param playersList list of player's names
     * @return The literal "neighbors([name1,name2,name3,...])"
     */
    public static Literal neighbors(List<String> playersList) {
        String players = String.join(",", playersList);
        return Literal.parseLiteral("neighbors([" + players + "])");
    }
}
