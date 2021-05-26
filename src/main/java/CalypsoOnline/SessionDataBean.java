/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Configs;
import CalypsoCommon.DataMatrix;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.faces.bean.SessionScoped;
import CalypsoCommon.LevelDataMatrix;
import CalypsoCommon.SampleAnnotation;
import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import javax.faces.bean.ManagedBean;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.AgeFileFilter;
import org.apache.commons.lang.time.DateUtils;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "SessionDataBean")
@SessionScoped
public class SessionDataBean {

    private LevelDataMatrix dataM; // = new LevelDataMatrix(0);
    private SampleAnnotation sAnnot;
    private String annotFileName = "";
    private String countsFileName = "";
    private String distFileName = "";
    private String distFile = "";
    private String distDelim = "\t";
    private String currentLevel = "";
    private String errorM = "";
    private static final String MANAGED_BEAN_NAME = "SessionDataBean";
    private String taxFileType = "";
    private String taxfilePath = "";
    private boolean visibilityMode = false;
    private String normalization = "none";
    private boolean tss = false;
    private Configs config = new Configs();

    public static SessionDataBean getCurrentInstance() {
        FacesContext context = FacesContext.getCurrentInstance();
        return (SessionDataBean) context.getELContext().getELResolver().getValue(context.getELContext(), null, MANAGED_BEAN_NAME);

        //return (SessionDataBean) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get(MANAGED_BEAN_NAME);
    }

    public void clearTmpFiles() {
        CalypsoOConfigs config = new CalypsoOConfigs();
        String dir = config.getTmpDirWeb();
        cleanDir(dir);
        dir = config.getTempDir();
        cleanDir(dir);

        Configs con = new Configs();

        dir = con.getTmpDir();
        cleanDir(dir);
    }

    public void cleanDir(String dir) {
        System.out.println("Deleting old tmp files in dir " + dir);
        Date oldestAllowedFileDate = DateUtils.addDays(new Date(), -1); //minus days from current date
        File targetDir = new File(dir);
        Iterator<File> filesToDelete = FileUtils.iterateFiles(targetDir, new AgeFileFilter(oldestAllowedFileDate), null);
        //if deleting subdirs, replace null above with TrueFileFilter.INSTANCE
        while (filesToDelete.hasNext()) {
            filesToDelete.next().delete();
        }
    }

    public boolean clearCounts() {
        if (dataM != null) {
            dataM.clear();
        }
        countsFileName = "";

        dataM = null;

        return true;
    }

    public boolean clearDist() {
        distFileName = "";
        distFile = "";

        return true;
    }

    public boolean clearAnnot() {
        sAnnot = null;
        annotFileName = "";

        if (dataM != null) {
            dataM.clearAnnot();
        }
        return true;
    }

    public boolean clearTax() {
        taxFileType = "";
        taxfilePath = "";
        return true;
    }

    public List getLevels() {

        if (dataM == null) {
            System.out.println("ARGGHHHH dataM == null!!!!");
        }

        HashMap hm = dataM.getDataM();
        Set<String> levels = hm.keySet();

        List l = new ArrayList();

        Object[] lO = new String[levels.size()];
        lO = levels.toArray();
        java.util.Arrays.sort(lO);

        for (Object li : lO) {
            l.add(new SelectItem(li.toString(), li.toString()));
        }

        return (l);
    }

    public String getNormalization() {
        return normalization;
    }

    public void setNormalization(String normalization) {
        this.normalization = normalization;
    }

    public boolean isTss() {
        return tss;
    }

    public void setTss(boolean tss) {
        this.tss = tss;
    }

    public String getDistDelim() {
        return distDelim;
    }

    public void setDistDelim(String distDelim) {
        this.distDelim = distDelim;
    }

    public String getErrorM() {
        System.out.println("Fetching error message");
        return errorM;
    }

    public void setErrorM(String errorM) {
        this.errorM = errorM;
    }

    public void clearErrorM() {
        this.errorM = "";
    }

    public Boolean getDataMiner() {
        Configs config = new Configs();

        return config.isDataMiner();
    }

    public String getVersion() {
        Configs config = new Configs();
        CalypsoOConfigs oc = new CalypsoOConfigs();

        if (config.isDataMiner()) {
            return oc.getDataMinerVersion();
        } else {
            return oc.getCalypsoVersion();
        }

    }

    public String getDistFile() {
        return distFile;
    }

    public void setDistFile(String distFile) {
        this.distFile = distFile;
    }

    public String getDistFileName() {
        return distFileName;
    }

    public void setDistFileName(String distFileName) {
        this.distFileName = distFileName;
    }

    public void setVisibilityMode(Boolean visibilityMode) {
        this.visibilityMode = visibilityMode;

    }

    public Boolean getVisibilityMode() {
        return visibilityMode;
    }

