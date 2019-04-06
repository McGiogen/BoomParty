/* Handle movement */

// GO TO
+!goto(Player) // if arrived at destination Player
	: at(Player)
	<- true. // that's all, do nothing

+!goto(Player) // if NOT arrived at destination Player
	: not at(Player)
	<- move_towards(Player).

// Gestione failure del plan
-!goto(Player)
    <- true.

// GO IN
+!goinStart(Area) // goin needs a start to define a free position in Area, without tests
    <- move_in(Area).

+!goin(Area) // if arrived at free position in Area
    : going_to(null)
    <- true.

+!goin(Area) // if NOT arrived at free position in Area
    : not going_to(null)
    <- move_in(Area).

// RANDOM MOVEMENT
+!moveRandomly
    <- move_randomly.