package it.unibo.boomparty.env;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.FontMetrics;
import java.util.List;
import java.util.stream.Collectors;

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
    }

    @Override
    public void drawObstacle(Graphics g, int x, int y) {
        super.drawObstacle(g, x, y);

        if (
               x == this.model.getWidth() - 1
               && y == 1
               && this.model.squadraVincitrice != null
               && this.model.grigiVincitori != null
        ) {
            this.drawVincitori(g, x, y);
        }
    }

    public void drawVincitori(final Graphics g, final int x, final int y) {
        // Stampa team vincitore
        String s1 = "Vincono i " + (this.model.squadraVincitrice.equals(TEAM_PLAYER.ROSSO) ? "Rossi" : "Blu") + "!!!";

        // Stampa vincitori grigi
        List<String> grigiVincitori = this.model.grigiVincitori.stream()
                .map(ROLE_PLAYER::getValue)
                .collect(Collectors.toList());
        String s2 = grigiVincitori.size() > 0 ? "Vincitori grigi: " + String.join(", ", grigiVincitori) : "Nessun vincitore grigio";

        g.setFont(this.defaultFont);
        FontMetrics metrics = g.getFontMetrics();
        int height = metrics.getHeight();
        int width1 = metrics.stringWidth( s1 );
        int width2 = metrics.stringWidth( s2 );

        // Disegno gli sfondi
        g.setColor(this.model.squadraVincitrice.equals(TEAM_PLAYER.ROSSO) ? Color.red : Color.blue);
        g.fillRect(cellSizeW/2 - 2,cellSizeH/2 - 6, width1 + 4, height + 2);

        g.setColor(Color.gray);
        g.fillRect(cellSizeW/2 - 2, height + cellSizeH/2 - 4, width2 + 4, height + 2);

        // Stampo i testi
        g.setColor(Color.white);
        g.drawString(s1, cellSizeW/2, cellSizeH/2 + height/2);
        g.drawString(s2, cellSizeW/2, height + 2 + cellSizeH/2 + height/2);
    }
}
