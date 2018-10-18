package it.unibo.boomparty.env;

import java.util.List;

import it.unibo.boomparty.Main;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.environment.Environment;
import jason.environment.grid.Location;

public class BasicEnvironment extends Environment{

    WorldModel model; // the model of the grid

	@Override
	public void init(final String[] args) {
        this.model = new WorldModel(2);

		Main.main(null);
	}
	
	public List<Literal> getPercepts(String agName) {
		// TODO
		return null;
	}
	
	/* public void updatePercepts() { } */
	
	/**
     * The <code>boolean</code> returned represents the action "feedback"
     * (success/failure)
     */
    @Override
    public boolean executeAction(final String ag, final Structure action) {
        System.out.println("[" + ag + "] doing: " + action);
        boolean result = false;
        
        if (action.getFunctor().equals("move_towards")) {
            //final String who = action.getTerm(0).toString(); // get who (or where) to move
            Location dest = null;
            
            // TODO La destinazione dev'essere una certa persona
            dest = this.model.getAgs()[1];
            
            result = this.model.moveTowards(dest);
        } else {
        	System.err.println("Failed to execute action " + action);
        }
        // only if action completed successfully, update agents' percepts
        if (result) {
            // this.updatePercepts();
            try {
                Thread.sleep(1000);
            } catch (final Exception e) { }
        }
        return result;
    }
}
