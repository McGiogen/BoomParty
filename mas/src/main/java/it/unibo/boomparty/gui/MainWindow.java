package it.unibo.boomparty.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JTabbedPane;

import it.unibo.boomparty.utils.JadeUtils;
import it.unibo.boomparty.utils.TucsonUtils;
import jade.gui.GuiEvent;

public class MainWindow extends JFrame {

    private static final long serialVersionUID = 2825466842242726196L;
    private IMainGuiController ctrl;

    private Dimension screenSize;

    public MainWindow(IMainGuiController ctrl) {
        this.ctrl = ctrl;
        this.screenSize = Toolkit.getDefaultToolkit().getScreenSize();
        this.initUI();
        this.setVisible(true);
    }

    private void initUI() {

        //Ask for window decorations provided by the look and feel.
        JFrame.setDefaultLookAndFeelDecorated(true);

        //1. Create the frame.
        setTitle("Domotic Home");

        //2. What happens when the frame closes?
        setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);

        //3. Kill gui agent
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent event) {
                // Pass to the agent the event.
                final GuiEvent ge = new GuiEvent(this, MainWindowEvent.CLOSE_GUI.getValue());
                MainWindow.this.ctrl.postGuiEvent(ge);
            }
        });

        int width = (int) screenSize.getWidth();
        int height = (int) screenSize.getHeight();
        this.setMinimumSize(new Dimension(2*width/3, (4*height)/5));
        this.setPreferredSize(new Dimension(width/2, (4*height)/5));

        setLocationRelativeTo(null);

        createLayout();
    }

    private void createLayout() {

        this.setLayout(new BorderLayout());

        /****** MENU BAR *****/

        // Menu' file
        JMenu fileMenu = new JMenu("File");
        JMenuItem exitItem = new JMenuItem("Esci");
        exitItem.addActionListener((ActionEvent event) -> {
            System.exit(0);
        });
        fileMenu.add(exitItem);


        // Menu' degli strumenti
        JMenu toolsMenu = new JMenu("Tools");
        JMenuItem tucsonInspectorItem = new JMenuItem("Tucson Inspector");
        tucsonInspectorItem.addActionListener((ActionEvent event) -> {
            TucsonUtils.launchInspector();
        });
        toolsMenu.add(tucsonInspectorItem);
        JMenuItem jadeRMAItem = new JMenuItem("Jade RMA");
        jadeRMAItem.addActionListener((ActionEvent event) -> {
            JadeUtils.launchRMA(this.ctrl.getMainAgentContainer());
        });
        toolsMenu.add(jadeRMAItem);


        JMenuBar menuBar = new JMenuBar();
        menuBar.add(fileMenu);
        menuBar.add(toolsMenu);
        setJMenuBar(menuBar);


        /******** WINDOW CONTENT ********/
        JTabbedPane tabbedPane = new JTabbedPane();

        getContentPane().add(tabbedPane, BorderLayout.CENTER);


        /********* LOG AREA **************/
//        LogPane log = new LogPane();
//        getContentPane().add(log, BorderLayout.SOUTH);
    }

}

