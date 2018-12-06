{ include("artifactHelper.asl") }

knowledge([]).

+!updateKnowledge(Source, Target, ComunicationMode, CardTeam, CardRole)
    <-
        .print("Inizio updateKnowledge");
        !getConfidance(ComunicationMode, Confidence);
        !salvaInfo(Target, CardTeam, CardRole, Confidence).

+!updateKnowledge(Source, Target, ComunicationMode, ReceiverCardArtifName)
    <-
        .print("Inizio updateKnowledge");
        !getConfidance(ComunicationMode, Confidence);
        lookupArtifact(ReceiverCardArtifName, ReceiverCardArtifID);
        getTeam(TeamTarget) [artifact_id(ReceiverCardArtifID)];
        getRole(RuoloTarget) [artifact_id(ReceiverCardArtifID)];
        !salvaInfo(Target, TeamTarget, RuoloTarget, Confidence).

+!getConfidance(ComunicationMode, Confidence)
    <-
        if(ComunicationMode == "carta"){
            Confidence = 100;
        } elif (ComunicationMode == "parlato") {
            Confidence = 50;
        } else {
            Confidence = 0;
        }.

+!salvaInfo(Target, TeamTarget, RuoloTarget, Confidence)
    <-
        ?knowledge(KnowledgeList);
        if(.member(know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))), KnowledgeList)) {
            .print(Target, " conosciuto");
            .delete(know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))), KnowledgeList, CleanKnowledgeList);
            if(RuoloTarget \== null){
                NewTargetData = know(name(Target), ruolo(val(RuoloTarget), conf(Confidence)), team(val(TeamTarget), conf(Confidence)));
            } else {
                NewTargetData = know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(TeamTarget), conf(Confidence)));
            }
            .union(CleanKnowledgeList, [NewTargetData], NewKnowledge);
            -+knowledge(NewKnowledge);

        } else {
            .print(Target, " non conosciuto");
            NewTargetData = know(name(Target), ruolo(val(RuoloTarget), conf(Confidence)), team(val(TeamTarget), conf(Confidence)));
            .union(KnowledgeList, [NewTargetData], NewKnowledge);
            -+knowledge(NewKnowledge);
        }

        .print("Fine salvaInfo").

// TODO Recuperare le info di Target da knowledge() DA TESTARE
+!getTargetKnowledge(Target, TargetData)
    <-
        ?knowledge(KnowledgeList);
        if(.member(know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))), KnowledgeList)) {
            .nth(Pos, KnowledgeList, know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))));
            .nth(Pos, KnowledgeList, TargetData);
        } else {
            TargetData = null;
        }
        .print("getTargetKnowledge fine ", TargetData).