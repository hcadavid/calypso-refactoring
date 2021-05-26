/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Configs;
import CalypsoCommon.DataMatrix;
import CalypsoCommon.JavaR;
import CalypsoCommon.LevelDataMatrix;

import CalypsoCommon.Utils;
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
@ManagedBean(name = "RegressionBean")
@SessionScoped
public class RegressionBean {

    String level = "";
    String image = "";
    String taxFilter = "50";
    String chartLink = "";
    String color = "default";
    String height = "200";
    String width = "290";
    String resolution = "200";
    boolean selectMode = true;
    String taxa = "All";
    boolean pairwise = false;
    String groupA = "all";
    String groupB = "all";
    String groupSA = "all";
    String groupSB = "all";
    String statsFileLink = "";
    boolean vertical = true;
    boolean showTable = false;
    boolean showTR = false;
    String listFile = null;
    String regressionFile = null;
    boolean paired = false;
    String errorm = "";
    boolean unclassified = false;
    String groupS = "all";
    Boolean showChart = false;
    String regressBy = "response";
    String regressionFileLink = "";
    String index = "shannon";
    String dist = "jaccard";
    String corIndex = "pearson";
    
    Configs config = new Configs();
    
    
    String timeBy = "time";

    /** Creates a new instance of GroupsPlotsBean */
    public RegressionBean() {
        if(config.isDataMiner()){
            taxFilter = "100";
            
             level = "default";
        }
    }

    public String getTimeBy() {
        return timeBy;
    }

    public void setTimeBy(String timeBy) {
        this.timeBy = timeBy;
    }

    
   
    public String getRegressBy() {
        return regressBy;
    }

    public void setRegressBy(String regressBy) {
        this.regressBy = regressBy;
    }

    

  
    

    public String getIndex() {
        return index;
    }

    public void setIndex(String index) {
        this.index = index;
    }

    public String getDist() {
        return dist;
    }

    public void setDist(String dist) {
        this.dist = dist;
    }

    

    public String getPheight() {
        String px = Utils.mmToPX(height);
        return (px);
    }

    public String getPwidth() {
        return (Utils.mmToPX(width));
    }

    public boolean isUnclassified() {
        return unclassified;
    }

    public void setUnclassified(boolean unclassified) {
        this.unclassified = unclassified;
    }

    public boolean isShowTable() {
        return showTable;
    }

