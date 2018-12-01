{ include("comunication.asl") }

// team(teamSender).
// ruolo(ruoloSender).
ruoloCorrente(ruoloSender).
riferimentoCarta("CardSender").

!boot.

+!boot
    <-  .print("inizio s");
        ?riferimentoCarta(CardName);
        makeArtifact(CardName, "it.unibo.boomparty.domain.artifacts.Card", ["blu", "pres"], CardId);
        focus(CardId);
        +riferimentoCartaId(CardId);
        .print("Carta ", CardName, " creata e focussata");
        !inviaRichiestaInfo(receiver, "carta", false).

+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN, Team: ", CardTeam, ", Role: ", CardRole).

+!updateKnowledge(Receiver, Target, Mode, ReceiverCardArtifName) <- .print("AVVIO UPDATEKNOWLEDGE CARD PLAN -> Receiver: ", Receiver, "; Target: ", Target, "; CardName: ", ReceiverCardArtifName).