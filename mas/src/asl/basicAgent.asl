{ include("tucsonBaseWrapper.asl") }

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
knowledge([]).

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
        !preparazioneGioco;
        .print("fine boot").

/*
+!boot
    <-  !init;
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
        !tucsonOpInp(token(X), Op0);
        t4jn.api.getResult(Op0, Result);
        if (Result \== null) {
            t4jn.api.getArg(Result, 0, TokenVal);
            if (TokenVal == "mazziere") {
                ?name(Name);
                .print("Ricevuto ruolo mazziere ", Name);
                !creaTimer;
                !assegnaRuoli;
                !assegnaStanze;
            }
            !recuperaRuolo;
            !recuperaStanza;

            // TODO attendi il timer prima di iniziare a giocare
            .wait(5000)
            !giocaRound;
        } else {
            .print("Errore recupero token mazziere");
        }
        .print("Fase iniziale di preparazione ultimata").

+!creaTimer
    <-
        .print("Inizio creazione timer per le due stanze");
        !creaArtefattoTimer(roomA, "timerRoomA");
        !creaArtefattoTimer(roomB, "timerRoomB");
        .print("Fine creazione timer").

+!creaArtefattoTimer(StanzaId, TimerName)
    <-
        makeArtifact(TimerName, "it.unibo.boomparty.domain.artifacts.Timer", [], TimerRoomX);
        .print(TimerName, " creato");
        !tucsonOpOut(timer(room(StanzaId),timerName(TimerName)), OpTimerX).

+!assegnaRuoli
    <-
        .print("Inizio assegnazione ruoli");
        !tucsonOpIn(initialRole(redTeam(RTL), blueTeam(BTL), greyTeam(GTL)), OpRole);
        t4jn.api.getResult(OpRole, InitialRole);
        if (InitialRole \== null) {

            ElencoTeam = ["rosso", "blu", "grey"];
            for( .member(Team, ElencoTeam) ) {
                .nth(Pos, ElencoTeam, Team);
                t4jn.api.getArg(InitialRole, Pos, TeamAtom);
                t4jn.api.getArg(TeamAtom, 0, RoleStr);
                if( .string(RoleStr) ) {
                    .term2string(RoleArray, RoleStr);
                    for( .member(Role, RoleArray) ){
                        .random(Suffix, 0);
                        .concat("Card", Suffix, CardName);
                        makeArtifact(CardName, "it.unibo.boomparty.domain.artifacts.Card", [Team, Role], CardId);
                        !tucsonOpOut(infoRuoloDisp(artifId(CardId)), OpR);
                    }
                }
            }
        } else {
            .print("Errore recupero carte ruolo");
        }
        .print("Fine assegnazione ruoli").

+!assegnaStanze
    <-
        .print("Inizio assegnazione stanze");
        ?players(Playerlist);
        .length(Playerlist, NumPlayers);
        for ( .range(I, 0, NumPlayers-1) ) {
            .eval(IsLeader, I < 2);
            if ( I mod 2 == 0 ) {
                t4jn.api.out("default", "127.0.0.1", "20504", stanzaAssegn(roomA, IsLeader), Op3);
            } else {
                t4jn.api.out("default", "127.0.0.1", "20504", stanzaAssegn(roomB, IsLeader), Op3);
            }
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
        t4jn.api.getResult(Op0, StanzaAssegnLiteral);
        if (StanzaAssegnLiteral \== null) {
            t4jn.api.getArg(StanzaAssegnLiteral, 0, StanzaAssegnString);
            .term2string(StanzaAssegnAtom, StanzaAssegnString);
            +stanzaCorrente(StanzaAssegnAtom);
            .print("Stanza assegnatomi ", StanzaAssegnAtom);

            t4jn.api.getArg(StanzaAssegnLiteral, 1, IsLeader);
            if (IsLeader == "true") {
                .print("Mi è stato assegnato il ruolo di leader");
                +ruoloLeader(true);
                t4jn.api.out("default", "127.0.0.1", "20504", stanzaData(id(StanzaAssegnAtom), leader(MioNome)), OpL);
                !recuperaRiferimentoTimer(StanzaAssegnAtom);
            } else {
                +ruoloLeader(false);
            }

            t4jn.api.in("default", "127.0.0.1", "20504", player(name(MioNome),room(R)), OpIU);
            t4jn.api.out("default", "127.0.0.1", "20504", player(name(MioNome),room(StanzaAssegnAtom)), OpOU);
            start_in_area(StanzaAssegnAtom);
        } else {
            .print("Errore recupero stanza");
        }
        .print("Fine recupero stanza").

+!recuperaRiferimentoTimer(StanzaId)
    <-
        .print("Recupero il timer per la stanza ", StanzaId);
        !tucsonOpRd(timer(room(StanzaId),timerName(T)), OpR);
        t4jn.api.getResult(OpR, TimerLiteral);
        if (TimerLiteral \== null) {
            t4jn.api.getArg(TimerLiteral, 1, TimerNameLiteral);
            t4jn.api.getArg(TimerNameLiteral, 0, TimerName);
            +riferimentoTimer(TimerName);
            .print("Riferimento timer per la stanza ", StanzaId," recuperato: ", TimerName);
            // TODO: fare focus dell'artefatto
            !focussaTimerByNomeLogico(TimerName);
        } else {
            .print("Errore durante recupero riferimento timer per la stanza ", StanzaId);
        }
        .print("Terminato plan recupero riferimento timer per stanza ", StanzaId).

// Focus tramite ArtifactId dell'artefatto timer
// (22/11/18: attualmente non riusciamo a recuperare l'id dell'artefatto in modo consono da Tucson)
+!focussaTimer(TimerId)
    <-
        .print("Eseguo focus su timer: ", TimerId);
        focus(TimerId).

// Focus tramite ArtifactName dell'artefatto timer
+!focussaTimerByNomeLogico(ArtifactName)
    <-
        .print("Recupero artefatto di nome: ", ArtifactName);
        lookupArtifact(ArtifactName, ArtifactId);
        focus(ArtifactId);
        .print("Artefatto ", ArtifactName, " trovato e focussato").

-!focussaTimerByNomeLogico(ArtifactName)
    <-
        .print(ArtifactName, " non trovato");
        .wait(1000);
        .print("Riprovo a fare la lookup su artefatto ", ArtifactName);
        !focussaTimerByNomeLogico(ArtifactName).

/* Triggerato dal signal dell'artifact Timer */
+timeUp
    <-
        ?name(Me);
        .print(Me, " ha percepito lo scadere del timer!").

