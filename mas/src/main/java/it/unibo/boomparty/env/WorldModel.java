package it.unibo.boomparty.env;

import jason.environment.grid.Area;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class WorldModel extends GridWorldModel {
	Area roomA;
	Area roomB;
	Area hallway;
	
	/**
	 * Create a world with two squared rooms and a hallway
	 * @param numPlayers
	 */
	public WorldModel(int numPlayers) {
    	super(0,0,0);
    	
    	int roomSize = calculateRoomSize(numPlayers, 10);
    	int worldWidth = roomSize*2 + 1;
    	int worldHeight = roomSize + 2;
    	
    	this.initWorld(worldWidth, worldHeight, numPlayers);
    	
    	this.roomA = new Area(0, 2, roomSize-1, worldHeight-1);
    	this.roomB = new Area(roomSize+1, 2, worldWidth-1, worldHeight-1);
    	this.hallway = new Area(roomSize-2, 0, roomSize+2, 1);
    	
    	// Clean areas from walls
        digArea(this.data, this.roomA);
        digArea(this.data, this.roomB);
        digArea(this.data, this.hallway);
    	
    	// Choose a random position for every player
    	for (int i = 0; i < numPlayers; i++) {
    		Area room = i % 2 == 0 ? roomA : roomB;
            this.setAgPos(i, this.getFreePos(room));
    	}
    }

	/**
     * Copy of GridWorldModel constructor 
     * @param w 		Width, number of blocks
     * @param h 		Height, number of blocks
     * @param nbAgs 	Number of agents 
     */
    private void initWorld(int w, int h, int nbAgs) {
    	this.width  = w;
    	this.height = h;

        // int data
    	this.data = new int[width][height];
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
            	this.data[i][j] = OBSTACLE;
            }
        }

        this.agPos = new Location[nbAgs];
        for (int i = 0; i < this.agPos.length; i++) {
        	this.agPos[i] = new Location(-1, -1);
        }
    }
    
    /**
     * Returns a random free location using isFree to test the availability of some possible location (it means free of agents and obstacles)
     * @param a Search only in this Area
     * @return The free position or null
     */
    protected Location getFreePos(Area a) {
    	int areaWidth = a.br.x + 1;
    	int areaHeight = a.br.y + 1;
        for (int i = 0; i < (areaWidth * areaHeight * 5); i++) {
            int x = random.nextInt(areaWidth) + a.tl.x;
            int y = random.nextInt(areaHeight) + a.tl.y;
            Location l = new Location(x,y);
            if (isFree(l)) {
                return l;
            }
        }
        return null; // not found
    }
    
    Location[] getAgs() {
    	return this.agPos;
    }

    int get(int x, int y) {
        return this.data[x][y];
    }

    /* Utilities*/
    
    public static int distance(Location l1, Location l2) {
    	return l1.distanceChebyshev(l2);
	}
    
    private static int calculateRoomSize(int numPlayers, int minSize) {
    	return Math.max(minSize, (int) Math.ceil(numPlayers / 3.0 * 2.0));
    }
    
    private static void digArea(int[][] data, Area a) {
		for (int x = a.tl.x; x <= a.br.x; x++) {
			for (int y = a.tl.y; y <= a.br.y; y++) {
				data[x][y] = CLEAN;
			}
		}
	}

	public List<Integer> getNeighbors(Location pPosition) {
		ArrayList<Integer> neighbors = new ArrayList<>(8);
    	Area around = new Area(pPosition.x - 1, pPosition.y - 1, pPosition.x + 1, pPosition.y + 1);

		Location[] agents = this.getAgs();
    	for (int i = 0; i < agents.length; i++) {
			if (around.contains(agents[i])) {
				neighbors.add(i);
			}
		}

		return neighbors;
	}
}
