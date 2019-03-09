{ include("artifactHelper.asl") }

//contenuto di knowledge: know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam)
knowledge([]).

+!updateKnowledge(Source, Target, CommunicationMode, CardTeam, CardRole)
    <-
        .print("Inizio updateKnowledge, Target: ", Target, " CardTeam: ", CardTeam, " CardRole: ", CardRole);
        !getConfidance(CommunicationMode, Confidence);
        !salvaInfo(Target, CardTeam, CardRole, Confidence).

+!updateKnowledge(Source, Target, CommunicationMode, ReceiverCardArtifName)
    <-
        .print("Inizio updateKnowledge");
        !getConfidance(CommunicationMode, Confidence);
        lookupArtifact(ReceiverCardArtifName, ReceiverCardArtifID);
        getTeam(TeamTarget) [artifact_id(ReceiverCardArtifID)];
        getRole(RuoloTarget) [artifact_id(ReceiverCardArtifID)];
        !salvaInfo(Target, TeamTarget, RuoloTarget, Confidence).

+!getConfidance(CommunicationMode, Confidence)
    <-
        if(CommunicationMode == "carta"){
            Confidence = 100;
        } elif (CommunicationMode == "parlato") {
            Confidence = 50;
        } else {
            Confidence = 0;
        }.

/* plan ad uso interno per salvare le info in knowledge, per interagire dall'esterno fare riferimento ad updateKnowledge */
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
            if(RuoloTarget \== null){
                NewTargetData = know(name(Target), ruolo(val(RuoloTarget), conf(Confidence)), team(val(TeamTarget), conf(Confidence)));
            } else {
                NewTargetData = know(name(Target), ruolo(val(null), conf(null)), team(val(TeamTarget), conf(Confidence)));
            }
            .union(KnowledgeList, [NewTargetData], NewKnowledge);
            -+knowledge(NewKnowledge);
        }
        .print("Fine salvaInfo").

+!getTargetKnowledge(Target, TargetData)
    <-
        ?knowledge(KnowledgeList);
        if(.member(know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))), KnowledgeList)) {
            .nth(Pos, KnowledgeList, know(name(Target), ruolo(val(ValRuolo), conf(ConfRuolo)), team(val(ValTeam), conf(ConfTeam))));
            .nth(Pos, KnowledgeList, TargetData);
        } else {
            TargetData = null;
        }
        //.print("getTargetKnowledge fine ", TargetData);
        .