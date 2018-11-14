package it.unibo.boomparty.service;

import it.unibo.boomparty.gui.MainGuiAgent;
import jason.JasonException;
import jason.infra.centralised.RunCentralisedMAS;
import jason.infra.jade.RunJadeMAS;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.boomparty.agents.impl.SettingsAgent;
import it.unibo.boomparty.utils.JadeUtils;
import it.unibo.boomparty.utils.TucsonUtils;
import jade.wrapper.AgentContainer;
import jade.wrapper.AgentController;
import jade.wrapper.StaleProxyException;


public class BootstrapService {

    private static Logger log = LogManager.getLogger();
    private AgentContainer mainJadeContainer;
    private String tname;


    public BootstrapService() {
    }

    public void startSimulation(int players){
        // mas project
        bootMasProject(false);
        // agenti
        // startAgents(players);
    }

    private void bootMasProject(boolean debug) {
        System.out.println("Launching mas2j project");
        try {
            if (debug) {
                RunCentralisedMAS.main(new String[]{"boomparty.mas2j", "-debug"});
            } else {
                // tucson
                startTucson();

                // jade
                startJade();

                startAgents(4);

                // jason
                RunJadeMAS.main(new String[]{"boomparty.mas2j"});

                // qui non arriva fino a quando MAS è attivo
            }
        }catch (JasonException e) {
            e.printStackTrace();
        }
    }

    private void startTucson() {
        // Tucson Node Service
        this.tname = TucsonUtils.startNS();
        log.info("Istanziato Tucson: " + tname);
    }

    private void startJade() {

        this.mainJadeContainer = JadeUtils.startMainContainer();

        // Avvio la gui e il relativo agente se richiesto
        try {
            AgentContainer agentContainer = JadeUtils.startPeripheralContainer();
            AgentController agGui = JadeUtils.createNewAgent(
                    agentContainer,
                    "mainGuiAgent",
                    MainGuiAgent.class,
                    new Object[] { tname }
            );
            agGui.start();
        } catch (StaleProxyException e) {
            log.error("Errore set up sistema: " + e.getMessage());
        }
    }

    private void startAgents(int players) {
        try {
            // Avvio l'agente che gestisce le configurazioni del sistema
            AgentController agSetting = this.mainJadeContainer.createNewAgent(
                    "settingsAgent",
                    SettingsAgent.class.getName(),
                    new Object[] { tname }
            );
            agSetting.start();
        } catch (StaleProxyException e) {
            log.error("Errore durante creazione agenti: " + e.getMessage());
        }
    }

//    /**
//     * Nel caso si volesse simulare il comportamento del jason eclipse plugin
//     * DO NOT REMOVE
//     */
//    private static void compileProject() {
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

//    private static MAS2JProject parseProject() {
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
//    private static String loadFile(String archive) throws FileNotFoundException, IOException {
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

}