    public String getTaxfilePath() {
        return taxfilePath;
    }

    public void setTaxfilePath(String taxfilePath) {
        System.out.println(taxFileType);
        if (taxFileType.equals("") || taxFileType.equals("NoTax")) {
            visibilityMode = false;
        } else {
            visibilityMode = true;
        }
        this.taxfilePath = taxfilePath;
    }

    public String getTaxFileType() {
        return taxFileType;
    }

    public void setTaxFileType(String taxFileType) {

        this.taxFileType = taxFileType;
    }

    public String getCurrentLevel() {
        return currentLevel;
    }

    public void setCurrentLevel(String currentLevel) {
        this.currentLevel = currentLevel;
    }

    public SampleAnnotation getsAnnot() {
        return sAnnot;
    }

    public void setsAnnot(SampleAnnotation sAnnot) {
        this.sAnnot = sAnnot;
    }

    public String getAnnotFileName() {
        return annotFileName;
    }

    public void setAnnotFileName(String annotFileName) {
        this.annotFileName = annotFileName;
    }

    public String getCountsFileName() {
        return countsFileName;
    }

    public void setCountsFileName(String countsFileName) {
        this.countsFileName = countsFileName;
    }

    public LevelDataMatrix getDataM() {
        return dataM;
    }

    public void setDataM(LevelDataMatrix dataM) {
        this.dataM = dataM;
    }

    /**
     * Creates a new instance of SessionDataBean
     */
    public SessionDataBean() {
        clearTmpFiles();
    }

    public void action() {
    }

    public List getDisplays() {
        List l = new ArrayList();
        l.add(new SelectItem("screen", "Screen"));
        l.add(new SelectItem("file", "File"));
        return (l);
    }

    public List getColors() {
        List l = new ArrayList();
        l.add(new SelectItem("default", "default"));
        l.add(new SelectItem("yellowblue2", "yellowblue"));
        l.add(new SelectItem("yellowblue", "yellowblue2"));
        l.add(new SelectItem("blueYellowRed", "blueYellowRed"));
        l.add(new SelectItem("bw", "black&white"));
        l.add(new SelectItem("black", "black"));
        l.add(new SelectItem("rainbow", "rainbow"));
        l.add(new SelectItem("bright", "Bright"));
        l.add(new SelectItem("lb", "blue1"));
        l.add(new SelectItem("db", "blue2"));
        l.add(new SelectItem("blue3", "blue3"));
        l.add(new SelectItem("blue4", "blue4"));
        l.add(new SelectItem("green", "green"));
        l.add(new SelectItem("bluered3", "bluered"));
        l.add(new SelectItem("bluered2", "bluered2"));
        l.add(new SelectItem("bluered", "bluered3"));
        l.add(new SelectItem("bluered4", "bluered4"));
        l.add(new SelectItem("bluered5", "bluered5"));
        l.add(new SelectItem("bluered6", "bluered6"));
        l.add(new SelectItem("brb", "bluered7"));
        l.add(new SelectItem("greenblack", "greenblack"));
        l.add(new SelectItem("grey", "grey"));
        l.add(new SelectItem("heat", "heat"));
        l.add(new SelectItem("heat2", "heat2"));
        l.add(new SelectItem("heat3", "heat3"));
        l.add(new SelectItem("bgy", "BlueGreenYellow"));
        l.add(new SelectItem("redblack", "redblack"));
        l.add(new SelectItem("redgreen", "redgreen"));
        l.add(new SelectItem("redwhite", "redwhite"));
        l.add(new SelectItem("ybgbr", "YBGBR"));
        l.add(new SelectItem("gbr", "GreenBlackRed"));

        return (l);
    }

    public List getColorsHeatMap() {
        List l = new ArrayList();

        System.out.println("HeatMap colors");

        l.add(new SelectItem("blueGoldRed", "BlueGoldRed"));
        l.add(new SelectItem("blueYellowRed", "blueYellowRed"));

        l.add(new SelectItem("yellowblue2", "yellowblue"));
        l.add(new SelectItem("yellowblue", "yellowblue2"));

        l.add(new SelectItem("lb", "blue1"));
        l.add(new SelectItem("db", "blue2"));
        l.add(new SelectItem("blue3", "blue3"));
        l.add(new SelectItem("blue4", "blue4"));
        l.add(new SelectItem("green", "green"));
        l.add(new SelectItem("bluered3", "bluered"));
        l.add(new SelectItem("bluered2", "bluered2"));
        l.add(new SelectItem("bluered", "bluered3"));
        l.add(new SelectItem("bluered4", "bluered4"));
        l.add(new SelectItem("bluered5", "bluered5"));
        l.add(new SelectItem("bluered6", "bluered6"));
        l.add(new SelectItem("brb", "bluered7"));
        l.add(new SelectItem("greenblack", "greenblack"));
        l.add(new SelectItem("grey", "grey"));
        l.add(new SelectItem("heat", "heat"));
        l.add(new SelectItem("heat2", "heat2"));
        l.add(new SelectItem("bgy", "BlueGreenYellow"));

        l.add(new SelectItem("redblack", "redblack"));
        l.add(new SelectItem("redgreen", "redgreen"));
        l.add(new SelectItem("redwhite", "redwhite"));
        l.add(new SelectItem("ybgbr", "YBGBR"));
        l.add(new SelectItem("gbr", "GreenBlackRed"));

        return (l);
    }

