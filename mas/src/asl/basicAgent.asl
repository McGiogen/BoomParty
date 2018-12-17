{ include("tucsonBaseWrapper.asl") }
{ include("basicRules.asl") }
{ include("communication.asl") }
{ include("timerHelper.asl") }

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
knowledge([]).              // Contenuto: know(name(Name), ruolo(val(Role), conf(ConfRole)), team(val(Team), conf(ConfTeam))))
riferimentoTimer.           // Artifact name del timer della stanza in cui mi trovo
riferimentoTimerAlt.        // Artifact name del timer dell'altra stanza
ruoloLeader.                // Booleano che indica se sono il leader della stanza corrente o meno
turnoIniziato(false).       // Booleano che indica se il turno è già inizato

/* Environment percepts */
// area(roomA|roomB|hallway)
// position(X,Y)
// players([ player( name(N), area(A), position(X,Y) ), ... ])

// visible_players(List)
// neighbors(List)

/* Rules */
votaPerNuovoLeader(Sender) :-
    knowledge(KnowledgeList)
    & .member(know(name(Sender), ruolo(val(_), conf(_)), team(val(ValTeam), conf(_))), KnowledgeList)
    & ruoloCorrente(CardArtifName)
    & lookupArtifact(CardArtifName, CardArtifID)
    & getTeam(MyTeam)[artifact_id(CardArtifID)]
    & ValTeam = MyTeam.

/* Valuta se Room è la mia stanza */
inMyRoom(Room) :-
    stanzaCorrente(R)
    & Room = R.

numberOfPlayerInMyRoom(N) :-
    visible_players(Playerlist) &
    .length(Playerlist, N).

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

