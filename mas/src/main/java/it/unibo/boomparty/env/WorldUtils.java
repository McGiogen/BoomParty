package it.unibo.boomparty.env;

import jason.environment.grid.Area;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.List;

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
}
