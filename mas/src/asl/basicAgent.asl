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
riferimentoTimer(null).     // Artifact name del timer della stanza in cui mi trovo
riferimentoTimerAlt(null).  // Artifact name del timer dell'altra stanza
ruoloLeader(null).          // Booleano che indica se sono il leader della stanza corrente o meno
turnoIniziato(false).       // Booleano che indica se il turno è già inizato
mazziere(false).            // Booleano che indica se il giocatore è il mazziere. Il mazziere farà le valutazioni di fine partita
ruoloCorrente(null).        // Artifact name della card in mio possesso
stanzaBombarolo(null).      // Stanza in cui si trova il bombarolo a fine partita
stanzaPresidente(null).     // Stanza in cui si trova il presidente a fine partita
stanzaMogliePres(null).     // Stanza in cui si trova la moglie del presidente a fine partita
stanzaAmantePres(null).     // Stanza in cui si trova l'amante del presidente a fine partita
turnoNumero(0).             // Numero del round corrente di gioco (5 round totali)

/* Environment percepts */
// area(roomA|roomB|hallway)
// position(X,Y)
// players([ player( name(N), area(A), position(X,Y) ), ... ])

// visible_players(List)
// neighbors(List)


/* Valuta se Room è la mia stanza */
inMyRoom(Room) :-
    stanzaCorrente(Room).

numberOfPlayerInMyRoom(N) :-
    visible_players(Playerlist) &
    .length(Playerlist, N).

/* Initial goals */

!boot.

+?card(MyTeam, MyRole)
    <-
        ?ruoloCorrente(CardArtifName);
        lookupArtifact(CardArtifName, CardArtifID);
        getTeam(MyTeam)[artifact_id(CardArtifID)];
        getRole(MyRole)[artifact_id(CardArtifID)];
        .

+?myRoomLeader(Leader)
    <-
        ?stanzaCorrente(Room);
        !tucsonOpRd(stanzaData(id(Room), leader(_)), Op0);
        t4jn.api.getResult(Op0, StanzaDataStr);
        .term2string(StanzaData, StanzaDataStr);
        stanzaData(id(Room), leader(LeaderAtom)) = StanzaData;
        .term2string(LeaderAtom, Leader);
        .