/* Operazioni round di gioco */
+!giocaRound
    <-
        .print("Inizio a giocare il round");

        // TODO-DRIU: se è leader, deve far partire il timer
        // ?ruoloLeader(isMeLeader);

        // if (isMeLeader \== false) {
        //    ?name(Me);
        //    .print(Me, " sono il leader, devo avviare il timer e avvertire gli altri");
        // }

        ?knowledge(StartKnowledge);
        ?visible_players(Playerlist);

        .length(StartKnowledge, NumKnowledge);
        .length(Playerlist, NumPlayers);
        .print("Conosco ", NumKnowledge, " su ", NumPlayers, " giocatori");

        if (NumKnowledge < NumPlayers) {
            // Cerco una persona con cui parlare
            +tmp(null);
            +index1(0);
            while (index1(I) & tmp(Target) & Target == null) {
                .nth(I, Playerlist, TempName);
                //?Temp( name(TempName), role(R), team(T) area(A), position(X,Y), confidence(C) );
                if (not(.member(know(TempName),StartKnowledge))) {
                    -+tmp(TempName);
                }
                -+index1(I+1);
            }
            ?tmp(Target);
            .print("TROVATO ", Target);

            !goto(Target);

            // TODO scambia informazioni con il giocatore raggiunto
            .wait(3000)

            .union(StartKnowledge, [know(Target)], NewKnowledge);
            -+knowledge(NewKnowledge);

            !giocaRound
        } else {
          // TODO anyone
          .print("Conosco tutti... e ora cosa faccio?");
        }
        .


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