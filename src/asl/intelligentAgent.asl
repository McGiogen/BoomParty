{ include("basicAgent.asl") }

+!giocaRound
    : turnoIniziato(true) & not attendiFineConversazione(F1, F2, F3, F4)
    <-
        ?knowledge(KnowList);
        ?conversations(ConvList);
        ?players(Playerlist);

        .length(KnowList, NumKnowledge);
        .length(Playerlist, NumPlayers);
        .length(ConvList, NumConversations);

        if (desireToKnow(Someone)) {
            if (at(Someone)) {
                .print("Provo a parlare con ", Someone);
                !tryToSpeakWith(Someone);
                -desireToKnow(Someone);
            } else {
                !goto(Someone);
            }
        } else {
            // Provo a cercare qualcuno con cui scambiare informazioni
            !tryToDesireToKnow(Success);

            if (NumConversations < NumPlayers & Success == false) {
                .print("Faccio mosse più ardite");
                ?card(MyTeam, _);
                ?leaderStanzaCorrente(Leader);
                !getTargetKnowledge(Leader, LeaderKnow);
                if (ruoloLeader(false) & LeaderKnow \== null & know(name(_), ruolo(val(_), conf(_)), team(val(LeaderTeam), conf(_))) = LeaderKnow & LeaderTeam \== MyTeam) {
                    // Il Leader non è della mia squadra, valuto se è il caso di propormi come leader
                    .print("Valuto se è il caso di propormi come leader");
                    .wait(10000);

                    +conteggioPotenzialiVoti(1);
                    for (.member(Player, Playerlist) & Player \== null) {
                        !getTargetKnowledge(Player, PlayerKnow);
                        if (PlayerKnow \== null) {
                            know(name(PP), ruolo(val(_), conf(_)), team(val(PlayerTeam), conf(_))) = PlayerKnow;
                            if (PlayerTeam \== LeaderTeam) {
                                ?conteggioPotenzialiVoti(NumVoti);
                                -+conteggioPotenzialiVoti(NumVoti + 1);
                            }
                        }
                    }
                    -conteggioPotenzialiVoti(NumVoti);

                    if (numberOfPlayerInMyRoom(Tot) & NumVoti > (Tot / 2)) {
                        .print("Provo a candidarmi come leader, ci sono ", NumVoti, " possibili voti");
                        !tryToCandidateAsLeader;
                    }
                } else {
                    // TODO
                    .print("Finito tutto... e poi cosa faccio?");

                    !moveRandomly;
                    // .wait(10000);
                }
            }
        }
        !giocaRound;
        .

// sono in attesa della fine della convesazione corrente prima di riprendere il normale ciclo di round
+!giocaRound
    : turnoIniziato(true) & attendiFineConversazione(F1, F2, F3, F4)
    <- true.

+!tryToDesireToKnow(Success)
    <-
        // Cerco una persona con cui parlare
        ?conversations(MyConversations);
        ?visible_players(Playerlist);
        .length(Playerlist, NumPlayers);
        +desireToKnow(null);

        // Per prima cosa cerco un giocatore di cui non conosco nulla
        +index(0);
        while (index(I) & I < NumPlayers & desireToKnow(Target) & Target == null) {
            .nth(I, Playerlist, TempName);
            if (
                not(.member(conversation(playerTarget(TempName), playerSpeaker(_), mode(_), flagOnlyTeam(_), esito(_)), MyConversations))
                & not(.member(conversation(playerTarget(_), playerSpeaker(TempName), mode(_), flagOnlyTeam(_), esito(_)), MyConversations))
                ) {
                // Ho trovato un giocatore di cui non so nulla
                -+desireToKnow(TempName);
            }
            -+index(I+1);
        }
        -index(_);

        if (desireToKnow(Target) & Target == null) {
            .abolish(desireToKnow(_));
            Success = false;
        } else {
            Success = true;
        }
        .

+!tryToSpeakWith(Player)
    <-
        ?name(MyName);
        CommunicationMode = "carta";
        FlagOnlyTeam = true;
        .term2string(PlayerAtom, Player);
        !inviaRichiestaInfo(PlayerAtom, CommunicationMode, FlagOnlyTeam);
        +attendiFineConversazione(Player, MyName, CommunicationMode, FlagOnlyTeam);
         .print("AGGIUNTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO attendiFineConversazione: ", Player, MyName, CommunicationMode, FlagOnlyTeam);
         //.wait(10000);
        .

+updateConvComplete(Target, Source, CommunicationMode, FlagOnlyTeam, Response)
    :  attendiFineConversazione(Target, Source, CommunicationMode, FlagOnlyTeam)
    <-
         .print("rimuovooooooooooooooooooooooooooooooooooooooooooo attendiFineConversazione: ", Target, Source, CommunicationMode, FlagOnlyTeam);
        -updateConvComplete(Target, Source, CommunicationMode, FlagOnlyTeam, Response);
        -attendiFineConversazione(Target, Source, CommunicationMode, FlagOnlyTeam)
        !giocaRound.

+!tryToCandidateAsLeaderc
    <-
        .count(startVotazioneLeader[source(_)], N);
        if (N == 0 & ruoloLeader(false)) {
            .print("Mi candido come leader");
            !startVotazioneLeader;
        } else {
            .print("Mi candiderei ma c'è una votazione in corso oppure sono già leader");
        }
        .

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

+!scegliOstaggi(GiocatoriInStanza, NumOstaggi, Ostaggi)
    <-
        +tempOstaggi([]);
        for (.range(I, 0, NumOstaggi-1)) {
            ?tempOstaggi(TempOstaggi);
            .nth(I, GiocatoriInStanza, Ostaggio);
            .union(TempOstaggi, [Ostaggio], NewOstaggi);

            -+tempOstaggi(NewOstaggi);
        }
        -tempOstaggi(Ostaggi);
        .

// Azioni di pulizia tra un round e il successivo
+!fineRound
    <-
        .abolish(desireToKnow(_));
        .