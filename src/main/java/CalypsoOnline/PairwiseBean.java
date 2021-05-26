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
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "PairwiseBean")
@SessionScoped
public class PairwiseBean {

    String level = "";
    String image = "";
    String type = "default";
    String taxFilter = "300";
    String chartLink = "";
    String display = "";
    Boolean toFile = false;
    Boolean toScreen = true;
    String color = "default";
    String height = "120";
    String width = "180";
    String resolution = "200";
    String taxa = "";
    String test = "Wilcoxon";
    String index = "Shannon";
    boolean selectMode = true;
    String firstT = "";
    String secondT = "";
    String thirdT = "";
    String fourthT = "";
    boolean filesGenerated = false;
    boolean tableGenerated = false;
    boolean phistGenerated = false;
   
    String errorm = "";
    boolean label = true;
    boolean legend = true;
    String p = "";
    boolean showP = false;
    StatsMatrix matrixStats = null;
    String alternative = "two.sided";
    Configs config = new Configs();

    /** Creates a new instance of GroupsPlotsBean */
    public PairwiseBean() {
        if(config.isDataMiner()){
            taxFilter = "0";
            
             level = "default";
        }
    }

    public String getAlternative() {
        return alternative;
    }

    public void setAlternative(String alternative) {
        this.alternative = alternative;
    }

    public String getIndex() {
        return index;
    }

    public void setIndex(String index) {
        this.index = index;
    }

    public String getTest() {
        return test;
    }

    public void setTest(String test) {
        this.test = test;
    }

     public String getPheight(){
        String px = Utils.mmToPX(height);
       return(px);
    }

    public String getPwidth(){
       return(Utils.mmToPX(width));
    }

    public boolean isPhistGenerated() {
        return phistGenerated;
    }

    public void setPhistGenerated(boolean phistGenerated) {
        this.phistGenerated = phistGenerated;
    }

    public boolean isSelectMode() {
        return selectMode;
    }

    public void setSelectedMode() {

        selectMode = false;


        this.filesGenerated = false;
        this.showP = false;
        this.phistGenerated = false;
        this.tableGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;

    }

    public String getFirstT() {
        return firstT;
    }

    public void setFirstT(String firstT) {
        this.firstT = firstT;
    }

    public String getSecondT() {
        return secondT;
    }

    public void setSecondT(String secondT) {
        this.secondT = secondT;
    }

    public String getThirdT() {
        return thirdT;
    }

    public void setThirdT(String thirdT) {
        this.thirdT = thirdT;
    }

    public String getFourthT() {
        return fourthT;
    }

