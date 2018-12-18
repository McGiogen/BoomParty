{ include("artifactHelper.asl") }

/* Focus tramite ArtifactName dell'artefatto timer */
+!focusTimer
    <-
        ?riferimentoTimer(TimerName);

        !focusByNomeLogico(TimerName, TimerID);

        +riferimentoTimerID(TimerID);

        .print("Fine plan focussaTimerByNameLogico").

-!focusTimer
    <-
        ?riferimentoTimer(TimerName);
        .print(TimerName, " non trovato");
        .wait(1000);
        .print("Riprovo a fare la lookup su artefatto ", TimerName);
        !focusTimerByNomeLogico.

+!defocusTimer
    <-
        ?riferimentoTimer(TimerName);
        ?riferimentoTimerID(TimerID);
        !defocusById(TimerName, TimerID).

-!defocusTimer
    <-
        ?riferimentoTimer(TimerName);
        .print("Errure durante il defocus del timer ", TimerName).

+!creaArtefattoTimer(StanzaId, TimerName)
    <-
        makeArtifact(TimerName, "it.unibo.boomparty.domain.artifacts.Timer", [], TimerRoomX);
        .print(TimerName, " creato");
        !tucsonOpOut(timer(room(StanzaId),timerName(TimerName)), OpTimerX).

/* Recupero dei riferimenti artefatti Timer con allocamento in belief:
 *
 * - riferimentoTimer       per il Timer della stanza del giocatore
 * - riferimentoTimerAlt    per il Timer dell'altra stanza
 */
+!recuperaNomiTimer
    <-
        .print("Recupero nomi timer");
        !tucsonOpRdAll(timer(room(Stanza),timerName(TimerName)), OpR);
        t4jn.api.getResult(OpR, TimersList);

        if (TimersList \== null) {
            // recupero il riferimento alla stanza in cui mi trovo per fare valutazioni
            // all'interno del ciclo for, in modo da sapere quale timer è quello su cui
            // dovrò fare focus e quale timer salvare come "l'altro"
            ?stanzaCorrente(StanzaCorrente);

            .term2string(StanzaCorrente, StanzaCorrenteStr);

            for( .member(TimeLiteralStr, TimersList) ) {
                // Recuperando tramite .member si vede che perde
                // il fatto di essere un literal
                .term2string(TimerLiteral, TimeLiteralStr);

                t4jn.api.getArg(TimerLiteral, 0, StanzaLiteral);
                t4jn.api.getArg(StanzaLiteral, 0, Stanza);

                //.term2string(Stanza, StanzaStr);

                t4jn.api.getArg(TimerLiteral, 1, TimerNameLiteral);
                t4jn.api.getArg(TimerNameLiteral, 0, TimerName);

                .print("Trovato Timer ", TimerName, " per stanza ", Stanza, " e mia stanza è ", StanzaCorrente);

                if (Stanza = StanzaCorrenteStr) {
                    .print(TimerName, " è il timer della mia stanza");
                    +riferimentoTimer(TimerName);
                } else {
                    .print(TimerName, " è il timer dell'altra stanza");
                    +riferimentoTimerAlt(TimerName);
                }
            }
        } else {
            .print("Nessun nome recuperato");
        }

        .print("Terminato plan recupero nomi timer").

/* Logica per invertire i riferimenti del timer */
+!invertiTimer
    <-
        .print("Inizio plan per scambio riferimento timer");

        // Tolgo il focus dal timer attuale
        !defocusTimer;

        ?riferimentoTimer(OldTimer);
        ?riferimentoTimerAlt(NewTimer);

        // Inverto il riferimento al timer
        +riferimentoTimer(NewTimer);
        +riferimentoTimerAlt(OldTimer);

        // Effettuo il focus sul nuovo timer
        !focuTimer;

        .print("Fine plan per scambio riferimento timer").