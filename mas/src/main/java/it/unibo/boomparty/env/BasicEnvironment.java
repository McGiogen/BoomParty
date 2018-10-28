package it.unibo.boomparty.env;

import java.util.ArrayList;
import java.util.List;

import it.unibo.boomparty.PerceptsBuilder;
import jason.asSyntax.Literal;
import jason.asSyntax.StringTerm;
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
            // Add percepts
            for (Literal percept : getPercepts(player)) {
                this.addPercept(player.getName(), percept);
            }
        }
    }

    public List<Literal> getPercepts(HumanModel player) {
        String pName = player.getName();
        Location pPosition = this.model.getAgPos(player.getIndex());

        this.clearPercepts(pName);
        ArrayList<Literal> percepts = new ArrayList<>();

        // Area
        if (this.model.roomA.contains(pPosition)) {
            percepts.add(PerceptsBuilder.area("roomA"));
        } else if (this.model.roomB.contains(pPosition)) {
            percepts.add(PerceptsBuilder.area("roomB"));
        } else {
            percepts.add(PerceptsBuilder.area("hallway"));
        }

        // Position
        percepts.add(PerceptsBuilder.position(pPosition));

        // Players
        List<String> playersNames = new ArrayList<>(this.players.size());
        for (HumanModel p : this.players) {
            playersNames.add(p.getName());
        }
        percepts.add(PerceptsBuilder.players(playersNames));

        // Neighbors
        List<Integer> neighborsIndexes = WorldUtils.getNeighbors(this.model.getAgs(), pPosition);
        List<String> neighborsNames = new ArrayList<>(neighborsIndexes.size());
        for (int i : neighborsIndexes) {
            neighborsNames.add(this.players.get(i).getName());
        }
        percepts.add(PerceptsBuilder.neighbors(neighborsNames));

        return percepts;
    }

	/**
     * The <code>boolean</code> returned represents the action "feedback"
     * (success/failure)
     */
    @Override
    public boolean executeAction(final String agName, final Structure action) {
        // this.getLogger().info("[" + agName + "] doing: " + action);
        EnvironmentActions.Result result = new EnvironmentActions.Result();

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
        this.takeTime(result.getTimeSpent());
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
