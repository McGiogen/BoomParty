// CArtAgO artifact code for project BoomParty

package it.unibo.boomparty.domain.artifacts;

import cartago.*;

public class Clock extends Artifact {
	private final static int TICK = 1000;
	private boolean working;
	private int tickTime = TICK;

	void init(int tickTime) {
		if (tickTime > 0) {
			this.tickTime = tickTime;
		} else {
			System.out.println("Impossibile impostare un tick minore o uguale a 0");
		}

		this.working = false;
	}

	@OPERATION
	void start() {
		if (!this.working) {
			this.working = true;
			execInternalOp("work");
		} else {
			failed("already started");
		}
	}

	@OPERATION
	void stop() {
		this.working = false;
	}

	@INTERNAL_OPERATION
	void work() {
		while (this.working) {
			signal("tick");
			await_time(this.tickTime);
		}
	}
}
