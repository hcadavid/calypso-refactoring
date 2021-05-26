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

import java.util.List;
import java.util.Set;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "BarChartsBean")
@SessionScoped
public class BarChartsBean {

    String level = "default";
    String image = "";
    String type = "";
    String orderBy = "";
    String taxFilter = "20";
    String chartLink = "";
    Boolean toFile = false;
    String color = "default";
    Boolean transpose = false;
    Boolean stacked = true;
    
    String signLevel = "1.0";
    Boolean fileGenerated = false;
    Boolean legend = true;
    
    Boolean reOrder = true;
    Boolean scale = false;
    String trim = "0.0";
    String cc = "0.0";
    String height = "200";
    String width = "530";
    String resolution = "200";
    String groupS = "all";
    String errorm = "";
    boolean tableGenerated = false;
    String figureFormat = "png";
    boolean isNotTable = false;
    boolean selectMode = true;
    
   
    
    Configs config = new Configs();
    
    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    
    
    
    public boolean isTableGenerated() {
        return tableGenerated;
    }
 
      public boolean isNotTable() {
          if(type.equals("table")){
              return false;
          }else{
              return true;
          }
    }  
    

    public void setTableGenerated(boolean tableGenerated) {
        this.tableGenerated = tableGenerated;
    }

    public String getFigureFormat() {
        return figureFormat;
    }

    public void setFigureFormat(String figureFormat) {
        this.figureFormat = figureFormat;
    }

    public Boolean getLegend() {
        return legend;
    }

    public void setLegend(Boolean legend) {
        this.legend = legend;
    }

    public String getSignLevel() {
        return signLevel;
    }

    public void setSignLevel(String signLevel) {
        this.signLevel = signLevel;
    }

    public boolean isSelectMode() {
        return selectMode;
    }

    public void setSelectMode(boolean selectMode) {
        this.selectMode = selectMode;
    }

   

   public void setSelectedMode() {
        selectMode = false;

        this.fileGenerated = false;
        this.tableGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;

    }

    
    
     public String getPheight(){
        String px = Utils.mmToPX(height);
       return(px);
    }

