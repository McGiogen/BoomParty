package it.unibo.boomparty.env;

import jason.environment.grid.Area;
import jason.environment.grid.Location;
import jason.util.Pair;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import static jason.environment.grid.GridWorldModel.CLEAN;

public class WorldUtils {
	public final static double areaPerPlayer = 25d;

	public static int distance(Location l1, Location l2) {
		return l1.distanceChebyshev(l2);
	}

	public static int calculateRoomSize(int numPlayers, int minSize) {
		return Math.max(minSize, (int) Math.ceil(Math.sqrt(numPlayers / 2.0 * areaPerPlayer)));
	}

	public static void digArea(int[][] data, Area a) {
		for (int x = a.tl.x; x <= a.br.x; x++) {
			for (int y = a.tl.y; y <= a.br.y; y++) {
				data[x][y] = CLEAN;
			}
		}
	}

	public static List<Integer> getNeighbors(WorldModel model, HumanModel player) {
		Location[] agents = model.getAgs();
		Location pPosition = model.getAgPos(player.getIndex());
		if (pPosition == null) return new ArrayList<>();

		Area around = new Area(pPosition.x - 1, pPosition.y - 1, pPosition.x + 1, pPosition.y + 1);

		ArrayList<Integer> neighbors = new ArrayList<>(8);
		for (int i = 0; i < agents.length; i++) {
			if (agents[i] != null && around.contains(agents[i]) && i != player.getIndex()) {
				neighbors.add(i);
			}
		}

		return neighbors;
	}

	public static List<Pair<Integer, Integer>> getVisiblePlayers(WorldModel model, HumanModel player) {
		Location[] agents = model.getAgs();
		Location pPosition = model.getAgPos(player.getIndex());
		if (pPosition == null) return new ArrayList<>();

		Area pArea = getArea(model, pPosition);

		// Lista di oggetti (index, distance)
        List<Pair<Integer, Integer>> orderedList = new ArrayList<>(agents.length);

		for (int i = 0; i < agents.length; i++) {
			if (agents[i] != null) {
				int distance = distance(pPosition, agents[i]);
				if (pArea != null && pArea.contains(agents[i]) && i != player.getIndex()) {
					orderedList.add(new Pair<>(i, distance));
				}
			}
		}

		return orderedList.stream()
                .sorted(Comparator.comparing(Pair::getSecond))
                .collect(Collectors.toList());
	}

	public static Area getArea(WorldModel model, Location location) {
		if (location == null) {
			return null;
		} else if (model.roomA.contains(location)) {
			return model.roomA;
		} else if (model.roomB.contains(location)) {
			return model.roomB;
		} else if (model.hallway.contains(location)) {
			return model.hallway;
		} else {
			return null;
		}
	}

	public static Area getArea(WorldModel model, String areaName) {
	    switch (areaName) {
	        case "roomA": return model.roomA;
            case "roomB": return model.roomB;
            case "hallway": return model.hallway;
            default: return null;
        }
    }

	public static String getAreaName(WorldModel model, Location location) {
	    Area area = getArea(model, location);
	    return getAreaName(model, area);
    }

    public static String getAreaName(WorldModel model, Area area) {
        if (model.roomA.equals(area)) {
            return "roomA";
        } else if (model.roomB.equals(area)) {
            return "roomB";
        } else {
            return "hallway";
        }
    }
}
