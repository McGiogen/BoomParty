/*
 * Beliefs riguardo sè stesso:
 * - Nome
 * - Ruolo(nomeRuolo, Team(blue|red|gray))
 * - Stanza(1|2)
 * - Posizione(x, y)
 * - ? notifica nuovo giocatore vicino -> NuovoGiocatoreVicino(playerName)
 * - ? tenere traccia dei giocatori col quale è stata avviata una conversazione, come?
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

// TODO all_players deve ritornare i dati pubblici di tutti i giocatori
//giocatoriVicini(List) :- action.NearPlayers(nome(N)).

/* Initial goals */

!boot.

+!boot
    <-  !init;
    	!at("fernando").

+!init
    <-	?nome(X);
    	.print("PLAYER ", X, " START!");
    	.all_names(List);
    	.print("All players: ", List);
    	it.unibo.boomparty.action.nearPlayers(X, NearP);
    	.print("I giocatori vicini a me sono: ", NearP).

/* Handle movement */
/*
//+!at(P) // if arrived at destination P
//	: at(P)
//	<- true. // ...that's all, do nothing, the "original" intention (the "context") can continue
*/
+!at(P) // if NOT arrived at destination P
	//: not at(P)
	: true
	<- move_towards(P);
	!at(P). // ...continue attempting to reach destination

+hello[source(A)]
	<- .print("va che roba mi ha scritto quell'inetto di:", A).