package it.unibo.boomparty.service;

import alice.logictuple.exceptions.InvalidLogicTupleException;
import alice.tucson.api.TucsonTupleCentreId;
import alice.tucson.asynchSupport.actions.ordinary.Out;
import com.github.javafaker.Faker;
import it.unibo.boomparty.domain.tuples.PlayerTuple;
import it.unibo.boomparty.env.BasicEnvironment;
import it.unibo.boomparty.service.model.SimulationArgs;
import it.unibo.boomparty.utils.JadeUtils;
import it.unibo.boomparty.utils.TucsonChannel;
import it.unibo.boomparty.utils.TucsonUtils;
import it.unibo.tucson4jason.architecture.BoomPartyAgentArch;
import jade.wrapper.AgentContainer;
import jason.JasonException;
import jason.infra.centralised.RunCentralisedMAS;
import jason.infra.jade.RunJadeMAS;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class SimulationService {

    private static Logger log = LogManager.getLogger();
    private String tname;

    /**
     * Simulation entry point
     */
    public void startSimulation(SimulationArgs args){
        try {
            // generazione giocatori
            List<String> playersName = generatePlayersName(args.getPlayers());

            // tucson
            TucsonChannel tucsonChannel = startTucson(args.isDebug());

            // settings
            putSettingsOnTupleSpace(tucsonChannel, playersName);

            // mas project
            if(args.isDistributed()){
                // go jade
                startDistributedJadeMasProject(false);
            } else {
                // go centralised
                startCentralisedMasProject(args.isDebug(), buildMas2jFile(args, playersName));
            }
        } catch (Exception e) {
            e.printStackTrace();
            log.error("Errore durante avvio della simulazione");
        }
    }

    /**
     * This infrastructure runs all agent in the same host.
     * It provides fast startup and high performance for systems that can be executed in a single computer.
     * It is also useful to test and develop (prototype) systems.
     * Centralised is the default infrastructure.
     */
    private void startCentralisedMasProject(boolean debug, String mas2jPath) throws JasonException {
        System.out.println("Launching mas2j project");
        // start mas
        debug = false;
        if(debug){
            // nb: jason in modalità debug funziona "passo passo"
            RunCentralisedMAS.main(new String[]{mas2jPath, "-debug"});
        } else {
            RunCentralisedMAS.main(new String[]{mas2jPath});
        }
    }

    /**
     * http://jason.sourceforge.net/faq/#sec:whyjade
     * When should I use the JADE infrastructures?
     * The centralised infrastructure does not support:
     * execution of the agent at distributed hosts, and interoperability with non-Jason agent.
     *
     * If you need any of these features, you should choose the JADE infrastructure (or implement/plug a new infrastructure for/into Jason yourself).
     * The interoperability with non-Jason agent is achieved by JADE through FIPA-ACL communication.
     */
    private void startDistributedJadeMasProject(boolean debug) {
        System.out.println("Launching mas2j project");
        try {
            if (debug) {
                RunCentralisedMAS.main(new String[]{"boomparty.mas2j", "-debug"});
            } else {
                // tucson
                startTucson(debug);

                // jade
                startJade(false);

                // jason
                RunJadeMAS.main(new String[]{"boomparty.mas2j"});

                // qui non arriva fino a quando MAS è attivo
            }
        }catch (JasonException e) {
            e.printStackTrace();
        }
    }

    /**
     * Start Tucson platform
     */
    private TucsonChannel startTucson(boolean debug) {
        // Tucson Node Service
        TucsonTupleCentreId ttci = TucsonUtils.startTucsonNS(Settings.TNS_PORT);
        if(ttci != null){
            this.tname = TucsonUtils.buildNSId(ttci); // default@127.0.1.1:20504
            log.info("Istanziato Tucson: " + tname);
        } else {
            log.error("Errore durante lo start di Tucson sulla porta: " + Settings.TNS_PORT);
        }

        // Tucson channel
        TucsonChannel tChannel = new TucsonChannel("tucsonChannel", ttci);
        log.info("Canale di comunicazione verso tucson creato correttamente");

        // Respect reaction
        TucsonUtils.loadReactionFromFile(tChannel, Settings.REACTION_FILE);
        log.info("Respect reactions caricate correttamente");

        // Tucson inspector
        if(debug){
            TucsonUtils.launchInspector();
            log.info("Istanziato Tucson Inspector su " + tname);
        }

        return tChannel;
    }

    /**
     * Start jade platform
     * @param isRemote true when the current node is being distributed
     */
    private void startJade(boolean isRemote) {
        AgentContainer jadeContainer;
        if(isRemote){
            jadeContainer = JadeUtils.startPeripheralContainer(Settings.MC_HOST, Settings.MC_PORT);
        } else {
            // main container sul nodo della simulazione
            jadeContainer = JadeUtils.startMainContainer();
        }
    }

//    /**
//     * Nel caso si volesse simulare il comportamento del jason eclipse plugin
//     * DO NOT REMOVE
//     */
//    private void compileProject() {
//        new Thread(() -> {
//            MAS2JProject project = parseProject();
//            // launch the MAS
//            try {
//                MASLauncherInfraTier masLauncher;
//                masLauncher = project.getInfrastructureFactory().createMASLauncher();
//                masLauncher.setProject(project);
//                //masLauncher.setListener(arg0)
//                if (masLauncher.writeScripts(true, false)) {
//                    new Thread(masLauncher, "MAS-Launcher").start();
//                }
//            } catch (Exception ex) {
//                ex.printStackTrace();
//            }
//        }).start();
//    }
//
//    private MAS2JProject parseProject() {
//        try {
//            System.out.println("Parsing project file... ");
//
//            // String projectDirectory = "C:\\Users\\Ale\\Documents\\BoomParty\\mas";
//            String projectDirectory = new File(".").getCanonicalPath();
//            String mas2jPath = projectDirectory + File.separator + "boomparty.mas2j";
//
//            //String text = loadFile(mainFile.getLocation().toString());
//            String text = loadFile(mas2jPath);
//
//            jason.mas2j.parser.mas2j parser = new jason.mas2j.parser.mas2j(new StringReader(text));
//            MAS2JProject project = parser.mas();
//            project.setDirectory(projectDirectory);
//            project.setProjectFile(new File(mas2jPath));
//            project.fixAgentsSrc();
//            System.out.println(" parsed successfully!\n");
//            return project;
//        } catch (ParseException ex) {
//            System.out.println("\nmas2j: syntactic errors found... \n" + ex + "\n");
//        } catch (TokenMgrError ex) {
//            System.out.println("\nmas2j: lexical errors found... \n" + ex + "\n");
//        } catch (Exception ex) {
//            System.out.println("Error: " + ex.getMessage());
//            ex.printStackTrace();
//        }
//        return null;
//    }
//
//    private String loadFile(String archive) throws FileNotFoundException, IOException {
//
//        File file = new File(archive);
//
//        if (!file.exists()) {
//            return null;
//        }
//
//        BufferedReader br = new BufferedReader(new FileReader(archive));
//        StringBuffer outputBuf = new StringBuffer();
//
//        String line;
//        while( (line = br.readLine()) != null ){
//            outputBuf.append(line + "\n");
//        }
//        br.close();
//        return outputBuf.toString().trim();
//    }

    /**
     * Crea il file mas2j della simulazione
     * @param playersName La lista dei giocatori
     * @return Il percorso al file generato
     */
    private String buildMas2jFile(SimulationArgs args, List<String> playersName){

        List<String> lines = new ArrayList<>();
        lines.add("MAS boomparty {");
        lines.add("\tinfrastructure: " + (args.isDistributed() ? "Jade": "Centralised"));
        lines.add("\tenvironment: " + BasicEnvironment.class.getName());
        lines.add("\tagents:");
        for (String name: playersName) {
            lines.add("\t\t"+name+" tucsonAgent agentArchClass "+ BoomPartyAgentArch.class.getName() +";");
        }
        lines.add("\taslSourcePath:");
        lines.add("\t\t\"src/asl\";");
        lines.add("}");

        try {
            Path file = Files.createTempFile("tmp-mas2j",".mas2j");
            //Path file = Paths.get("/home/aleneri/Downloads/test.mas2j");
            Files.write(file, lines, Charset.forName("UTF-8"));
            return file.toString();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Genera un nome per ogni player della partita
     * @param players Numero di giocatori
     * @return La lista di nomi
     */
    private List<String> generatePlayersName(int players){
        Faker f = new Faker();
        List<String> names = new ArrayList<>();
        for (int i = 0; i < players; i++){
            //names.add(f.gameOfThrones().character());
            names.add(f.superhero().name().replaceAll("\\s|-", "").toLowerCase());
        }
        return names;
    }

    /**
     * Inserisco le config di simulazione su tucson
     */
    private void putSettingsOnTupleSpace(TucsonChannel tChannel, List<String> playersName) throws InvalidLogicTupleException {
        // inserisco i giocatori della partita
        for (String name: playersName){
            tChannel.actionAsync(Out.class, new PlayerTuple(name, null).toTuple());
        }
        // inserisco il token che tutti gli agenti proveranno a "claimare"
        // il primo che riesce a prenderlo -> diventa mazziere
        tChannel.actionAsync(Out.class, "token(mazziere)");
    }
}

