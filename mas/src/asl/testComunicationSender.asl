{ include("comunication.asl") }

team(teamSender).
ruolo(ruoloSender).
ruoloCorrente(ruoloSender).

!boot.

+!boot
    <-  .print("inizio s");
        !inviaRichiestaInfo(receiver, "carta", false).

+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN, Team: ", CardTeam, ", Role: ", CardRole).

+!updateKnowledge(Receiver, Target, Mode, ReceiverCardArtifName) <- .print("AVVIO UPDATEKNOWLEDGE CARD PLAN -> Receiver: ", Receiver, "; Target: ", Target, "; CardName: ", ReceiverCardArtifName).