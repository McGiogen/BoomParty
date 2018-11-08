!startTwo.

+!startOne
    <- makeArtifact("Card1", "it.unibo.boomparty.artifacts.Card", ["pagliaccio"], Card1);
       focus(Card1);
       getRole(CardRole);
       .print("Card role: ", CardRole).

+!startTwo
    <- makeArtifact("Timer1", "it.unibo.boomparty.artifacts.Timer", [], Timer1);
       focus(Timer1);
       setMinutes(1);
       startTimer;
       .print("Timer started").

+timeUp
    <- .print("Tick percieved").