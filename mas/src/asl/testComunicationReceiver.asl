{ include("comunication.asl") }

team(teamReceiver).
ruolo(ruoloReceiver).
ruoloCorrente(ruoloReceiver).

+!updateKnowledge(Sender, Target, Mode, CardTeam, CardRole) <- .print("AVVIO UPDATEKNOWLEDGE PLAN");.
