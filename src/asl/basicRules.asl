list_contains([], _) :- false.
list_contains([X|_], X) :- true.
list_contains([Elem|Tail], X) :- list_contains(Tail, X).

at(P) :- neighbors(List) & list_contains(List, P).

numberOfPlayerInMyRoom(N) :-
    visible_players(Playerlist) &
    .length(Playerlist, N).

+?numberOfOstaggi(NumOstaggi)
    <-
        ?turnoNumero(T);
        ?players(Players);
        .length(Players, N);
        if (N <= 10) {
            .nth(T-1, [1,1,1], NumOstaggi);
        } elif (N <= 13) {
            .nth(T-1, [2,2,1,1,1], NumOstaggi);
        } elif (N <= 17) {
            .nth(T-1, [3,2,2,1,1], NumOstaggi);
        } elif (N <= 21) {
            .nth(T-1, [4,3,2,1,1], NumOstaggi);
        } else {
            .nth(T-1, [5,4,3,2,1], NumOstaggi);
        }
        .

+?minutiTurno(Minuti, Turno)
    <-
        ?players(Players);
        .length(Players, N);
        if (N <= 10) {
            .nth(Turno-1, [3,2,1], Minuti);
        } else {
            .nth(Turno-1, [5,4,3,2,1], Minuti);
        }
        .

totaleTurni(Count) :-
    players(Players) &
    .length(Players, N) &
    ((N <= 10 & Count = 3) | (N > 10 & Count = 5))
    .
