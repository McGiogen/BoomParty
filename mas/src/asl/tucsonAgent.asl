{ include("basicAgent.asl") }

/* Initial beliefs and rules */

/* Initial goals */
/*
!start.

+!start
    <- 
    	!messaggia
    	!!one;
		!two.

+!messaggia : true
	<-
		.send(paolo, tell, hello).

+!one
    <- .print("ONE START");
       t4jn.api.in("default", "127.0.0.1", "20504", hello(X,Y), Op0);
       .print("Getting result for op #", Op0);
       t4jn.api.getResult(Op0, Result);
       .print("Got: ", Result, " for op #", Op0);
       t4jn.api.out("default", "127.0.0.1", "20504", Result, Op1);
       .print("ONE END, got: ", Result, " for op #", Op1).

+!two
    <- .print("TW0 START");
       .print("action 1");
       .print("action 2");
       .print("action 3");
       t4jn.api.out("default", "127.0.0.1", "20504", hello(wonderful,world), Op2);
       .print("Op #", Op2, " done");
       .print("TWO END").

 */