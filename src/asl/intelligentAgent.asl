{ include("basicAgent.asl") }

+!giocaRound
    <-
        ?knowledge(KnowList);
        ?conversations(ConvList);
        ?players(Playerlist);

        .length(KnowList, NumKnowledge);
        .length(Playerlist, NumPlayers);
        .length(ConvList, NumConversations);

        if (desireToKnow(Someone)) {
            .print("Inizio turno, provo a parlare con ", Someone);
            if(at(Someone)) {
                .print("Provo a parlare con ", Someone);
                .abolish(desireToKnow(_));
                !tryToSpeakWith(Someone);
            } elif( visible_players(VisiblePlayer) & .member(Someone, VisiblePlayer) ) {
                !goto(Someone);
            } else {
                -desireToKnow(Someone);
            }
        } else {
            .print("Inizio turno, avvio ricerca player con cui comunicare...");
            // Provo a cercare qualcuno con cui scambiare informazioni
            !tryToDesireToKnow(Success);

            if (NumConversations < NumPlayers & Success == false) {
                .print("Nessun player individuato, faccio mosse più ardite");
                ?card(MyTeam, _);
                ?leaderStanzaCorrente(Leader);
                !getTargetKnowledge(Leader, LeaderKnow);
                if (ruoloLeader(false) & LeaderKnow \== null & know(name(_), ruolo(val(_), conf(_)), team(val(LeaderTeam), conf(_))) = LeaderKnow & LeaderTeam \== MyTeam) {
                    // Il Leader non è della mia squadra, valuto se è il caso di propormi come leader
                    .print("Valuto se è il caso di propormi come leader");
                    .wait(10000);

                    +conteggioPotenzialiVoti(1);
                    for (.member(Player, Playerlist)) {
                        if(Player \== null) {
                            !getTargetKnowledge(Player, PlayerKnow);
                            if (PlayerKnow \== null) {
                                know(name(PP), ruolo(val(_), conf(_)), team(val(PlayerTeam), conf(_))) = PlayerKnow;
                                if (PlayerTeam \== LeaderTeam) {
                                    ?conteggioPotenzialiVoti(NumVoti);
                                    -+conteggioPotenzialiVoti(NumVoti + 1);
                                }
                            }
                        }
                    }
                    -conteggioPotenzialiVoti(NumVoti);

                    if (numberOfPlayerInMyRoom(Tot) & NumVoti > (Tot / 2)) {
                        .print("Provo a candidarmi come leader, ci sono ", NumVoti, " possibili voti");
                        !tryToCandidateAsLeader;
                    }
                } else {
                    !moveRandomly;
                }
            } else {
                .print("Player individuato per conversazione");
            }
        }
        .

+!tryToDesireToKnow(Success)
    <-
        // Cerco una persona con cui parlare
        if (conversations(MyConversations) & visible_players(Playerlist)) {
            .length(Playerlist, NumPlayers);
            +tmpDesireToKnow(null);

            // Per prima cosa cerco un giocatore di cui non conosco nulla
            +index(0);
            while(index(I) & I < NumPlayers & tmpDesireToKnow(Target) & Target == null) {
                .nth(I, Playerlist, TempName);
                .term2string(TempNameAtom, TempName);
                if(
                    not(.member(conversation(initiator(_), playerTarget(TempNameAtom), playerSpeaker(_), mode(_), flagOnlyTeam(_), esito(_), time(_)), MyConversations))
                    & not(.member(conversation(initiator(_), playerTarget(_), playerSpeaker(TempNameAtom), mode(_), flagOnlyTeam(_), esito(_), time(_)), MyConversations))
                    ) {
                    // Ho trovato un giocatore di cui non so nulla
                    -+tmpDesireToKnow(TempName);
                }
                -+index(I+1);
            }
            -index(_);

            -tmpDesireToKnow(Target);
            if (Target == null) {

                // Cerco un giocatore di cui non dispongo tutte le informazioni con certezza
                +tmpDesireToKnow(null);
                for( .member(TempNameD, Playerlist) ) {
                    if(tmpDesireToKnow(Target) & Target == null) {
                        .term2string(TempNameAtomD, TempNameD);
                        !gotMaxKnowledge(TempNameAtomD, Result);
                        if(Result == false) {
                            !getLeastKnowledgeIncreaseMode(TempNameAtomD, CommunicationMode, FlagOnlyTeam);
                            !getConversation(self, TempNameAtomD, TempNameAtomD, CommunicationMode, FlagOnlyTeam, "negata", ConvData);
                            if(ConvData == null) {
                                // Ho trovato un giocatore di cui non so tutte le informazioni
                                -+tmpDesireToKnow(TempNameD);
                            }
                        }
                    }
                }

                -tmpDesireToKnow(TargetD);
                if (TargetD == null) {
                    Success = false;
                } else {
                    +desireToKnow(TargetD);
                    Success = true;
                }
            } else {
                +desireToKnow(Target);
                Success = true;
            }
        } else {
            Success = false;
        }
        .

+!tryToSpeakWith(Player)
    <-
        .term2string(PlayerAtom, Player);
        !getLeastKnowledgeIncreaseMode(PlayerAtom, CommunicationMode, FlagOnlyTeam);
        !inviaRichiestaInfo(PlayerAtom, CommunicationMode, FlagOnlyTeam);
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

// Ho rifiutato una conversazione perche occupato, verifico se poteva interessarmi parlare con quel player nel caso lo contatto io quando mi libero
+conversazioneNegataOccupato(Player)
    <-
        .print("conversazioneNegataOccupato, verifico se mi sono perso una conversazione interessante con ", Player);
        !gotMaxKnowledge(Player, Result);
        if(Result == false) {
            +desireToKnow(Player);
        }
        .