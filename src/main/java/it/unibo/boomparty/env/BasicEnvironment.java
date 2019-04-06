package it.unibo.boomparty.env;

import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;
import jaca.CartagoEnvironment;
import jason.asSyntax.*;
import jason.environment.grid.Area;
import jason.environment.grid.Location;
import jason.util.Pair;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class BasicEnvironment extends CartagoEnvironment {

    private WorldModel model; // the model of the grid

	@Override
	public void init(String[] args) {
	    String[] playersNames = args[0].split(",");
	    super.init(Arrays.copyOfRange(args, 1, args.length));
        this.model = new WorldModel(playersNames);

        final WorldView view = new WorldView(this.model);
        this.model.setView(view);

        // Update all agent with the initial state of the environment
        this.updatePercepts();
	}

    /**
     * Aggiorna i percepts (o beliefs) di tutti gli agenti ad ogni modifica dell'environment.
     */
	public void updatePercepts() {
	    for (HumanModel player : model.getPlayers()) {
            // Add percepts
            List<Literal> percepts = getPercepts(player);
            this.clearPercepts(player.getName());
            for (Literal percept : percepts) {
                this.addPercept(player.getName(), percept);
            }
        }
    }

    public List<Literal> getPercepts(HumanModel player) {
        Location pPosition = this.model.getAgPos(player.getIndex());

        ArrayList<Literal> percepts = new ArrayList<>();

        // Area
        percepts.add(PerceptsBuilder.area(WorldUtils.getAreaName(model, pPosition)));

        // Position
        percepts.add(PerceptsBuilder.position(pPosition));

        // Players
        percepts.add(PerceptsBuilder.players(model.getPlayers(), model));

        // Neighbors
        List<Integer> neighborsIndexes = WorldUtils.getNeighbors(this.model, player);
        List<String> neighborsNames = new ArrayList<>(neighborsIndexes.size());
        for (int i : neighborsIndexes) {
            neighborsNames.add(model.getPlayer(i).getName());
        }
        percepts.add(PerceptsBuilder.neighbors(neighborsNames));

        // Visible players
        List<Pair<Integer, Integer>> visiblesIndexes = WorldUtils.getVisiblePlayers(this.model, player);
        List<Pair<String, Integer>> visiblesNamed = new ArrayList<>(visiblesIndexes.size());
        for (Pair<Integer, Integer> pair : visiblesIndexes) {
            String name = model.getPlayer(pair.getFirst()).getName();
            visiblesNamed.add(new Pair<>(name, pair.getSecond()));
        }
        Literal vp = PerceptsBuilder.visible_players(visiblesNamed);
        //this.getLogger().info("[" + player.getName() + "] visible_players = " + vp);
        percepts.add(vp);

        // Going to a position, or null
        percepts.add(PerceptsBuilder.going_to(player.getPath()));

        return percepts;
    }

	/**
     * The <code>boolean</code> returned represents the operations "feedback"
     * (success/failure)
     */
    @Override
    public boolean executeAction(final String agName, final Structure action) {
        // this.getLogger().info("[" + agName + "] doing: " + action.getFunctor());
        EnvironmentActions.Result result = new EnvironmentActions.Result();

        try {
            switch(EnvironmentActionsEnum.valueOf(action.getFunctor().toUpperCase())) {
                case MOVE_TOWARDS: {
                    // get who (or where) to move
                    String goalName = ((StringTerm) action.getTerm(0)).getString();

                    HumanModel source = this.getPlayer(agName);
                    HumanModel target = this.getPlayer(goalName);

                    if (source != null && target != null) {
                        final Location goal = this.model.getAgPos(target.getIndex());
                        if (goal != null) {
                            result = EnvironmentActions.moveTo(this, source, goal, false);
                            if (!result.isSuccess()) {
                                result = EnvironmentActions.moveIfPossible(this, source, false);
                            }
                        }
                    }
                    break;
                }
                case MOVE_IN: {
                    // get where to move
                    String areaName = action.getTerm(0).toString();

                    HumanModel source = this.getPlayer(agName);
                    Area target = WorldUtils.getArea(this.getModel(), areaName);

                    if (source != null && target != null) {
                        Location goal = null;
                        boolean pathAlreadyCalculated = source.getPath() != null && WorldUtils.getArea(this.getModel(), source.getPath().getGoal().getLocation()).equals(target);
                        if (pathAlreadyCalculated) {
                            goal = source.getPath().getGoal().getLocation();
                        } else {
                            goal = this.getModel().getFreePos(target);
                        }
                        if (goal != null) {
                            result = EnvironmentActions.moveTo(this, source, goal, true);
                            if (!result.isSuccess()) {
                                result = EnvironmentActions.moveIfPossible(this, source, true);
                            }
                        }
                    }
                    break;
                }
                case MOVE_RANDOMLY: {
                    HumanModel source = this.getPlayer(agName);
                    if (source != null) {
                        result = EnvironmentActions.moveIfPossible(this, source, false);
                    }
                    break;
                }
                case START_IN_AREA: {
                    String areaName = ((Atom) action.getTerm(0)).getFunctor();
                    HumanModel player = this.getPlayer(agName);

                    synchronized (this) {
                        Area room = WorldUtils.getArea(this.model, areaName);
                        this.model.setAgPos(player.getIndex(), this.model.getFreePos(room));
                    }

                    result.setSuccess(true);
                    break;
                }
                case REGISTER: {
                    String codiceTeam = ((StringTerm) action.getTerm(0)).getString();
                    String codiceRuolo = ((StringTerm) action.getTerm(1)).getString();

                    TEAM_PLAYER team = TEAM_PLAYER.byCodice(codiceTeam);
                    ROLE_PLAYER ruolo = ROLE_PLAYER.byCodice(codiceRuolo);

                    HumanModel agentModel = this.getPlayer(agName);
                    agentModel.setRuolo(ruolo);
                    agentModel.setTeam(team);

                    result.setSuccess(true);
                    break;
                }
                case ELETTO_LEADER: {
                    HumanModel agentModel = this.getPlayer(agName);
                    agentModel.setLeader(true);

                    result.setSuccess(true);
                    break;
                }
                case DEPOSTO_LEADER: {
                    HumanModel agentModel = this.getPlayer(agName);
                    agentModel.setLeader(false);

                    result.setSuccess(true);
                    break;
                }
                case TELL_WINNERS: {
                    List<Term> vincitoriTerm = ((ListTermImpl) action.getTerm(0)).getAsList();
                    List<String> vincitori = vincitoriTerm.stream()
                            .map(term -> ((StringTerm) term).getString())
                            .filter(name -> !"none".equals(name))
                            .collect(Collectors.toList());

                    this.model.squadraVincitrice = TEAM_PLAYER.byCodice(vincitori.remove(0));
                    this.model.grigiVincitori = vincitori.stream()
                            .map(ROLE_PLAYER::byCodice)
                            .collect(Collectors.toList());

                    this.model.getView().repaint();

                    result.setSuccess(true);
                    break;
                }
                case TURN: {
                    String turn = action.getTerm(0).toString();

                    this.model.turn = turn;

                    this.model.getView().repaint();

                    result.setSuccess(true);
                    break;
                }
                default:
                    this.getLogger().info("[" + agName + "] Failed to execute operations " + action);
            }
        } catch (final Exception e) {
        	this.getLogger().info("[" + agName + "] EXCEPTION: " + e);
        }

        // Update all agent when the environment change
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
        return model.getPlayers();
    }

    /**
     * Returns the HumanModel from the actor unique name
     * @param name name of the actor
     * @return the model of the actor or null
     */
    public HumanModel getPlayer(String name) {
        return model.getPlayer(name);
    }

    /**
     * Returns the HumanModel from the WorldModel index
     * @param index index of the actor
     * @return the model of the actor or null
     */
    public HumanModel getPlayer(int index) {
        return model.getPlayer(index);
    }
}
