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
team(null).  // TODO
role(null).  // TODO

/* Environment percepts */
// area(roomA|roomB|hallway)
// position(X,Y)
// players([ player( name(N), role(R), team(T) area(A), position(X,Y), confidence(C) ), ... ])

// visible_players(List)
// REMOVE? neighbors(List)

/* Initial rules */
list_contains([], _) :- false.
list_contains([X|_], X) :- true.
list_contains([Elem|Tail], X) :- list_contains(Tail, X).
at(P) :- neighbors(List) & list_contains(List, P).


/* Initial goals */

!boot.


/*+!boot
    <-  !init
        ?visible_players(Players);
        .nth(0, Players, NearestPlayer);    // Choosing the nearest (first) player
        !goto(NearestPlayer).*/

+!boot
    <-  ?name(X);
        .print("PLAYER ", X, " START!");
        !init
        !preparazioneGioco
        .print("fine boot").

+!init
    <-
    	.all_names(List);
    	.print("All players: ", List).
    	//it.unibo.boomparty.action.nearPlayers(X, NearP);
    	//.print("I giocatori vicini a me sono: ", NearP).


/* Operazioni fase inziale partita */

+!preparazioneGioco
    <-
        t4jn.api.inp("default", "127.0.0.1", "20504", token(X), Op0);
        t4jn.api.getResult(Op0, Result);
        if(not(Result == null)) {
            t4jn.api.getArg(Result, 0, TokenVal);
            if(TokenVal == "mazziere") {
                ?name(Name);
                .print("Ricevuto ruolo mazziere ", Name);
                !assegnaRuoli;
                !assegnaStanze;
            }
            !recuperaRuolo;
            !recuperaStanza;
        } else {
            .print("Errore recupero token mazziere");
        }
        .print("Fase iniziale di preparazione ultimata").

+!assegnaRuoli
    <-
        .print("Inizio assegnazione ruoli");
        /* TODO creazione artefatti cartE */
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(1111)), Op1);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(2222)), Op2);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(3333)), Op3);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(4444)), Op4);
        .print("Fine assegnazione ruoli").

+!assegnaStanze
    <-
        .print("Inizio assegnazione stanze");
        /* TODO creazione stanza */
        t4jn.api.out("default", "127.0.0.1", "20504", stanza(1), Op1);
        t4jn.api.out("default", "127.0.0.1", "20504", stanza(2), Op2);
        t4jn.api.out("default", "127.0.0.1", "20504", stanza(1), Op3);
        t4jn.api.out("default", "127.0.0.1", "20504", stanza(2), Op4);
        /* TODO creazione leader stanza */
        .print("Fine assegnazione stanze").

+!recuperaRuolo
    <-
        .print("Inizio recupero ruolo");
        t4jn.api.uin("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(ID)), Op0);
        t4jn.api.getResult(Op0, InfoRuoloDisp);
        if(not(InfoRuoloDisp == null)) {
            t4jn.api.getArg(InfoRuoloDisp, 0, ArtifAtom);
            t4jn.api.getArg(ArtifAtom, 0, ArtifId);
            +ruoloCorrente(ArtifId);
            .print("Ruolo assegnatomi ", ArtifId);
        } else {
            .print("Errore recupero ruolo");
        }
        .print("Fine recupero ruolo").


+!recuperaStanza
    <-
        .print("Inizio recupero stanza");
        t4jn.api.uin("default", "127.0.0.1", "20504", stanza(St), Op0);
        t4jn.api.getResult(Op0, StanzaAtom);
        if(not(StanzaAtom == null)) {
            t4jn.api.getArg(StanzaAtom, 0, StanzaId);
            +stanzaCorrente(StanzaId);
            .print("Stanza assegnatomi ", StanzaId);
        } else {
            .print("Errore recupero stanza");
        }
        .print("Fine recupero stanza").

/* Handle movement */

+!goto(Player) // if arrived at destination Player
	: at(Player)
	<- true. // that's all, do nothing

+!goto(Player) // if NOT arrived at destination Player
	: not at(Player)
	<- move_towards(Player);
	!goto(Player). // continue attempting to reach destination


+hello[source(A)]
	<- .print("va che roba mi ha scritto quell'inetto di:", A).