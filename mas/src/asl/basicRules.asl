list_contains([], _) :- false.
list_contains([X|_], X) :- true.
list_contains([Elem|Tail], X) :- list_contains(Tail, X).

at(P) :- neighbors(List) & list_contains(List, P).

numberOfPlayerInMyRoom(N) :-
    visible_players(Playerlist) &
    .length(Playerlist, N).
