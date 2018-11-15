// !startFour.
!test2.

+!test
    <- makeArtifact("Pippo", "it.unibo.boomparty.domain.artifacts.Card", ["pippo"], Pippo);
       makeArtifact("Pluto", "it.unibo.boomparty.domain.artifacts.Card", ["palla"], Palla);
       t4jn.api.out("default", "127.0.0.1", "20504", artifactId(Pippo), Op1);
       t4jn.api.out("default", "127.0.0.1", "20504", artifactId(Palla), Op2).

+!test2
    <- !registerArtifact("Pippo", "it.unibo.boomparty.domain.artifacts.Card", ["pippo"], Pippo);
       !registerArtifact("Pluto", "it.unibo.boomparty.domain.artifacts.Card", ["palla"], Palla).

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

+!registerArtifact(ArtifactName, ArtifactClass, ArtifactParams, ArtifactId)
    <- makeArtifact(ArtifactName, ArtifactClass, ArtifactParams, ArtifactId);
       t4jn.api.out("default", "127.0.0.1", "20504", artifact(artifactName(ArtifactName), artifactId(ArtifactId)), Op).
