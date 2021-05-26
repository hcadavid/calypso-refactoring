 /*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package CalypsoOnline;

import CalypsoCommon.Configs;
import java.io.File;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author lutzK
 */
public class CalypsoOConfigs {

    // make sure to have the "build" in the dir!!!! otherwise it is not in glassfish docoment dir
    String tmpDirWeb;
    String tmpDirUrl;
    String tempDir;
    String exampleAnnot;
    String exampleAnnotDataMiner;
    String exampleCounts;
    String exampleDistanceMatrix;
    String exampleCountsDataMiner;
    Boolean inProduction = true;
    String rdp22;
    String rdp25;
    String gg13_5;
    String gg13_8;
    String exampleTax;
    String calypsoVersion = "5.2";
    String dataMinerVersion = "3.0";
    Configs config = new Configs();
    Boolean hInputFile = false;
    
    public CalypsoOConfigs() {
        setConfigs();
    }
 
    public boolean isDataMiner(){
        return config.isDataMiner();
    }

    public String getExampleDistanceMatrix() {
        System.out.println(exampleDistanceMatrix);
        return exampleDistanceMatrix;
    }

    public void setExampleDistanceMatrix(String exampleDistanceMatrix) {
        this.exampleDistanceMatrix = exampleDistanceMatrix;
    }
    
    
    
    public String getExampleCounts(){
        if(config.isDataMiner()){
            return this.exampleCountsDataMiner;
        }
        return this.exampleCounts;
    }
    
    public String getExampleAnnot(){
        if(config.isDataMiner()){
            return this.exampleAnnotDataMiner;
        }
        return this.exampleAnnot;
    }
    
    public String getExampleTaxa(){
        return this.exampleTax;
    }
    
    public void setConfigs()  {

        Configs conf = new Configs();

        String hostname = conf.getHostname();

        String installDIR = conf.getInstallDIR();

        if(hostname.matches("(?i).*sciappv01.*")){
            //tmpDirUrl = "bioinfo.qimr.edu.au/CalypsoOnline_1/faces/tempf/";
            tmpDirUrl = "../../tempf/";
            exampleAnnot = installDIR + "/resources/ExampleAnnotation.csv";
            exampleAnnotDataMiner = installDIR + "/resources/ExampleDataMinerMeta.csv";
            exampleCounts = installDIR + "/resources/ExampleCounts.csv";
            exampleCountsDataMiner = installDIR + "/resources/ExampleDataMinerData.csv";
            exampleTax =  installDIR + "/resources/Example_Taxonomy.txt";
            exampleDistanceMatrix =  installDIR + "/resources/exampleDistanceMatrix.txt";
            rdp22 =  installDIR + "/resources/bergeyTrainingTree6.xml";
            rdp25 =  installDIR + "/resources/bergeyTrainingTree9.xml";
            gg13_5 = installDIR + "/resources/99_otu_taxonomy.txt";
            gg13_8 = installDIR + "/resources/gg_13_8_99_otu_taxonomy.txt";
            tempDir = "/var/tmp/calypso/";

            tmpDirWeb = "/opt/glassfish/glassfish/domains/domain1/docroot/tempf/";
        }
        else if(hostname.matches("(?i).*calypso.*"))
        {
            tmpDirUrl = "../../tempf/";
            exampleAnnot = installDIR + "/resources/ExampleAnnotation.csv";
            exampleAnnotDataMiner = installDIR + "/resources/ExampleDataMinerMeta.csv";
            exampleCounts = installDIR + "/resources/ExampleCounts.csv";
            exampleCountsDataMiner = installDIR + "/resources/ExampleDataMinerData.csv";
            exampleTax =  installDIR + "/resources/Example_Taxonomy.txt";
            exampleDistanceMatrix =  installDIR + "/resources/exampleDistanceMatrix.txt";
            rdp22 =  installDIR + "/resources/bergeyTrainingTree6.xml";
            rdp25 =  installDIR + "/resources/bergeyTrainingTree9.xml";
            gg13_5 = installDIR + "/resources/99_otu_taxonomy.txt";
            gg13_8 = installDIR + "/resources/gg_13_8_99_";
            tempDir = "/tmp/calypso/";

            tmpDirWeb = "/home/calypso/glassfish/glassfish/domains/domain1/docroot/tempf/";
        }
        else if(hostname.matches("(?i).*qimr10377.*"))
        {
            tmpDirUrl = "http://localhost:8080/CalypsoOnline_1/faces/tempf/";
            tempDir = "/var/tmp/calypso/";
            tmpDirWeb = installDIR + "build/web/tempf/";
            exampleAnnot = installDIR + "build/web/resources/ExampleAnnotation.csv";
             exampleAnnotDataMiner = installDIR + "build/web/resources/ExampleDataMinerMeta.csv";
            exampleCounts = installDIR + "build/web/resources/ExampleCounts.csv";
            exampleCountsDataMiner = installDIR + "build/web/resources/ExampleDataMinerData.csv";
            exampleTax =  installDIR + "build/web/resources/Example_Taxonomy.txt";
            exampleDistanceMatrix =  installDIR + "build/web/resources/exampleDistanceMatrix.txt";
	    rdp22 =  installDIR + "build/web/resources/bergeyTrainingTree6.xml";
            rdp25 =  installDIR + "build/web/resources/bergeyTrainingTree9.xml";
            gg13_5 = installDIR + "build/web/resources/99_otu_taxonomy.txt";
            gg13_8 = installDIR + "build/web/resources/gg_13_8_99_otu_taxonomy.txt";

            inProduction = false;
        }
        else if(hostname.matches("(?i).*Users-MacBook.*") ||
                hostname.contains("eduroam"))
        {
            tmpDirUrl = "http://localhost:8080/calypso/faces/tempf/";
            tempDir = "/var/tmp/calypso/";
            String installDIRBuild = installDIR + "";
            tmpDirWeb = installDIRBuild + "build/web/tempf/";
            exampleAnnot = installDIRBuild + "build/web/resources/ExampleAnnotation.csv";
             exampleAnnotDataMiner = installDIRBuild + "build/web/resources/ExampleDataMinerMeta.csv";
            exampleCounts = installDIRBuild + "build/web/resources/ExampleCounts.csv";
             exampleCountsDataMiner = installDIRBuild+ "build/web/resources/ExampleDataMinerData.csv";
            exampleTax =  installDIRBuild + "build/web/resources/Example_Taxonomy.txt";
            exampleDistanceMatrix =  installDIR + "build/web/resources/exampleDistanceMatrix.txt";
            rdp22 =  installDIRBuild + "build/web/resources/bergeyTrainingTree6.xml";
            rdp25 =  installDIRBuild + "build/web/resources/bergeyTrainingTree9.xml";
            gg13_5 = installDIRBuild + "build/web/resources/99_otu_taxonomy.txt";
            gg13_8 = installDIRBuild + "build/web/resources/gg_13_8_99_otu_taxonomy.txt";
            inProduction = false;
            hInputFile = true;
        }
        else{
            System.out.println("ERROR 177: unknown host " + hostname);
        }

        // check if tmp dirs exist
        File td = new File(tempDir);
        
        if(! td.exists()){
            if(! td.mkdirs()){         
                    System.out.println("ERROR: could not create tmp dir" + tempDir);
            }
        }

    }