+!assegnaRuoli
    <-
        .print("Inizio assegnazione ruoli");
        !tucsonOpIn(initialRole(redTeam(RTL), blueTeam(BTL), greyTeam(GTL)), OpRole);
        t4jn.api.getResult(OpRole, InitialRole);
        if (InitialRole \== null) {
            // Inizializzo il suffisso per la creazione delle carte
            +suffissoCarta(0);

            ElencoTeam = ["rosso", "blu", "grey"];
            for( .member(Team, ElencoTeam) ) {
                .nth(Pos, ElencoTeam, Team);
                t4jn.api.getArg(InitialRole, Pos, TeamAtom);
                t4jn.api.getArg(TeamAtom, 0, RoleStr);
                if( .string(RoleStr) ) {
                    .term2string(RoleArray, RoleStr);
                    for( .member(Role, RoleArray) ){
                        ?suffissoCarta(Suffix);
                        .concat("Card", Suffix, CardName);
                        makeArtifact(CardName, "it.unibo.boomparty.domain.artifacts.Card", [Team, Role], CardId);
                        -+suffissoCarta(Suffix+1);
                        !tucsonOpOut(infoRuoloDisp(artifName(CardName)), OpR);
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
        t4jn.api.uin("default", "127.0.0.1", "20504", infoRuoloDisp(artifName(NAME)), Op0);
        t4jn.api.getResult(Op0, InfoRuoloDisp);
        if (InfoRuoloDisp \== null) {
            t4jn.api.getArg(InfoRuoloDisp, 0, ArtifAtom);
            t4jn.api.getArg(ArtifAtom, 0, ArtifactName);
            +ruoloCorrente(ArtifactName);
            .print("Ruolo assegnatomi ", ArtifactName);
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
            } else {
                +ruoloLeader(false);
            }

            // Recupero i nomi dei Timer per potervi fare il focus successivamente
            !recuperaNomiTimer;

            // Effettuo focus sul timer
            !focusTimer;

            t4jn.api.in("default", "127.0.0.1", "20504", player(name(MioNome),room(R)), OpIU);
            t4jn.api.out("default", "127.0.0.1", "20504", player(name(MioNome),room(StanzaAssegnAtom)), OpOU);
            start_in_area(StanzaAssegnAtom);
        } else {
            .print("Errore recupero stanza");
        }
        .print("Fine recupero stanza").

/* Operazioni round di gioco */
+!giocaRound
    <-
        .print("Inizio a giocare il round");

        ?turnoIniziato(Iniziato);

        if (Iniziato == false) {
            // Turno non iniziato, devo controllare per attivare il timer
            // Controllo se sono leader, nel qual caso faccio partire il timer
            ?ruoloLeader(IsMeLeader);

            if (IsMeLeader \== false) {
                ?name(Me);
                .print(Me, " sono il leader, devo avviare il timer e avvertire gli altri");

                // Recupero l'id dell'artefatto Timer per essere sicuro di effettuare
                // le operazioni sull'artefatto a cui faccio riferimento
                ?riferimentoTimerID(TimerID);

                // Imposto il minutaggio e faccio partire il timer
                setMinutes(1) [artifact_id(TimerID)];
                startTimer [artifact_id(TimerID)];
            }

            // Imposto turno iniziato
            +turnoIniziato(true);
        }

        ?knowledge(StartKnowledge);
        ?visible_players(Playerlist);

        .length(StartKnowledge, NumKnowledge);
        .length(Playerlist, NumPlayers);
        .print("Conosco ", NumKnowledge, " su ", NumPlayers, " giocatori");

        if (NumKnowledge < NumPlayers) {
            // Cerco una persona con cui parlare
            +tmp(null);
            +index(0);
            while (index(I) & tmp(Target) & Target == null) {
                .nth(I, Playerlist, TempName);
                //?Temp( name(TempName), role(R), team(T) area(A), position(X,Y), confidence(C) );
                if (not(.member(know(name(TempName), ruolo(val(_), conf(_)), team(val(_), conf(_))), StartKnowledge))) {
                    -+tmp(TempName);
                }
                -+index(I+1);
            }
            ?tmp(Target);
            -tmp(Target);
            -index(_);
            .print("TROVATO ", Target);

            !goto(Target);

            // TODO scambia informazioni con il giocatore raggiunto
            .wait(3000)

            .union(StartKnowledge, [know(name(Target), ruolo(val(null), conf(null)), team(val(red), conf(100)))], NewKnowledge);
            -+knowledge(NewKnowledge);

            !giocaRound
        } else {
            // TODO anyone
            .print("Conosco tutti... e ora cosa faccio?");

            // Test regola voto leader
            /*
            ?visible_players(Playerlist);
            .nth(0, Playerlist, Name);
            .print("Controllo se voto per ", Name);
            ?votaPerNuovoLeader(Name);
            .print("SI, VOTEREI ", Name);
            */

            // Test implementazione regola voto leader
            /*
            ?visible_players(Playerlist);
            .nth(0, Playerlist, Name);
            .print("Controllo se voto per ", Name);
            ?knowledge(KnowledgeList);
            .member(know(name(Sender), ruolo(val(_), conf(_)), team(val(ValTeam), conf(_))), KnowledgeList);
            ?ruoloCorrente(CardArtifName);
            lookupArtifact(CardArtifName, CardArtifID);
            .print("La mia carta: ", CardArtifID, "/", CardArtifName, ", il suo team: ", ValTeam);
            getTeam(MyTeam)[artifact_id(CardArtifID)];
            if (ValTeam = MyTeam) {
                .print("SI, VOTEREI ", Name);
            } else {
                .print("NO, NON VOTEREI PER ", Name);
            }
            */
        }
        .

/* Triggerato dal signal dell'artifact Timer */

+roundStarted
    <-
        ?name(Me);
        .print(Me, " ha percepito l'inizio del timer!").

+roundEnded
    : ruoloLeader(true)
    <-
        .print("Percepito lo scadere del timer!");
        +turnoIniziato(false).

+roundEnded
    : ruoloLeader(false)
    <-
        .print("Percepito lo scadere del timer!");
        +turnoIniziato(false);
        ?name(Me);
        ?stanzaCorrente(R);
        .broadcast(tell, end_round_ack(Me, R)).

// messaggio emesso dagli agenti che hanno terminato il turno
+end_round_ack(Player, Room)[source(A)]
    : ruoloLeader(true) & inMyRoom(Room) & numberOfPlayerInMyRoom(N) & .count(end_round_ack(_, Room), N)
    <-
        // todo: qui andrebbe gestito se io stesso leader non sto facendo ben altro.. nel senso che devo avere turnoIniziato(false)
        .print("Tutti i player della mia stanza hanno terminato il turno! ", Room);
        .abolish(end_round_ack(_, Room)); // per non portarmi dietro gli ack di ogni round
        !scambiaPlayer.

/* Mid turn phase */

+!scambiaPlayer
    <-
        .print("Scambio i player").

/* Handle movement */

+!goto(Player) // if arrived at destination Player
	: at(Player)
	<- true. // that's all, do nothing

+!goto(Player) // if NOT arrived at destination Player
	: not at(Player)
	<- move_towards(Player);
	!goto(Player). // continue attempting to reach destination

