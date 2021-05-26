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
import java.util.ArrayList;
import java.util.List;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "MultivariatBean")
@SessionScoped
public class MultivariatBean {

    String level = "";
    String image = "";
    String type = "default";
    String taxFilter = "0";
    String chartLink = "";
    String ccaTableLink = "";
    String display = "";
    Boolean toFile = false;
    String color = "default";
    String colorBy = "group";
    String symbolBy = "NULL";
    String height = "150";
    String width = "220";
    String resolution = "200";
    boolean selectMode = true;
    String taxa = "";
    boolean pairwise = false;
    String groupA = "all";
    String groupB = "all";
    String groupSA = "all";
    String groupSB = "all";
    String distMethod = "jaccard";
    boolean filesGenerated = false;
    boolean showCCATable = false;
    String orderBy = "GST";
    String errorm = "";
    String minSim = "0.5";
    String vSize = "5";
    Configs config = new Configs();
    
    boolean scale = false;
    
    boolean legend = true;
    String groupS = "all";
    boolean label = false;
    String firstC = "1";
    String secondC = "2";
    String hull = "hullF";
    boolean loadings = false;
    String figureFormat = "png";

    
    /** Creates a new instance of GroupsPlotsBean */
    public MultivariatBean() {
        if(config.isDataMiner()){
            taxFilter = "0";
            
            level = "default";
        }
    }

    public String getMinSim() {
        return minSim;
    }

    public String getFigureFormat() {
        return figureFormat;
    }

    public void setFigureFormat(String figureFormat) {
        this.figureFormat = figureFormat;
    }
    
    

    public void setMinSim(String minSim) {
        this.minSim = minSim;
    }

    public String getCcaTableLink() {
        return ccaTableLink;
    }

    public void setCcaTableLink(String ccaTableLink) {
        this.ccaTableLink = ccaTableLink;
    }



    public String getvSize() {
        return vSize;
    }

    public void setvSize(String vSize) {
        this.vSize = vSize;
    }

    public String getPheight() {
        String px = Utils.mmToPX(height);
        return (px);
    }

    public String getPwidth() {       
        return (Utils.mmToPX(width));
    }

    public String getFirstC() {
        return firstC;
    }

    public void setFirstC(String firstC) {
        this.firstC = firstC;
    }

    public String getSecondC() {
        return secondC;
    }

    public void setSecondC(String secondC) {
        this.secondC = secondC;
    }

    public boolean isLoadings() {
        return loadings;
    }

    public void setLoadings(boolean loadings) {
        this.loadings = loadings;
    }

    public boolean isScale() {
        return scale;
    }

    public void setScale(boolean scale) {
        this.scale = scale;
    }

    public String getDistMethod() {
        return distMethod;
    }

    public void setDistMethod(String distMethod) {
        this.distMethod = distMethod;
    }

    public boolean isLabel() {
        return label;
    }

    public void setLabel(boolean label) {
        this.label = label;
    }

   

    public boolean isLegend() {
        return legend;
    }

