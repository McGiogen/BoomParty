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
stanzaCorrente(null).       // Stanza in cui si trova il giocatore

/* Environment percepts */
// area(roomA|roomB|hallway).
// position(X,Y).
// players([ player( name(N), area(A), position(X,Y) ), ... ]).

visible_players([]).    //visible_players(List)
// neighbors(List).
// going_to(position(X,Y)).

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

+?leaderStanzaCorrente(Leader)
    <-
        ?stanzaCorrente(Room);
        !tucsonOpRd(stanzaData(id(Room), leader(_)), Op0);
        t4jn.api.getResult(Op0, StanzaDataStr);
        .term2string(StanzaData, StanzaDataStr);
        stanzaData(id(Room), leader(LeaderAtom)) = StanzaData;
        .term2string(LeaderAtom, Leader);
        .

+?numberOfOstaggi(NumOstaggi)
    <-
        ?turnoNumero(T);
        ?players(Players);
        .length(Players, N);
        if (N <= 13) {
            .nth(T-1, [2,2,1,1,1], NumOstaggi);
        } elif (N <= 17) {
            .nth(T-1, [3,2,2,1,1], NumOstaggi);
        } elif (N <= 21) {
            .nth(T-1, [4,3,2,1,1], NumOstaggi);
        } else {
            .nth(T-1, [5,4,3,2,1], NumOstaggi);
        }
        .

+!boot
    <-  ?name(X);
        .print("PLAYER ", X, " START!");
        !preparazioneGioco;

        if (ruoloLeader(true)) {
            // Attendi che tutti i giocatori siano pronti prima di iniziare a giocare
            .wait(3000);
            !avviaRound;
        }

        .print("fine boot").

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
            -+stanzaCorrente(StanzaAssegnAtom);
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

/* Triggerato dal signal dell'artifact Timer */

+roundStarted
    <-
        .print("Percepito l'inizio del timer!");
        ?turnoNumero(Index);
        -+turnoNumero(Index + 1);
        -+turnoIniziato(true);
        .perceive;
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
    : ruoloLeader(true) & stanzaCorrente(Room) & numberOfPlayerInMyRoom(N) & .count(end_round_ack(_, Room), N)
    <-
        // todo: qui andrebbe gestito se io stesso leader non sto facendo ben altro.. nel senso che devo avere turnoIniziato(false)
        .print("Tutti i player della mia stanza hanno terminato il turno! ", Room);
        .abolish(end_round_ack(_, Room)); // per non portarmi dietro gli ack di ogni round
        !scambiaPlayer.

/* Handle ostaggi */

+!scambiaPlayer
    <-
        .print("Scambio i player");
        // TODO GIO 1: Lascia decidere gli ostaggi ad intelligentAgent e poi invia messaggio ai giocatori scelti
        ?stanzaCorrente(StanzaAssegnAtom);
        ?numberOfOstaggi(NumOstaggi);
        ?visible_players(Players);

        for (.range(I, 0, NumOstaggi-1)) {
            .nth(I, Players, Ostaggio);
            .send(Ostaggio, tell, ostaggio);
            .print("Ostaggio n.", (I+1), ": ", Ostaggio);
        }
        .

// TODO GIO 2: Se il leader ti dice che sei un ostaggio, spostati nell'altra stanza e avvisa l'altro leader di essere arrivato
+ostaggio
    : ruoloLeader(false)
    <-
        ?stanzaCorrente(Partenza);
        if (Partenza = roomA) {
            Arrivo = roomB;
        } else {
            Arrivo = roomA;
        }

        !goinStart(Arrivo);
        while (not going_to(null)) {
            !goin(Arrivo);
        }
        // Aggiorno riferimento stanza corrente
        -+stanzaCorrente(Arrivo);

        // Aggiorno riferimento timer
        !invertiTimer;

        -ostaggio;

        // Comunico il mio arrivo al leader della nuova stanza
        ?leaderStanzaCorrente(Leader);
        .send(Leader, tell, arrivoOstaggio);
    .

// TODO GIO 3: Quando i nuovi ostaggi arrivano, avvisano il leader. Una volta che sono tutti arrivati
// TODO GIO 3  ...il leader fa partire il timer per il round successivo o il mazziere fa il calcolo dei vincitori
+arrivoOstaggio[source(Ag)]
    <-
        ?numberOfOstaggi(Attesi);
        .count(arrivoOstaggio[source(_)], Arrivati);

        if (Arrivati >= Attesi) {
            .abolish(arrivoOstaggio);
            !avviaRound;
        } else {
            +arrivoOstaggio[source(Ag)];
        }
        .

/* Handle movement */

// GO TO
+!goto(Player) // if arrived at destination Player
	: at(Player)
	<- true. // that's all, do nothing

+!goto(Player) // if NOT arrived at destination Player
	: not at(Player)
	<- move_towards(Player).

// GO IN
+!goinStart(Area) // goin needs a start to define a free position in Area, without tests
    <- move_in(Area).

+!goin(Area) // if arrived at free position in Area
    : going_to(null)
    <- true.

+!goin(Area) // if NOT arrived at free position in Area
    : not going_to(null)
    <- move_in(Area).


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