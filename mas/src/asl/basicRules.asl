list_contains([], _) :- false.
list_contains([X|_], X) :- true.
list_contains([Elem|Tail], X) :- list_contains(Tail, X).

at(P) :- neighbors(List) & list_contains(List, P).

ruolo_rilevante(RoleName) :- RoleName == "Presidente" | RoleName == "Bombarolo".