    public void setFourthT(String fourthT) {
        this.fourthT = fourthT;
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



    public boolean isFilesGenerated() {
        return filesGenerated;
    }

    public void setFilesGenerated(boolean filesGenerated) {
        this.filesGenerated = filesGenerated;
    }

    public String getP() {
        return p;
    }

    public boolean isShowP() {
        return showP;
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

    public boolean isTableGenerated() {
        return tableGenerated;
    }

    public void setTableGenerated(boolean tableGenerated) {
        this.tableGenerated = tableGenerated;
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
        showP = false;
        filesGenerated = false;
        tableGenerated = false;
        phistGenerated = false;
        matrixStats = null;

        if (firstT.equals(secondT)) {
            errorm = "ERROR: Select different secondary groups";
            System.out.println(errorm);
            return false;
        }

        if (type.equals("dist") || type.equals("table3")) {
            if (fourthT.equals(thirdT)) {
                errorm = "ERROR: Select different secondary groups";
                System.out.println(errorm);
                return false;
            }
        }
        System.out.println("Getting distance chart");
        CalypsoOConfigs config = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        LevelDataMatrix ldm = dataBean.getDataM();
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            errorm = "Internal ERROR: null dataMatrix";
            System.out.println(errorm);
            return false;
        }

        String matrixFile = dataM.getMatrixCompNorm();

        if (matrixFile == null) {
            this.errorm = dataM.getErrorM();
            return false;
        }

        String annotFile = dataM.getAnnot().getAnnotFile();


        int tF = Integer.parseInt(taxFilter);
        if(type.equals("taxas")) tF=0;


        String title = level;
        if(config.isDataMiner()) title = "";

        String chartFileName;
        if (toScreen) {
            chartFileName = config.tempFileName(".png");
        } else {
            chartFileName = config.tempFileName(".pdf");
        }
String chartFile = config.tempFileWeb(chartFileName);
       



        System.out.println("Runnning R");

        JavaR jr = new JavaR();

        System.out.println(type);

        if(! jr.pairwise(matrixFile, annotFile, tF, chartFile, 
                color, type, test, alternative, index, title, label, 
                legend, firstT, secondT, thirdT, fourthT, taxa, 
                Integer.parseInt(width.trim()), Integer.parseInt(height.trim()), 
                Integer.parseInt(resolution.trim()))){
            errorm = jr.getError();
            return false;
        }

        
        
        String link = config.getTmpDirUrl() + chartFileName;

        this.setChartLink(link);

        if (type.equals("table") || type.equals("table3")) {
            filesGenerated = false;
            showP = false;
            tableGenerated = true;
            matrixStats = jr.getStatsMatrix();

            if(matrixStats == null){
                errorm = "Internal ERROR: null matrixStats";
            System.out.println(errorm);
            return false;
            }

            phistGenerated = true;
        } else {
            filesGenerated = true;

            p = jr.getP();
            if (!(p == null)) { 
                showP = true;
            }
        }
        return true;
    }

    public String getTableRows() {
        if (matrixStats == null) {
            errorm = "Internal ERROR: null matrixStats";
            System.out.println(errorm);

            return ("");
        }

        Set<String> groups = matrixStats.getGroupNames();

        // print header
        String table;

        if(type.equals("table3")){
            table = "<thead><tr><th>Taxa</th><th>Group</th><th>P "+ firstT + " - " + secondT  +
                   "</th><th>P " + thirdT + " - " +fourthT + "</th>\n";
        }
        else{
            table = "<thead><tr><th>Taxa</th><th>Group</th><th>P</th><th>P.adj</th><th>FDR qValue</th><th>Mean" + firstT + "</th><th>Mean"+secondT+"</th>\n";
        }

        table += "</tr></thead>\n<tbody>";

        Set<String> ids = matrixStats.getIDs();

        Iterator idT = ids.iterator();

        //print p, p.adj and means
        while (idT.hasNext()) {
            String id = (String) idT.next();
            String tax = matrixStats.getTaxa(id);
            String pg = matrixStats.getP(id);
            String pAdj = matrixStats.getPAdj(id);
            String fdr = matrixStats.getFDR(id);
            String group = matrixStats.getGroup(id);
            String meanG1 = matrixStats.getMean(id, "meanG1");
            String meanG2 = matrixStats.getMean(id, "meanG2");
            

           if(type.equals("table3")){
               String p34 = matrixStats.getP34(id);
               table += "<tr><td>" + tax + "</td><td>" + group + "</td><td>" + pg + "</td><td>"
                       + p34 + "</td></tr>\n";
           }
           else{
                table += "<tr><td>" + tax + "</td><td>" + group + "</td><td>" + pg + "</td><td>" + pAdj + "</td><td>"
                    + fdr + "</td><td>"+ meanG1 + "</td><td>"+ meanG2 + "</td></tr>";
           }
        }

        table += "</tbody></table>\n";

        return table;
    }

    public void setSelectedGroups() {

        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;
    }

    public List getTypes() {
        List l = new ArrayList();

        if(! config.isDataMiner()) l.add(new SelectItem("divs", "DiversityScatter"));
       // l.add(new SelectItem("divb", "DiversityBoxPlot"));
     //   l.add(new SelectItem("taxab", "TaxaBoxPlot"));
        String taxasLabel = "TaxaScatter";
        if(config.isDataMiner()) taxasLabel = "Feature Plot";
        l.add(new SelectItem("taxas", taxasLabel));
        l.add(new SelectItem("scatter", "Scatter Plot"));
        l.add(new SelectItem("bubble", "BubblePlot"));
        l.add(new SelectItem("table", "Table"));
      //  l.add(new SelectItem("table3", "Stats Table TL3"));
       // l.add(new SelectItem("dist", "DistancePlot"));
       

        return (l);
    }
    
     public boolean isTaxasopt() {
        
        if(type.equals("taxas") ){
            return true;
        }
        
        return false;
    }
     
      public boolean isDivopt() {
        
        if(type.equals("divs")){
            return true;
        }
        
        return false;
    }

    public List getAllGroupS() {


        List l = SessionDataBean.getCurrentInstance().getGroupSNotAll();

        return (l);
    }

    public List getAllTests() {
        List l = new ArrayList();
        l.add(new SelectItem("wilcox", "Wilcoxon"));
        l.add(new SelectItem("ttest", "Ttest"));
        return (l);
    }

    public List getAternatives() {
        List l = new ArrayList();
        l.add(new SelectItem("two.sided", "Two sided"));
        l.add(new SelectItem("greater", "Greater"));
        l.add(new SelectItem("less", "Less"));
        return (l);
    }

    public List getAllTaxa() {


        List l = SessionDataBean.getCurrentInstance().getAllTaxa(level);

        return (l);
    }

    public List getIndexTypes() {
        List l = SessionDataBean.getCurrentInstance().getDiversityIndexTypes();
        return (l);
    }
}
