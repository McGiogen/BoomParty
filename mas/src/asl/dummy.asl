!startFour.

+!startOne
    <- makeArtifact("Card1", "it.unibo.boomparty.domain.artifacts.Card", ["pagliaccio"], Card1);
       focus(Card1);
       getRole(CardRole);
       .print("Card role: ", CardRole).

+!startTwo
    <- makeArtifact("Timer1", "it.unibo.boomparty.domain.artifacts.Timer", [], Timer1);
       focus(Timer1);
       setMinutes(1);
       startTimer;
       .print("Timer started").

+!startTree
    <- t4jn.api.out("default", "127.0.0.1", "20504", culo(luca), Op1).

+timeUp
    <- .print("Tick percieved").

+!startFour
    <- makeArtifact("Card1", "it.unibo.boomparty.domain.artifacts.Card", ["pagliaccio"], Card1);
       focus(Card1);
       getRole(CardRole);
       .print("Card role: ", CardRole);
       t4jn.api.out("default", "127.0.0.1", "20504", culo(luca), Op1).

