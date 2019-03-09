
// contenuto conversation(playerTarget(Target), playerSpeaker(Source), mode(ModeVal), flagOnlyTeam(FlagVal), esito(Resp))
// ModeVal = ["parlato"|"carta"]; FlagVal = [true|false]; Resp = ["accettata"|"negata"]
conversations([]).

+!updateConversations(Target, Source, CommunicationMode, FlagOnlyTeam, Response)
    :   (CommunicationMode = "parlato" | CommunicationMode = "carta") &
        (FlagOnlyTeam = true | FlagOnlyTeam = false) &
        (Response = "accettata" | Response = "negata")
    <-
        ?conversations(ConvList);

        if( .member(conversation(playerTarget(Target), playerSpeaker(Source), mode(ModeVal), flagOnlyTeam(FlagVal), esito(Resp)), ConvList) ) {
            .print("updateConversations, elemento già presente");
        } else {
            NewConvElem = conversation(playerTarget(Target), playerSpeaker(Source), mode(CommunicationMode), flagOnlyTeam(FlagOnlyTeam), esito(Response));
            .union(ConvList, [NewConvElem], NewConvList);
            -+conversations(NewConvList);
        }
        +updateConvComplete(Target, Source, CommunicationMode, FlagOnlyTeam, Response);
        .print("Fine updateConversations").

+!getConversation(Target, Source, CommunicationMode, FlagOnlyTeam, Response, ConvData)
    :   (CommunicationMode = "parlato" | CommunicationMode = "carta") &
        (FlagOnlyTeam = true | FlagOnlyTeam = false) &
        (Response = "accettata" | Response = "negata")
    <-
        ?conversations(ConvList);
        if(.member(conversation(playerTarget(Target), playerSpeaker(Source), mode(ModeVal), flagOnlyTeam(FlagVal), esito(Resp)), ConvList)) {
            .nth(Pos, ConvList, conversation(playerTarget(Target), playerSpeaker(Source), mode(ModeVal), flagOnlyTeam(FlagVal), esito(Resp)));
            .nth(Pos, ConvList, ConvData);
        } else {
            ConvData = null;
        }
        .print("getConversations fine ", ConvData).