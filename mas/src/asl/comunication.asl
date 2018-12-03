{ include("tucsonBaseWrapper.asl") }

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
        .print("inviaRichiestaInfo ", Receiver, Target);
        .send(Receiver, tell, Belief).

/**
    Sender mi ha chiesto delle informazioni su un giocatore (Target).
*/
+richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)]
    : /* FIXME Mode == "parlato" | (Mode == "carta" & Target == <MIO_NOME>)*/
        Mode == "parlato" | Mode == "carta"
    <-
        // TODO scegliere quando rifiutare una richiesta .send(Sender, tell, rispostaInfoNegata
        .print("richiestaInfo ", Target, Sender);
        if (Mode == "parlato") {
            !inviaRispostaInfo(Sender, Target, "parlato", FlagOnlyTeam);
        } elif (Mode == "carta") {
            .send(Sender, tell, rispostaInfoAccetta);
            !inviaRispostaInfo(Sender, Sender, "carta", FlagOnlyTeam);
        }
        -richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)].

/**
    Sender ha rifiutato una mia richiesta di informazioni.
*/
+rispostaInfoNegata[source(Sender)]
    : waitingRispostaInfo(S, richiestaInfo(Target, Mode, FlagOnlyTeam))
    <-
        -waitingRispostaInfo(Sender, Any).

/**
    Sender ha accettato uno scambio carta. Ero in attesa di una sua risposta.
*/
+rispostaInfoAccetta[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, "carta", FlagOnlyTeam))
    <-
        -waitingRispostaInfo(Sender, Any);
        !inviaRispostaInfo(Sender, Sender, "carta", FlagOnlyTeam);.

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
        if (Mode == "parlato") {
            if(Target == Receiver) {
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
            .send(Receiver, tell, Belief)

            !inviaRispostaInfo(Sender, Target, "parlato", FlagOnlyTeam);
        } elif (Mode == "carta") {
            // ?ruoloCorrente(CardArtifName);

            // recupero il riferimento alla mia carta per passarlo su Tucson
            ?riferimentoCarta(CardArtifName);

            !tucsonOpOut(avvioScambioCarta(player(Target),artifName(CardArtifName)), OpT);
            !tucsonOpIn(rispostaScambioCarta(player(Target),artifName(CAN)), OpRispSC);
            t4jn.api.getResult(OpRispSC, Risposta);
            if (Risposta \== null) {
                ?mioNomeString(MyName);
                ?riferimentoCartaId(MyArtifID);

                .term2String(Receiver, ReceiverStr);

                // Concedo il diritto a Receiver di leggere tutta la carta
                grantRights(MyName, ReceiverStr, "B", EsitoGrant) [artifact_id(MyArtifID)];

                if (EsitoGrant == true) {
                    .print("Concessi dirtti a ", Receiver);
                } else {
                    .print("Impossibile concedere diritti a ", Receiver);
                }

                t4jn.api.getArg(Risposta, 1, CardAtom);
                t4jn.api.getArg(CardAtom, 0, ReceiverCardArtifName);
                !updateKnowledge(Receiver, Target, "carta", ReceiverCardArtifName);

                // Ricevuto il nome dell'artefatto, ne recupero l'ID
                lookupArtifact(ReceiverCardArtifName, ReceiverCardArtifID);

                getTeam(MyName, ReceiverTeam, EsitoTeam) [artifact_id(ReceiverCardArtifID)];

                if (EsitoTeam == true) {
                    .print("TEAM: ", ReceiverTeam);
                }

                getRole(MyName, ReceiverRole, EsitoRole) [artifact_id(ReceiverCardArtifID)];

                if (EsitoRole == true) {
                    .print("RUOLO: ", ReceiverRole);
                }

                // .print(ReceiverCardArtifName, " le sue info sono -> TEAM: ", ReceiverTeam, "; RUOLO: ", ReceiverRole);

                // Concedo il diritto a Receiver di leggere tutta la carta
                removeRights(MyName, ReceiverStr, "B", EsitoRemove) [artifact_id(MyArtifID)];

                if (EsitoRemove == true) {
                    .print("Rimossi dirtti a ", Receiver);
                } else {
                    .print("Impossibile rimuovere dirtti a ", Receiver);
                }
            }
        }
    .print("inviaRispostaInfo ", Mode, " fine").