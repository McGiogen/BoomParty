{ include("tucsonBaseWrapper.asl") }
{ include("knowledge.asl") }

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
    Nel caso sia in possesso alle informazioni richieste su target e nel caso mi interessino le informazioni di sender rispondo affermativamente
*/
+richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)]
    <-
        // TODO TESTARE BENE TUTTI I POSSIBILI CASI (in particolare caso in cui FlagOnlyTeam=true e nella knoledge ci sia ValRuoloSen e non ci sia ConfTeamSen )
        .print("richiestaInfo ", Target, Sender);
        ?name(MyName);
        !getTargetKnowledge(Target, TargetKnowledge);
        if(MyName == Target | TargetKnowledge \== null) {
            know(name(Tar), ruolo(val(ValRuoloTar), conf(ConfRuoloTar)), team(val(ValTeamTar), conf(ConfTeamTar))) = TargetKnowledge;
            if(FlagOnlyTeam == false | ValTeam \== null | MyName == Target) {
                !getTargetKnowledge(Sender, SenderKnowledge);
                if(SenderKnowledge \== null) {
                    know(name(Sen), ruolo(val(ValRuoloSen), conf(ConfRuoloSen)), team(val(ValTeamSen), conf(ConfTeamSen))) = SenderKnowledge;
                    if (Mode == "parlato") {

                        if( ConfRuoloSen<50 | (FlagOnlyTeam==true & (ValTeamSen==null | ( ConfTeamSen \== null & ConfTeamSen<50)))) {
                            if(Mode == "carta") {
                                //comunico tramite send di aver accettato la richiesta
                                .send(Sender, tell, rispostaInfoAccetta);
                            }
                            !inviaRispostaInfo(Sender, Target, Mode, FlagOnlyTeam);
                        } else {
                            .send(Sender, tell, rispostaInfoNegata);
                        }
                    } else {
                        .send(Sender, tell, rispostaInfoNegata);
                    }
                } elif (Mode == "parlato" | MyName == Target) {
                    if(Mode == "carta") {
                        //comunico tramite send di aver accettato la richiesta
                        .send(Sender, tell, rispostaInfoAccetta);
                    }
                    !inviaRispostaInfo(Sender, Target, Mode, FlagOnlyTeam);
                } else {
                    .send(Sender, tell, rispostaInfoNegata);
                }
            } else {
                .send(Sender, tell, rispostaInfoNegata);
            }
        } else {
            .send(Sender, tell, rispostaInfoNegata);
        }
        -richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)].

/**
    Sender ha rifiutato una mia richiesta di informazioni. todo testare
*/
+rispostaInfoNegata[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, Mode, FlagOnlyTeam))
    <-
        -waitingRispostaInfo(Sender, richiestaInfo(Target, Mode, FlagOnlyTeam)).

/**
    Sender ha accettato uno scambio carta. Ero in attesa di una sua risposta.
*/
+rispostaInfoAccetta[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, "carta", FlagOnlyTeam))
    <-
        -waitingRispostaInfo(Sender, richiestaInfo(Target, "carta", FlagOnlyTeam));
        -rispostaInfoAccetta[source(Sender)];
        !inviaRispostaInfo(Sender, Target, "carta", FlagOnlyTeam);.

/**
    Sender ha accettato uno scambio e mi ha risposto ad una richiesta di informazioni
    sul giocatore Target. Ero in attesa di una sua risposta.
*/
+rispostaInfo(Target, CardTeam, CardRole)[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, "parlato", FlagOnlyTeam))
    <-
        .print("rispostaInfo con richiesta risposta, inizio");
        ?name(MyName);
        !inviaRispostaInfo(Sender, MyName, "parlato", FlagOnlyTeam);
        -waitingRispostaInfo(Sender, richiestaInfo(Target, "parlato", FlagOnlyTeam));

        // Ci hanno inviato la squadra (Team) e -forse- il ruolo (CardRole) di un giocatore (Target)
        !updateKnowledge(Sender, Target, "parlato", CardTeam, CardRole);
        -rispostaInfo(Target, CardTeam, CardRole)[source(Sender)].

/**
    Sender mi aveva richiesto uno scambio di informazioni. Io ho inviato quanto richiesto e
    ora lui mi ha risposto con le informazioni richieste in cambio.
*/
+rispostaInfo(Target, CardTeam, CardRole)[source(Sender)]
    <-
        // Ci hanno inviato la squadra (Team) e -forse- il ruolo (CardRole) di un giocatore (Target)
        .print("rispostaInfo senza richiesta risposta, inizio");
        !updateKnowledge(Sender, Target, "parlato", CardTeam, CardRole);
        -rispostaInfo(Target, CardTeam, CardRole)[source(Sender)].

