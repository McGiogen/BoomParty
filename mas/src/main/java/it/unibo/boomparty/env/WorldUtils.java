package it.unibo.boomparty.env;

import jason.environment.grid.Area;
import jason.environment.grid.Location;
import jason.util.Pair;

import java.util.*;
import java.util.stream.Collectors;

import static jason.environment.grid.GridWorldModel.CLEAN;

public class WorldUtils {
	public static int distance(Location l1, Location l2) {
		return l1.distanceChebyshev(l2);
	}

	public static int calculateRoomSize(int numPlayers, int minSize) {
		return Math.max(minSize, (int) Math.ceil(numPlayers / 3.0 * 2.0));
	}

	public static void digArea(int[][] data, Area a) {
		for (int x = a.tl.x; x <= a.br.x; x++) {
			for (int y = a.tl.y; y <= a.br.y; y++) {
				data[x][y] = CLEAN;
			}
		}
	}

	public static List<Integer> getNeighbors(Location[] agents, Location pPosition) {
		ArrayList<Integer> neighbors = new ArrayList<>(8);
		Area around = new Area(pPosition.x - 1, pPosition.y - 1, pPosition.x + 1, pPosition.y + 1);

		for (int i = 0; i < agents.length; i++) {
			if (around.contains(agents[i])) {
				neighbors.add(i);
			}
		}

		return neighbors;
	}

	public static List<Pair<Integer, Integer>> getVisiblePlayers(WorldModel model, Location pPosition) {
		Area pArea = getArea(model, pPosition);
		Location[] agents = model.getAgs();

		// Lista di oggetti (index, distance)
        List<Pair<Integer, Integer>> orderedList = new ArrayList<>(agents.length);

		for (int i = 0; i < agents.length; i++) {
			int distance = distance(pPosition, agents[i]);
            if (pArea != null && pArea.contains(agents[i])) {
                orderedList.add(new Pair<>(i, distance));
            }
		}

		return orderedList.stream()
                .sorted(Comparator.comparing(Pair::getSecond))
                .collect(Collectors.toList());
	}

	/*public static Integer getNearest(WorldModel model, Location pPosition) {
		Area pArea = getArea(model, pPosition);
		Location[] agents = model.getAgs();

		Integer nearest = null;
		Integer minDistance = Integer.MAX_VALUE;

		for (int i = 0; i < agents.length; i++) {
		    int distance = distance(pPosition, agents[i]);
			if (distance > 0 && distance < minDistance && pArea.contains(agents[i])) {
				nearest = i;
			}
		}

		return nearest;
	}*/

	public static Area getArea(WorldModel model, Location location) {
		if (model.roomA.contains(location)) {
			return model.roomA;
		} else if (model.roomB.contains(location)) {
			return model.roomB;
		} else if (model.hallway.contains(location)) {
			return model.hallway;
		} else {
			return null;
		}
	}
}