    public List getOrderBy() {
        List l = new ArrayList();
        l.add(new SelectItem("GST", "GroupP-Pair-GroupS"));
        l.add(new SelectItem("STG", "Pair-GroupS-GroupP"));
        l.add(new SelectItem("SGT", "Pair-GroupP-GroupS"));
        l.add(new SelectItem("TSG", "GroupS-Pair-GroupP"));
        l.add(new SelectItem("TGS", "GroupS-GroupP-Pair"));
        l.add(new SelectItem("GTS", "GroupP-GroupS-Pair"));
        l.add(new SelectItem("LSTG", "Label-Pair-GS-GP"));
        return (l);
    }

    public List getGroupBy() {
        return (getGroupBy(true, true));
    }

    public List getGroupBy(Boolean totalReads, Boolean pairs) {
        List l = new ArrayList();
        l.add(new SelectItem("group", "Primary Group"));
        l.add(new SelectItem("time", "Secondary Group"));

        if (pairs) {
            l.add(new SelectItem("pair", "Pair"));
        }

        if (totalReads & ! config.isDataMiner()) {
            l.add(new SelectItem("total", "TotalReads"));
        }

        //List env = getEnvironmentalVariables(false);
        //l.addAll(env);
        return (l);
    }

    public List getColorBy() {
        List l = getGroupBy();
        List env = getEnvironmentalVariables(false);
        l.addAll(env);

        return (l);
    }

    public List getEnvAndTaxa() {
        List l = getGroupBy();
        l.add("--");
        List env = getEnvironmentalVariables(false);
        l.addAll(env);
        List tax = getAllTaxa(currentLevel);
        l.addAll(tax);
        return (l);
    }

    public List getEnvironmentalVariables(Boolean includeAll) {
        LevelDataMatrix ldm = this.getDataM();
        SampleAnnotation annot = ldm.getSAnnot();

        List l = new ArrayList();

        if (annot == null) {
            return l;
        }

        if (includeAll) {
            l.add(new SelectItem("all", "All"));
        }

        Set<String> envsAll = annot.getEnvVarsAll();

        Object[] so = new String[envsAll.size()];
        so = envsAll.toArray();
        java.util.Arrays.sort(so);

        for (Object e : so) {
            l.add(new SelectItem(e.toString(), e.toString()));
        }

        return (l);
    }

    public List getAllTaxa(String level) {
        LevelDataMatrix ldm = getDataM();
        DataMatrix dM = ldm.getDataMatrix(level);

        List l = new ArrayList();

        if (dM == null) {
            return l;
        }

        LinkedHashSet<String> taxaAll = dM.getOrderedTaxa(0, true);

        Object[] tA = new String[taxaAll.size()];
        tA = taxaAll.toArray();
        java.util.Arrays.sort(tA);

        for (Object t : tA) {
            l.add(new SelectItem(t.toString(), t.toString()));
        }

        return (l);
    }

    public List getModes() {
        List l = new ArrayList();
        l.add(new SelectItem("all", "All taxa"));
        l.add(new SelectItem("taxa", "Single taxa"));
        return (l);
    }

    public List getGroups(String groupMode, Boolean includeAll) {
        List l;

        if (groupMode.equals("group")) {
            l = getGroups(includeAll);
        } else if (groupMode.equals("time")) {
            l = this.getGroupS(includeAll);
        } else if (groupMode.equals("pair")) {
            l = this.getPairs(includeAll);
        } else {
            l = new ArrayList();
        }

        return l;
    }

    public List getGroups(Boolean includeAll) {
        LevelDataMatrix ldm = this.getDataM();
        SampleAnnotation annot = ldm.getSAnnot();

        List l = new ArrayList();

        if (annot == null) {
            return l;
        }

        if (includeAll) {
            l.add(new SelectItem("all", "All"));
        }

        LinkedHashSet<String> groupsAll = annot.getGroupsAll();

        Object[] so = new String[groupsAll.size()];
        so = groupsAll.toArray();
        java.util.Arrays.sort(so);

        for (Object g : so) {
            l.add(new SelectItem(g.toString(), g.toString()));
        }

        return (l);
    }

