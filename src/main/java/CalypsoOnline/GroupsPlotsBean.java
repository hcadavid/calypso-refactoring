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
@ManagedBean(name = "GroupsPlotsBean")
@SessionScoped
public class GroupsPlotsBean {

    String level = "";
    String image = "";
    String type = "default";
    String taxFilter = "300";
    String signLevel = "0.05";
    String coreMin = "0.40";
    String chartLink = "";
    String statsLink = "";
    String corLink = "";
    String distLink = "";
    
    String display = "";
    Boolean toFile = false;
    Boolean toScreen = true;
    String color = "default";
    Boolean log = false;
    
    String height = "150";
    String width = "220";
    String resolution = "200";
    Configs config = new Configs();
    
    boolean tableGenerated = false;
    String tableFile = "";
    
    String groupBy = "";
    boolean pairwise = false;
    
    
    boolean vertical = true;
    boolean chartGenerated = false;
    boolean statsGenerated = false;
    boolean corGenerated = false;
    boolean distGenerated = false;
    String errorm = "";
    boolean grid = true;
    
    String figureFormat = "png";
     
     String groupS = "all";
     String distMethod = "jaccard";
     boolean selectMode = true;
    
   

    /** Creates a new instance of GroupsPlotsBean */
    public GroupsPlotsBean() {
        if(config.isDataMiner()){
            taxFilter = "30";
          
            level = "default";
            this.signLevel = "0.00001";
        }
    }

    public String getCorLink() {
        return corLink;
    }

    public void setCorLink(String corLink) {
        this.corLink = corLink;
    }

    
    public String getDistLink() {
        return distLink;
    }

    public void setDistLink(String distLink) {
        this.distLink = distLink;
    }

    public String getStatsLink() {
        return statsLink;
    }

    public void setStatsLink(String statsLink) {
        this.statsLink = statsLink;
    }

    public String getSignLevel() {
        return signLevel;
    }

    public void setSignLevel(String signLevel) {
        this.signLevel = signLevel;
    }
    
    public String getCoreMin() {
        return coreMin;
    }

    public void setCoreMin(String coreMin) {
        this.coreMin = coreMin;
    }
    
    public String getFigureFormat() {
        return figureFormat;
    }

    public void setFigureFormat(String figureFormat) {
        this.figureFormat = figureFormat;
    }

     
    
    public boolean isDistopt() {
        
        
        if(type.equals("distplot") || type.equals("anosim") || type.equals("globalStats") ){
            return true;
        }
        
        return false;
    }
    
    public boolean isSignlopt() {
       
        
        if(type.equals("aovplot") || type.equals("nestedanova") || 
                type.equals("rankplot") || type.equals("rankbox") ){
            return true;
        }
        
        return false;
    }
    
    public boolean iSQTopt() {
        
        if(type.equals("strip") || type.equals("aovplot") 
                || type.equals("nestedanova") || type.equals("box") || type.equals("rankbox") ){
            return true;
        }
        
        return false;
    }
       
       public boolean isCoreopt() {       
        if(type.equals("core")){
            return true;
        }      
        return false;
    }


 
    
    

    public String getDistMethod() {
        return distMethod;
    }

    public void setDistMethod(String distMethod) {
        this.distMethod = distMethod;
    }

    
    
