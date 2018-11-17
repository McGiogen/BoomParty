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
// neighbors(List)

/* Initial rules */
list_contains([], _) :- false.
list_contains([X|_], X) :- true.
list_contains([Elem|Tail], X) :- list_contains(Tail, X).
at(P) :- neighbors(List) & list_contains(List, P).


/* Initial goals */

!boot.

+!boot
    <-  ?name(X);
        .print("PLAYER ", X, " START!");
        //!init
        !preparazioneGioco
        .print("fine boot").

/*
+!boot
    <-  !init
        ?visible_players(Players);
        .nth(0, Players, NearestPlayer);    // Choosing the nearest (first) player
        !goto(NearestPlayer).
*/

/*
+!init
    <-
    	.all_names(List);
    	.print("All players: ", List).
    	//it.unibo.boomparty.agent.operations.nearPlayers(X, NearP);
    	//.print("I giocatori vicini a me sono: ", NearP).
*/


/* Operazioni fase iniziale partita */

+!preparazioneGioco
    <-
        t4jn.api.inp("default", "127.0.0.1", "20504", token(X), Op0);
        t4jn.api.getResult(Op0, Result);
        if (Result \== null) {
            t4jn.api.getArg(Result, 0, TokenVal);
            if (TokenVal == "mazziere") {
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
        //?players(Playerlist);
        // todo Luca: sostituire PlayerList con la tupla dei ruoli
        //.print(Playerlist);
        //for ( .member(X,Playerlist) ) {
            //.print(X);    // print all members of the list
            // ?X(name(Y));
            // makeArtifact("Card1", "it.unibo.boomparty.domain.artifacts.Card", ["pagliaccio"], CardId);
            // t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(CardId)), Op1);
        //}
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(1111)), Op1);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(2222)), Op2);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(3333)), Op3);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(4444)), Op4);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(11511)), Op51);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(22522)), Op52);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(33533)), Op53);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(44544)), Op54);
        t4jn.api.out("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(11211)), Op551);
        .print("Fine assegnazione ruoli").

+!assegnaStanze
    <-
        .print("Inizio assegnazione stanze");
        ?players(Playerlist);
        .length(Playerlist, NumPlayers);
        for ( .range(I, 0, NumPlayers-1) ) {
            .eval(IsLeader, I < 2);
            t4jn.api.out("default", "127.0.0.1", "20504", stanzaAssegn(I mod 2 + 1, IsLeader), Op3);
        }
        .print("Fine assegnazione stanze").

+!recuperaRuolo
    <-
        .print("Inizio recupero ruolo");
        t4jn.api.uin("default", "127.0.0.1", "20504", infoRuoloDisp(artifId(ID)), Op0);
        t4jn.api.getResult(Op0, InfoRuoloDisp);
        if (InfoRuoloDisp \== null) {
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
        ?name(MioNome);
        t4jn.api.uin("default", "127.0.0.1", "20504", stanzaAssegn(St, IsL), Op0);
        t4jn.api.getResult(Op0, StanzaAssegnAtom);
        if (StanzaAtom \== null) {
            t4jn.api.getArg(StanzaAssegnAtom, 0, StanzaAssegnId);
            +stanzaCorrente(StanzaAssegnId);
            .print("Stanza assegnatomi ", StanzaAssegnId);

            t4jn.api.getArg(StanzaAssegnAtom, 1, IsLeader);
            if (IsLeader == "true") {
                .print("Mi è stato assegnato il ruolo di leader");
                +ruoloLeader(true);
                t4jn.api.out("default", "127.0.0.1", "20504", stanzaData(id(StanzaAssegnId), leader(MioNome)), OpL);
            } else {
                +ruoloLeader(false);
            }

            t4jn.api.in("default", "127.0.0.1", "20504", player(name(MioNome),room(R)), OpIU);
            t4jn.api.out("default", "127.0.0.1", "20504", player(name(MioNome),room(StanzaAssegnId)), OpOU);
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