    public void setLegend(boolean legend) {
        this.legend = legend;
    }

    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
    }
    public String getSymbolBy() {
        return symbolBy;
    }

    public void setSymbolBy(String symbolBy) {
        this.symbolBy = symbolBy;
    }
    public String getColorBy() {
        return colorBy;
    }

    public void setColorBy(String colorBy) {
        this.colorBy = colorBy;
    }

    public String getHull() {
        return hull;
    }

    public void setHull(String hull) {
        this.hull = hull;
    }

    
    
    public String getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
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

    public boolean isFilesGenerated() {
        return filesGenerated;
    }

    public void setFilesGenerated(boolean filesGenerated) {
        this.filesGenerated = filesGenerated;
    }

    public boolean isShowCCATable() {
        return showCCATable;
    }

    public void setShowCCATable(boolean showCCATable) {
        this.showCCATable = showCCATable;
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

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public String getDisplay() {
        return display;
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
        filesGenerated = false;
        showCCATable = false;
        
        
        CalypsoOConfigs config = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);
        
        if (dataM == null) {
            errorm = "Internal ERROR: null dataMatrix";
            System.out.println(errorm);
            return false;
        }
  
        String dfFile = dataM.getMatrixCompNorm();
  
        if (dfFile == null) {
            this.errorm = "ERROR: no dataMatrix: " + dataM.getErrorM();
            System.out.println(errorm);
            return false;
        }
  
        String annotFile = dataM.getAnnot().getAnnotFile();

  
        int tF = Integer.parseInt(taxFilter);



        String title = "";
        if(!config.isDataMiner()) title=level;
        String plotType = type;


        String gA = groupA;
        String gB = groupB;
        String tA = groupSA;
        String tB = groupSB;

        if (type.contains("dendro") | type.equals("pcoa") | type.equals("heatmap")) {
            if(config.isDataMiner()) title = distMethod;
            else title = title + " (" + distMethod + ")";
        }



        String chartFileName;
        
        if(figureFormat.equals("pdf")){
            chartFileName = config.tempFileName(".pdf");
        }
        else if(figureFormat.equals("svg")){
            chartFileName = config.tempFileName(".svg");
        }
        else{
        chartFileName = config.tempFileName(".png");
        }
        String chartFile = config.tempFileWeb(chartFileName);

          
        
        String ccaTableName = config.tempFileName(".png");
        String ccaTableFile = config.tempFileWeb(ccaTableName);
 
        

        System.out.println("Runnning R");

        JavaR jr = new JavaR();
 
        
        String link = config.getTmpDirUrl() + chartFileName;       
        
        if(dataM.getAnnot().getEnvVarsAll().isEmpty()){
            if(type.equals("adonis+") || type.equals("ccap") || type.equals("rdap") || type.equals("pcap")  || type.equals("dendrop")){
                type = type.substring(0, type.length()-1);
                this.errorm = "Warning: no environmental variables provided. Running "+type+".";             
            }else if(type.equals("envheatmap")){
                type = "heatmap";
            }
        }

        if(! jr.multivariat(dfFile, type, chartFile, 
                annotFile, ccaTableFile, tF, orderBy, colorBy, color, plotType, distMethod,
                title, scale, Integer.parseInt(width.trim()), Integer.parseInt(height.trim()),
                Integer.parseInt(resolution.trim()), legend, groupS, label,
                loadings, firstC, secondC,
                Double.parseDouble(minSim.trim()), Integer.parseInt(vSize.trim()), figureFormat, 
                hull,symbolBy,SessionDataBean.getCurrentInstance().getDistFile())){
            this.errorm = jr.getError();
            return(false);
            
        }

        this.setChartLink(link);
        
        if(type.startsWith("cca") || type.startsWith("rda")){
            showCCATable = true;
            link = config.getTmpDirUrl() + ccaTableName;
            ccaTableLink = link;          
        }
        

        filesGenerated = true;

        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

        this.filesGenerated = false;
        this.showCCATable = false;
        this.errorm = "";
        //this.toScreen = false;
        //this.toFile = false;

    }

    public void setSelectedGroups() {

        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;
    }

    public List getTypes() {
        List l = new ArrayList();
        l.add(new SelectItem("pcoa", "PCoA"));
         l.add(new SelectItem("pca", "PCA"));
         l.add(new SelectItem("pcap", "PCA+"));
         l.add(new SelectItem("cca", "CCA"));
     //   l.add(new SelectItem("ccaF", "CCA-F"));
        l.add(new SelectItem("ccap", "CCA+"));
         //      l.add(new SelectItem("pcao", "PCA O"));
        l.add(new SelectItem("dapc", "DAPC"));
         l.add(new SelectItem("rda", "RDA"));
      //   l.add(new SelectItem("rdaF", "RDA-F"));
        l.add(new SelectItem("rdap", "RDA+"));
        l.add(new SelectItem("dca", "DCA"));
       // l.add(new SelectItem("dcap", "DCA+"));
        l.add(new SelectItem("metaMDS", "NMDS"));
        l.add(new SelectItem("pls", "PLS"));
        
        l.add(new SelectItem("heatmap", "Heatmap"));
        l.add(new SelectItem("envheatmap", "Heatmap+"));
        
        if(!config.isDataMiner()) l.add(new SelectItem("betadisper", "PERMDISP2"));
       if(!config.isDataMiner())  l.add(new SelectItem("anosim", "Anosim"));
         
        l.add(new SelectItem("dendro", "HierarchicalClustering"));
        l.add(new SelectItem("dendrop", "HierarchicalClustering+"));
        l.add(new SelectItem("graph", "Network"));
        
       
 
       
        l.add(new SelectItem("svm", "SVM LOOC"));
       if(!config.isDataMiner())  l.add(new SelectItem("adonis", "Adonis"));
    //    l.add(new SelectItem("adonisF", "Adonis-F"));
      if(!config.isDataMiner())  l.add(new SelectItem("adonis+", "Adonis+"));
        
        return (l);
    }
                     
    public boolean isComponentsopt() {
        
        if(type.contains("pcoa") || type.contains("pca") || type.contains("rda") || type.contains("dca") ||
          type.contains("cca") ){
            return true;
        }
        
        return false;
    }
    
                     
    public boolean isSymbolopt() {
        
        if(type.contains("pcoa") ){
            return true;
        }
        
        return false;
    }
    
    public boolean isShowLegendOpt() {
        
        if(type.contains("svm") ){
            return false;
        }
        
        return true;
    }
    
    public boolean isColorOpt() {
        
        if(type.contains("svm") ){
            return false;
        }
        
        return true;
    }
    
    public boolean isLoadingsopt() {
        
        if(type.contains("pca") || type.contains("rda") || type.contains("dca") ||
           type.contains("MDS") || type.contains("cca") ){
            return true;
        }
        
        return false;
    }
    
    public boolean isSampleIDopt() {
        
        if(type.equals("pcoa") || type.contains("pca") || type.contains("rda") || type.contains("dca") ||
           type.contains("MDS") || type.contains("cca") ){
            return true;
        }
        
        return false;
    }
    
    
    public boolean isDistopt() {
        
        if(type.equals("pcoa") || type.equals("betadisper") || type.equals("anosim") ||
           type.contains("dendro") || type.equals("graph") || 
                type.equals("heatmap")   ){
            return true;
        }
        
        return false;
    }
    
       public boolean isNetworkopt() {
        
        if(type.equals("graph") ){
            return true;
        }
        
        return false;
    }


    public List getAllTaxa() {


        List l = SessionDataBean.getCurrentInstance().getAllTaxa(level);

        return (l);
    }

    public List getCmodes() {
        List l = new ArrayList();
        l.add(new SelectItem("allG", "All Groups"));
        l.add(new SelectItem("allT", "All GroupS Points"));
        l.add(new SelectItem("gt", "Groups & GroupS"));
        return (l);
    }

    public List getAllGroupS() {
        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }

    public List getComponents() {
        List l = new ArrayList();
        l.add(new SelectItem("1", "1"));
        l.add(new SelectItem("2", "2"));
        l.add(new SelectItem("3", "3"));
        l.add(new SelectItem("4", "4"));
        l.add(new SelectItem("5", "5"));
        l.add(new SelectItem("6", "6"));
        l.add(new SelectItem("7", "7"));
        return (l);
    }
    
    public List getColors(){
        SessionDataBean sdb = SessionDataBean.getCurrentInstance();
        if(type.contains("heatmap")) return sdb.getColorsHeatMap();
        return sdb.getColors();
    }
    
    public List getHulls() {
        List l = new ArrayList();
        l.add(new SelectItem("ellipse", "Ellipse"));
        l.add(new SelectItem("ellipseF", "Filled Ellipse"));
        l.add(new SelectItem("hull", "Hull"));
        l.add(new SelectItem("hullF", "Filled Hull"));
        l.add(new SelectItem("spider", "Spider"));
        l.add(new SelectItem("spiderF", "Filled Spider"));
        l.add(new SelectItem("cluster", "Cluster"));
        l.add(new SelectItem("none", "None"));
        return (l);
    }
    
     public boolean isHullopt() {
        
        if(type.contains("pca") || type.contains("rda") || type.contains("dca") ||
           type.contains("MDS") || type.contains("cca") ){
            return true;
        }
        
        return false;
    }
}
