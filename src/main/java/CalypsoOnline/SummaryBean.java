    /*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.DataMatrix;
import CalypsoCommon.JavaR;
import CalypsoCommon.LevelDataMatrix;
import CalypsoCommon.SampleAnnotation;
import CalypsoCommon.Utils;
import java.io.IOException;
import java.math.BigDecimal;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "SummaryBean")
@SessionScoped
public class SummaryBean {

    String level = "";
    String image = "";
    String type = "";
    
    
    String chartLink = "";
    Boolean toFile = false;
    String color = "default";
   
    
    
  
    Boolean fileGenerated = false;
    Boolean fullLabel = false;
    String height = "100";
    String width = "180";
    String resolution = "200";
    String groupS = "all";
    String errorm = "";
    boolean logScale = false;
    Boolean selectMode = true;

    



    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public boolean isLogScale() {
        return logScale;
    }

    public void setLogScale(boolean logScale) {
        this.logScale = logScale;
    }

    public Boolean getSelectMode() {
        return selectMode;
    }

    public void setSelectMode(Boolean selectMode) {
        this.selectMode = selectMode;
    }

    public void setSelectedMode() {
        selectMode = false;

        this.fileGenerated = false;
       
        //this.toScreen = false;
        //this.toFile = false;

    }
    
    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    

    public Boolean getFullLabel() {
        return fullLabel;
    }

    public void setFullLabel(Boolean fullLabel) {
        this.fullLabel = fullLabel;
    }

    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
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

    public String getPheight(){
        String px = Utils.mmToPX(height);
       return(px);
    }

    public String getPwidth(){
       return(Utils.mmToPX(width));
    }

    public Boolean getFileGenerated() {
        return fileGenerated;
    }

    public void setFileGenerated(Boolean fileGenerated) {
        this.fileGenerated = fileGenerated;
    }

    /** Creates a new instance of BarChartsBean */
    public SummaryBean() {
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

        CalypsoOConfigs config = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        
        if(level.equals("")){
            HashMap hm = ldm.getDataM();
           Set<String> levels = hm.keySet();
           
           level=levels.toArray()[0].toString();
        }
        
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorM = "Internal ERROR: null dataMatrix";
            System.out.println(errorM);
            return false;
        }


        String matrixFile = dataM.getMatrixComp();
        String annotFile = dataM.getAnnot().getAnnotFile();

          if (matrixFile == null) {
            String errorM = "Internal ERROR: null matrixFile";
            System.out.println(errorM);
            return false;
        }
        
        


        JavaR jr = new JavaR();

        String chartFileName;

        chartFileName = config.tempFileName(".png");

        String chartFile = config.tempFileWeb(chartFileName);

        System.out.println("Runnning R");

       
        int w = Integer.parseInt(width);
        int h = Integer.parseInt(height);
        int r = Integer.parseInt(resolution);

       
        String useType = type;
        
        boolean boxplot = false;
        
        if(type.equals("readsBySampleBG")){
            boxplot = true;
            useType = "readsBySample";
        }

        System.out.println(type);
        if (!jr.summary(matrixFile, annotFile, chartFile, color, useType, w, h, r, level, groupS, logScale, boxplot)) {
            errorm = jr.getError();
            return false;
        }
        String link = config.getTmpDirUrl() + chartFileName;
        this.setChartLink(link);
        this.fileGenerated = true;





        return true;
    }

    public List getTypes() {
        List l = new ArrayList();
        l.add(new SelectItem("readsBySample", "ReadsPerSample"));
        l.add(new SelectItem("readsBySampleBC", "ReadsPerSampleBarChart"));
        l.add(new SelectItem("readsBySampleBG", "ReadsPerSampleByGroup"));
     //   l.add(new SelectItem("readsByTaxa", "ReadsPerTaxon"));
    //    l.add(new SelectItem("detectDist", "PositiveSamples"));

        return (l);
    }
    
     public boolean isRanksopt() {
        
        if(type.equals("readsByTaxa") || type.equals("detectDist") ){
            return true;
        }
        
        return false;
    }

    public List getAllGroupS() {


        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }
}
