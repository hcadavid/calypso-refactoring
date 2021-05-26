/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

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
@ManagedBean(name = "DiversityBean")
@SessionScoped
public class DiversityBean {

    String level = "";
    String image = "";
    String type = "default";
    
    String chartLink = "";
    String color = "default";
    String height = "150";
    String width = "180";
    String resolution = "200";
    boolean selectMode = true;
    String taxa = "";
    
    boolean pairwise = false;
  
    
    String statsFileLink = "";
    boolean vertical = true;
    boolean filesGenerated = false;
    String index;
    String orderBy = "GST";
    boolean fullLabel = false;
    String errorm = "";
    String p = "";
    boolean showP = false;
    boolean unclassified = false;
    String groupS = "all";
    String colorBy = "group";
    String figureFormat = "png";
    

    /** Creates a new instance of GroupsPlotsBean */
    public DiversityBean() {
        
    }

    public String getIndex() {
        return index;
    }

    public void setIndex(String index) {
        this.index = index;
    }

    public String getColorBy() {
        return colorBy;
    }

    public void setColorBy(String colorBy) {
        this.colorBy = colorBy;
    }

    public String getFigureFormat() {
        return figureFormat;
    }

    public void setFigureFormat(String figureFormat) {
        this.figureFormat = figureFormat;
    }

    
    
    public boolean isUnclassified() {
        return unclassified;
    }

    public void setUnclassified(boolean unclassified) {
        this.unclassified = unclassified;
    }

   
    

     public String getPheight(){
        String px = Utils.mmToPX(height);
       return(px);
    }

    public String getPwidth(){
       return(Utils.mmToPX(width));
    }

    public boolean isVertical() {
        return vertical;
    }

    public void setVertical(boolean vertical) {
        this.vertical = vertical;
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

    public String getChartLink() {
        filesGenerated = true;
        return chartLink;
    }

    public void setChartLink(String chartLink) {
        this.chartLink = chartLink;
    }

    public boolean isFullLabel() {
        return fullLabel;
    }

    public void setFullLabel(boolean fullLabel) {
        this.fullLabel = fullLabel;
    }

    public String getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public String getP() {
        return p;
    }

    public void setP(String p) {
        this.p = p;
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

    public boolean isShowP() {
        return showP;
    }

    public void setShowP(boolean showP) {
        this.showP = showP;
    }

    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
    }

    

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
    
    

    public boolean getChart() {
        errorm = "";
        p = "";
        this.setChartLink("");
        filesGenerated = false;
        showP = false;

       

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

        

        String title = level;
        String plotType = type;

        boolean groupByGroupS = false;
        boolean groupAndGroupS = false;

       

        String matrixFile = dataM.getMatrixComp();

        if (matrixFile == null) {
            System.out.println("ERROR: no matrixFile in DiversityBean");
            return (false);
        }

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
        
        String chartFileName = config.tempFileName(suffix);


        String chartFile = config.tempFileWeb(chartFileName);

        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        String annotFile = dataM.getAnnot().getAnnotFile();

        
        if (!jr.diversityChart(matrixFile, annotFile, orderBy, chartFile,
                color, colorBy, plotType, index, title, unclassified,
                Integer.parseInt(width.trim()), Integer.parseInt(height.trim()),
                Integer.parseInt(resolution.trim()), groupS, figureFormat)) {
            errorm = jr.getError();

            return false;
        }
        p = jr.getP();
        if (!(p == null)) {
            showP = true;
        }



        String link = config.getTmpDirUrl() + chartFileName;

        this.setChartLink(link);

        filesGenerated = true;

        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

        filesGenerated = false;
        showP = false;
        errorm = "";
        //this.toScreen = false;
        //this.toFile = false;

    }

    public void setSelectedGroups() {

        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;javar
    }

    public List getTypes() {
        List l = new ArrayList();
        l.add(new SelectItem("box+", "Stripchart"));
        l.add(new SelectItem("box", "Boxplot"));
        l.add(new SelectItem("bar", "Barchart"));
        
        l.add(new SelectItem("rarG", "Rarefaction (Group)"));
        l.add(new SelectItem("rarI", "Rarefaction (Individual)"));
        l.add(new SelectItem("rarB", "Rarefaction (Boxplot)"));
          l.add(new SelectItem("mcpHill", "mcpHill"));
     //   l.add(new SelectItem("abundance", "AbundancePlot"));
      //  l.add(new SelectItem("anova+", "Anova+"));
     //    l.add(new SelectItem("anova+TwoWayInt", "Anova+TWI"));
          l.add(new SelectItem("anova+Add", "Anova+"));
       
       
        
        return (l);
    }

    public List getAllGroupS() {
        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }

    public List getIndexTypes() {
        List l = SessionDataBean.getCurrentInstance().getDiversityIndexTypes();
        return (l);
    }
}