/**
    Metodo per l'invio di una risposta ad una richiesta di informazioni.
    Receiver: Agente a cui inviare la risposta
    Target: Agente di cui sono state chieste informazioni
    Mode: come avviene lo scambio info, "parlato"|"carta"
    FlagOnlyTeam: se scambiare solo il team o tutto, true|false

    Invia il seguente beliefs: rispostaInfo(Target, cardTeam, cardRole)
*/
+!inviaRispostaInfo(Receiver, Target, Mode, FlagOnlyTeam)
    <-
        .print("inviaRispostaInfo Receiver: ", Receiver, " Target: ", Target, " Mode: ", Mode, " FlagOnlyTeam: ", FlagOnlyTeam);
        if (Mode == "parlato") {
            ?name(MyName);
            if(Target == MyName) {
                ?ruoloCorrente(CardArtifName);
                lookupArtifact(CardArtifName, CardArtifID);
                getTeam(CardTeam) [artifact_id(CardArtifID)];
                getRole(CardRole) [artifact_id(CardArtifID)];
            } else {
                // TODO (Recuperare le info di Target da knowledge) TESTARE
                !getTargetKnowledge(Target, know(name(Tar), ruolo(val(CardRole), conf(ConfRuolo)), team(val(CardTeam), conf(ConfTeam))));
            }

            if (FlagOnlyTeam == true) {
                Belief = rispostaInfo(Target, CardTeam, CardRole);
            } else {
                Belief = rispostaInfo(Target, CardTeam, null);
            }
            .send(Receiver, tell, Belief);
        } elif (Mode == "carta") {

            // recupero il riferimento alla mia carta per passarlo su Tucson
            ?ruoloCorrente(CardArtifName);

            !tucsonOpOut(avvioScambioCarta(player(Receiver),artifName(CardArtifName)), OpT);
            !tucsonOpIn(rispostaScambioCarta(player(Receiver),artifName(CAN)), OpRispSC);
            t4jn.api.getResult(OpRispSC, Risposta);
            if (Risposta \== null) {
                t4jn.api.getArg(Risposta, 1, CardAtom);
                t4jn.api.getArg(CardAtom, 0, ReceiverCardArtifName);
                !updateKnowledge(Receiver, Receiver, "carta", ReceiverCardArtifName);

                // Ricevuto il nome dell'artefatto, ne recupero l'ID
                lookupArtifact(ReceiverCardArtifName, ReceiverCardArtifID);

                getTeam(ReceiverTeam) [artifact_id(ReceiverCardArtifID)];
                getRole(ReceiverRole) [artifact_id(ReceiverCardArtifID)];

                .print(ReceiverCardArtifName, " le sue info sono -> TEAM: ", ReceiverTeam, "; RUOLO: ", ReceiverRole);
            }
        }
    .print("inviaRispostaInfo ", Mode, " fine").

/*
// Il giocatore inizia una votazione per diventare leader
!startVotazioneLeader
    <-
        ?visible_players(Playerlist);
        Belief = startVotazioneLeader;
        for( .member(Receiver, Playerlist) ) {
            .send(Receiver, tell, Belief);
        }
        .wait(15000)
        !endVotazioneLeader.

// Il giocatore vota o meno per candidato leader
+startVotazioneLeader[source(Sender)]
    <-
        // TODO implementare votaPerNuovoLeader in basicAgent
        ?votaPerNuovoLeader(Sender);

        // Invio del voto solo al leader corrente e al candidato
        ?stanzaCorrente(StanzaAssegnAtom);
        !tucsonOpRd(stanzaData(id(StanzaAssegnAtom), leader(Leader)), Op0);
        .send(Leader, tell, votoLeader);
        .send(Sender, tell, votoLeader);
        -startVotazioneLeader[source(Sender)];
        .

// Un voto è stato registrato contro il giocatore o a suo favore (rispettivamente se è leader o no)
// +votoLeader[source(Voter)]

// Il giocatore termina la votazione per diventare leader
!endVotazioneLeader
    <-
        ?visible_players(Playerlist);

        .length(Playerlist, NumPlayers);
        .count(votoLeader[source(X)], NumVoti);
        if (NumVoti > NumPlayers/2) {
            // TODO cambio di leader della stanza
        }
        .abolish(votoLeader);

        Belief = endVotazioneLeader;
        for( .member(Receiver, Playerlist) ) {
            .send(Receiver, tell, Belief);
        }.

+endVotazioneLeader[source(Sender)]
    <-
        .abolish(votoLeader);
        -endVotazioneLeader[source(Sender)];
        .*/