    public String getErrorm() {
        String message = errorm;
        errorm = "";
        return message;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

     public String getPheight(){
        String px = Utils.mmToPX(height);
        
        return(px);
    }

    public String getPwidth(){
       return(Utils.mmToPX(width));
    }

    public boolean isGrid() {
        return grid;
    }

    public void setGrid(boolean grid) {
        this.grid = grid;
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

    public boolean isChartGenerated() {
        return chartGenerated;
    }

    public void setChartGenerated(boolean chartGenerated) {
        this.chartGenerated = chartGenerated;
    }

    public boolean isStatsGenerated() {
        return statsGenerated;
    }

    public void setStatsGenerated(boolean statsGenerated) {
        this.statsGenerated = statsGenerated;
    }

    public boolean isCorGenerated() {
        return corGenerated;
    }

    public void setCorGenerated(boolean corGenerated) {
        this.corGenerated = corGenerated;
    }

    public boolean isDistGenerated() {
        return distGenerated;
    }

    public void setDistGenerated(boolean distGenerated) {
        this.distGenerated = distGenerated;
    }

    

   


    public boolean isPairwise() {
        return pairwise;
    }

    public void setPairwise(boolean pairwise) {
        this.pairwise = pairwise;
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

    public Boolean getLog() {
        return log;
    }

    public void setLog(Boolean log) {
        this.log = log;
    }

   

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getDisplay() {
        return display;
    }

    public void setDisplay(String display) {
        if (display.equals("file")) {
            toFile = true;
        } else {
            toFile = false;
        }
        toScreen = !toFile;
        this.display = display;
    }

    public Boolean getToFile() {
        return toFile;
    }

    public void setToFile(Boolean toFile) {
        this.toFile = toFile;
    }

    public Boolean getToScreen() {
        return toScreen;
    }

    public void setToScreen(Boolean toScreen) {
        this.toScreen = toScreen;
    }

    public String getChartLink() {

        return chartLink;
    }

    public void setChartLink(String chartLink) {
        this.chartLink = chartLink;
    }

      public boolean isSelectMode() {
        return selectMode;
    }
     public void setSelectMode(boolean selectMode) {
        this.selectMode = selectMode;
    }
    
      public void setSelectedMode() {
        selectMode = false;

        this.chartGenerated = false;
        statsGenerated = false;
        this.corGenerated = false;
        this.distGenerated = false;
        this.tableGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;

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

    public String getGroupBy() {
        return groupBy;
    }

    public void setGroupBy(String groupBy) {
        this.groupBy = groupBy;
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

       public String getTableRows() {
        if (type.contains("core")) {
            return(getTableCoreAnalysis());
        }
        return "";
   }    
       
    public boolean isTableGenerated() {
        return tableGenerated;
    }

    public void setTableGenerated(boolean tableGenerated) {
        this.tableGenerated = tableGenerated;
    }
    
    public boolean getChart() {
        this.chartGenerated = false;
        this.tableGenerated = false;
        statsGenerated = false;
        corGenerated = false;
        distGenerated = false;

        System.out.println("Getting group chart");
        CalypsoOConfigs config = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix";
            System.out.println(errorM);
            return false;
        }

        
        

        int tF = Integer.parseInt(taxFilter);
        
        

        String title = "";
        String plotType = type;

        String tString = null;
 
        if(!config.isDataMiner()) title = level;
       
        Utils ut = new Utils();
      
        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        String matrixFile = dataM.getMatrixCompNorm();
        String annotFile = dataM.getAnnot().getAnnotFile();

        String suffix;
        
        if(figureFormat.equals("pdf")){
            suffix = ".pdf";
        }
        else if(figureFormat.equals("svg")){
            suffix = ".svg";
        }
        else{
            suffix = ".png";
        }
        
            String chartFileName;

        chartFileName = config.tempFileName(suffix);
        String chartFile = config.tempFileWeb(chartFileName);
        
        String statsFileName = config.tempFileName(".png");
        String statsFile = config.getTmpDirWeb() + statsFileName;
        String distFileName = config.tempFileName(".png");
        String distFile = config.getTmpDirWeb() + distFileName;


        String corFileName = config.tempFileName(suffix);

        String corFile = config.getTmpDirWeb() + corFileName;

        if(groupS.equals("")){
            errorm = "error, no secondary group";
            return false;
        }

        if(plotType.equals("core")){
 
            int n = 0;
            if(groupBy.equals("group")){              
                n= dataM.getAnnot().getGroupsAll().size();
            }else if(groupBy.equals("time")){    
                  n=dataM.getAnnot().getGroupSAll().size();              
                
            }else if(groupBy.equals("pair")){    
                   n=dataM.getAnnot().getPairsAll().size();               
                
            }
            if(n > 10){
                this.tableGenerated = false;
                chartGenerated = false;
                errorm = "Error: more than 10 groups defined.";                
                return false;
                
            }else if(n == 1){
                 this.tableGenerated = false;
                chartGenerated = false;
                 errorm = "Error: only 1 group defined. Library supports Venn diagrams with at least 2 groups";
                 return false;
            }else if(n > 5){
                this.tableGenerated = true;
                chartGenerated = false;
                errorm = "Error: more than 5 groups defined. Library supports Venn diagrams with 5 groups at most";
            }else{
                this.tableGenerated = true;
                chartGenerated = true;
            }
        }              
        
        if(! jr.groupChart(matrixFile, annotFile, chartFile, 
                statsFile, distFile, corFile,tF,Double.parseDouble(signLevel),
                color, log, plotType, vertical, grid, title, Integer.parseInt(width.trim()),
                Integer.parseInt(height.trim()), Integer.parseInt(resolution.trim()), 
                groupBy, tString, groupS, distMethod,figureFormat,
                Double.parseDouble(coreMin),false, SessionDataBean.getCurrentInstance().getDistFile())){
            errorm = jr.getError();
            return false;
        }

        statsLink = config.getTmpDirUrl() + statsFileName;
        distLink = config.getTmpDirUrl() + distFileName;
        corLink = config.getTmpDirUrl() + corFileName;
        chartLink = config.getTmpDirUrl() + chartFileName;
        

        tableFile = config.tempFileWeb(statsFileName); 
        

        if(plotType.equals("globalStats")){
            statsGenerated = true;
            corGenerated = true;
            distGenerated = true;
        }
        else if(plotType.equals("globalStatsChis"))
        {
            statsGenerated = true;
        }
        else{
            chartGenerated = true;
        }
        return true;
    }

    

    public void setSelectedGroups() {

        this.chartGenerated = false;
        statsGenerated = false;
        tableGenerated=false;
        //this.toScreen = false;
        //this.toFile = false;
    }

    public List getTypes() {
        List l = new ArrayList();
         l.add(new SelectItem("aovplot", "AnovaPlot"));
         l.add(new SelectItem("nestedanova", "NestedAnova"));
         l.add(new SelectItem("rankplot", "RankTestPlot"));
          l.add(new SelectItem("rankbox", "RankTestBoxplot"));
         if(!config.isDataMiner()) l.add(new SelectItem("anosim", "Anosim"));
         if(!config.isDataMiner()) l.add(new SelectItem("globalStats", "GlobCommunityComp"));
        // l.add(new SelectItem("globalStatsChis", "GlobCommunityCompChi"));
        l.add(new SelectItem("box", "Boxplot"));
        l.add(new SelectItem("strip", "Stripchart"));     
        l.add(new SelectItem("bubble", "BubblePlot"));
        l.add(new SelectItem("barchart", "BarChart"));
        l.add(new SelectItem("distplot", "DistancePlot"));
        l.add(new SelectItem("core", "VennDiagram"));
      //  l.add(new SelectItem("lsd", "LSDplot"));
        
        return (l);
    }

 
    
    
   

    public List getAllGroupS() {


        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }

    public List getGroupByMode(){
        return(SessionDataBean.getCurrentInstance().getGroupBy(false,true));
    }
    
    public String getTableCoreAnalysis() {
        if (tableFile == null) {
            errorm = "Internal ERROR: null anovaPlusFile file";
            System.out.println(errorm);

            return ("");
        }

        // print header
        String fn = "Taxa";
        if(config.isDataMiner()) fn="Feature";
        
        String table = "<thead><tr><th>"+fn+"</th>";

        try {
            Scanner scanner = new Scanner(new File(tableFile));
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
            errorm = "ERROR while parsing file " + tableFile + err.toString();
            System.out.println(errorm);
            return "";
        }
        table += "</tbody></table>\n";
        return table;
    }
}
