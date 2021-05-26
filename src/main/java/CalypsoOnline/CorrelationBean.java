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
@ManagedBean(name = "CorrelationBean")
@SessionScoped
public class CorrelationBean {

    String level = "default";
    String image = "";
    String taxFilter = "100";
    String chartLink = "";
    String display = "";
    String color = "default";
    String height = "180";
    String width = "180";
    String resolution = "200";
    boolean selectMode = true;
    String taxa = "";
    String env = "";
    String envTaxa = "";
    boolean pairwise = false;
    String groupA = "all";
    String groupB = "all";
    String groupSA = "all";
    String groupSB = "all";
    String type;
    String vSize = "30";
    String nodeX = "3";
    String nodeY = "2";
    String minSim = "0.25";
    boolean filesGenerated = false;
    String orderBy = "GST";
    String errorm = "";
    boolean corLayout = true;
    boolean aoverlap = true;
    String corIndex = "pearson";
    String figureFormat = "png";
    
    Configs config = new Configs();

    /**
     * Creates a new instance of GroupsPlotsBean
     */
    public CorrelationBean() {
        if(config.isDataMiner()){
            taxFilter = "0";  
            level = "default";
            minSim = "0.5";
        }
    }

    public String getCorIndex() {
        return corIndex;
    }

    public void setCorIndex(String corIndex) {
        this.corIndex = corIndex;
    }

    public String getMinSim() {
        return minSim;
    }

    public void setMinSim(String minSim) {
        this.minSim = minSim;
    }

    public String getPheight() {
        String px = Utils.mmToPX(height);
        return (px);
    }

    public String getPwidth() {
        return (Utils.mmToPX(width));
    }

    public String getvSize() {
        return vSize;
    }

    public void setvSize(String vSize) {
        this.vSize = vSize;
    }

    public String getNodeX() {
        return nodeX;
    }

    public void setNodeX(String nodeX) {
        this.nodeX = nodeX;
    }

    public String getNodeY() {
        return nodeY;
    }

    public void setNodeY(String nodeY) {
        this.nodeY = nodeY;
    }

    public boolean isCorLayout() {
        return corLayout;
    }

    public void setCorLayout(boolean corLayout) {
        this.corLayout = corLayout;
    }

    public boolean isAoverlap() {
        return aoverlap;
    }

    public void setAoverlap(boolean aoverlap) {
        this.aoverlap = aoverlap;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
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

    public void setGroupSA(String groupSA) {
        this.groupSA = groupSA;
    }

    public String getGroupSB() {
        return groupSB;
    }

    public void setGroupSB(String groupSB) {
        this.groupSB = groupSB;
    }

    public String getFigureFormat() {
        return figureFormat;
    }

    public void setFigureFormat(String figureFormat) {
        this.figureFormat = figureFormat;
    }

    public boolean isPairwise() {
        return pairwise;
    }

    public void setPairwise(boolean pairwise) {
        this.pairwise = pairwise;
    }

    public String getEnv() {
        return env;
    }

    public void setEnv(String env) {
        this.env = env;
    }

    public String getEnvTaxa() {
        return envTaxa;
    }

    public void setEnvTaxa(String envTaxa) {
        this.envTaxa = envTaxa;
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

    public boolean getChart() {
        errorm = "";

        System.out.println("Getting correlation chart");
        CalypsoOConfigs config = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            errorm = "Internal ERROR: null dataMatrix";
            System.out.println(errorm);
            return false;
        }

        String dataMatrix = dataM.getMatrixCompNorm();

        if (dataMatrix == null) {
            this.errorm = dataM.getErrorM();
            return false;
        }

        String annotFile = dataM.getAnnot().getAnnotFile();


        int tF = Integer.parseInt(taxFilter);



        String title = level;
        if(config.isDataMiner()) title = "";


        String chartFileName;

        if (figureFormat.equals("pdf")) {
            chartFileName = config.tempFileName(".pdf");
        } else if (figureFormat.equals("svg")) {
            chartFileName = config.tempFileName(".svg");
        } else {
            chartFileName = config.tempFileName(".png");
        }
        String chartFile = config.tempFileWeb(chartFileName);


        System.out.println("Runnning R");

        JavaR jr = new JavaR();


        if (type.equals("plot")) {
              if (!jr.correlationplot(dataMatrix, annotFile, tF, type, orderBy, chartFile,
                    color, title, Integer.parseInt(width.trim()), Integer.parseInt(height.trim()),
                    Integer.parseInt(resolution.trim()), corIndex, 
                    figureFormat,  env, envTaxa, taxa)) {

                errorm = jr.getError();
                return false;
            }          
            
        } else {

            if (!jr.correlation(dataMatrix, annotFile, tF, type, orderBy, chartFile,
                    color, title, Integer.parseInt(width.trim()), Integer.parseInt(height.trim()),
                    Integer.parseInt(resolution.trim()), Double.parseDouble(minSim.trim()),
                    Integer.parseInt(vSize.trim()), corIndex, corLayout, aoverlap, "NA", "NA", "NA",
                    figureFormat, nodeX, nodeY)) {

                errorm = jr.getError();
                return false;
            }
        }

        String link = config.getTmpDirUrl() + chartFileName;



        this.setChartLink(link);


        filesGenerated = true;

        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

        this.filesGenerated = false;


    }

    public void setSelectedGroups() {

        this.filesGenerated = false;

    }

    public List getAllTaxa() {


        List l = SessionDataBean.getCurrentInstance().getAllTaxa(level);

        return (l);
    }

    public List getTypes() {
        List l = new ArrayList();
         l.add(new SelectItem("graph+", "Network+"));
        l.add(new SelectItem("graph", "Network"));
       
        l.add(new SelectItem("som", "SOM"));
        l.add(new SelectItem("som+", "SOM+"));
        l.add(new SelectItem("heatmap", "Heatmap"));
       // l.add(new SelectItem("plot", "Plot"));


        return (l);
    }

    public boolean isNodeXYopt() {

        if (type.contains("som")) {
            return true;
        }

        return false;
    }

    public boolean isNetworksopt() {

        if (this.selectMode) {
            return false;
        }

        if (type.contains("graph")) {
            return true;
        }

        return false;
    }

    public boolean isPlot() {

        if (this.selectMode) {
            return false;
        }

        if (type.contains("plot")) {
            return true;
        }

        return false;
    }

    public boolean isCorindexopt() {

        if (type.contains("som")) {
            return false;
        }

        return true;
    }

    public List getCorIndexS() {
        List l = new ArrayList();

        l.add(new SelectItem("pearson", "Pearson"));
        l.add(new SelectItem("spearman", "Spearman"));


        return (l);
    }

    public List getEnvAndTaxa() {
        List l = new ArrayList();
    //    l.add("--");
        l.add(new SelectItem("group", "Primary Group"));
        l.add(new SelectItem("time", "Secondary Group"));
        List env = SessionDataBean.getCurrentInstance().getEnvironmentalVariables(false);
        l.addAll(env);
        List tax = getAllTaxa();
        l.addAll(tax);
        return (l);
    }
    
    public List getColors() {
        List l = new ArrayList();
   
        if(type.contains("graph")){
            l.add(new SelectItem("black", "Black"));
             l.add(new SelectItem("white", "White"));
        }
        else{
            l = SessionDataBean.getCurrentInstance().getColorsHeatMap();
        }
        
        
        
        return (l);
    }
    
    public List getOpt() {
        List l = new ArrayList();
        l.add("--");
        List tax = getAllTaxa();
        l.addAll(tax);
        return (l);
    }
}
