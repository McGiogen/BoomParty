{ include("comunication.asl") }

// team(teamReceiver).
// ruolo(ruoloReceiver).
ruoloCorrente(ruoloReceiver).
riferimentoCarta("CardReceiver").

!boot.

+!boot
    <-  .print("inizio r");
        ?riferimentoCarta(CardName);
        makeArtifact(CardName, "it.unibo.boomparty.domain.artifacts.Card", ["rosso", "bomb"], CardId);
        +riferimentoCartaId(CardId);
        .print("Carta ", CardName, " creata e focussata").
/*
+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN, Team: ", CardTeam, ", Role: ", CardRole).

+!updateKnowledge(Receiver, Target, Mode, ReceiverCardArtifName) <- .print("AVVIO UPDATEKNOWLEDGE CARD PLAN -> Receiver: ", Receiver, "; Target: ", Target, "; CardName: ", ReceiverCardArtifName).
*/