    public void setShowTable(boolean showTable) {
        this.showTable = showTable;
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

    public boolean isVertical() {
        return vertical;
    }

    public void setVertical(boolean vertical) {
        this.vertical = vertical;
    }

    public String getCorIndex() {
        return corIndex;
    }

    public void setCorIndex(String corIndex) {
        this.corIndex = corIndex;
    }
    
    

    public String getStatsFileLink() {
        return statsFileLink;
    }

    public void setStatsFileLink(String statsFileLink) {
        this.statsFileLink = statsFileLink;
    }

    public Boolean getShowChart() {
        return showChart;
    }

    public void setShowChart(Boolean showChart) {
        this.showChart = showChart;
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

    public boolean isPairwise() {
        return pairwise;
    }

    public void setPairwise(boolean pairwise) {
        this.pairwise = pairwise;
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

    public void setSelectMode(boolean selectMode) {
        this.selectMode = selectMode;
    }

    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getResolution() {
        return resolution;
    }

    public void setResolution(String resolution) {
        this.resolution = resolution;
    }

    public String getWidth() {
        return width;
    }

    public void setWidth(String width) {
        this.width = width;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public boolean isShowTR() {
        return showTR;
    }

    public void setShowTR(boolean showTR) {
        this.showTR = showTR;
    }

    public String getChartLink() {
        return chartLink;
    }

    public void setChartLink(String chartLink) {
        this.chartLink = chartLink;
    }

    public boolean isPaired() {
        return paired;
    }

    public void setPaired(boolean paired) {
        this.paired = paired;
    }

    

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getRegressionFileLink() {
        return regressionFileLink;
    }

    public void setRegressionFileLink(String regressionFileLink) {
        this.regressionFileLink = regressionFileLink;
    }



    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
    }

    public String getRegressionFile() {
        return regressionFile;
    }

    public void setRegressionFile(String regressionFile) {
        this.regressionFile = regressionFile;
    }

    

    public String getTaxFilter() {
        return taxFilter;
    }

    public void setTaxFilter(String taxFilter) {
        this.taxFilter = taxFilter;
    }

    public void setSelectedMode() {
        selectMode = false;

        showTable = false;
        showChart = false;
        showTR = false;

        errorm = "";
        //this.toScreen = false;
        //this.toFile = false;

    }

    public String getTableRows() {
        if (listFile == null) {
            errorm = "Internal ERROR: null list";
            System.out.println(errorm);

            return ("");
        }

        // print header
        String fname = "Taxa";
        if(config.isDataMiner()) fname = "Feature";
        String table = "<thead><tr><th>"+fname+"</th><th>P</th><th>R        </th><th>Mean Abundance</th><th>Positive Samples</th></tr></thead>\n<tbody>";

        System.out.println("Scanning file " + listFile);

        try {
            Scanner scanner = new Scanner(new File(listFile));
            scanner.useDelimiter("\n");
            //first use a Scanner to get each line

            // get first line
            scanner.nextLine();

            while (scanner.hasNext()) {
                String line = scanner.nextLine();
                String[] fields = line.split(",");

                if (fields.length != 5) {
                    errorm = "ERROR wrong format, expecting 5 line elements.";
                    System.out.println(errorm);
                    return "";
                }

                String p = fields[0].trim();
                String co = fields[1].trim();
                String tax = fields[2].trim();
                String mean = fields[3].trim();
                String present = fields[4].trim();


                System.out.println(tax + " " + p);

                table += "<tr><td>" + tax + "</td><td>" + p + "</td><td>" + co + "</td><td>" + mean + "</td><td>" + present + "</td></tr>\n";
            }
            scanner.close();

        } catch (Exception err) {
            errorm = "ERROR while parsing file " + listFile + err.toString();
            System.out.println(errorm);
            return "";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public String getTableRegression() {
        if (regressionFile == null) {
            errorm = "Internal ERROR: null regression file";
            System.out.println(errorm);

            return ("");
        }

        // print header
        String fname = "Taxa";
        if(config.isDataMiner()) fname = "Feature";
        String table = "<thead><tr><th>"+fname+"</th><th>P</th><th>Coefficient</th></thead>\n<tbody>";

        System.out.println("Scanning file " + regressionFile);

        try {
            Scanner scanner = new Scanner(new File(regressionFile));
            scanner.useDelimiter("\n");
            //first use a Scanner to get each line

            // get first line
            scanner.nextLine();

            while (scanner.hasNext()) {

                String line = scanner.nextLine();
                String[] fields = line.split(",");

                if (fields.length != 3) {
                    errorm = "ERROR wrong format, expecting 3 line elements.";
                    System.out.println(errorm);
                    return "";
                }

                String tax = fields[0].trim();
                String co = fields[1].trim();
                String p = fields[2].trim();

                table += "<tr><td>" + tax + "</td><td>" + p + "</td><td>" + co + "</td></tr>\n";
            }
            scanner.close();

        } catch (Exception err) {
            errorm = "ERROR while parsing file " + regressionFile + err.toString();
            System.out.println(errorm);
            return "";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public String getTableTR() {
        if (regressionFile == null) {
            errorm = "Internal ERROR: null regression file";
            System.out.println(errorm);

            return ("");
        }

        // print header
        String fname = "Taxa";
        if(config.isDataMiner()) fname = "Feature";
        String table = "<thead><tr><th>"+fname+"</th>";

        System.out.println("Scanning file " + regressionFile);

        try {
            Scanner scanner = new Scanner(new File(regressionFile));
            scanner.useDelimiter("\n");
            //first use a Scanner to get each line

            // get header first line
            String line = scanner.nextLine();
            String[] fields = line.split(",");
            int envN = fields.length - 2;
            String [] envs = fields;

            for(int i = 2; i < fields.length; i++){
                table += "<th>" + envs[i] + "</h>";
            }
            table += "\n<tbody>";

            while (scanner.hasNext()) {
                line = scanner.nextLine();
                fields = line.split(",");

                if (fields.length < 3) {
                    errorm = "ERROR wrong format, expecting 3 line elements.";
                    System.out.println(errorm);
                    return "";
                }

                table += "<tr>";

               

                for(int i = 1; i < fields.length;i++){

                    table += "<td>" + fields[i] + "</td>";
                }

                table += "</tr>\n";
            }
            scanner.close();

        } catch (Exception err) {
            errorm = "ERROR while parsing file " + regressionFile + err.toString();
            System.out.println(errorm);
            return "";
        }

        table += "</tbody></table>\n";

        return table;
    }

    public boolean run() {
        errorm = "";

        this.setChartLink("");

        showChart = false;
        showTable = false;
        listFile = null;
        regressionFile = null;
        showTR = false;
        regressionFileLink = null;

        if ((  regressBy.equals("group") | regressBy.equals("time") |
                regressBy.equals("pair") )  && groupA.equals(groupB)) {
            errorm = "ERROR: Select different conditions";
            System.out.println(errorm);
            return false;
        }

        System.out.println("Getting diversity chart");
        CalypsoOConfigs config = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            errorm = "Internal ERROR: null dataMatrix";
            System.out.println(errorm);

            return false;
        }

        int tF = Integer.parseInt(taxFilter);
    String matrixFile = dataM.getMatrixCompNorm();
        
        // include all taxa for diversity 
        if(regressBy.equals("diversity") | regressBy.equals("diversityDist")
                    | regressBy.equals("distance")){
            tF=0;
        }
        // use raw file (non-normalized) for diversity regression
        if(regressBy.equals("diversity") | regressBy.equals("diversityDist")){
            matrixFile = dataM.getMatrixComp();
        }
        
        
        String title = level;


        

        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        String annotFile = dataM.getAnnot().getAnnotFile();

        Utils ut = new Utils();

        String outRegression = "";

        String chartFileName = config.tempFileName(".png");

        String chartFile = config.tempFileWeb(chartFileName);

        String outList = "";

        String regressionFileName = "";


        if(regressBy.startsWith("taxa")){
            regressionFileName = config.tempFileName(".csv");
            outRegression = config.tempFileWeb(regressionFileName);
        }

        else if(taxa.equals("all")) {
            outRegression = config.tempFile(".tmp");
            outList = config.tempFile(".tmp");
        }

        if (!jr.regression(matrixFile, annotFile, tF, chartFile, outList,
                outRegression, color, title, Integer.parseInt(width.trim()),
                Integer.parseInt(height.trim()), Integer.parseInt(resolution.trim()),
                groupS, taxa, regressBy, groupA, groupB, paired, index, dist, 
                timeBy, corIndex)) {
            errorm = jr.getError();

            return false;
        }

        if (regressBy.startsWith("taxa")) {
            showChart = true;
            showTable = false;
            showTR = true;
            regressionFile = outRegression;
            regressionFileLink = config.getTmpDirUrl() + regressionFileName;
        } else {
            showChart = true;
            showTR = false;

            if(regressBy.equals("diversity") | regressBy.equals("diversityDist")
                    | regressBy.equals("distance")){
                showTable = false;
                regressionFile = null;
                listFile = null;
            }

            else if(taxa.equals("all")) {
                showTable = true;
                
                listFile = outList;
                regressionFile = outRegression;
            }
            
        }

        String link = config.getTmpDirUrl() + chartFileName;
            this.setChartLink(link);

        return true;
    }

    public List getAllGroupS() {
        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }

    public List getAllTaxa() {
        List l = SessionDataBean.getCurrentInstance().getAllTaxa(level);
        System.out.println(l.toString());
        l.add(0, new SelectItem("all", "All"));


        return (l);
    }

    public List getRegressionModes() {
        List l = new ArrayList();
        String ten = "Taxa vs Envp";
        if(config.isDataMiner()) ten = "Features vs Factors";
        l.add(new SelectItem("taxa", ten));
     //   l.add(new SelectItem("taxaLMEM", "Taxa vs Envp LMEM"));        
        l.add(new SelectItem("taxaTS", "Time Series"));
       if(!config.isDataMiner()) l.add(new SelectItem("diversity", "Diversity vs Envp"));
     //   l.add(new SelectItem("diversityDist", "Diversity Dist vs Envp"));
      //  l.add(new SelectItem("distance", "Distance vs Envp"));
      SessionDataBean sdb = SessionDataBean.getCurrentInstance();
       //l.addAll(sdb.getGroupBy(false,true));
       l.addAll(sdb.getEnvironmentalVariables(false));
        
        return (l);
    }
    
    public boolean iSTimeByopt() {
        
        if(regressBy.equals("taxaTS")){
            return true;
        }
        
        return false;
    }

     public boolean isDistopt() {       
        if(regressBy.equals("distance")){  
            return true;
        }
        return false;
    }
     
      public boolean isTaxaopt() {  
        
        if(regressBy.equals("diversity") || regressBy.equals("distance")){  
            return false;
        }
        return true;
    }
      
      public boolean isFilteropt() {  
        
        if(regressBy.equals("diversity") || regressBy.equals("distance")){  
            return false;
        }
        return true;
    }
     
      
      
      public boolean isDiversityopt() {       
          if(regressBy.equals("diversity")){  
            return true;
        }
        return false;
    }
     
      public boolean isConditionsopt() {       
        if(regressBy.equals("distance") || regressBy.equals("taxa") || regressBy.equals("taxaTS")
                || regressBy.equals("diversity") ){
            return false;
        }    
        return true;
    }
    
    public List getGroups() {
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        String grpMode = regressBy;
    
        List l = new ArrayList();

        l= dataBean.getGroups(grpMode, false);
        
        return (l);

    }
    
    public List getCorIndexS() {
        List l = new ArrayList();

        l.add(new SelectItem("pearson", "Pearson"));
        l.add(new SelectItem("spearman", "Spearman"));


        return (l);
    }
    
    public boolean isCorindexopt() {


        if(regressBy.equals("taxaTS") ){
            return(false);
        }


        return true;
    }

     public List getIndexTypes() {
        List l = SessionDataBean.getCurrentInstance().getDiversityIndexTypes();
        return (l);
    }
}
