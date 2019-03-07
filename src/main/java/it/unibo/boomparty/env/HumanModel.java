package it.unibo.boomparty.env;

public class HumanModel {
    private final String name;
    private final int index;
    private PathFinder.Path path;

    public HumanModel(String name, int index) {
        this.name = name;
        this.index = index;
    }

    public PathFinder.Path getPath() {
        return path;
    }

    public void setPath(PathFinder.Path path) {
        this.path = path;
    }

    public String getName() {
        return name;
    }

    public int getIndex() {
        return index;
    }
}
