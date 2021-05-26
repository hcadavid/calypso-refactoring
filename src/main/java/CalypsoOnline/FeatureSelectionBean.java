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
@ManagedBean(name = "FeatureSelectionBean")
@SessionScoped
public class FeatureSelectionBean {

    String level = "default";
    String type = "default";
    String taxFilter = "50";
   
    boolean selectMode = true;

    String taxa = "";
    String groupBy = "group";

    
    String figureLink = "";
    String figureFile = "";

    String method = "";

    String errorm = "";

   
    
    boolean figuresGenerated = false;
    
    String top = "100";
    String direction = "forward";
    String corIndex = "pearson";
  

    Configs config = new Configs();

    
    /**
     * Creates a new instance of GroupsPlotsBean
     */
    public FeatureSelectionBean() {
        if (config.isDataMiner()) {

            level = "default";
        }
    }

    public String getFigureLink() {
        return figureLink;
    }

    public void setFigureLink(String figureLink) {
        this.figureLink = figureLink;
    }

    

  
    


  

    public boolean isFiguresGenerated() {
        return figuresGenerated;
    }

    public void setFiguresGenerated(boolean figuresGenerated) {
        this.figuresGenerated = figuresGenerated;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getTop() {
        return top;
    }

    public void setTop(String top) {
        this.top = top;
    }

    public String getDirection() {
        return direction;
    }

    public void setDirection(String direction) {
        this.direction = direction;
    }

    public String getCorIndex() {
        return corIndex;
    }

    public void setCorIndex(String corIndex) {
        this.corIndex = corIndex;
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

    public boolean run() {
        
        figuresGenerated = false;
        
        figureLink = "";
        figureFile = "";
        
        
        
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

        String figureFileName = configO.tempFileName(".png");

        figureFile = configO.tempFileWeb(figureFileName);


        if (!jr.doFeatureSelection(matrixFile, annotFile, method, figureFile,
                level, tF, groupBy, Integer.parseInt(top.trim()), direction, corIndex)) {
            errorm = jr.getError();
        
            this.figuresGenerated = false;
            return false;
        }

        
         
        
        
        String url = configO.getTmpDirUrl() + figureFileName;
        figureLink = url;
        
        
        
        figuresGenerated = true;
        
        
        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

       
        this.figuresGenerated = false;
        errorm = "";
        //this.toScreen = false;
        //this.toFile = false;

    }

    public void setSelectedGroups() {
        this.figuresGenerated = false;
        
        //this.toScreen = false;
        //this.toFile = false;
    }

    public boolean isDirectionOpt(){
        if(method.equals("step")) return true;
        
        return false;
    }
    
    public List getMethods() {
        List l = new ArrayList();
        l.add(new SelectItem("step", "Step-wise Regression"));
        l.add(new SelectItem("glmnet", "LASSO Regularized Regression"));
         l.add(new SelectItem("randomForest", "Random Forest"));

        //l.add(new SelectItem("chi", "Chi-square"));
        return (l);
    }

   
    public boolean iSGroupByopt() {

        
        return true;
    }

    public List getAllGroupS() {

        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }
    
    public List getGroupNames() {

        SessionDataBean session = SessionDataBean.getCurrentInstance();
        
        List l;
        
        if(method.equals("regression")) l = session.getEnvironmentalVariables(false);
        else l = session.getColorBy();

        return (l);
    }
    
    public List getCorIndexS() {
        List l = new ArrayList();

        l.add(new SelectItem("pearson", "Pearson"));
        l.add(new SelectItem("spearman", "Spearman"));


        return (l);
    }
    
    public List getDirections() {
        List l = new ArrayList();

        l.add(new SelectItem("forward", "Forward"));

            l.add(new SelectItem("both", "Forward & Backward"));


        return (l);
    }

}
