package it.unibo.boomparty.env;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.FontMetrics;
import java.util.List;
import java.util.stream.Collectors;

import it.unibo.boomparty.constants.GameConstans.TEAM;
import it.unibo.boomparty.constants.GameConstans.ROLE;
import jason.environment.grid.GridWorldView;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class WorldView extends GridWorldView {

	private static final long serialVersionUID = -4073575483650955313L;

    private static Logger log = LogManager.getRootLogger();
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
        if(agentModel != null) {
            Color agentColor = (agentModel.getTeam() != null) ? agentModel.getTeam().getColore() : Color.black;
            String agentText = (agentModel.getRuolo() != null) ? agentModel.getRuolo().getSigla() : Integer.toString(id);

            super.drawAgent(g, x, y, agentColor, -1);
            if(agentModel.isLeader()) {
                g.setColor(Color.green);
            } else {
                g.setColor(Color.white);
            }
            super.drawString(g, x, y, this.defaultFont, agentText);
        } else {
            log.error("Fallito recupero agentModel per player con id: " + id);
        }
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

        if (
                this.model.turn != null
                && x == this.model.getWidth() - 1
                && y == 1
        ) {
            this.drawTurno(g, x, y);
        }
    }

    public void drawVincitori(final Graphics g, final int x, final int y) {
        // Stampa team vincitore
        String s1 = "Vincono i " + (this.model.squadraVincitrice.equals(TEAM.ROSSO) ? "Rossi" : "Blu") + "!!!";

        // Stampa vincitori grigi
        List<String> grigiVincitori = this.model.grigiVincitori.stream()
                .map(ROLE::getValue)
                .collect(Collectors.toList());
        String s2 = grigiVincitori.size() > 0 ? "Vincitori grigi: " + String.join(", ", grigiVincitori) : "Nessun vincitore grigio";

        g.setFont(this.defaultFont);
        FontMetrics metrics = g.getFontMetrics();
        int height = metrics.getHeight();
        int width1 = metrics.stringWidth( s1 );
        int width2 = metrics.stringWidth( s2 );
        int margin = height/2;

        // Disegno gli sfondi
        g.setColor(this.model.squadraVincitrice.equals(TEAM.ROSSO) ? Color.red : Color.blue);
        g.fillRect(margin, margin, width1 + 4, height + 2);

        g.setColor(Color.gray);
        g.fillRect(margin, height + margin + 2, width2 + 4, height + 2);

        // Stampo i testi
        g.setColor(Color.white);
        g.drawString(s1, margin + 2, margin + 5 + height/2);
        g.drawString(s2, margin + 2, height + 2 + margin + 5 + height/2 );
    }

    public void drawTurno(final Graphics g, final int x, final int y) {
        String s = "Turno " + this.model.turn;

        g.setFont(this.defaultFont);
        FontMetrics metrics = g.getFontMetrics();
        int height = metrics.getHeight();
        int width = metrics.stringWidth(s);
        int maxWidth = cellSizeW * this.model.getWidth();
        int margin = height/2;

        g.setColor(Color.MAGENTA);
        g.fillRect(maxWidth - width - margin - 2, margin, width + 4, height + 2);

        g.setColor(Color.white);
        g.drawString(s, maxWidth - width - margin, margin + 5 + height/2);
    }
}
