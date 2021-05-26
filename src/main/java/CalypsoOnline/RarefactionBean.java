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
@ManagedBean(name = "RarefactionBean")
@SessionScoped
public class RarefactionBean {

    String level = "";
    String image = "";
    String type = "default";
    
    String chartLink = "";

    String display = "";
    Boolean toFile = false;
    Boolean toScreen = true;
    String color = "default";
    String colorBy = "group";
    String height = "100";
    String width = "180";
    String resolution = "200";
    boolean selectMode = true;
    String taxa = "";
    
    boolean pairwise = false;
    String groupA = "all";
    String groupB = "all";
    String groupSA = "all";
    String groupSB = "all";

   
    boolean filesGenerated = false;
    String errorm = "";
    

    /** Creates a new instance of GroupsPlotsBean */
    public RarefactionBean() {
    }


    public String getColorBy() {
        return colorBy;
    }

    public void setColorBy(String colorBy) {
        this.colorBy = colorBy;
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

     public String getPheight(){
        String px = Utils.mmToPX(height);
       return(px);
    }

    public String getPwidth(){
       return(Utils.mmToPX(width));
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

   

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public boolean getChart() {
        errorm = "";
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

        String dfFile = dataM.getMatrixComp();

        if (dfFile == null) {
            this.errorm = dataM.getErrorM();
            return false;
        }

        String annotFile = dataM.getAnnot().getAnnotFile();


        

        String title = "";
        String plotType = type;

        

        String gA = groupA;
        String gB = groupB;
        String tA = groupSA;
        String tB = groupSB;


        title = level;



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

        jr.rarefaction(dfFile, annotFile, chartFile, color, title, colorBy,
                Integer.parseInt(width.trim()), Integer.parseInt(height.trim()),
                Integer.parseInt(resolution.trim()));


        String link = config.getTmpDirUrl() + chartFileName;



        this.setChartLink(link);


        filesGenerated = true;

        return true;
    }

    public void setSelectedMode() {
        selectMode = false;

        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;

    }

    public void setSelectedGroups() {

        this.filesGenerated = false;
        //this.toScreen = false;
        //this.toFile = false;
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
}
