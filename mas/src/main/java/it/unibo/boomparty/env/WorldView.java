package it.unibo.boomparty.env;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;

import jason.environment.grid.GridWorldView;

public class WorldView extends GridWorldView {

	private static final long serialVersionUID = -4073575483650955313L;
	WorldModel model;

    public WorldView(final WorldModel model) {
        super(model, "BoomParty", 800);
        this.setSize(this.getWidth(), this.getWidth()/model.getWidth()*model.getHeight());
        
        this.model = model;
        this.defaultFont = new Font("Arial", Font.BOLD, 14); // change default font
        this.setVisible(true);
        this.repaint();
    }

    @Override
    public void drawAgent(final Graphics g, final int x, final int y, Color c, final int id) {
        super.drawAgent(g, x, y, c, -1);
        g.setColor(Color.white);
        super.drawString(g, x, y, this.defaultFont, "Ag");
    }
}