    public String getPwidth(){
       return(Utils.mmToPX(width));
    }
    

  

   
    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
    }

    public Boolean getReOrder() {
        return reOrder;
    }

    public void setReOrder(Boolean reOrder) {
        this.reOrder = reOrder;
    }

    public Boolean getScale() {
        return scale;
    }

    public void setScale(Boolean scale) {
        this.scale = scale;
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

    public String getTrim() {
        return trim;
    }

    public void setTrim(String trim) {
        this.trim = trim;
    }

    public String getWidth() {
        return width;
    }

    public String getCc() {
        return cc;
    }

    public void setCc(String cc) {
        this.cc = cc;
    }

    public void setWidth(String width) {
        this.width = width;
    }

    public Boolean getTranspose() {
        return transpose;
    }

    public Boolean getStacked() {
        return stacked;
    }

    public void setStacked(Boolean stacked) {
        this.stacked = stacked;
    }

    public void setTranspose(Boolean transpose) {
        this.transpose = transpose;
    }

    public Boolean getFileGenerated() {
        return fileGenerated;
    }

    public void setFileGenerated(Boolean fileGenerated) {
        this.fileGenerated = fileGenerated;
    }

    /** Creates a new instance of BarChartsBean */
    public BarChartsBean() {
        
        if(config.isDataMiner()){
            taxFilter = "0";
           
            level = "default";
        }
    }

    public Boolean getToFile() {
        return toFile;
    }

    public void setToFile(Boolean toFile) {
        this.toFile = toFile;
    }

    public String getChartLink() {
        return chartLink;
    }

    public void setChartLink(String chartLink) {
        this.chartLink = chartLink;
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

    public String getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
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

    public boolean getChart() {
        errorm = "";
        this.setChartLink("");

        this.fileGenerated = false;
        this.tableGenerated = false;

        CalypsoOConfigs configO = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix";
            System.out.println(errorM);
            return false;
        }


        String matrixFile;
        
        if(config.isDataMiner()) matrixFile = dataM.getMatrixCompNorm();
        else matrixFile = dataM.getMatrixComp();
        
        String annotFile = dataM.getAnnot().getAnnotFile();

           int tF = Integer.parseInt(taxFilter);
           Double p = Double.parseDouble(signLevel);

        JavaR jr = new JavaR();

        String suffix;
        
        switch (figureFormat){
            case "pdf" :   
                suffix = ".pdf";
                break;    
            case  "svg" : 
                suffix = ".svg";
                break;
            default : 
                suffix = ".png";
        }
        
 
        String chartFileName;

        chartFileName = configO.tempFileName(suffix);

        
        String chartFile = configO.tempFileWeb(chartFileName);


        System.out.println("Runnning R");

        Boolean beside = !stacked;

        int w = Integer.parseInt(width);
        int h = Integer.parseInt(height);
        int r = Integer.parseInt(resolution);

        Double tr = Double.parseDouble(trim);

        if(scale) cc = "0.0";
        
        Double colorC = Double.parseDouble(cc);
        
        if (type.equals("table")) {
            this.tableGenerated = true;
        } else {

            String title = "";
            if(! config.isDataMiner()) title = level;
            
             if(type.contains("heat")){
                 if(color.equals("default") || color.equals("black") || color.equals("bright")
                         || color.equals("rainbow")){
                     color="blueGoldRed";
                 }
             }
            
             
             boolean tss = false;
             if(dataBean.isTss()) tss = true;
             
            if (!jr.taxaChart(matrixFile, annotFile, chartFile, orderBy, tF, color, 
                    transpose, beside, type, w, h, r, reOrder, title, groupS,
                    figureFormat,legend, p, scale, tr, tss, colorC)) {
                System.out.println("ERROR running jr.taxaChart()");
                
                errorm = jr.getError();

                return false;
            }
            String link = configO.getTmpDirUrl() + chartFileName;
            this.setChartLink(link);
            this.fileGenerated = true;

        }




        return true;
    }

    public String getTableRowsNorm() {
        errorm = "";

        System.out.println("\nDraw tables!!!!\n\n");
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix";
            System.out.println(errorM);
            return "";
        }
        
        StatsMatrix matrixStats = new StatsMatrix();
        
        System.out.println("Parsing data "+dataM.getMatrixCompNorm());
        
        if(!matrixStats.parseData(dataM.getMatrixCompNormAnnot())){
             String errorM = "Internal ERROR: error parsing data file";
            System.out.println(errorM);
            return "";
        }
        
       Set<String> samples = matrixStats.getSampleNames();

       
       System.out.println(samples);
       
        // print header
        // String fname = "Taxa";
        //if(config.isDataMiner()) fname = "Feature";
        String table = "<thead><tr><th></th>\n";


        for (String sample : samples) {
            table += "<th>" + sample + "</th>";
        }
        table += "</tr></thead>\n<tbody>";

        Set<String> features = matrixStats.getIDs();


        //print p, p.adj and means
        for (String feature : features) {
            
            table += "<tr><td>" + feature + "</td>";
            

            for (String sample : samples) {
                String value = matrixStats.getSampleValue(feature,sample);
                table += "<td>" + value + "</td>";
            }
            table += "</tr>\n";
        }

        table += "</tbody></table>\n";

        this.tableGenerated = true;

        return table;
    }
    
    public String getCountsNormLink(){
        CalypsoOConfigs configO = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();
        
        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix 234 " + level;
            System.out.println(errorM);
            return "";
        }
        
        String file = dataM.getMatrixCompNormAnnot();
        
         if (file == null) {
            String errorM = "Internal ERROR: null file 434";
            System.out.println(errorM);
            return "";
        }
        
        System.out.println(file);
        
        File tmp = new File(file);
        String name = tmp.getName();
        
        return(configO.getTmpDirUrl() + name );
    }

    public String getTableAsTxt() {
        errorm = "";
        System.out.println("in tableAsTxt()");

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix";
            System.out.println(errorM);
            return "";
        }
        
        StatsMatrix matrixStats = new StatsMatrix();
        if(!matrixStats.parseData(dataM.getMatrixCompNorm())){
             String errorM = "Internal ERROR: error parsing data file";
            System.out.println(errorM);
            return "";
        }
        
       Set<String> samples = matrixStats.getSampleNames();

        // print header
         String fname = "Taxa";
        if(config.isDataMiner()) fname = "Feature";
        String table = fname;

      
    for (String sample : samples) {
            table += "," + sample;
        }
        table += "\n";

        Set<String> features = matrixStats.getIDs();

       

        //print p, p.adj and means
        for (String feature : features) {            
            table += feature;
            
            
            for (String sample : samples) {
                String value = matrixStats.getSampleValue(feature,sample);
                table += "," + value;
            }
            table += "\n";
        }

        
        return table;
    }


    
    
    public List getTypes() {
        List l = new ArrayList();
        l.add(new SelectItem("heatp", "HeatMap+"));
        
        l.add(new SelectItem("heat", "HeatMap"));
        l.add(new SelectItem("bar", "Barchart"));
        l.add(new SelectItem("boxplot", "BoxPlot"));
        l.add(new SelectItem("bubble", "Bubbleplot"));
       l.add(new SelectItem("table", "Table"));
        return (l);
    }

    public boolean getGroupbyopt(){
        return type.equals("heat");
    }
    
    
    public List getAllGroupS() {


        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }
    
      public List getColors(){
        SessionDataBean sdb = SessionDataBean.getCurrentInstance();
        System.out.println("Type: " + type);
        if(type.contains("heat")) return sdb.getColorsHeatMap();
        return sdb.getColors();
    }
    
    public boolean isFilter() {
        
        return !type.contains("table");
    }
    
    public boolean isShowColor() {
        
        return type.contains("heat") || type.equals("bar");
    }
    
    public boolean isShowTableLink() {
        if(config.isDataMiner()) return true;
        return(! selectMode);
    }
    
    public boolean isHeatmap() {
        
        return type.contains("heat");
    }
    
}
