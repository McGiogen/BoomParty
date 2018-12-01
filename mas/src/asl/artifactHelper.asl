+!focusByNomeLogico(ArtifactName, ArtifactId)
    <-
        .print("Recupero artefatto di nome: ", ArtifactName);
        lookupArtifact(ArtifactName, ArtifactId);
        focus(ArtifactId);
        .print("Artefatto ", ArtifactName, " trovato e focussato").

+!defocusById(ArtifactName, ArtifactId)
    <-
        .print("Mi accingo a togliere il focus da artefatto ", ArtifactName," di ID: ", ArtifactId);
        stopFocus(ArtifactId).