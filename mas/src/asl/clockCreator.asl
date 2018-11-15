/* Initial beliefs and rules */

/* Initial goals */

!start.

+!start
<- !createClock("myClock").

+!createClock(ArtName)
<- makeArtifact(ArtName, "it.unibo.boomparty.domain.artifacts.Clock",[], MyClock);
start;
.my_name(AgentName);
.print(AgentName,": artifact ", ArtName, " started.").