package it.unibo.boomparty.env;

import jason.environment.grid.Location;

public class EnvironmentActions {

    public static boolean hasObstacleOnPath(PathFinder.Path path, WorldModel model) {
        return path != null && (!path.isPracticable() || !model.isFree(path.getFirst().getLocation()));
    }

    public static Result moveTo(BasicEnvironment env, final HumanModel ag, final Location goal, final boolean exactlyAtGoal) {
        final Result result = new Result();
        final Location start = env.getModel().getAgPos(ag.getIndex());

        if (start.equals(goal)) {
            result.setSuccess(true);
            return result;
        }

        boolean noPath = ag.getPath() == null || !ag.getPath().getGoal().getLocation().equals(goal);
        boolean obstacleOnPath = hasObstacleOnPath(ag.getPath(), env.getModel());

        if (noPath || obstacleOnPath) {
            env.getLogger().fine(
                    "Calculating path of [" + ag.getName() + "] from " + start.x + "," + start.y + " to " + goal.x + "," + goal.y +
                    (noPath ? " for the first time" : " because there is an obstacle on the next step of my path"));

            // get agent location
            final Location loc = env.getModel().getAgPos(ag.getIndex());

            // compute where to move
            PathFinder.Path path = new PathFinder().findPath(env.getModel(), loc, goal);
            ag.setPath(path);

            if (path == null || !path.isPracticable()) {
                // Non è possibile costruire il percorso, uno o più ostacoli bloccano il percorso
                result.setSuccess(false);
                result.setTimeSpent(1000);
                return result;
            }

            // remove start and destination nodes from path
            path.removeFirst();
            if (!exactlyAtGoal) path.removeLast();
        }

        if (ag.getPath().size() > 0) {
            // the path is defined, move one step to the goal
            final Location loc = ag.getPath().getFirst().getLocation();
            boolean success = setAgentPosition(ag, loc, env.getModel()); // actually move the agent in the grid
            result.setTimeSpent(1000);

            if (success) {
                ag.getPath().removeFirst();
            } else {
                result.setSuccess(false);
                return result;
            }
        }

        if (ag.getPath().size() == 0) {
            // the agent reached the goal, path completed
            ag.setPath(null);
        }

        result.setSuccess(true);

        return result;
    }

    public static Result moveIfPossible(BasicEnvironment env, final HumanModel ag, final boolean exitFromArea) {
        final Location agLoc = env.getModel().getAgPos(ag.getIndex());
        final Location newLoc = env.getModel().getFreePos(agLoc, exitFromArea);

        if (newLoc != null) {
            setAgentPosition(ag, newLoc, env.getModel()); // don't mind if it has no success
        }

        final Result result = new Result();
        int randomWaitTime = (int)(Math.random() * 2000);
        result.setTimeSpent(1000 + randomWaitTime);
        result.setSuccess(true);
        return result;
    }

    private static synchronized boolean setAgentPosition(final HumanModel ag, final Location loc, WorldModel model) {
        if (!model.isFree(loc)) return false;
        model.setAgPos(ag.getIndex(), loc); // actually move the agent in the grid
        return true;
    }

    public static class Result<T> {
        private int timeSpent;
        private boolean success;
        private T value;

        Result() {
            this.timeSpent = 0;
            this.success = false;
            this.value = null;
        }

        public int getTimeSpent() {
            return timeSpent;
        }

        public void setTimeSpent(int timeSpent) {
            this.timeSpent = timeSpent;
        }

        public boolean isSuccess() {
            return success;
        }

        public void setSuccess(boolean success) {
            this.success = success;
        }

        public T getValue() {
            return value;
        }

        public void setValue(T value) {
            this.value = value;
        }
    }
}