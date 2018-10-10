package it.unibo.boomparty.handlers;

import alice.tucson.service.TucsonOpCompletionEvent;

public interface IHandlerOpCompletion {

    void handle(TucsonOpCompletionEvent toce);
}

