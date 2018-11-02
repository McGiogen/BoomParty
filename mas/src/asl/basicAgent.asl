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


/* Initial beliefs */
name(N) :- .my_name(N).
// TODO ruolo(Ruolo, team(Team))

/* Environment percepts */
// area(roomA|roomB|hallway)
// position(X,Y)
// players(List)

// visible_players(List)
// REMOVE? neighbors(List)

/* Initial rules */
list_contains([], _) :- false.
list_contains([X|_], X) :- true.
list_contains([Elem|Tail], X) :- list_contains(Tail, X).

at(P) :- neighbors(List) & list_contains(List, P).


/* Initial goals */

!boot.

+!boot
    <-  !init
        ?visible_players(Players);
        .nth(0, Players, NearestPlayer);    // Choosing the nearest (first) player
        !goto(NearestPlayer).

+!init
    <-	?name(X);
    	.print("PLAYER ", X, " START!");
    	.all_names(List);
    	.print("All players: ", List).
    	//it.unibo.boomparty.action.nearPlayers(X, NearP);
    	//.print("I giocatori vicini a me sono: ", NearP).

/* Handle movement */

+!goto(Player) // if arrived at destination Player
	: at(P)
	<- true. // that's all, do nothing

+!goto(Player) // if NOT arrived at destination Player
	: not at(P)
	<- move_towards(Player);
	!goto(Player). // continue attempting to reach destination


+hello[source(A)]
	<- .print("va che roba mi ha scritto quell'inetto di:", A).