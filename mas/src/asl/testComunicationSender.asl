{ include("comunication.asl") }

team(teamSender).
ruolo(ruoloSender).
ruoloCorrente(ruoloSender).

!boot.

+!boot
    <-  !inviaRichiestaInfo(receiver, "parlato", false).

+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN");.