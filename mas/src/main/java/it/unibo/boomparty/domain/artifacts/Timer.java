package it.unibo.boomparty.domain.artifacts;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;

public class Timer extends Artifact {

    private final static long MILLISECONDS_IN_MINUTE = 60000;
    private boolean started = false;
    private long countdown;

    void init() {
        this.countdown = -1;
    }

    @OPERATION
    void setMinutes(long minutes) {
        if (minutes < 0) {
            failed("Minutes is less then 0");
        } else {
            this.countdown = minutes * MILLISECONDS_IN_MINUTE;
        }
    }

    @OPERATION
    void startTimer() {
        if (this.countdown < 0) {
            failed("Time set is invalid");
        } else if (this.started) {
            failed("Timer already started");
        } else {
            this.started = true;
            execInternalOp("doCountdown");
        }
    }

    @INTERNAL_OPERATION
    void doCountdown() {
//        System.out.println("Starting timer for " + this.countdown + " milliseconds.");
//        System.out.println(new Timestamp(new Date().getTime()));
        await_time(this.countdown);
        System.out.println("Times up!");
//        System.out.println(new Timestamp(new Date().getTime()));
        signal("timeUp");
        this.started = false;
    }
}
