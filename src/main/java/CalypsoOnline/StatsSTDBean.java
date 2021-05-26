/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Configs;
import CalypsoCommon.DataMatrix;
import CalypsoCommon.JavaR;
import CalypsoCommon.LevelDataMatrix;
import CalypsoCommon.StatsMatrix;
import CalypsoCommon.Utils;
import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Scanner;
import java.util.Set;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "StatsSTDBean")
@SessionScoped
public class StatsSTDBean {

    String level = "default";
    String type = "default";
    String taxFilter = "300";

    boolean selectMode = true;

    String taxa = "";
    String groupBy = "group";

    String groupA = "all";
    String groupB = "all";
    String groupSA = "all";
    String groupSB = "all";
    String statsFileLink = "";
    String histLink = "";
    String groupS = "all";

    String test = "";
    boolean vertical = true;

    String errorm = "";

    boolean filesGenerated = false;
    boolean figuresGenerated = false;
    StatsMatrix matrixStats = null;

    String anovaPlusFile = null;
    Configs config = new Configs();

    /**
     * Creates a new instance of GroupsPlotsBean
     */
    public StatsSTDBean() {
        if (config.isDataMiner()) {
            taxFilter = "0";
            level = "default";
        }

    }

    public String getGroupA() {
        return groupA;
    }

    public void setGroupA(String groupA) {
        this.groupA = groupA;
    }

    public String getGroupB() {
        return groupB;
    }

    public void setGroupB(String groupB) {
        this.groupB = groupB;
    }

