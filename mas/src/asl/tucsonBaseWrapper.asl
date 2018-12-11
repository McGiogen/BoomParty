
tnsName("default").
tnsServer("127.0.0.1").
tnsPort("20504").

+!resolveAddr(Name, Server, Port)
    <-
        ?tnsName(Name);
        ?tnsServer(Server);
        ?tnsPort(Port).

+!tucsonOpOut(Tupla, Operazione)
    <-
        !resolveAddr(Name, Server, Port);
        t4jn.api.out(Name, Server, Port, Tupla, Operazione).

+!tucsonOpIn(Tupla, Operazione)
    <-
        !resolveAddr(Name, Server, Port);
        t4jn.api.in(Name, Server, Port, Tupla, Operazione).

+!tucsonOpUin(Tupla, Operazione)
    <-
        !resolveAddr(Name, Server, Port);
        t4jn.api.uin(Name, Server, Port, Tupla, Operazione).

+!tucsonOpInp(Tupla, Operazione)
    <-
        !resolveAddr(Name, Server, Port);
        t4jn.api.inp(Name, Server, Port, Tupla, Operazione).

+!tucsonOpRd(Tupla, Operazione)
    <-
        !resolveAddr(Name, Server, Port);
        t4jn.api.rd(Name, Server, Port, Tupla, Operazione).

+!tucsonOpRdAll(Tupla, Operazione)
    <-
        !resolveAddr(Name, Server, Port);
        t4jn.api.rdAll(Name, Server, Port, Tupla, Operazione).