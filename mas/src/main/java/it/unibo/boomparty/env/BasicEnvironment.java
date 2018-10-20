package it.unibo.boomparty.env;

import java.util.ArrayList;
import java.util.List;

import it.unibo.boomparty.Main;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.asSyntax.Term;
import jason.environment.Environment;
import jason.environment.grid.Location;

public class BasicEnvironment extends Environment{

    WorldModel model; // the model of the grid
	private List<String> players;

	@Override
	public void init(final String[] args) {
		this.players = new ArrayList<String>() {{
		    add("paolo");
		    add("fernando");
		    add("giorgiovanni");
		    add("lucaneri");
		}};;
        this.model = new WorldModel(this.players.size());
		
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
        this.getLogger().info("[" + ag + "] doing: " + action);
        boolean result = false;
        
        try {
	        if (action.getFunctor().equals("move_towards")) {
	        	// get who (or where) to move
	        	Term term = action.getTerm(0);	// Ritorna il valore racchiuso da doppi apici
	            final String toWho = term.toString().substring(1, term.toString().length() - 1);
	            
	        	int iFromWho = this.players.indexOf(ag);
	        	int iToWho = this.players.indexOf(toWho);
	            
	            Location source = this.model.getAgPos(iFromWho);
	            Location dest = this.model.getAgPos(iToWho);
	            this.getLogger().info("[" + ag + "] is at " + source.x + "," + source.y + " and want to go to " + dest.x + "," + dest.y);
	            
	            result = this.model.moveTowards(iFromWho, dest);
	        } else {
	        	this.getLogger().info("[" + ag + "] Failed to execute action " + action);
	        }
        } catch (final Exception e) {
        	this.getLogger().info("[" + ag + "] EXCEPTION: " + e.getMessage());
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
