{ include("tucsonBaseWrapper.asl") }
{ include("knowledge.asl") }
{ include("conversationTracker.asl") }

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
        +attendiFineConversazione(Receiver, Mode, FlagOnlyTeam);
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
        -richiestaInfo(Target, Mode, FlagOnlyTeam)[source(Sender)];
        if (not attendiFineConversazione(_ , _ , _)) {
            +attendiFineConversazione(Sender, Mode, FlagOnlyTeam);
            .print("richiestaInfo ", Target, " ", Sender);
            ?name(MyName);
            !getTargetKnowledge(Target, TargetKnowledge);
            if( (MyName == Target | TargetKnowledge \== null)) {
                if(TargetKnowledge \== null) {
                    know(name(Tar), ruolo(val(ValRuoloTar), conf(ConfRuoloTar)), team(val(ValTeamTar), conf(ConfTeamTar))) = TargetKnowledge;
                }

                if(FlagOnlyTeam == false | ValTeamTar \== null | MyName == Target) {
                    !getTargetKnowledge(Sender, SenderKnowledge);
                    if(SenderKnowledge \== null) {
                        // verifico che posso migliorare la qualità delle informazioni in mio possesso con questa richiesta
                        know(name(Sen), ruolo(val(ValRuoloSen), conf(ConfRuoloSen)), team(val(ValTeamSen), conf(ConfTeamSen))) = SenderKnowledge;
                        if(Mode == "parlato") {
                            if( ConfRuoloSen<50 | (FlagOnlyTeam==true & (ValTeamSen==null | ( ConfTeamSen \== null & ConfTeamSen<50)))) {
                                !updateConversations(speaker, Sender, Sender, Mode, FlagOnlyTeam, "accettata");
                                !inviaRispostaInfo(Sender, Target, Mode, FlagOnlyTeam);
                                !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                            } else {
                                .send(Sender, tell, rispostaInfoNegata);
                                !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                            }
                        } else {
                            /* Mode == "carta" */
                            if( ConfRuoloSen<100 | (FlagOnlyTeam==true & (ValTeamSen==null | ( ConfTeamSen \== null & ConfTeamSen<100))) ) {
                                //comunico tramite send di aver accettato la richiesta
                                .send(Sender, tell, rispostaInfoAccetta);
                                !updateConversations(speaker, Sender, Sender, Mode, FlagOnlyTeam, "accettata");
                                !inviaRispostaInfo(Sender, Target, Mode, FlagOnlyTeam);
                                !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                            } else {
                                .send(Sender, tell, rispostaInfoNegata);
                                !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                            }
                        }
                    } elif (Mode == "parlato" | MyName == Target) {
                        //non possiedo le info quindi sono interessato
                        if(Mode == "carta") {
                            //comunico tramite send di aver accettato la richiesta
                            .send(Sender, tell, rispostaInfoAccetta);
                        }
                        !updateConversations(speaker, Sender, Sender, Mode, FlagOnlyTeam, "accettata");
                        !inviaRispostaInfo(Sender, Target, Mode, FlagOnlyTeam);
                        !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                    } else {
                        // non sono interessato
                        .send(Sender, tell, rispostaInfoNegata);
                        !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                    }
                } else {
                    // non possiedo le informazioni richieste
                    .send(Sender, tell, rispostaInfoNegata);
                    !concludiConversazione(Sender, Mode, FlagOnlyTeam);
                }
            } else {
                // non possiedo le informazioni richieste
                .send(Sender, tell, rispostaInfoNegata);
                !concludiConversazione(Sender, Mode, FlagOnlyTeam);
            }
        } else {
            // sto già conversando rifiuto l'offerta di comunicazione
             .send(Sender, tell, rispostaInfoNegata);
             -+conversazioneNegataOccupato(Sender);
             !concludiConversazione(Sender, Mode, FlagOnlyTeam);
        }
        .

/**
    Sender ha rifiutato una mia richiesta di informazioni.
*/
+rispostaInfoNegata[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, Mode, FlagOnlyTeam))
    <-
        -rispostaInfoNegata[source(Sender)];
        -waitingRispostaInfo(Sender, richiestaInfo(Target, Mode, FlagOnlyTeam));
        !updateConversations(self, Target, Sender, Mode, FlagOnlyTeam, "negata");
        !concludiConversazione(Sender, Mode, FlagOnlyTeam);
        .

/**
    Sender ha accettato uno scambio carta. Ero in attesa di una sua risposta.
*/
+rispostaInfoAccetta[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, "carta", FlagOnlyTeam))
    <-
        -rispostaInfoAccetta[source(Sender)];
        -waitingRispostaInfo(Sender, richiestaInfo(Target, "carta", FlagOnlyTeam));
        !updateConversations(self, Target, Sender, "carta", FlagOnlyTeam, "accettata");
        !inviaRispostaInfo(Sender, Target, "carta", FlagOnlyTeam);
        !concludiConversazione(Sender, Mode, FlagOnlyTeam);
        .

/**
    Sender ha accettato uno scambio e mi ha risposto ad una richiesta di informazioni
    sul giocatore Target. Ero in attesa di una sua risposta.
*/
+rispostaInfo(Target, CardTeam, CardRole)[source(Sender)]
    : waitingRispostaInfo(Sender, richiestaInfo(Target, "parlato", FlagOnlyTeam))[source(self)]
    <-
        -rispostaInfo(Target, CardTeam, CardRole)[source(Sender)];
        .print("rispostaInfo con richiesta risposta, inizio");
        ?name(MyName);
        !updateConversations(self, Target, Sender, "parlato", FlagOnlyTeam, "accettata");
        !inviaRispostaInfo(Sender, MyName, "parlato", FlagOnlyTeam);
        -waitingRispostaInfo(Sender, richiestaInfo(Target, "parlato", FlagOnlyTeam))[source(self)];

        // Ci hanno inviato la squadra (Team) e -forse- il ruolo (CardRole) di un giocatore (Target)
        !updateKnowledge(Sender, Target, "parlato", CardTeam, CardRole);
        !concludiConversazione(Sender, Mode, FlagOnlyTeam);
        .

