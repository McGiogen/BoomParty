/*
 * Beliefs riguardo sè stesso:
 * - Nome
 * - Ruolo(nomeRuolo, Team(blue|red|gray))
 * - Stanza(1|2)
 * - Posizione(x, y)
 * 
 * Beliefs riguardo terzi:
 * - Numero giocatori totali
 * - Ruoli presenti
 * - Agenti(Nome, Ruolo, Fiducia/Trust, Stanza, Posizione)
 * 
 * Goals:
 * - Cerca informazioni
 * ...
 * 
 * Intentions
 * - Muovi
 * - Parla
 */


/* Initial beliefs and rules */
nome(N) :- .my_name(N).
//ruolo(Ruolo, team(Team)) :- .my_role(Ruolo, Team).
stanza(1).
// TODO my_position deve ritornare la posizione del giocatore che esegue l'internal action
//posizione(X, Y) :- .my_position(X, Y).

// TODO all_players deve ritornare i dati pubblici di tutti i giocatori
//giocatori(List) :- all_players(List).

/* Initial goals */

!boot.

+!boot
    <- !init.

+!init
    <-	?nome(X);
    	.print("PLAYER ", X, " START!");
    	.all_names(List);
    	.print("All players: ", List).
