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
@ManagedBean(name = "TaxaBean")
@SessionScoped
public class TaxaBean {

    String level = "default";
    String image = "";
    String type = "default";

    String chartLink = "";
    String statsLink = "";
    String corLink = "";
    String distLink = "";

    String display = "";
    Boolean toFile = false;
    Boolean toScreen = true;
    String color = "default";
    Boolean log = false;

    String height = "130";
    String width = "220";
    String resolution = "200";

    String taxa = "";
    String groupBy = "";
    boolean pairwise = false;
    Configs config = new Configs();

    boolean chartGenerated = false;
    boolean statsGenerated = false;
    boolean corGenerated = false;
    boolean distGenerated = false;
    String errorm = "";

    String figureFormat = "png";

    String groupS = "all";
    String distMethod = "jaccard";
    boolean selectMode = true;

    /**
     * Creates a new instance of GroupsPlotsBean
     */
    public TaxaBean() {
        if (config.isDataMiner()) {
            selectMode = false;
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

    public String getFigureFormat() {
        return figureFormat;
    }

    public void setFigureFormat(String figureFormat) {
        this.figureFormat = figureFormat;
    }

    public String getErrorm() {
        String message = errorm;
        errorm = "";
        return message;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public String getPheight() {
        String px = Utils.mmToPX(height);

        return (px);
    }

    public String getPwidth() {
        return (Utils.mmToPX(width));
    }

    public String getGroupS() {
        return groupS;
    }

    public void setGroupS(String groupS) {
        this.groupS = groupS;
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

    public String getTaxa() {
        return taxa;
    }

    public void setTaxa(String taxa) {
        this.taxa = taxa;
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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public boolean getChart() {
        this.chartGenerated = false;
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

        String title = taxa;

        String tString = taxa;

        Utils ut = new Utils();

        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        String matrixFile;
        if (config.isDataMiner()) matrixFile = dataM.getMatrixCompNorm();
        else matrixFile = dataM.getMatrixComp();
        

        String annotFile = dataM.getAnnot().getAnnotFile();

        String suffix;

        if (figureFormat.equals("pdf")) {
            suffix = ".pdf";
        } else if (figureFormat.equals("svg")) {
            suffix = ".svg";
        } else {
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

        if (groupS.equals("")) {
            errorm = "error, no secondary group";
            return false;
        }

        boolean tss = false;
        if (dataBean.isTss()) {
            tss = true;
        }

        if (!jr.groupChart(matrixFile, annotFile, chartFile,
                statsFile, distFile, corFile, 0, 1,
                color, log, type, true, false, title, Integer.parseInt(width.trim()),
                Integer.parseInt(height.trim()), Integer.parseInt(resolution.trim()),
                groupBy, tString, groupS, distMethod, figureFormat, 0.40, tss,"")) {
            errorm = jr.getError();
            return false;
        }

        statsLink = config.getTmpDirUrl() + statsFileName;
        distLink = config.getTmpDirUrl() + distFileName;
        corLink = config.getTmpDirUrl() + corFileName;
        chartLink = config.getTmpDirUrl() + chartFileName;

        chartGenerated = true;

        return true;
    }

    public void setSelectedGroups() {

        this.chartGenerated = false;
        statsGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;
    }

    public List getTypes() {
        List l = new ArrayList();
        l.add(new SelectItem("stripchart", "Stripchart"));
        l.add(new SelectItem("box", "Boxplot"));
       

        return (l);
    }

    public List getAllTaxa() {

        List l = SessionDataBean.getCurrentInstance().getAllTaxa(level);

        return (l);
    }

    public List getAllGroupS() {

        List l = SessionDataBean.getCurrentInstance().getGroupS();

        return (l);
    }

    public List getGroupByMode() {
        return (SessionDataBean.getCurrentInstance().getGroupBy(false, true));
    }
}
