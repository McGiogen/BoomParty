package it.unibo.boomparty.env;

import it.unibo.boomparty.constants.GameConstans.ROLE;
import it.unibo.boomparty.constants.GameConstans.TEAM;
import jason.environment.grid.Area;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.GridWorldView;
import jason.environment.grid.Location;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public class WorldModel extends GridWorldModel {
    static Random random = new Random();
	Area roomA;
	Area roomB;
	Area hallway;
    private List<HumanModel> players;
    TEAM squadraVincitrice;
    List<ROLE> grigiVincitori;
    String turn;
	
	/**
	 * Create a world with two squared rooms and a hallway
	 * @param playersNames
	 */
	public WorldModel(String[] playersNames) {
    	super(0,0,0);

    	int numPlayers = playersNames.length;
    	int roomSize = WorldUtils.calculateRoomSize(numPlayers, 10);
    	int worldWidth = roomSize*2 + 1;
    	int worldHeight = roomSize + 2;
    	
    	this.initWorld(worldWidth, worldHeight, numPlayers);
    	
    	this.roomA = new Area(0, 2, roomSize-1, worldHeight-1);
    	this.roomB = new Area(roomSize+1, 2, worldWidth-1, worldHeight-1);
    	this.hallway = new Area(roomSize-2, 0, roomSize+2, 1);
    	
    	// Clean areas from walls
        WorldUtils.digArea(this.data, this.roomA);
        WorldUtils.digArea(this.data, this.roomB);
        WorldUtils.digArea(this.data, this.hallway);

        this.players = new ArrayList<>(numPlayers);
        for (int i = 0; i < numPlayers; i++) {
            players.add(new HumanModel(playersNames[i], i));
        }
    }

	/**
     * Copy of GridWorldModel constructor 
     * @param w 		Width, number of blocks
     * @param h 		Height, number of blocks
     * @param nbAgs 	Number of agent
     */
    private void initWorld(int w, int h, int nbAgs) {
    	this.width  = w;
    	this.height = h;

        // inizializzazione mappa con tutti ostacoli
    	this.data = new int[width][height];
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
            	this.data[i][j] = OBSTACLE;
            }
        }

        // inizializzazione location agenti fuori dalla mappa
        this.agPos = new Location[nbAgs];
        for (int i = 0; i < this.agPos.length; i++) {
        	this.agPos[i] = new Location(-1, -1);
        }
    }

    /**
     * Returns a random free location using isFree to test the availability of some possible locations (it means free of agents and obstacles)
     * It checks randomly in all the input area.
     * @param a Search only in this Area
     * @return The free position or null
     */
    protected Location getFreePos(final Area a) {
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

    /**
     * Returns a random free location using isFree to test the availability of some possible location (it means free of agents and obstacles)
     * It checks in the 8 locations around the input location
     * @param l Input location
     * @return The free position or null
     */
    protected Location getFreePos(final Location l, final boolean exitFromArea) {
        Area lArea = WorldUtils.getArea(this, l);
        ArrayList<Location> around = new ArrayList<>(8);

        // Genero l'elenco delle 8 possibili location attorno alla location in input
        for (int x = l.x - 1; x <= l.x + 1; x++) {
            for (int y = l.y - 1; y <= l.y + 1; y++) {
                if (l.x != x || l.y != y) {
                    around.add(new Location(x,y));
                }
            }
        }

        Collections.shuffle(around, random);

        for (Location ar: around) {
            if (isFree(ar) && (exitFromArea || lArea.equals(WorldUtils.getArea(this, ar)))) {
                return ar;
            }
        }
        return null; // not found
    }
    
    public Location[] getAgs() {
    	return this.agPos;
    }

    public int get(int x, int y) {
        return this.data[x][y];
    }

    public List<HumanModel> getPlayers() {
        return players;
    }

    /**
     * Returns the HumanModel from the actor unique name
     * @param name name of the actor
     * @return the model of the actor or null
     */
    public HumanModel getPlayer(String name) {
        for (HumanModel player : this.players) {
            if (player.getName().equals(name))
                return player;
        }
        return null;
    }

    /**
     * Returns the HumanModel from the WorldModel index
     * @param index index of the actor
     * @return the model of the actor or null
     */
    public HumanModel getPlayer(int index) {
        for (HumanModel player : this.players) {
            if (player.getIndex() == index)
                return player;
        }
        return null;
    }

    public GridWorldView getView() { return this.view; }
}