    public List getGroupS() {
        LevelDataMatrix ldm = this.getDataM();
        SampleAnnotation annot = ldm.getSAnnot();

        List l = new ArrayList();
        l.add(new SelectItem("all", "All"));

        if (annot == null) {
            return l;
        }

        LinkedHashSet<String> groupsAll = annot.getGroupSAll();

        Object[] so = new String[groupsAll.size()];
        so = groupsAll.toArray();
        java.util.Arrays.sort(so);

        for (Object g : so) {
            l.add(new SelectItem(g.toString(), g.toString()));
        }

        return (l);
    }

    public List getGroupS(Boolean includeAll) {
        LevelDataMatrix ldm = this.getDataM();
        SampleAnnotation annot = ldm.getSAnnot();

        List l = new ArrayList();

        if (includeAll) {
            l.add(new SelectItem("all", "All"));
        }

        if (annot == null) {
            return l;
        }

        LinkedHashSet<String> groupsAll = annot.getGroupSAll();

        Object[] so = new String[groupsAll.size()];
        so = groupsAll.toArray();
        java.util.Arrays.sort(so);

        for (Object g : so) {
            l.add(new SelectItem(g.toString(), g.toString()));
        }

        return (l);
    }

    public List getPairs(Boolean includeAll) {
        LevelDataMatrix ldm = this.getDataM();
        SampleAnnotation annot = ldm.getSAnnot();

        List l = new ArrayList();

        if (includeAll) {
            l.add(new SelectItem("all", "All"));
        }

        if (annot == null) {
            return l;
        }

        LinkedHashSet<String> pairsAll = annot.getPairsAll();

        Object[] so = new String[pairsAll.size()];
        so = pairsAll.toArray();
        java.util.Arrays.sort(so);

        for (Object g : so) {
            l.add(new SelectItem(g.toString(), g.toString()));
        }

        return (l);
    }

    public List getGroupSNotAll() {
        LevelDataMatrix ldm = this.getDataM();
        SampleAnnotation annot = ldm.getSAnnot();

        List l = new ArrayList();

        if (annot == null) {
            return l;
        }

        LinkedHashSet<String> groupsAll = annot.getGroupSAll();

        Iterator tIt = groupsAll.iterator();

        Object[] so = new String[groupsAll.size()];
        so = groupsAll.toArray();
        java.util.Arrays.sort(so);

        for (Object g : so) {
            l.add(new SelectItem(g.toString(), g.toString()));
        }

        return (l);
    }

    public List getDistmethods() {
        List l = new ArrayList();

        boolean isDataMiner = this.getDataMiner();

        if (!isDataMiner) {
            l.add(new SelectItem("bray", "Bray-Curtis"));
        }

        l.add(new SelectItem("jaccard", "Jaccard"));

        if (!isDataMiner) {

            if (!this.distFileName.equals("")) {
                l.add(new SelectItem("distFile", "Uploaded Distance Matrix"));
            }

            l.add(new SelectItem("yueclayton", "Yue & Clayton"));
            l.add(new SelectItem("chao", "Chao"));
        }
        //l.add(new SelectItem("inv-cor", "Inv Correlation"));

        l.add(new SelectItem("binomial", "Binomial"));
        l.add(new SelectItem("manhattan", "Manhattan"));
        l.add(new SelectItem("euclidian", "Euclidian"));
        l.add(new SelectItem("inv-pearson", "Pearson's cor"));
        l.add(new SelectItem("inv-spearman", "Spearman cor"));
        l.add(new SelectItem("categorical", "Hamming"));

        return (l);
    }

    public List getDiversityIndexTypes() {
        List l = new ArrayList();
        l.add(new SelectItem("shannon", "Shannon"));
        l.add(new SelectItem("richness", "Richness"));
        l.add(new SelectItem("chao1", "Chao1"));
        l.add(new SelectItem("ace", "ACE"));
        l.add(new SelectItem("evenness", "Evenness"));
        l.add(new SelectItem("simpson", "Simpson"));
        l.add(new SelectItem("invsimpson", "Invsimpson"));
        l.add(new SelectItem("fa", "Fisher's Alpha"));
        return (l);
    }

    public List getFigureFormats() {
        List l = new ArrayList();
        l.add(new SelectItem("png", "PNG"));
        l.add(new SelectItem("pdf", "PDF"));
        l.add(new SelectItem("svg", "SVG"));
        return (l);
    }

    public String terminateSession() {
        ExternalContext ec = FacesContext.getCurrentInstance().getExternalContext();
        ec.invalidateSession();
        try {
            ec.redirect("uploadFiles.jsp"); // redirect() invokes FacesContext.responseComplete() for you
            // redirect() invokes FacesContext.responseComplete() for you
        } catch (IOException ex) {
            Logger.getLogger(SessionDataBean.class.getName()).log(Level.SEVERE, null, ex);
        }

        return null;
    }

}
