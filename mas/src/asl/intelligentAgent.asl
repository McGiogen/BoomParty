{ include("basicAgent.asl") }

+!giocaRound
    : turnoIniziato(true)
    <-
        ?knowledge(KnowList);
        ?visible_players(Playerlist);

        .length(KnowList, NumKnowledge);
        .length(Playerlist, NumPlayers);

        if (desireToKnow(Someone)) {
            if (at(Someone)) {
                .print("Provo a parlare con ", Someone);
                !tryToSpeakWith(Someone);
                -desireToKnow(Someone);
            } else {
                !goto(Someone);
            }
        } elif (NumKnowledge < NumPlayers) {
            !tryToDesireToKnow;
        } else {
            ?card(MyTeam, _);
            ?leaderStanzaCorrente(Leader);
            !getTargetKnowledge(Leader, LeaderKnow);
            if (ruoloLeader(false) & LeaderKnow \== null & know(name(_), ruolo(val(_), conf(_)), team(val(LeaderTeam), conf(_))) = LeaderKnow & LeaderTeam \== MyTeam) {
                // Il Leader non è della mia squadra, valuto se è il caso di propormi come leader
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
                // TODO GIO
                .print("Finito tutto... e poi cosa faccio?");

                .wait(10000);
            }
        }
        !giocaRound;
        .

+!tryToDesireToKnow
    <-
        // Cerco una persona con cui parlare
        ?knowledge(MyKnowledge);
        ?visible_players(Playerlist);
        +desireToKnow(null);

        // Per prima cosa cerco un giocatore di cui non conosco nulla
        +index(0);
        while (index(I) & desireToKnow(Target) & Target == null) {
            .nth(I, Playerlist, TempName);
            if (not(.member(know(name(TempName), ruolo(val(_), conf(_)), team(val(_), conf(_))), MyKnowledge))) {
                // Ho trovato un giocatore di cui non so nulla
                -+desireToKnow(TempName);
            }
            -+index(I+1);
        }
        -index(_);

        ?desireToKnow(Target);
        if (Target == null) {
            -desireToKnow(Target);
        }
        .

+!tryToSpeakWith(Player)
    <-
        // TODO scambia informazioni con il giocatore raggiunto
        .wait(3000);

        ?knowledge(StartKnowledge);
        .union(StartKnowledge, [know(name(Player), ruolo(val(null), conf(null)), team(val("rosso"), conf(100)))], NewKnowledge);
        -+knowledge(NewKnowledge);
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

// Azioni di pulizia tra un round e il successivo
+!fineRound
    <-
        .abolish(desireToKnow(_));
        .