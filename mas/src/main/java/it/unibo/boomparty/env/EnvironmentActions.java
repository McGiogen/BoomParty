package it.unibo.boomparty.env;

import jason.environment.grid.Location;

public class EnvironmentActions {

    public static Result moveTowards(BasicEnvironment env, final HumanModel ag, final Location goal) {
        final Result result = new Result();
        final Location start = env.getModel().getAgPos(ag.getIndex());

        if (start.equals(goal)) {
            result.setSuccess(true);
            return result;
        }

        if (ag.getPath() == null || !ag.getPath().getGoal().getLocation().equals(goal)) {
            env.getLogger().info("Calculating path of [" + ag.getName() + "] to " + goal.x + "," + goal.y);

            // get agent location
            final Location loc = env.getModel().getAgPos(ag.getIndex());

            // compute where to move
            PathFinder.Path path = new PathFinder().findPath(env.getModel(), loc, goal);
            ag.setPath(path);

            // remove start and destination nodes from path
            path.removeFirst();
            path.removeLast();
        }

        if (ag.getPath().size() > 0) {
            // the path is defined, move one step to the goal
            final Location loc = ag.getPath().pop().getLocation();
            env.getModel().setAgPos(ag.getIndex(), loc); // actually move the agent in the grid
            result.setTimeSpent(1000);
        }

        if (ag.getPath().size() == 0) {
            // the agent reached the goal, path completed
            ag.setPath(null);
        }

        result.setSuccess(true);

        return result;
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