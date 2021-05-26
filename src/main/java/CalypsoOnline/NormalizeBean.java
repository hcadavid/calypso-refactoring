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


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "NormalizeBean")
@SessionScoped
public class NormalizeBean {

    String level = "default";
    String image = "";

    String orderBy = "";

    Boolean fileGenerated = false;
    Boolean showDistLink = false;
    
    String height = "300";
    String width = "500";
    String resolution = "120";

    String errorm = "";
    boolean tableGenerated = false;

    String normalization = "log2";
    boolean tss = false;
    String chartLink1 = "";
    String chartLink2 = "";
    String countsNormLink = "";
    String metaLink = "";
    String distLink = "";

    public String getChartLink1() {
        return chartLink1;
    }

    public String getCountsNormLink() {
        return countsNormLink;
}

    public String getMetaLink() {
        return metaLink;
    }

    public String getDistLink() {
        return distLink;
    }
    
    
    
    public void setChartLink1(String chartLink1) {
        this.chartLink1 = chartLink1;
    }

    public String getChartLink2() {
        return chartLink2;
    }

    public void setChartLink2(String chartLink2) {
        this.chartLink2 = chartLink2;
    }

    public boolean isTss() {
        return tss;
    }

    public void setTss(boolean tss) {
        this.tss = tss;
    }

    public String getNormalization() {
        return normalization;
    }

    public void setNormalization(String normalization) {
        this.normalization = normalization;
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
        String px = Utils.mmToPX(height);
        return (px);
    }

    public String getPwidth() {
        return (Utils.mmToPX(width));
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

    public Boolean getShowDistLink() {
        return showDistLink;
    }

    public void setShowDistLink(Boolean showDistLink) {
        this.showDistLink = showDistLink;
    }
    
    

    /**
     * Creates a new instance of BarChartsBean
     */
    public NormalizeBean() {

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
        countsNormLink = "";
        metaLink = "";
        distLink = "";
        
        this.fileGenerated = false;
        this.tableGenerated = false;
        showDistLink = false;

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

        String chartFileName1;
        String chartFileName2;

        chartFileName1 = configO.tempFileName(".png");
        chartFileName2 = configO.tempFileName(".png");

        String chartFile1 = configO.tempFileWeb(chartFileName1);
        String chartFile2 = configO.tempFileWeb(chartFileName2);

        File tmp1 = new File(chartFile1);
        tmp1.deleteOnExit();
        File tmp2 = new File(chartFile2);
        tmp2.deleteOnExit();
        
        System.out.println("Runnning R");

        int w = Integer.parseInt(width);
        int h = Integer.parseInt(height);
        int r = Integer.parseInt(resolution);

        String title = "";
        if (!config.isDataMiner()) {
            title = level;
        }

        String normCountsFileName = configO.tempFileName(".csv");
        String nf = configO.tempFileWeb(normCountsFileName);
            
       File tmp3 = new File(nf);
       tmp3.deleteOnExit();
       
        if (jr.normalizeChart(matrixFile, annotFile, chartFile1, chartFile2,
                orderBy, normalization, tss, w, h, r, title, nf, level)) {
        } else {
            System.out.println("ERROR running jr.taxaChart()");

            errorm = jr.getError();

            return false;
        }
        String link1 = configO.getTmpDirUrl() + chartFileName1;
        this.setChartLink1(link1);

        String link2 = configO.getTmpDirUrl() + chartFileName2;
        this.setChartLink2(link2);

        countsNormLink = configO.getTmpDirUrl() + normCountsFileName;

        metaLink = configO.getTmpDirUrl() + dataM.getAnnot().getAnnotFileName();
       
       String distFile = SessionDataBean.getCurrentInstance().getDistFile();
        File tmp = new File(distFile);
       distLink =  configO.getTmpDirUrl() + tmp.getName();
        
  
        this.fileGenerated = true;
        if(distFile.isEmpty() | config.isDataMiner()) showDistLink = false;
        else showDistLink = true;
 
        return true;
    }

}
