package it.unibo.boomparty.env;

import jason.environment.grid.Area;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

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
    	
    	int roomSize = calculateRoomSize(numPlayers);
    	int worldWidth = roomSize*2 + 2;
    	int worldHeight = roomSize;
    	
    	this.initWorld(worldWidth, worldHeight, numPlayers);
    	
    	this.roomA = new Area(0, 0, roomSize-1, roomSize-1);
    	this.roomB = new Area(roomSize + 2, 0, worldWidth-1, worldHeight-1);
    	this.hallway = new Area(roomSize, 0, roomSize+1, 0);
    	
    	// Put walls between the rooms
    	Area walls = new Area(hallway.tl.x, hallway.br.y, hallway.br.x, hallway.br.y);
    	fillAreaWithWalls(this.data, walls);
    	
    	// Choose a random position for every player
    	for (int i = 0; i < numPlayers; i++) {
    		Area room = i % 2 == 0 ? roomA : roomB;
            this.setAgPos(i, this.getFreePos(room));;
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
            	this.data[i][j] = CLEAN;
            }
        }

        this.agPos = new Location[nbAgs];
        for (int i = 0; i < this.agPos.length; i++) {
        	this.agPos[i] = new Location(-1, -1);
        }
    }

    boolean moveTowards(final int ag, final Location dest) {
        final Location r1 = this.getAgPos(ag);
        // compute where to move
        if (r1.x < dest.x) {
            r1.x++;
        } else if (r1.x > dest.x) {
            r1.x--;
        }
        if (r1.y < dest.y) {
            r1.y++;
        } else if (r1.y > dest.y) {
            r1.y--;
        }
        this.setAgPos(ag, r1); // actually move the robot in the grid
        
        return true;
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

    /* Utilities*/
    
    public static int distance(Location l1, Location l2) {
    	return l1.distanceChebyshev(l2);
	}
    
    private static int calculateRoomSize(int numPlayers) {
    	return (int) Math.ceil(numPlayers / 3.0 * 2.0);
    }
    
    private static void fillAreaWithWalls(int[][] data, Area a) {
		for (int x = a.tl.x; x <= a.br.x; x++) {
			for (int y = a.tl.y; y <= a.br.y; y++) {
				data[x][y] = OBSTACLE;
			}
		}
	}
}