/**
    Sender mi aveva richiesto uno scambio di informazioni. Io ho inviato quanto richiesto e
    ora lui mi ha risposto con le informazioni richieste in cambio.
*/
+rispostaInfo(Target, CardTeam, CardRole)[source(Sender)]
    <-
        -rispostaInfo(Target, CardTeam, CardRole)[source(Sender)];
        // Ci hanno inviato la squadra (Team) e -forse- il ruolo (CardRole) di un giocatore (Target)
        .print("rispostaInfo senza richiesta risposta, inizio");
        !updateKnowledge(Sender, Target, "parlato", CardTeam, CardRole);
        .

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
                !getTargetKnowledge(Target, know(name(Tar), ruolo(val(CardRole), conf(ConfRuolo)), team(val(CardTeam), conf(ConfTeam))));
            }

            if (FlagOnlyTeam == true) {
                Belief = rispostaInfo(Target, CardTeam, null);
            } else {
                Belief = rispostaInfo(Target, CardTeam, CardRole);
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

+!concludiConversazione(Ricevitore, Mode, FlagOnlyTeam)
    <-
        -attendiFineConversazione(Ricevitore, Mode, FlagOnlyTeam);
        if (not playing) {
            !play;
        }
        .



// Il giocatore inizia una votazione candidandosi come leader
+!startVotazioneLeader
    <-
        // Informa tutti i giocatori della stanza dell'inizio della votazione
        ?visible_players(Playerlist);
        +startVotazioneLeader;
        for( .member(Receiver, Playerlist) ) {
            .send(Receiver, tell, startVotazioneLeader);
        }

        // Si auto-vota
        ?name(MioNome);
        !sendVotoPerCandidatoAlLeader(MioNome);
        +votoLeader;

        // Lascia del tempo agli altri giocatori per votare poi fa lo scrutinio
        .wait(15000);
        !endVotazioneLeader.

// Il giocatore viene avvertito di una nuova votazione per cambio leader,
// sceglie se votare o meno per il candidato
+startVotazioneLeader[source(Sender)]
    <-
        .term2string(Sender,SenderString)
        !votaPerNuovoLeader(SenderString, Result);  // Plan da implementare fuori da questo file

        if (Result) {
            // Se a favore, invia il voto al leader corrente e al candidato
            !sendVotoPerCandidatoAlLeader(Sender);
            .send(Sender, tell, votoLeader)
        }
        .

// Da usare durante le votazioni per inviare il proprio voto al leader della propria stanza
// Ricordarsi di inviare il voto anche al candidato
+!sendVotoPerCandidatoAlLeader(Candidato)
    <-
        ?stanzaCorrente(StanzaAssegnAtom);

        !tucsonOpRd(stanzaData(id(StanzaAssegnAtom), leader(Leader)), Op0);
        t4jn.api.getResult(Op0, StanzaDataStr);
        .term2string(StanzaData, StanzaDataStr);
        stanzaData(id(StanzaAssegnAtom), leader(Leader)) = StanzaData;

        .send(Leader, tell, votoLeader).

// Un voto è stato registrato contro il leader e a favore del candidato
// +votoLeader[source(Voter)]

// Il candidato termina la votazione, il leader gli consegna lo "scettro" in caso di maggioranza a favore
+!endVotazioneLeader
    <-
        // Conta dei giocatori e dei voti
        ?visible_players(Playerlist);
        .length(Playerlist, NumAltriGiocatori);
        NumPlayers = NumAltriGiocatori + 1;
        ?name(MioNome);

        .count(votoLeader[source(_)], NumVoti);

        if (ruoloLeader(true)) {
            // Cambio di leader della stanza se la votazione ha avuto successo
            if (NumVoti > NumPlayers/2) {
                // Recupero info
                ?stanzaCorrente(StanzaAssegnAtom);

                // Mi rimuovo dalla posizione leader
                -+ruoloLeader(false);
                destituito_leader;
                !tucsonOpIn(stanzaData(id(StanzaAssegnAtom), leader(MioNome)), Op0);

                // Rendo nuovo leader il candidato
                ?startVotazioneLeader[source(Candidato)];
                .print("Ho perso la mia posizione da leader! Il nuovo leader è ", Candidato, ".");
                !tucsonOpOut(stanzaData(id(StanzaAssegnAtom), leader(Candidato)), Op1);
            }
        } else {
            // Comunicazione fine votazione
            if (NumVoti > NumPlayers/2) {
                .print("Votazione per cambio leader completata con successo, ", NumVoti, " voti su ", NumPlayers);
                -+ruoloLeader(true);
                eletto_leader;
            } else {
                .print("Votazione per cambio leader completata con fallimento, ", NumVoti, " voti su ", NumPlayers);
            }

            // Pulizia
            .abolish(votoLeader);
            -startVotazioneLeader;

            for( .member(Receiver, Playerlist) ) {
                .send(Receiver, tell, endVotazioneLeader);
            }
        }.

+endVotazioneLeader[source(Sender)]
    <-
        if (ruoloLeader(true)) {
            !endVotazioneLeader;
        }

        .abolish(votoLeader);
        -startVotazioneLeader[source(Sender)];
        -endVotazioneLeader[source(Sender)];
        .