    public String getCalypsoVersion() {
        return calypsoVersion;
    }

    public void setCalypsoVersion(String calypsoVersion) {
        this.calypsoVersion = calypsoVersion;
    }

    public String getDataMinerVersion() {
        return dataMinerVersion;
    }

    public void setDataMinerVersion(String dataMinerVersion) {
        this.dataMinerVersion = dataMinerVersion;
    }
    
    

    public String getTempDir() {
        return tempDir;
    }

    public void setTempDir(String tempDir) {
        this.tempDir = tempDir;
    }



    public String getTmpDirWeb() {
        return tmpDirWeb;
    }

    public void setTmpDirWeb(String tmpDirWeb) {
        this.tmpDirWeb = tmpDirWeb;
    }

    public String getTmpDirUrl() {
        return tmpDirUrl;
    }

    public void setTmpDirUrl(String tmpDirUrl) {
        this.tmpDirUrl = tmpDirUrl;
    }

 public String tempFileName(String suffix){

        String filename = "";
        try {
            File f = File.createTempFile("calypso-", suffix, new File(tempDir));
            filename = f.getName();
            f.delete();
        } catch (IOException ex) {
            Logger.getLogger(CalypsoOConfigs.class.getName()).log(Level.SEVERE, null, ex);
        }

        return filename;
    }

 public String tempFileName(String suffix, String prefix){

        String filename = "";
        try {
            File f = File.createTempFile("calypso-" + prefix + "-", suffix, new File(tempDir));
            filename = f.getName();
            f.delete();
        } catch (IOException ex) {
            Logger.getLogger(CalypsoOConfigs.class.getName()).log(Level.SEVERE, null, ex);
        }

        return filename;
    }

 public String tempFile(String suffix){

        String filename = "";
        try {
            File f = File.createTempFile("calypso-", suffix, new File(tempDir));
            filename = f.getAbsolutePath();
            f.delete();
        } catch (IOException ex) {
            Logger.getLogger(CalypsoOConfigs.class.getName()).log(Level.SEVERE, null, ex);
        }
        File frm = new File(filename);
        frm.deleteOnExit();
        
        return filename;
    }


 public File getTempFile(String suffix)  throws NullPointerException{

            if(tempDir.equals(null)){
            throw new NullPointerException();
         }
     
        File f = null;
        try {
            f = File.createTempFile("calypso-", suffix, new File(tempDir));
            f.deleteOnExit();
        } catch (IOException ex) {
            Logger.getLogger(CalypsoOConfigs.class.getName()).log(Level.SEVERE, null, ex);
            System.out.println("ERROR creating file");
            return null;
        }

        return f;
    }

 public String tempFileWeb(String name){
     name = this.tmpDirWeb + name;
     File f = new File(name);
     f.deleteOnExit();
     return(name);
 }

   public String getTempFileName(String suffix){

        String filename = "";
        try {
            File f = File.createTempFile("calypso-",  suffix, new File(tempDir));
            filename = f.getAbsolutePath();
            
            f.delete();
        } catch (IOException ex) {
            Logger.getLogger(CalypsoOConfigs.class.getName()).log(Level.SEVERE, null, ex);
        }

        return filename;
    }

    public Boolean getInProduction() {
        return inProduction;
    }

    public void setInProduction(Boolean inProduction) {
        this.inProduction = inProduction;
    }

 
}
