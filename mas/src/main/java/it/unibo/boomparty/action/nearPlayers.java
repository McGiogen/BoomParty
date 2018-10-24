package it.unibo.boomparty.action;

import jason.asSemantics.DefaultInternalAction;
import jason.asSemantics.TransitionSystem;
import jason.asSemantics.Unifier;
import jason.asSyntax.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.ArrayList;
import java.util.List;

public class nearPlayers extends DefaultInternalAction {

    private static Logger log = LogManager.getLogger();

    @Override
    public Object execute(final TransitionSystem ts, final Unifier un, final Term[] args) {
        log.debug("comando avviato");

        if(!args[0].isAtom()){
            log.error("nome giocatore non valido");
            //TODO valutare come gestire questa situazione
            return null;
        }
        log.info("giocatore: " + args[0]);

        Atom nomeGiocatoreTerm = (Atom) args[0];

        //TODO effettuare recupero agenti vicini, tramite env?
        List<String> giocatoriVicini = new ArrayList<String>();
        giocatoriVicini.add(nomeGiocatoreTerm.getFunctor());

        return un.unifies(args[1], new StringTermImpl(String.join(", ", giocatoriVicini)));
    }
}
