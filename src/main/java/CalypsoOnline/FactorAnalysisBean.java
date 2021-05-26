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


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "FactorAnalysisBean")
@SessionScoped
public class FactorAnalysisBean {

    String level = "default";
    String image = "";

    String orderBy = "";

    Boolean fileGenerated = false;
    
    
    String factors = "10";
    String height = "300";
    String width = "500";
    String resolution = "120";

    String errorm = "";
    boolean tableGenerated = false;

    
    String chartLink1 = "";
    String chartLink2 = "";
    String factorLink1 = "";
    String factorLink2 = "";
    String metaLink = "";
  
    String algorithm = "brunet";

    public String getChartLink1() {
        return chartLink1;
    }

     public String getChartLink2() {
        return chartLink2;
    }
    
    public String getMetaLink() {
        return metaLink;
    }

    public String getFactors() {
        return factors;
    }

    public void setFactors(String factors) {
        this.factors = factors;
    }

    public String getAlgorithm() {
        return algorithm;
    }

    public void setAlgorithm(String algorithm) {
        this.algorithm = algorithm;
    }
    
    

    public String getFactorLink1() {
        return factorLink1;
    }
    
      public String getFactorLink2() {
        return factorLink2;
    }

    
    
    public void setChartLink1(String chartLink1) {
        this.chartLink1 = chartLink1;
    }

   public void setChartLink2(String chartLink2) {
        this.chartLink2 = chartLink2;
    }
    
    Configs config = new Configs();

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    
    
    public boolean isTableGenerated() {
        return tableGenerated;
    }

    public void setTableGenerated(boolean tableGenerated) {
        this.tableGenerated = tableGenerated;
    }

    public String getPheight() {
        Integer px = Integer.parseInt(Utils.mmToPX(height))/2;
        return (px.toString());
    }

    public String getPwidth() {
        Integer w = Integer.parseInt(Utils.mmToPX(width))/2;
        return (w.toString());
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

    public Boolean getFileGenerated() {
        return fileGenerated;
    }

    public void setFileGenerated(Boolean fileGenerated) {
        this.fileGenerated = fileGenerated;
    }

    
    

    /**
     * Creates a new instance of BarChartsBean
     */
    public FactorAnalysisBean() {

        if (config.isDataMiner()) {

            level = "default";
        }
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

    public boolean getChart() {
        errorm = "";
        this.setChartLink1("");
        this.setChartLink2("");
        factorLink1 = "";
          factorLink2 = "";
        metaLink = "";
       
        
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

        String matrixFile = dataM.getMatrixComp();

        String annotFile = dataM.getAnnot().getAnnotFile();

        JavaR jr = new JavaR();

        String chartFileName1= configO.tempFileName(".png");
        String chartFile1 = configO.tempFileWeb(chartFileName1);
        File tmp1 = new File(chartFile1);
        tmp1.deleteOnExit();
        
        String chartFileName2= configO.tempFileName(".png");
        String chartFile2 = configO.tempFileWeb(chartFileName2);
        File tmp2 = new File(chartFile2);
        tmp2.deleteOnExit();
        
        
        String factorFileName1 = configO.tempFileName(".csv");
        String factorFile1 = configO.tempFileWeb(factorFileName1);
        File tmp3 = new File(factorFile1);
        tmp3.deleteOnExit();
        
        String factorFileName2 = configO.tempFileName(".csv");
        String factorFile2 = configO.tempFileWeb(factorFileName2);
        File tmp4 = new File(factorFile2);
        tmp4.deleteOnExit();
        
        System.out.println("Runnning R");

        int w = Integer.parseInt(width);
        int h = Integer.parseInt(height);
        int r = Integer.parseInt(resolution);
        
        int fa = Integer.parseInt(factors);

        String title = "";
        if (!config.isDataMiner()) {
            title = level;
        }
 
         if (!jr.factorAnalysis(matrixFile, annotFile, chartFile1, 
                 chartFile2, factorFile1,
                factorFile2,fa,
                w, h, r, title, level,algorithm)) {
            System.out.println("ERROR running jr.taxaChart()");

            errorm = jr.getError();

            return false;
        } 
       
       
        String link1 = configO.getTmpDirUrl() + chartFileName1;
        this.setChartLink1(link1);
        
        String link2 = configO.getTmpDirUrl() + chartFileName2;
        this.setChartLink2(link2);

        

        factorLink1 = configO.getTmpDirUrl() + factorFileName1;
        factorLink2 = configO.getTmpDirUrl() + factorFileName2;

        metaLink = configO.getTmpDirUrl() + dataM.getAnnot().getAnnotFileName();
       
        
        
  
        this.fileGenerated = true;
   

        return true;
    }
    
    public List getAlgorithms() {
        List l = new ArrayList();
        l.add(new SelectItem("brunet", "Brunet"));
        l.add(new SelectItem("KL", "KL"));
        l.add(new SelectItem("lee", "lee"));
        l.add(new SelectItem("Frobenius", "Frobenius"));
        l.add(new SelectItem("offset", "offset"));
        l.add(new SelectItem("nsNMF", "nsNMF"));
        l.add(new SelectItem("ls-nmf", "ls-nmf"));
        l.add(new SelectItem("pe-nmf", "pe-nmf"));
        return (l);
    }

}
