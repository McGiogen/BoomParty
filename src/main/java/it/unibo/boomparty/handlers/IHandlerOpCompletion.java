package it.unibo.boomparty.handlers;

import alice.tucson.service.TucsonOpCompletionEvent;

public interface IHandlerOpCompletion {

    public void handle(TucsonOpCompletionEvent toce);
}

