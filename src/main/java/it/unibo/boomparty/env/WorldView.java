package it.unibo.boomparty.env;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.FontMetrics;

import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;
import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
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

        HumanModel agentModel = model.getPlayer(id);
        Color agentColor = (agentModel.getTeam() != null) ? agentModel.getTeam().getColore() : Color.black;
        String agentText = (agentModel.getRuolo() != null) ? agentModel.getRuolo().getSigla() : Integer.toString(id);

        super.drawAgent(g, x, y, agentColor, -1);
        if(agentModel.isLeader()) {
            g.setColor(Color.orange);
        } else {
            g.setColor(Color.white);
        }
        super.drawString(g, x, y, this.defaultFont, agentText);

        if (
            agentModel.getRuolo().equals(ROLE_PLAYER.PRESIDENTE)
            && this.model.squadraVincitrice != null
            && this.model.grigiVincitori != null
        ) {
            this.drawVincitori(g, x, y);
        }
    }

    public void drawVincitori(final Graphics g, final int x, final int y) {
        // TODO Stampa anche i grigi
        // TODO Migliora la stampa
        String s = "Vincono i " + (this.model.squadraVincitrice.equals(TEAM_PLAYER.ROSSO) ? "Rossi" : "Blue") + "!!!";

        g.setFont(this.defaultFont);
        FontMetrics metrics = g.getFontMetrics();
        int height = metrics.getHeight();
        g.drawString( s, cellSizeW/2, cellSizeH/2 + height/2);
    }
}
