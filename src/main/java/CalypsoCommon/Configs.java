 /*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author lutzK
 */
public class Configs {

    String R;
    String RCharts;
    String RCyberT;
    String RCalypso;
    String tmpDir = "/tmp/calypso/";
    String hostname = "";
    Boolean debug;
    String installDIR;
    String perl;
    String qiime2calypso;
    String dataminer2calypso;
    String calypsoTools;
    String type = "calypso"; // either calypso, calypso-devel, dataminer or dataminer-devel
    String ktImportText = " -I /Users/lutzK/KronaTools-2.5/lib  /usr/local/bin/ktImportText";
    
    public void setConfigs() {

        try {
            InetAddress addr = InetAddress.getLocalHost();
            hostname = addr.getHostName();
        } catch (UnknownHostException e) {
            System.out.println("ERROR While getting host name");
            return;
        }


        if (hostname == null) {
            System.out.println("ERROR: HOSTNAME not set!!!!");
        }

        if (hostname.matches("(?i).*sciappv01.*")) {
            R = "/usr/local/bin/R";
            if(this.isDataMiner()) installDIR = "/opt/glassfish/glassfish/domains/domain1/applications/datasmart/";
            else if(this.isCalypsoDevel()) installDIR = "/opt/glassfish/glassfish/domains/domain1/applications/calypso.devel/";
            else installDIR = "/opt/glassfish/glassfish/domains/domain1/applications/calypso3/";
            debug = true;
            RCharts = installDIR + "/resources/charts.R";
            RCyberT = installDIR + "/resources/bayesreg.R";
            RCalypso = installDIR + "/resources/calypso.R";
            perl = "/usr/bin/perl";
            qiime2calypso = installDIR + "/resources/qiime2calypso.pl";
            dataminer2calypso = installDIR + "/resources/dataminer2calypso.pl";
            calypsoTools = installDIR + "/resources/calypsoTools.pl";

        } else if (hostname.matches("(?i).*qimr10377.*")) {
            R = "/usr/bin/R";
            installDIR = "/Users/lutzK/NetBeansProjects/CalypsoOnline_1/";
            debug = true;
            RCharts = installDIR + "web/resources/charts.R";
            RCalypso = installDIR + "web/resources/calypso.R";
            RCyberT = installDIR + "web/resources/bayesreg.R";
            
            perl = "/usr/bin/perl";
            qiime2calypso = installDIR + "web/resources/qiime2calypso.pl";
            dataminer2calypso = installDIR + "web/resources/dataminer2calypso.pl";
            calypsoTools = installDIR + "web/resources/calypsoTools.pl";

        } else if (hostname.matches("(?i).*Users-MacBook.*") ||
                hostname.contains("eduroam") ) {
            R = "/usr/bin/R";
            installDIR = "/Users/lutzK/NetBeansProjects/calypso/";
            String installDIRSources = installDIR + "CalypsoOnline_1-SOURCES/";
            debug = true;
            RCharts = installDIRSources + "web/resources/charts.R";
            RCalypso = installDIRSources + "web/resources/calypso.R";
            RCyberT = installDIRSources + "web/resources/bayesreg.R";
            
            perl = "/usr/bin/perl";
            qiime2calypso = installDIRSources + "web/resources/qiime2calypso.pl";
            dataminer2calypso = installDIRSources + "web/resources/dataminer2calypso.pl";
            calypsoTools = installDIRSources + "web/resources/calypsoTools.pl";

        }
        else if (hostname.matches("(?i).*calypso.*")) {
            R = "/usr/bin/R";
            String base = "/home/calypso/glassfish/glassfish/domains/domain1/applications";
            
           
            if(this.isDataMiner()) installDIR = base + "/datasmart/";
            else if(this.isCalypsoDevel()) installDIR = base + "/calypso-devel/";
            else if(this.isDataMinerDevel()) installDIR = base + "/datasmart-devel/";
            else installDIR = base + "/calypso/";
            debug = true;
            RCharts = installDIR + "/resources/charts.R";
            RCalypso = installDIR + "/resources/calypso.R";
            RCyberT = installDIR + "/resources/bayesreg.R";
            ktImportText = " -I /home/calypso/src/KronaTools-2.5/lib /home/calypso/src/KronaTools-2.5/scripts/ImportText.pl ";
                    
                    
            perl = "/usr/bin/perl";
            qiime2calypso = installDIR + "/resources/qiime2calypso.pl";
            dataminer2calypso = installDIR + "/resources/dataminer2calypso.pl";
            calypsoTools = installDIR + "/resources/calypsoTools.pl";

        }
        else {
            System.out.println("ERROR 176: unknown host :" + hostname + ":");
        }
        
        
        // check if tmp dirs exist
        File td = new File(tmpDir);
        
        if(! td.exists()){
            if(! td.mkdirs()){         
                    System.out.println("ERROR: could not create tmp dir" + tmpDir);
            }
        }
    }

    public String getDataminer2calypso() {
        return dataminer2calypso;
    }

    public void setDataminer2calypso(String dataminer2calypso) {
        this.dataminer2calypso = dataminer2calypso;
    }
    
    

    public Configs() {
        setConfigs();
    }

    public Boolean isDataMiner() {
        if (this.type.equals("dataminer")){return true;}
        if (this.type.equals("dataminer-devel")){return true;}
        return false;
    }

    public Boolean isCalypsoDevel() {
        if (this.type.equals("calupso-devel")){return true;}
        return false;
    }
    
    public Boolean isDataMinerDevel() {
        if (this.type.equals("dataminer-devel")){return true;}
        return false;
    }

    public String getKtImportText() {
        return ktImportText;
    }

    public void setKtImportText(String ktImportText) {
        this.ktImportText = ktImportText;
    }

    public String getPerl() {
        return perl;
    }

    

    public String getInstallDIR() {
        return installDIR;
    }

    public void setInstallDIR(String installDIR) {
        this.installDIR = installDIR;
    }

    public Boolean getDebug() {
        return debug;
    }

    public void setDebug(Boolean debug) {
        this.debug = debug;
    }

    public String getR() {
        return R;
    }

    public void setR(String rBIN) {
        this.R = rBIN;
    }

    public String getHostname() {
        return hostname;
    }

    public void setHostname(String hostname) {
        this.hostname = hostname;
    }

    public String getRCharts() {
        return RCharts;
    }

    public void setRCharts(String RCharts) {
        this.RCharts = RCharts;
    }

    public String getRCyberT() {
        return RCyberT;
    }

    public void setRCyberT(String RCyberT) {
        this.RCyberT = RCyberT;
    }

    
    
    public String getRCalypso() {
        return RCalypso;
    }

    public void setRCalypso(String RCalypso) {
        this.RCalypso = RCalypso;
    }

    

    public String getTmpDir() {
        return tmpDir;
    }

    public void setTmpDir(String tmpDir) {
        this.tmpDir = tmpDir;
    }

    public String tempFileName(String suffix) {

        String filename = "";
        try {
            File f = File.createTempFile("calypso-", suffix, new File(tmpDir));
            filename = f.getName();
            f.delete();
        } catch (IOException ex) {
            Logger.getLogger(Configs.class.getName()).log(Level.SEVERE, null, ex);
        }
       
        return filename;
    }    
        
       public String tempFile(String suffix) {

        String filename = "";
        try {
            File f = File.createTempFile("calypso-", suffix, new File(tmpDir));
      
           f.deleteOnExit();
           return f.getAbsolutePath();
        } catch (IOException ex) {
            Logger.getLogger(Configs.class.getName()).log(Level.SEVERE, null, ex);
        }
       
        return "";
    }
        
        
        
        
        
}
