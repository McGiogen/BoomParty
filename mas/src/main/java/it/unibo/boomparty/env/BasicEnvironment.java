package it.unibo.boomparty.env;

import java.util.ArrayList;
import java.util.List;

import jason.asSyntax.Literal;
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

	public List<Literal> getPercepts(String agName) {
		// TODO
		return null;
	}

	public void updatePercepts() { }

	/**
     * The <code>boolean</code> returned represents the action "feedback"
     * (success/failure)
     */
    @Override
    public boolean executeAction(final String agName, final Structure action) {
        // this.getLogger().info("[" + agName + "] doing: " + action);
        boolean result = false;
        int timeSpent = 0;

        try {
	        if (action.getFunctor().equals("move_towards")) {
	        	// get who (or where) to move
	        	String arg1 = action.getTerm(0).toString();
                // Strings are enclosed by double quotes
	            final String goalName = arg1.substring(1, arg1.length() - 1);

                HumanModel source = this.getPlayer(agName);
	        	HumanModel target = this.getPlayer(goalName);

	        	if (source != null && target != null) {
                    final Location start = this.model.getAgPos(source.getIndex());
                    final Location goal = this.model.getAgPos(target.getIndex());

                    if (!start.equals(goal)) {
                        timeSpent = 1000;
                        result = this.moveTowards(source, goal);
                    } else {
                        result = true;
                    }
                }
	        } else {
	        	this.getLogger().info("[" + agName + "] Failed to execute action " + action);
	        }
        } catch (final Exception e) {
        	this.getLogger().info("[" + agName + "] EXCEPTION: " + e.getMessage());
        }

        if (result) {
            // Update all agents when the environment change
            this.updatePercepts();
            this.takeTime(timeSpent);
        }
        return result;
    }

	private boolean moveTowards(final HumanModel ag, final Location dest) {
        if (ag.getPath() == null || !ag.getPath().getGoal().getLocation().equals(dest)) {
            this.getLogger().info("Calculating path of [" + ag.getName() +  "] to " + dest.x + "," + dest.y);

            // get agent location
            final Location loc = this.model.getAgPos(ag.getIndex());

            // compute where to move
            PathFinder.Path path = new PathFinder().findPath(this.model, loc, dest);
            ag.setPath(path);

            // remove start node from path
            path.pop();
        }

		if (ag.getPath().size() > 0) {
		    // the path is defined, move one step to the goal
			final Location loc = ag.getPath().pop().getLocation();
			this.model.setAgPos(ag.getIndex(), loc); // actually move the robot in the grid
		} else {
		    // the agent reached the goal, path completed
		    ag.setPath(null);
        }
		return true;
	}

    /**
     *
     * @param name
     * @return
     */
    private HumanModel getPlayer(String name) {
        for (HumanModel player : this.players) {
            if (player.getName().equals(name))
                return player;
        }
        return null;
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
}
