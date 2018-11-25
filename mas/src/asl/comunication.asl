+!inviaRichiestaInfo(Target, Mode, FlagOnlyTeam)
    <- !inviaRichiestaInfo(Target, Target, Mode, FlagOnlyTeam).

/**
    Metodo per l'invio di una richiesta di informazioni.
    Receiver: Agente a cui inviare la richiesta
    Target: Agente di cui si vogliono sapere informazioni
    Mode: come avviene lo scambio info, "parlato"|"carta"
    FlagOnlyTeam: se scambiare solo il team o tutto, true|false

    Invia il seguente beliefs: richiestaInfo(target, mode, flagOnlyTeam)
*/
+!inviaRichiestaInfo(Receiver, Target, Mode, FlagOnlyTeam)
    : Mode == "parlato" | (Mode == "carta" & Target == Receiver)
    <-
        Belief = richiestaInfo(Target, Mode, FlagOnlyTeam);
        +waitingRispostaInfo(Receiver, Belief);
        .send(Receiver, tell, Belief).

/**
    Sender mi ha chiesto delle informazioni su un giocatore (Target).
*/
+richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)]
    : Mode == "parlato" | (Mode == "carta" & Target == Sender)
    <-
        // TODO scegliere quando rifiutare una richiesta
        if (Mode == "parlato") {
            !inviaRispostaInfo(Sender, Target, "parlato", FlagOnlyTeam);
        } elif (Mode == "carta") {
            // TODO implementare scambio "carta"
        }
        -richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)].

/**
    Sender ha rifiutato una mia richiesta di informazioni.
*/
+rispostaInfoNegata[source(Sender)]
    <-
        -waitingRispostaInfo(Sender, Any).

/**
    Sender ha accettato uno scambio e mi ha risposto ad una richiesta di informazioni
    sul giocatore Target. Ero in attesa di una sua risposta.
*/
+rispostaInfo(CardTeam, CardRole)[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, "parlato", FlagOnlyTeam))
    <-
        !inviaRispostaInfo(Sender, Target, "parlato", FlagOnlyTeam);
        -waitingRispostaInfo(Sender, Any);

        // Ci hanno inviato la squadra (Team) e -forse- il ruolo (CardRole) di un giocatore (Target)
        !updateKnowledge(Sender, Target, "parlato", CardTeam, CardRole);
        -rispostaInfo(CardTeam, CardRole)[source(Sender)].

/**
    Sender mi aveva richiesto uno scambio di informazioni. Io ho inviato quanto richiesto e
    ora lui mi ha risposto con le informazioni richieste in cambio.
*/
+rispostaInfo(CardTeam, CardRole)[source(Sender)]
    <-
        // Ci hanno inviato la squadra (Team) e -forse- il ruolo (CardRole) di un giocatore (Target)
        !updateKnowledge(Sender, Target, "parlato", CardTeam, CardRole);
        -rispostaInfo(CardTeam, CardRole)[source(Sender)].

/**
    Metodo per l'invio di una risposta ad una richiesta di informazioni.
    Receiver: Agente a cui inviare la risposta
    Target: Agente di cui sono state chieste informazioni
    Mode: come avviene lo scambio info, "parlato"|"carta"
    FlagOnlyTeam: se scambiare solo il team o tutto, true|false

    Invia il seguente beliefs: rispostaInfo(cardTeam, cardRole)
*/
+!inviaRispostaInfo(Receiver, Target, Mode, FlagOnlyTeam)
    <-
        if (Target == Receiver) {
            ?ruoloCorrente(CardArtifName);
            // TODO ANDREA Controlla che funzioni
            // focus(CardArtifName);
            // getTeam(CardTeam);

            // REMOVE ANDREA Rimuovi dopo il TODO qui sopra
            ?team(CardTeam);
            ?ruolo(CardRole);
        } else {
            // TODO Recuperare le info di Target da knowledge()
        }

        if (FlagOnlyTeam == true) {
            Belief = rispostaInfo(CardTeam, null);
        } else {
            // TODO ANDREA
            // getRole(CardRole);
            Belief = rispostaInfo(CardTeam, CardRole);
        }
        .send(Receiver, tell, Belief).
