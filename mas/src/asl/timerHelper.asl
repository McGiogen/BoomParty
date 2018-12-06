{ include("artifactHelper.asl") }

// Focus tramite ArtifactName dell'artefatto timer
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
        ?riferimentoTimerID(TimerID);
        !defocusById(TimerID).

-!defocusTimer
    <-
        ?riferimentoTimer(TimerName);
        .print("Errure durante il defocus del timer ", TimerName).