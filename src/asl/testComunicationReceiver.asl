{ include("communication.asl") }

riferimentoCarta("CardReceiver").
name(N) :- .my_name(N).

!boot.

+!boot
    <-  .print("inizio r");
        ?riferimentoCarta(CardName);
        makeArtifact(CardName, "it.unibo.boomparty.domain.artifacts.Card", ["rosso", "bomb"], CardId);
        +ruoloCorrente(CardName);
        .print("Carta ", CardName, " creata e focussata").
/*
+!boot
    <-
        !getTargetKnowledge(receiver, know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))));
        .print("Carta ", ValRuolo).
*/
/*
+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN, Team: ", CardTeam, ", Role: ", CardRole).

+!updateKnowledge(Receiver, Target, Mode, ReceiverCardArtifName) <- .print("AVVIO UPDATEKNOWLEDGE CARD PLAN -> Receiver: ", Receiver, "; Target: ", Target, "; CardName: ", ReceiverCardArtifName).
*/
