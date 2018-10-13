package it.unibo.boomparty.env;

import java.util.List;

import it.unibo.boomparty.Main;
import jason.asSyntax.Literal;
import jason.asSyntax.Structure;
import jason.environment.Environment;

public class BasicEnvironment extends Environment{

	@Override
	public void init(final String[] args) {

		Main.main(null);
	}
	
	public List<Literal> getPercepts(String agName) {
		// TODO
		return null;
	}
	
	/*
	public void updatePercepts() { } */
	
	@Override
	public boolean executeAction(final String ag, final Structure action) {
		// TODO
		return false;
	}
}