    public String getGroupSA() {
        return groupSA;
    }

    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
    }

    public boolean isVertical() {
        return vertical;
    }

    public void setVertical(boolean vertical) {
        this.vertical = vertical;
    }

    public String getHistLink() {
        return histLink;
    }

    public void setHistLink(String histLink) {
        this.histLink = histLink;
    }

    public String getStatsFileLink() {
        return statsFileLink;
    }

    public void setStatsFileLink(String statsFileLink) {
        this.statsFileLink = statsFileLink;
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

    public void setGroupSA(String groupSA) {
        this.groupSA = groupSA;
    }

    public String getGroupSB() {
        return groupSB;
    }

    public void setGroupSB(String groupSB) {
        this.groupSB = groupSB;
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

    public boolean getStats() {
        filesGenerated = false;
        figuresGenerated = false;

        histLink = "";
        statsFileLink = "";
        matrixStats = null;
        anovaPlusFile = null;
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
        CalypsoOConfigs config = new CalypsoOConfigs();

        int tF = Integer.parseInt(taxFilter);

        String matrixFile;

        if (test.equals("DESeq2") || test.equals("ANCOM")
                || test.equals("aldex")) {
            matrixFile = dataM.getMatrixComp();
        } else {
            matrixFile = dataM.getMatrixCompNorm();
        }

        if (matrixFile == null) {
            this.errorm = dataM.getErrorM();
            System.out.println("ERROR fetching matrix file (" + level + "): + errorm)");
            return false;
        }

        String annotFile = dataM.getAnnot().getAnnotFile();

        if (annotFile == null) {
            this.errorm = dataM.getErrorM();
            System.out.println("ERROR fetching annotFile: " + errorm);
            return false;
        }

        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        String outFileName = config.tempFileName(".csv");

        String outFile = config.tempFileWeb(outFileName);

        String histFileName = config.tempFileName(".png");
        String histFile = config.tempFileWeb(histFileName);

        String lsdFileName = config.tempFileName(".png");
        String ldsFile = config.tempFileWeb(lsdFileName);

        Utils ut = new Utils();

        if (!jr.doStats(matrixFile, annotFile, histFile, test, outFile,
                level, tF, groupBy, groupS)) {
            errorm = jr.getError();
            System.out.println("ERROR running R: " + errorm);
            return false;
        }

        if (test.contains("anova+")) {
            anovaPlusFile = outFile;
        } else {

            matrixStats = jr.getStatsMatrix();

            String hLink = config.getTmpDirUrl() + histFileName;

            histLink = hLink;

            System.out.println("hist: " + hLink + " " + histFile);
            figuresGenerated = true;
        }

        String link = config.getTmpDirUrl() + outFileName;

        statsFileLink = link;

        filesGenerated = true;

        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

        this.filesGenerated = false;
        this.figuresGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;

    }

    public void setSelectedGroups() {

        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;
    }

    public List getAllTaxa(String level) {

        List l = new ArrayList(SessionDataBean.getCurrentInstance().getAllTaxa(level));

        return (l);
    }

    public String getTableAnovaPlus() {
        if (anovaPlusFile == null) {
            errorm = "Internal ERROR: null anovaPlusFile file";
            System.out.println(errorm);

            return ("");
        }

        // print header
        String fname = "Taxa";
        if (config.isDataMiner()) {
            fname = "Feature";
        }
        String table = "<thead><tr><th>" + fname + "</th>";

        System.out.println("Scanning file " + anovaPlusFile);

        try {
            Scanner scanner = new Scanner(new File(anovaPlusFile));
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
            errorm = "ERROR while parsing file " + anovaPlusFile + err.toString();
            System.out.println(errorm);
            return "";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public String getTableALDEX() {

        Set<String> samples = matrixStats.getSampleNames();

        System.out.println(samples);

        // print header
        // String fname = "Taxa";
        //if(config.isDataMiner()) fname = "Feature";
        String fn;
        
        if(config.isDataMiner()) fn = "Feature";
        else fn = "Taxa";
        
        String table = "<thead><tr><th>" + fn + "</th>\n";

        for (String sample : samples) {
            table += "<th>" + sample + "</th>";
        }
        table += "</tr></thead>\n<tbody>";

        Set<String> features = matrixStats.getIDs();

        //print p, p.adj and means
        for (String feature : features) {

            table += "<tr><td>" + feature + "</td>";

            for (String sample : samples) {
                String value = matrixStats.getSampleValue(feature, sample);
                table += "<td>" + value + "</td>";
            }
            table += "</tr>\n";
        }

        table += "</tbody></table>\n";

        return table;

    }

    public String getTableRandomForest() {

        Set<String> groups = matrixStats.getGroupNames();

        // print header
        String fname = "Taxa";
        if (config.isDataMiner()) {
            fname = "Feature";
        }
        String table = "<thead><tr><th>" + fname + "</th><th>Score (Mean Decrease Accuracy)</th>\n";

        Iterator sG = groups.iterator();
        while (sG.hasNext()) {
            String group = (String) sG.next();
            table += "<th>" + group + "</th>";
        }
        table += "</tr></thead>\n<tbody>";

        Set<String> ids = matrixStats.getIDs();

        Iterator idT = ids.iterator();

        //print p, p.adj and means
        while (idT.hasNext()) {
            String id = (String) idT.next();
            String score = String.valueOf(matrixStats.getP(id));

            String tax = matrixStats.getTaxa(id);

            table += "<tr><td>" + tax + "</td><td>" + score + "</td>";

            sG = groups.iterator();
            while (sG.hasNext()) {
                String group = (String) sG.next();
                String mean = String.valueOf(matrixStats.getMean(tax, group));
                table += "<td>" + mean + "</td>";
            }
            table += "</tr>\n";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public String getTableRows() {
        if (test.contains("anova+")) {
            return (getTableAnovaPlus());
        }

        if (test.contains("randomForest")) {
            return (getTableRandomForest());
        }

        if (test.equals("aldex")) {
            return (getTableALDEX());
        }

        Set<String> groups = matrixStats.getGroupNames();

        // print header
        String fname = "Taxa";
        if (config.isDataMiner()) {
            fname = "Feature";
        } else if (test.equals("ANCOM")) {
            fname = "Significant Taxa";
        }
        String table;

        if (test.equals("ANCOM")) {
            table = "<thead><tr><th>" + fname + "</th>\n";
        } else {
            table = "<thead><tr><th>" + fname + "</th><th>P</th><th>P.Bonf</th><th>FDR qValue</th><th>BH</th>\n";
        }

        Iterator sG = groups.iterator();
        while (sG.hasNext()) {
            String group = (String) sG.next();
            table += "<th> " + group + "</th>";
        }
        table += "</tr></thead>\n<tbody>";

        Set<String> ids = matrixStats.getIDs();

        Iterator idT = ids.iterator();

        //print p, p.adj and means
        while (idT.hasNext()) {
            String id = (String) idT.next();
            String p = String.valueOf(matrixStats.getP(id));
            String pAdj = String.valueOf(matrixStats.getPAdj(id));
            String fdr = String.valueOf(matrixStats.getFDR(id));
            String bh = String.valueOf(matrixStats.getBH(id));
            String tax = matrixStats.getTaxa(id);

            if (test.equals("ANCOM")) {
                table += "<tr><td>" + tax + "</td>";
            } else {
                table += "<tr><td>" + tax + "</td><td>" + p + "</td><td>" + pAdj + "</td><td>"
                        + fdr + "</td><td>" + bh + "</td>";
            }

            sG = groups.iterator();
            while (sG.hasNext()) {
                String group = (String) sG.next();
                String mean = String.valueOf(matrixStats.getMean(tax, group));
                table += "<td>" + mean + "</td>";
            }
            table += "</tr>\n";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public List getTests() {
        List l = new ArrayList();
        l.add(new SelectItem("rank", "RankTest"));
        l.add(new SelectItem("anova", "Anova"));
        l.add(new SelectItem("nestedanova", "Nested Anova"));
        l.add(new SelectItem("bayes", "Bayes Anova"));
        l.add(new SelectItem("DESeq2", "Negative binominal (DESeq2)"));
        l.add(new SelectItem("ANCOM", "ANCOM"));
        l.add(new SelectItem("aldex", "ALDEx2"));
       // l.add(new SelectItem("anova+", "Anova+"));
        //  l.add(new SelectItem("anova+TwoWayInt", "Anova+TWI"));
        l.add(new SelectItem("anova+Add", "Anova+"));
        l.add(new SelectItem("randomForest", "RandomForest"));
        //l.add(new SelectItem("chi", "Chi-square"));
        return (l);
    }

    public boolean iSQTopt() {

        if (test.contains("anova")) {
            return true;
        }

        return false;
    }

    public boolean showImage() {
        if (!figuresGenerated) {
            return false;
        }

        return !(test.equals("ANCOM") || test.equals("aldex"));
    }

    public boolean iSGroupByopt() {

        return !test.equals("nestedanova");
    }

    public List getAllGroupS() {

        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }

}
