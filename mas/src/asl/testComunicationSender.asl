{ include("comunication.asl") }

riferimentoCarta("CardSender").
name(N) :- .my_name(N).

!boot.

+!boot
    <-  .print("inizio s");
        ?riferimentoCarta(CardName);
        makeArtifact(CardName, "it.unibo.boomparty.domain.artifacts.Card", ["blu", "pres"], CardId);
        focus(CardId);
        +ruoloCorrente(CardName);
        .print("Carta ", CardName, " creata e focussata");
        !inviaRichiestaInfo(receiver, "carta", true).
/*
+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN, Team: ", CardTeam, ", Role: ", CardRole).

+!updateKnowledge(Receiver, Target, Mode, ReceiverCardArtifName) <- .print("AVVIO UPDATEKNOWLEDGE CARD PLAN -> Receiver: ", Receiver, "; Target: ", Target, "; CardName: ", ReceiverCardArtifName).
*/