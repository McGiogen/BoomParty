
// contenuto conversation(initiator(Initiator), playerTarget(Target), playerSpeaker(Source), mode(ModeVal), flagOnlyTeam(FlagVal), esito(Resp), Time(system.time))
// Initiator = [self|speaker]; ModeVal = ["parlato"|"carta"]; FlagVal = [true|false]; Resp = ["accettata"|"negata"]
conversations([]).

+!updateConversations(Initiator, Target, Source, CommunicationMode, FlagOnlyTeam, Response)
    :   (CommunicationMode == "parlato" | CommunicationMode == "carta") &
        (FlagOnlyTeam == true | FlagOnlyTeam == false) &
        (Response == "accettata" | Response == "negata")
    <-
        ?conversations(ConvList);

        Time = system.time;
        if( .member(conversation(initiator(Initiator), playerTarget(Target), playerSpeaker(Source), mode(CommunicationMode), flagOnlyTeam(FlagOnlyTeam), esito(Response), time(_)), ConvList) ) {
            .print("updateConversations, elemento già presente");
        } else {
            NewConvElem = conversation(initiator(Initiator), playerTarget(Target), playerSpeaker(Source), mode(CommunicationMode), flagOnlyTeam(FlagOnlyTeam), esito(Response), time(Time));
            .union(ConvList, [NewConvElem], NewConvList);
            -+conversations(NewConvList);
        }
        .print("Fine updateConversations").

+!getConversation(Initiator, Target, Source, CommunicationMode, FlagOnlyTeam, Response, ConvData)
    :   (CommunicationMode == "parlato" | CommunicationMode == "carta") &
        (FlagOnlyTeam == true | FlagOnlyTeam == false) &
        (Response == "accettata" | Response == "negata")
    <-
        ?conversations(ConvList);
        if(.member(conversation(initiator(Initiator), playerTarget(Target), playerSpeaker(Source), mode(CommunicationMode), flagOnlyTeam(FlagOnlyTeam), esito(Response), time(_)), ConvList)) {
            .nth(Pos, ConvList, conversation(initiator(Initiator), playerTarget(Target), playerSpeaker(Source), mode(CommunicationMode), flagOnlyTeam(FlagOnlyTeam), esito(Response), time(_)));
            .nth(Pos, ConvList, ConvData);
        } else {
            ConvData = null;
        }
        .print("getConversations fine ", ConvData).