+!boot
    <-  ?name(X);
        .print("PLAYER ", X, " START!");
        !preparazioneGioco;

        if (ruoloLeader(true)) {
            // Attendi che tutti i giocatori siano pronti prima di iniziare a giocare
            .wait(3000)
            !avviaRound;
        }

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
                // Aggiorno il belief, così alla fine della partita saprò che sono io a dover tirare le somme
                -+mazziere(true);

                ?name(Name);
                .print("Ricevuto ruolo mazziere ", Name);
                !creaTimer;
                !assegnaRuoli;
                !assegnaStanze;
            }
            !recuperaRuolo;
            !recuperaStanza;
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

            ElencoTeam = ["rosso", "blu", "grigio"];
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
            -+ruoloCorrente(ArtifactName);
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
                -+ruoloLeader(true);
                t4jn.api.out("default", "127.0.0.1", "20504", stanzaData(id(StanzaAssegnAtom), leader(MioNome)), OpL);
            } else {
                -+ruoloLeader(false);
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
+!avviaRound
    : turnoIniziato(false) & ruoloLeader(true)
    <-
        // Il turno deve iniziare, attivo il timer
        ?name(Me);
        .print(Me, " sono il leader, devo avviare il timer e avvertire gli altri");

        // Recupero l'id dell'artefatto Timer per essere sicuro di effettuare
        // le operazioni sull'artefatto a cui faccio riferimento
        ?riferimentoTimerID(TimerID);

        // Imposto il minutaggio e faccio partire il timer
        ?turnoNumero(Index);

        if (Index < 5) {
            -+turnoNumero(Index + 1);
            setMinutes(5 - Index) [artifact_id(TimerID)];
            startTimer [artifact_id(TimerID)];
            .print("Avvio del ", Index + 1, "° round");
        } else {
            // TODO niente? Finisce il gioco e devono essere stampati i risultati
        }
        .

+!giocaRound
    : turnoIniziato(false)
    <- true.

+!giocaRound
    : turnoIniziato(true)
    <-
        ?knowledge(KnowList);
        ?visible_players(Playerlist);

        .length(KnowList, NumKnowledge);
        .length(Playerlist, NumPlayers);

        if (desireToKnow(Someone)) {
            if (at(Someone)) {
                .print("Provo a parlare con ", Someone);
                !tryToSpeakWith(Someone);
                -desireToKnow(Someone);
            } else {
                !goto(Someone);
            }
        } elif (NumKnowledge < NumPlayers) {
            !tryToDesireToKnow;
        } else {
            ?card(MyTeam, _);
            ?myRoomLeader(Leader);
            !getTargetKnowledge(Leader, LeaderKnow);
            if (ruoloLeader(false) & LeaderKnow \== null & know(name(_), ruolo(val(_), conf(_)), team(val(LeaderTeam), conf(_))) = LeaderKnow & LeaderTeam \== MyTeam) {
                // Il Leader non è della mia squadra, valuto se è il caso di propormi come leader
                .wait(10000);

                +conteggioPotenzialiVoti(1);
                for (.member(Player, Playerlist)) {
                    !getTargetKnowledge(Player, PlayerKnow);
                    know(name(PP), ruolo(val(_), conf(_)), team(val(PlayerTeam), conf(_))) = PlayerKnow;
                    if (PlayerTeam \== LeaderTeam) {
                        ?conteggioPotenzialiVoti(NumVoti);
                        -+conteggioPotenzialiVoti(NumVoti + 1);
                    }
                }
                -conteggioPotenzialiVoti(NumVoti);

                if (numberOfPlayerInMyRoom(Tot) & NumVoti > (Tot / 2)) {
                    .print("Provo a candidarmi come leader, ci sono ", NumVoti, " possibili voti");
                    !tryToCandidateAsLeader;
                }
            } else {
                // TODO GIO
                .print("Finito tutto... e poi cosa faccio?");

                .wait(10000);
            }
        }
        !giocaRound;
        .

+!tryToDesireToKnow
    <-
        // Cerco una persona con cui parlare
        ?knowledge(MyKnowledge);
        ?visible_players(Playerlist);
        +desireToKnow(null);

        // Per prima cosa cerco un giocatore di cui non conosco nulla
        +index(0);
        while (index(I) & desireToKnow(Target) & Target == null) {
            .nth(I, Playerlist, TempName);
            if (not(.member(know(name(TempName), ruolo(val(_), conf(_)), team(val(_), conf(_))), MyKnowledge))) {
                // Ho trovato un giocatore di cui non so nulla
                -+desireToKnow(TempName);
            }
            -+index(I+1);
        }
        -index(_);

        ?desireToKnow(Target);
        if (Target == null) {
            -desireToKnow(Target);
        }
        .

+!tryToSpeakWith(Player)
    <-
        // TODO scambia informazioni con il giocatore raggiunto
        .wait(3000);

        ?knowledge(StartKnowledge);
        .union(StartKnowledge, [know(name(Player), ruolo(val(null), conf(null)), team(val("rosso"), conf(100)))], NewKnowledge);
        -+knowledge(NewKnowledge);
        .

+!tryToCandidateAsLeader
    <-
        .count(startVotazioneLeader[source(_)], N);
        if (N == 0 & ruoloLeader(false)) {
            .print("Mi candido come leader");
            !startVotazioneLeader;
        } else {
            .print("Mi candiderei ma c'è una votazione in corso oppure sono già leader");
        }
        .

/* Triggerato dal signal dell'artifact Timer */

+roundStarted
    <-
        -+turnoIniziato(true);
        ?name(Me);
        .print(Me, " ha percepito l'inizio del timer!");
        !giocaRound.

+roundEnded
    : ruoloLeader(true)
    <-
        .print("Percepito lo scadere del timer!");
        -+turnoIniziato(false);
        !rivelaRuolo.

+roundEnded
    : ruoloLeader(false)
    <-
        .print("Percepito lo scadere del timer!");
        -+turnoIniziato(false);
        ?name(Me);
        ?stanzaCorrente(R);
        .broadcast(tell, end_round_ack(Me, R));
        !rivelaRuolo.

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
	<- move_towards(Player).

/* Handle voto leader */
+!votaPerNuovoLeader(Sender, Result)
    <-
        ?knowledge(KnowledgeList);
        if (.member(know(name(Sender), ruolo(val(_), conf(_)), team(val(ValTeam), conf(_))), KnowledgeList)) {
            ?card(MyTeam, _);
            .print("Secondo me il leader candidato ", Sender, " è del team: ", ValTeam, ". La mia carta: ", CardArtifID, "/", CardArtifName, "/", MyTeam);
            if (ValTeam = MyTeam) {
                Result = true;
            } else {
                Result = false;
            }
        } else {
            .print("Non conosco il leader candidato ", Sender, ". Non voto.");
            Result = false;
        }
        .

/* Operazioni finali */
+!rivelaRuolo
    <-
        ?card(Role, Team);

        ?stanzaCorrente(Stanza);

        ?name(MioNome);

        //.print("Sono nella stanza ", Stanza, ", sono della squadra ", Team, " e il mio ruolo è ", Role);
        .print("Scrivo le mie info di fine partita sul Tuple Centre");

        !tucsonOpOut(statusEnd(player(MioNome),room(Stanza),team(Team),role(Role)), OpR);

        // Sono il mazziere, aspetto che tutti scrivino sul TC e poi faccio le valutazioni
        if (mazziere(true)) {
            .wait(3000);
            !valutaEndGame;
        }
        .

+!valutaEndGame // metto la guard per sicurezza, solo il mazziere è incaricato di questo compito
    : mazziere(true)
    <-
        .print("Leggo dal Tuple Centre le tuple di fine partita per fare le valutazioni");

        !tucsonOpRdAll(statusEnd(player(_),room(X),team(_),role(Y)), OpResult);

        t4jn.api.getResult(OpResult, StatusEndList);

        if (StatusEndList \== null) {
            .length(StatusEndList, NumTuples);
            ?players(PlayersList);
            .length(PlayersList, NumPlayers);

            if (NumTuples == NumPlayers) {
                for (.member(PlayerStatusEndLiteralStr, StatusEndList)) {
                    // Recuperando tramite .member si vede che perde
                    // il fatto di essere un literal
                    .term2string(PlayerStatusEndLiteral, PlayerStatusEndLiteralStr);

                    t4jn.api.getArg(PlayerStatusEndLiteral, 1, StanzaLiteral);
                    t4jn.api.getArg(StanzaLiteral, 0, Stanza);

                    t4jn.api.getArg(PlayerStatusEndLiteral, 3, RoleLiteral);
                    t4jn.api.getArg(RoleLiteral, 0, Role);

                    if (Role == "bomb") {
                        -+stanzaBombarolo(Stanza);
                    } elif (Role == "pres") {
                        -+stanzaPresidente(Stanza);
                    } elif (Role == "mogpres") {
                        -+stanzaMogliePres(Stanza);
                    } elif (Role == "amapres") {
                        -+stanzaAmantePres(Stanza);
                    }
                }

                ?stanzaPresidente(StanzaPresidente);

                // Controllo se bombarolo e presidente sono nella stessa stanza
                if (stanzaBombarolo(StanzaPresidente)) {
                    .print("Bombarolo in stanza del presidente, vince la squadra ROSSA!");
                } else {
                    .print("Presidente in stanza senza il bombarolo, vince la squadra BLU!");
                }

                // Controllo se moglie del presidente o l'amante sono nella stanza con il presidente
                // senza l'altra contro parte, per decretare chi ha vinto fra le due
                if (stanzaMogliePres(StanzaPresidente)) {
                    if (stanzaAmantePres(StanzaPresidente)) {
                        .print("Moglie e amante del presidente in stessa stanza, non vince nessuna delle due!");
                    } else {
                        .print("Moglie del presidente in stanza col presidente senza la perfida amante, la Moglie vince!");
                    }
                } elif (stanzaAmantePres(StanzaPresidente)) {
                    .print("Amante del presidente in stanza col presidente senza quella racchia della moglie, l'Amante vince!");
                } else {
                    .print("Moglie e Amante del presidente non sono con il presidente, peccato...");
                }
            } else {
                .print("Il numero di tuple sul Tuple Centre non corrisponde col numero di giocatori, impossibile valutare!");
            }
        } else {
            .print("Errore nel recupero delle info di fine partita");
        }

        .