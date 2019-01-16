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
giocoFinito(false).         // Booleano che indica se è stato recepito il segnale di gameEnded

/* Environment percepts */
// area(roomA|roomB|hallway).
// position(X,Y).
// players([ player( name(N), area(A), position(X,Y) ), ... ]).

//visible_players(List)
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

+?leaderAltraStanza(Leader)
    <-
        ?stanzaCorrente(Stanza);
        if (Stanza = roomA) {
            AltraStanza = roomB;
        } else {
            AltraStanza = roomA;
        }
        !tucsonOpRd(stanzaData(id(AltraStanza), leader(_)), Op0);
        t4jn.api.getResult(Op0, StanzaDataStr);
        .term2string(StanzaData, StanzaDataStr);
        stanzaData(id(AltraStanza), leader(LeaderAtom)) = StanzaData;
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
            // Niente? Il gioco è finito e devono essere stampati i risultati
        }
        .

+!giocaRound
    : turnoIniziato(false)
    <-
        ?name(Me);
        ?stanzaCorrente(R);
        if (not ruoloLeader(true)) {
            ?leaderStanzaCorrente(Leader);
            .send(Leader, tell, end_round_ack(Me, R));
        } else {
            +end_round_ack(Me, R);
        }
        .

// Gestione failure del plan
-!giocaRound
    <- !giocaRound.

/* Triggerato dal signal dell'artifact Timer */

+roundStarted
    <-
        .print("Percepito l'inizio del timer!");
        ?turnoNumero(Index);
        -+turnoNumero(Index + 1);
        -+turnoIniziato(true);
        !giocaRound.

+roundEnded
    <-
        .print("Percepito lo scadere del timer!");
        -+turnoIniziato(false);
        !fineRound; // Pulizia gestita da intelligentAgent
        .

// messaggio emesso dagli agenti che hanno terminato il turno
+end_round_ack(Player, Room)[source(A)]
    : ruoloLeader(true) & stanzaCorrente(Room) & numberOfPlayerInMyRoom(N) & .count(end_round_ack(_, Room), N+1)
    <-
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

        .abolish(ostaggio);

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
            // Aggiungo controllo anche sul fatto che non sia già finito il gioco
            // ovvero che l'altro leader abbia già dato il tana libera tutti
            if (turnoNumero(5) & giocoFinito(false)) {
                .broadcast(tell, gameEnded);
                !rivelaRuolo;
            } else {
                // Avverto l'altro leader che i miei ostaggi sono arrivati
                ?stanzaCorrente(Stanza);
                ?leaderAltraStanza(Leader);
                .send(Leader, tell, ostaggiArrivati(Stanza));

                +ostaggiArrivati(Stanza);

                // Quando gli ostaggi di entrambe le stanze sono arrivati inizia il nuovo turno
                if (.count(ostaggiArrivati(_)) > 1) {
                    .abolish(ostaggiArrivati(_));
                    !avviaRound;
                }
            }
        } else {
            +arrivoOstaggio[source(Ag)];
        }
        .

+ostaggiArrivati(Stanza)[source(Source)]
    : Source \== self
    <-
        +ostaggiArrivati(Stanza)[source(Source)];

        // Quando gli ostaggi di entrambe le stanze sono arrivati inizia il nuovo turno
        if (.count(ostaggiArrivati(_)) > 1) {
            .abolish(ostaggiArrivati(_));
            !avviaRound;
        }
        .

+gameEnded
    : giocoFinito(false)
    <-
        -+giocoFinito(true);

        !rivelaRuolo;

        // Sono il mazziere, aspetto che tutti scrivino sul TC e poi faccio le valutazioni
        if (mazziere(true)) {
            !valutaEndGame;
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
        ?card(Team, Role);

        ?stanzaCorrente(Stanza);

        ?name(MioNome);

        //.print("Sono nella stanza ", Stanza, ", sono della squadra ", Team, " e il mio ruolo è ", Role);
        .print("Scrivo le mie info di fine partita sul Tuple Centre");

        !tucsonOpOut(statusEnd(player(MioNome),room(Stanza),team(Team),role(Role)), OpR);
        .

+!valutaEndGame // metto la guard per sicurezza, solo il mazziere è incaricato di questo compito
    : mazziere(true)
    <-
        .print("Leggo dal Tuple Centre le tuple di fine partita per fare le valutazioni");

        ?players(PlayersList);
        .length(PlayersList, NumPlayers);

        // Aggiungo belief temporaneo per supporto a lettura tuple
        +tmp([]);

        while(tmp(StatusEndList) & .length(StatusEndList, NumTuples) & NumTuples < NumPlayers) {
            // Attendo nuovamente 3 secondi prima di ricontrollare
            .wait(3000);

            !tucsonOpRdAll(statusEnd(player(_),room(X),team(_),role(Y)), OpResult);
            t4jn.api.getResult(OpResult, StatusEndListWhile);

            -+tmp(StatusEndListWhile);
        }

        -tmp(StatusEndListEnd);

        // Recupero i nomi dei leader delle due stanze per controllare il caso del "Nato leader"
        ?leaderStanzaCorrente(LeaderCorr);
        ?leaderAltraStanza(LeaderAlt);

        +natoLeader(false);
        +nomeNatoLeader(null);

        if (StatusEndListEnd \== null) {
            for (.member(PlayerStatusEndLiteralStr, StatusEndListEnd)) {
                // Recuperando tramite .member si vede che perde
                // il fatto di essere un literal
                .term2string(PlayerStatusEndLiteral, PlayerStatusEndLiteralStr);

                statusEnd(player(NomeAtom),room(StanzaAtom),team(_),role(RoleAtom)) = PlayerStatusEndLiteral;

                // Li trasformo in stringa
                .term2string(NomeAtom, Nome);
                .term2string(StanzaAtom, Stanza);
                .term2string(RoleAtom, Role);

                if (Role == "bomb") {
                    .print("Bombarolo: ", Nome);
                    -+stanzaBombarolo(Stanza);
                } elif (Role == "pres") {
                    .print("Presidente: ", Nome);
                    -+stanzaPresidente(Stanza);
                } elif (Role == "mogpres") {
                    .print("Moglie: ", Nome);
                    -+stanzaMogliePres(Stanza);
                } elif (Role == "amapres") {
                    .print("Amante: ", Nome);
                    -+stanzaAmantePres(Stanza);
                } elif (Role == "natoleader") {
                    .print("NatoLeader: ", Nome);
                    -+nomeNatoLeader(Nome);
                    if (Nome = LeaderCorr | Nome = LeaderAlt) {
                        -+natoLeader(true);
                    }
                }
            }

            .print("-------------------------------------");

            ?stanzaBombarolo(StanzaBomb);
            ?stanzaPresidente(StanzaPresidente);
            ?stanzaMogliePres(StanzaMoglie);
            ?stanzaAmantePres(StanzaAmante);

            .print("Bomb: ", StanzaBomb, " Pres: ", StanzaPresidente, " Moglie: ", StanzaMoglie, " Amante: ", StanzaAmante);

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

            ?nomeNatoLeader(NatoLeader);

            .print("NatoLeader: ", NatoLeader,", Leader stanza corrente: ", LeaderCorr, ", Leader altra stanza: ", LeaderAlt);

            // Controllo se il "Nato leader" è leader, in tal caso VINCE!
            if (natoLeader(true)) {
                .print("Nato leader è leader di una delle due stanze, EGLI VINCE!");
            } else {
                .print("Nato leader non è leader, povero lui :(");
            }

        } else {
            .print("Errore nel recupero delle info di fine partita");
        }
        .