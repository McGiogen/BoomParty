package it.unibo.boomparty.domain.artifacts;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import it.unibo.boomparty.constants.GameConstans.ROLE_PLAYER;
import it.unibo.boomparty.constants.GameConstans.TEAM_PLAYER;

import java.util.*;

public class Card extends Artifact {

    private String owner = "";
    private Map<Character, List<String>> rightsGiven = new HashMap<>();

    private ROLE_PLAYER role;
    private TEAM_PLAYER team;


    void init(String team, String role) {
        this.team = TEAM_PLAYER.byCodice(team);
        this. role = ROLE_PLAYER.byCodice(role);
    }

    @OPERATION
    void setOwner(String newOwner, String oldOwner) {
        if (this.owner.equals("") || this.owner.equals(oldOwner)) {
            // Se oldOwner è presente ed è uguale a quello segnato per questo artefatto
            // Oppure se non è settato neanche l'owner
            // allora imposto newOwner come owner di questo artefatto
            this.owner = newOwner;
        }
    }

    /**
     * Permette ad un agente diverso dall'owner di interrogare l'artefatto sul valore di team (T),
     * ruolo (R) o entrambi (B) in base al livello specificato dall'owner.
     *
     * @param owner     attuale proprietario dell'artefatto
     * @param toWhom    agente a cui concere il diritto
     * @param ofWhat    quale diritto concedere (T team, R ruolo, B entrambi)
     * @param result    Risulato dell'operazione (true|false)
     */
    @OPERATION
    void grantRights(String owner, String toWhom, Character ofWhat, OpFeedbackParam<Boolean> result) {
        result.set(true);

        // Solo il proprietario può demandare
        if (!this.owner.equals(owner)) {
            result.set(false);
            return;
        }

        if (!ofWhat.equals("T".toCharArray()[0]) || !ofWhat.equals("R".toCharArray()[0]) || !ofWhat.equals("B".toCharArray()[0])) {
            result.set(false);

            return;
        }

        if (!rightsGiven.containsKey(ofWhat)) {
            rightsGiven.put(ofWhat, new ArrayList<>());
        }

        List<String> rightsList = rightsGiven.get(ofWhat);

        // Se non contiene questo soggetto, aggiorno la lista
        if (!rightsList.contains(toWhom)) {
            rightsList.add(toWhom);
            rightsGiven.put(ofWhat, rightsList);
        } else {
            result.set(false);
        }
    }

    /**
     * Rimuove la capacità di un agente di interrogare l'artefatto sul valore di team (T),
     * ruolo (R) o entrambi (B) in base al livello specificato dall'owner.
     *
     * @param owner     attuale proprietario dell'artefatto
     * @param toWhom    agente a cui rimuovere il diritto
     * @param ofWhat    quale diritto rimuovere (T team, R ruolo, B entrambi)
     * @param result    Risulato dell'operazione (true|false)
     */
    @OPERATION
    void removeRights(String owner, String toWhom, Character ofWhat, OpFeedbackParam<Boolean> result) {
        result.set(true);

        // Solo il proprietario può rimuovere i diritti
        if (!this.owner.equals(owner)) {
            result.set(false);
            return;
        }

        if (!ofWhat.equals("T".toCharArray()[0]) || !ofWhat.equals("R".toCharArray()[0]) || !ofWhat.equals("B".toCharArray()[0])) {
            result.set(false);

            return;
        }

        // Se non contiene questo livello ritorno comunque false
        if (!rightsGiven.containsKey(ofWhat)) {
            result.set(false);

            return;
        }

        List<String> rightsList = rightsGiven.get(ofWhat);

        // Anche in questo caso torno falso
        if (!rightsList.contains(toWhom)) {
            result.set(false);

            return;
        }

        rightsList.remove(toWhom);

        // Aggiorno la lista
        rightsGiven.put(ofWhat, rightsList);

    }

    @OPERATION
    void getRole(String asker, OpFeedbackParam<String> role) {
        // Restituisco solo se ho i diritti
        if (this.owner.equals(asker)
                || this.rightsGiven.get("R".toCharArray()[0]).contains(asker)
                || this.rightsGiven.get("B".toCharArray()[0]).contains(asker)) {
            role.set(this.role.getCodice());

            return;
        }

        role.set("");
    }

    @OPERATION
    void getTeam(String asker, OpFeedbackParam<String> team) {
        // Restituisco solo se ho i diritti
        if (this.owner.equals(asker)
                || this.rightsGiven.get("R".toCharArray()[0]).contains(asker)
                || this.rightsGiven.get("B".toCharArray()[0]).contains(asker)) {
            team.set(this.team.getCodice());

            return;
        }

        team.set("");
    }
}
