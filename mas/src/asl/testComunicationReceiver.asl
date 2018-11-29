{ include("comunication.asl") }

team(teamReceiver).
ruolo(ruoloReceiver).
ruoloCorrente(ruoloReceiver).

!boot.

+!boot
    <-  .print("inizio r").

+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN, Team: ", CardTeam, ", Role: ", CardRole).

+!updateKnowledge(Receiver, Target, Mode, ReceiverCardArtifName) <- .print("AVVIO UPDATEKNOWLEDGE CARD PLAN ", ReceiverCardArtifName).
