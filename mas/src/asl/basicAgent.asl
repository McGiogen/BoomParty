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
name(N) :- .my_name(N).
// TODO ruolo(Ruolo, team(Team))

/* Environment percepts */
// area(roomA|roomB|hallway)
// position(X,Y)
// players(List)

// TODO giocatoriVicini(List) :- action.NearPlayers(name(N)).
// REMOVE? neighbors(List)

/* Initial goals */

!boot.

+!boot
    <-  !init
        ?visible_players(P);
        .nth(1, P, X);
        !at(X).

+!init
    <-	?name(X);
    	.print("PLAYER ", X, " START!");
    	.all_names(List);
    	.print("All players: ", List);
    	it.unibo.boomparty.action.nearPlayers(X, NearP);
    	.print("I giocatori vicini a me sono: ", NearP).
        //nearest(NearestP);
        //.print("Il più vicino è: ", NearestP).

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