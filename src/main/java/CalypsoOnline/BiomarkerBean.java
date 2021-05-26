/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Configs;
import CalypsoCommon.DataMatrix;
import CalypsoCommon.JavaR;
import CalypsoCommon.LevelDataMatrix;

import java.io.File;
import java.util.ArrayList;

import java.util.List;
import java.util.Scanner;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "BiomarkerBean")
@SessionScoped
public class BiomarkerBean {

    String level = "default";
    String type = "default";
    String taxFilter = "50";
   
    boolean selectMode = true;

    String taxa = "";
    String groupBy = "group";

    String histLink = "";
    String orLink = "";
    String resultsFileLink = "";

    String test = "";

    String errorm = "";

    boolean filesGenerated = false;
    boolean figuresGenerated = false;
    boolean inverseOR = false;

    Configs config = new Configs();

    String resultsFile;

    /**
     * Creates a new instance of GroupsPlotsBean
     */
    public BiomarkerBean() {
        if (config.isDataMiner()) {

            level = "default";
        }
    }

    public String getHistLink() {
        return histLink;
    }

    public void setHistLink(String histLink) {
        this.histLink = histLink;
    }

    public String getOrLink() {
        return orLink;
    }

    public void setOrLink(String orLink) {
        this.orLink = orLink;
    }

    public boolean getInverseOR() {
        return inverseOR;
    }

    public void setInverseOR(boolean inverseOR) {
        this.inverseOR = inverseOR;
    }
    
    

    public String getResultsFile() {
        return resultsFile;
    }

    public void setResultsFile(String resultsFile) {
        this.resultsFile = resultsFile;
    }

    public boolean isFilesGenerated() {
        return filesGenerated;
    }

    public void setFilesGenerated(boolean filesGenerated) {
        this.filesGenerated = filesGenerated;
    }

    public boolean isFiguresGenerated() {
        return figuresGenerated;
    }

    public void setFiguresGenerated(boolean figuresGenerated) {
        this.figuresGenerated = figuresGenerated;
    }

    public String getTest() {
        return test;
    }

    public void setTest(String test) {
        this.test = test;
    }

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public String getGroupBy() {
        return groupBy;
    }

    public void setGroupBy(String groupBy) {
        this.groupBy = groupBy;
    }

    public String getTaxa() {
        return taxa;
    }

    public void setTaxa(String taxa) {
        this.taxa = taxa;
    }

    public boolean isSelectMode() {
        return selectMode;
    }

    public void setSelectMode() {
        selectMode = false;
        this.errorm = "";
    }

    

    public String getResultsFileLink() {
        return resultsFileLink;
    }

    public void setResultsFileLink(String resultsFileLink) {
        this.resultsFileLink = resultsFileLink;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getTaxFilter() {
        return taxFilter;
    }

    public void setTaxFilter(String taxFilter) {
        this.taxFilter = taxFilter;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public boolean getBiomarker() {
        filesGenerated = false;
        figuresGenerated = false;
        
        resultsFileLink = "";

        histLink = "";
        orLink = "";
        this.resultsFile = null;
        errorm = "";

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix";
            System.out.println(errorM);
            return false;
        }

        // do test in R
        CalypsoOConfigs configO = new CalypsoOConfigs();

        int tF = Integer.parseInt(taxFilter);

        String matrixFile = dataM.getMatrixCompNorm();

        if (matrixFile == null) {
            this.errorm = dataM.getErrorM();
            return false;
        }

        String annotFile = dataM.getAnnot().getAnnotFile();

        if (annotFile == null) {
            this.errorm = dataM.getErrorM();
            return false;
        }

        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        String outFileName = configO.tempFileName(".csv");

        this.resultsFile = configO.tempFileWeb(outFileName);

        String histFileName = configO.tempFileName(".png");
         String orFileName = configO.tempFileName(".png");
        String histFile = configO.tempFileWeb(histFileName);
        String orFile = configO.tempFileWeb(orFileName);

        if (!jr.doBiomarker(matrixFile, annotFile, histFile, orFile, test, resultsFile,
                level, tF, groupBy, inverseOR)) {
            errorm = jr.getError();
            resultsFile = null;
            this.filesGenerated = false;
            this.figuresGenerated = false;
            return false;
        }

        
         String link = configO.getTmpDirUrl() + outFileName;

            resultsFileLink = link;
            
        String hLink = configO.getTmpDirUrl() + histFileName;

        histLink = hLink;
        
        String orl = configO.getTmpDirUrl() + orFileName;
        orLink = orl;
        
        System.out.println("hist: " + hLink + " " + histFile);
        
        if(test.equals("randomForest")) figuresGenerated = false;
        else figuresGenerated = true;
        
        filesGenerated = true;

        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

        this.filesGenerated = false;
        this.figuresGenerated = false;
        errorm = "";
        //this.toScreen = false;
        //this.toFile = false;

    }

    public void setSelectedGroups() {
        this.figuresGenerated = false;
        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;
    }

    public String getTable() {
        if (this.resultsFile == null) {
            errorm = "Internal ERROR: null anovaPlusFile file";
            System.out.println(errorm);

            return ("");
        }

        // print header
        String fn = "Taxa";
        if(config.isDataMiner()) fn = "Feature";
        
        String table = "<thead><tr><th> " + fn + "</th>";

        System.out.println("Scanning file " + resultsFile);

        try {
            Scanner scanner = new Scanner(new File(resultsFile));
            scanner.useDelimiter("\n");
            //first use a Scanner to get each line

            // get header first line
            String line = scanner.nextLine();
            String[] fields = line.split(",");
            int envN = fields.length - 1;
            String[] envs = fields;

            for (int i = 1; i < fields.length; i++) {
                table += "<th>" + envs[i].trim() + "</h>";
            }
            table += "\n<tbody>";

            // iterate over each line
            while (scanner.hasNext()) {
                line = scanner.nextLine();
                fields = line.split(",");

                if (fields.length < 3) {
                    errorm = "ERROR wrong format, expecting 3 line elements.";
                    System.out.println(errorm);
                    return "";
                }

                table += "<tr>";

                for (int i = 0; i < fields.length; i++) {

                    table += "<td>" + fields[i].trim() + "</td>";
                }

                table += "</tr>\n";
            }
            scanner.close();

        } catch (Exception err) {
            errorm = "ERROR while parsing file " + resultsFile + err.toString();
            System.out.println(errorm);
            return "";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public List getTests() {
        List l = new ArrayList();
        l.add(new SelectItem("rank", "Wilcoxon Test"));
        l.add(new SelectItem("ttest", "T-test"));
        l.add(new SelectItem("bayes", "Bayes T-test"));
        l.add(new SelectItem("nestedanova", "Nested Anova"));
         l.add(new SelectItem("randomForest", "Random Forest"));
        l.add(new SelectItem("regression", "LogisticRegression"));

        //l.add(new SelectItem("chi", "Chi-square"));
        return (l);
    }

    public boolean iSQTopt() {

        if (test.contains("anova")) {
            return true;
        }

        return false;
    }

    public boolean iSGroupByopt() {

        if (test.equals("nestedanova")) {
            return false;
        }

        return true;
    }

    public List getAllGroupS() {

        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }
    
    public List getGroupNames() {

        SessionDataBean session = SessionDataBean.getCurrentInstance();
        
        List l;
        
        if(test.equals("regression")) l = session.getEnvironmentalVariables(false);
        else l = session.getColorBy();

        return (l);
    }

}
