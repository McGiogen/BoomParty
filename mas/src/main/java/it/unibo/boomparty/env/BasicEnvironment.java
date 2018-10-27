package it.unibo.boomparty.env;

import java.util.ArrayList;
import java.util.List;

import it.unibo.boomparty.PerceptsBuilder;
import jason.asSyntax.Literal;
import jason.asSyntax.StringTerm;
import jason.asSyntax.StringTermImpl;
import jason.asSyntax.Structure;
import jaca.CartagoEnvironment;
import jason.environment.grid.Location;

public class BasicEnvironment extends CartagoEnvironment {

    private WorldModel model; // the model of the grid
	private List<HumanModel> players;

	@Override
	public void init(final String[] args) {
	    super.init(args);
		this.players = new ArrayList<HumanModel>() {{
		    add(new HumanModel("paolo", 0));
		    add(new HumanModel("fernando", 1));
		    add(new HumanModel("giorgiovanni", 2));
		    add(new HumanModel("lucaneri", 3));
		}};
        this.model = new WorldModel(this.players.size());

        final WorldView view = new WorldView(this.model);
        this.model.setView(view);

        // Update all agents with the initial state of the environment
        this.updatePercepts();
	}

    /**
     * Aggiorna i percepts (o beliefs) di tutti gli agenti ad ogni modifica dell'environment.
     */
	public void updatePercepts() {
	    for (HumanModel player : this.players) {
	        String pName = player.getName();
            Location pPosition = this.model.getAgPos(player.getIndex());

            this.clearPercepts(pName);

            // Area
            Literal at;
            if (this.model.roomA.contains(pPosition)) {
                at = PerceptsBuilder.at("roomA");
            } else if (this.model.roomB.contains(pPosition)) {
                at = PerceptsBuilder.at("roomB");
            } else {
                at = PerceptsBuilder.at("hallway");
            }
            this.addPercept(pName, at);

            // Neighbors
            List<Integer> indexes = WorldUtils.getNeighbors(this.model.getAgs(), pPosition);
            List<String> playersNames = new ArrayList<>(indexes.size());
            for (int i : indexes) {
                playersNames.add(this.players.get(i).getName());
            }
            Literal neighbors = PerceptsBuilder.neighbors(playersNames);
            this.addPercept(pName, neighbors);

            this.getLogger().info("[" + pName + "] " + at.toString() + ", " + neighbors.toString());
        }
    }

	/**
     * The <code>boolean</code> returned represents the action "feedback"
     * (success/failure)
     */
    @Override
    public boolean executeAction(final String agName, final Structure action) {
        // this.getLogger().info("[" + agName + "] doing: " + action);
        EnvironmentActions.Result result = new EnvironmentActions.Result();
        int timeSpent = 0;

        try {
            switch(action.getFunctor()) {
                case "move_towards": {
                    // get who (or where) to move
                    String goalName = ((StringTerm) action.getTerm(0)).getString();

                    HumanModel source = this.getPlayer(agName);
                    HumanModel target = this.getPlayer(goalName);

                    if (source != null && target != null) {
                        final Location goal = this.model.getAgPos(target.getIndex());
                        result = EnvironmentActions.moveTowards(this, source, goal);
                    }
                    break;
                }
                case "nearest": {
                    HumanModel source = this.getPlayer(agName);
                    EnvironmentActions.Result<HumanModel> res = EnvironmentActions.nearest(this, source);
                    // un.unifies(action.getTerm(0), new StringTermImpl(res.getValue().getName()));

                    result = res;
                    break;
                }
                default:
                    this.getLogger().info("[" + agName + "] Failed to execute action " + action);
            }
        } catch (final Exception e) {
        	this.getLogger().info("[" + agName + "] EXCEPTION: " + e.getMessage());
        }

        // Update all agents when the environment change
        this.updatePercepts();
        this.takeTime(timeSpent);
        return result.isSuccess();
    }

    /**
     * Impiega il tempo richiesto.
     * @param timeSpent tempo da impiegare
     */
    private void takeTime(int timeSpent) {
        if (timeSpent <= 0) {
            return;
        }
        try {
            Thread.sleep(timeSpent);
        } catch (final Exception e) { }
    }

    public WorldModel getModel() {
        return model;
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
}
