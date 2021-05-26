/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Configs;
import CalypsoCommon.DataMatrix;
import CalypsoCommon.Hierarchy;
import CalypsoCommon.JavaR;
import CalypsoCommon.LevelDataMatrix;
import CalypsoCommon.SampleAnnotation;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;

import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import javax.xml.bind.DatatypeConverter;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "HierarchyBean")
@SessionScoped
public class HierarchyBean {

    String taxonomy = "";
    String errorm = "";
    String edgesWidth = "rel";
    String groupBy = "";
    String level = "";
    String taxFilter = "0";
    String jsonFileName = "";
    String height = "180";
    String width = "180";
    String taxa = "";
    String visualization = "";
    String kronaFileLink = "";


    Boolean sampleplots = true;
   Boolean firstDraw = true;
    private boolean selectMode = false;
    private String corIndex = "pearson";
    String minSim = "0.25";
    String vSize = "rel";
    String colorNodesBy;
    String background = "black";
    boolean aoverlap = true;
    String otu="";
    Configs config = new Configs();
    

     /**
     * Creates a new instance of HierarchyBean
     */
    public HierarchyBean() {
        if(config.isDataMiner()){
            taxFilter = "0";
           
        }
    }

    public void setSelectedMode() {
        selectMode = false;
        jsonFileName = "";
        firstDraw = true;
    }

    public List getCorIndexS() {
        List l = new ArrayList();

        l.add(new SelectItem("pearson", "Pearson"));
        l.add(new SelectItem("spearman", "Spearman"));


        return (l);
    }

    public boolean isNotkronaopt() {
        
        if(visualization.contains("krona") ){
            return false;
        }
        
        return true;
    }
    
    public String getOtu() {
        
  

        return otu;
    }

    public void setOtu(String otu) {
       SessionDataBean dataBean = SessionDataBean.getCurrentInstance();
        LevelDataMatrix ldm = dataBean.getDataM();
        HashMap hm = ldm.getDataM();
        Set<String> levels = hm.keySet();
        

        List l = new ArrayList();
        Object[] lO = new String[levels.size()];
        lO = levels.toArray();
        java.util.Arrays.sort(lO);
        
        for (Object li : lO) {
             if(li.toString().matches("otu")){
                 otu = li.toString();
             }
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

    public String getvSize() {
        return vSize;
    }

    public void setvSize(String vSize) {
        this.vSize = vSize;
    }

    public String getWidth() {
        return width;
    }

    public void setWidth(String width) {
        this.width = width;
    }
    public boolean isAoverlap() {
        return aoverlap;
    }
    public String getKronaFileLink() {
        return kronaFileLink;
    }

    public void setKronaFileLink(String kronaFileLink) {
        this.kronaFileLink = kronaFileLink;
    }
    public void setAoverlap(boolean aoverlap) {
        this.aoverlap = aoverlap;
    }
    public String getColorNodesBy() {
        return colorNodesBy;
    }

    public void setColorNodesBy(String colorNodesBy) {
        this.colorNodesBy = colorNodesBy;
    }

    public String getBackground() {
        return background;
    }

    public void setBackground(String background) {
        this.background = background;
    }

    public List getBackgroundcolors() {
        List l = new ArrayList();

        l.add(new SelectItem("black", "Black"));
        l.add(new SelectItem("white", "White"));


        return (l);
    }

    public Boolean getSampleplots() {
        return sampleplots;
    }

    public void setSampleplots(Boolean sampleplots) {
        this.sampleplots = sampleplots;
    }

    public String getErrorm() {
        String message = errorm;
        errorm = "";
        return message;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public Boolean getFirstDraw() {
        return firstDraw;
    }

    public void setFirstDraw(Boolean firstDraw) {
        this.firstDraw = firstDraw;
    }

    public void setJsonFileName(String jsonFileName) {
        this.jsonFileName = jsonFileName;
    }

    public String getJsonFileName() {
        return jsonFileName;
    }
    
    public String getJsonFileNameURL() {
        CalypsoOConfigs conf = new CalypsoOConfigs();
        String url = conf.getTmpDirUrl() + jsonFileName;
        return url;
    }
   
     public void setJsonFileNameURL(String test) {
    //    System.out.println("in setURL " + test);
    }
    
    public String getHeight() {
        return height;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public String getVisualization() {
        return visualization;
    }

    public void setVisualization(String visualization) {
        this.visualization = visualization;
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

    public List getGroupByMode() {
        List l = new ArrayList();
        l.add(new SelectItem("group", "Primary group"));
        l.add(new SelectItem("time", "Secondary group"));
        return l;
    }

    public List getVisualizationMode() {
        List l = new ArrayList();
        l.add(new SelectItem("dendrogram", "Dendrogram"));
        l.add(new SelectItem("radial", "Radial tree"));
        l.add(new SelectItem("graph", "Network"));
        l.add(new SelectItem("graph+", "Network+"));
        l.add(new SelectItem("krona", "Krona"));
        //     l.add(new SelectItem("sunburst", "Sunburst"));
        return (l);
    }
    public boolean isNetworks2opt() {

        if (this.selectMode) {
            return false;
        }

        if (visualization.equals("radial") || visualization.equals("dendrogram") || visualization.equals("krona")) {
            return true;
        }

        return false;
    }

    public boolean isNetworksopt() {

        if (this.selectMode) {
            return false;
        }

        if (visualization.equals("graph") || visualization.equals("graph+")) {
            return true;
        }

        return false;
    }
    
    public String getEdgesWidth() {
        return edgesWidth;
    }

    public void setEdgesWidth(String edgesWidth) {
        this.edgesWidth = edgesWidth;
    }

    public List getEdgesWidths() {
        List l = new ArrayList();
        l.add(new SelectItem("fixed", "Fixed values"));
        l.add(new SelectItem("rel", "Relative abundance"));
        return (l);
    }

    public String getTaxonomy() {
        return taxonomy;
    }

    public void setTaxonomy(String taxonomy) {
        this.taxonomy = taxonomy;
    }

    public List getTaxonomys() {
        List l = new ArrayList();
        l.add(new SelectItem("rdp2.2", "RDP v2.2"));
        l.add(new SelectItem("rdp2.5", "RDP v2.5"));
        return (l);
    }

    public String getTaxFilter() {
        return taxFilter;
    }

    public void setTaxFilter(String taxFilter) {
        this.taxFilter = taxFilter;
    }

    @SuppressWarnings("empty-statement")
    public boolean run() throws IOException {


        CalypsoOConfigs conf = new CalypsoOConfigs();
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();
        jsonFileName = conf.tempFileName(".json");

        //if rdp classification selected draw only to genus rank
        if (level.toLowerCase().equals("species") && dataBean.getTaxFileType().contains("rdp")) {
            jsonFileName = "";
            this.errorm = "No species assignments available based on RDP Classifier. Please select another level.";
            return false;
        }

        LevelDataMatrix ldm = dataBean.getDataM();
        HashMap hm = ldm.getDataM();
        Set<String> levels = hm.keySet();
        if (visualization.equals("dendrogram") || visualization.equals("radial") || visualization.equals("krona")) {      
            Object[] lO = new String[levels.size()];
            lO = levels.toArray();
        
            for (Object li : lO) {
                Pattern ptn = Pattern.compile("otu", Pattern.CASE_INSENSITIVE);
                Matcher match = ptn.matcher(li.toString());
                if(match.find()){
                   level = li.toString();
                }
            }          
        }
        //looks for ranks to visualize in tree; case-insensitive search
      //  if (level.toLowerCase().startsWith("otu")) {
      //      if(levels.contains("Species")){
      //          level = "Species";
      //      } 
     //       if(levels.contains("species")){
      //  //        level = "species";
     //       }            
     //   }
        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            errorm = "Internal ERROR: null dataMatrix";
            return false;
        }
        String dataMatrix = dataM.getMatrixComp();

        if (dataMatrix == null) {
            this.errorm = dataM.getErrorM();
            return false;
        }
        String annotFile = dataM.getAnnot().getAnnotFile();

        //Read taxonomy in calyso format generated during import of taxonomy file
        String taxFileName = dataBean.getTaxfilePath();
        Hierarchy hierarchy = new Hierarchy("calypso");
        hierarchy.readCalypso(taxFileName);
        String ranksTaxonomy = hierarchy.getRanksTaxonomy();
        if (ranksTaxonomy.equals("")) {
            this.errorm = "No taxonomic ranks given";
            return false;
        }
        String[] rankssorted = ranksTaxonomy.split("\t");

        HashMap<String, HashMap<String, ArrayList<String>>> summary = new HashMap();
        LinkedHashSet<String> groupList = new LinkedHashSet<String>();
        List<String> rsselected = new ArrayList<String>();
        HashMap<String, String> ranks = new HashMap<String, String>();
        ranks.put("k", "superkingdom");
        ranks.put("p", "phylum");
        ranks.put("c", "class");
        ranks.put("o", "order");
        ranks.put("f", "family");
        ranks.put("g", "genus");
        ranks.put("s", "species");
        ranks.put("d", "superkingdom");


        if (visualization.equals("graph") || visualization.equals("graph+")) {
            dataMatrix = dataM.getMatrixCompNorm();
            //get correlation, abundances, layout for graph
            Boolean booleanValue = true;
            int tF = Integer.parseInt(taxFilter);
            String corr = conf.getTmpDirWeb() + conf.tempFileName(".corr");
            String layout = conf.getTmpDirWeb() + conf.tempFileName(".layout");
            String abundance = conf.getTmpDirWeb() + conf.tempFileName(".abund");
            String chartFile = conf.getTmpDirWeb() + "image.png";
            jsonFileName = conf.tempFileName(".json");
            String jsonNetwork = conf.getTmpDirWeb() + jsonFileName;
            JavaR jr = new JavaR();
            if (!jr.correlation(dataMatrix, annotFile, tF, visualization, "GST", chartFile,
                    "lb", level, Integer.parseInt(width.trim()), Integer.parseInt(height.trim()),
                    200, Double.parseDouble(minSim), 5, corIndex, booleanValue, aoverlap, corr, layout,
                    abundance,
                    "png", "3", "2")) {
                
                errorm = jr.getError();
            }
            /**
             * *************parse files************
             */
            
            
            //parse layout
            BufferedReader br;
            try {
                br = new BufferedReader(new FileReader(layout));
            } catch (FileNotFoundException ex) {
                //         Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);\
                return false;
            }
            boolean isHeader = true;
            HashMap<String, String[]> layoutMap = new HashMap();
            double maxX = -1000;
            double maxY = -1000;
            double minX = 1000;
            double minY = 1000;
            double nameWidth= 0; 
//            AffineTransform af = new AffineTransform();     
//            FontRenderContext fr = new FontRenderContext(af,true,true);     
//            Font f = new Font("SansSerif", 0, 6); // use exact font
            try {
                String line = br.readLine();
                while (line != null) {
                    if (isHeader) {
                        isHeader = false;

                    } else {
                        String[] col = line.split(",");
                        if(!(col[0].equals(""))){
                            String[] pos = {col[1], col[2]};
                         //   if(!(col[0].startsWith("unclassified"))){
                            layoutMap.put(col[0], pos);
                            if(maxY < Double.parseDouble(col[2])){
                                maxY = Double.parseDouble(col[2]);
                            }
                            if(maxX < Double.parseDouble(col[1])){
                                maxX = Double.parseDouble(col[1]);
                                //nameWidth= f.getStringBounds(col[0], fr).getWidth(); 
                            }
                            if(minX > Double.parseDouble(col[1])){
                                minX = Double.parseDouble(col[1]);
                            }
                            if(minY > Double.parseDouble(col[2])){
                                minY = Double.parseDouble(col[2]);
                            }
                        }//}
                    }
                    line = br.readLine();
                }
            } catch (IOException ex) {
                // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                return false;
            }
            
            //parse correlation files containing links
            try {
                br = new BufferedReader(new FileReader(corr));
            } catch (FileNotFoundException ex) {
                return false;
            }
            isHeader = true;
            List<String> header = new ArrayList<String>();
            HashMap<String, HashMap<String, String>> corMatrix = new HashMap();
            HashMap<String, Boolean> hasLink = new HashMap();
            HashMap<String, Integer> envVar = new HashMap();
            try {
                String line = br.readLine();
                int columnstart = 1;
                while (line != null) {
                    if (isHeader) {
                        header = Arrays.asList(line.split(","));
                        isHeader = false;
                    } else {
                        String[] col = line.split(",");
                          if(layoutMap.containsKey(col[0])){                       
 //                       if (!(col[0].equals("Unclassified"))) {
                            corMatrix.put(col[0], new HashMap<String, String>());
                            for (int i = columnstart; i < col.length; i++) {
                              //  if (!(header.get(i).equals("Unclassified"))) {
                                  if (layoutMap.containsKey(header.get(i))) { 
                                     if (!(col[i].equals("NA")) && ((Double.parseDouble(col[i]) > Double.parseDouble(minSim)) || (Double.parseDouble(col[i]) < (-1 * Double.parseDouble(minSim))))) {
                                        corMatrix.get(col[0]).put(header.get(i), col[i]);
                                        hasLink.put(header.get(i), true);
                                        hasLink.put(col[0], true);

                                    }
                                    envVar.put(col[0],1);
                                }
                            }

                        }
                    }
                    columnstart++;
                    line = br.readLine();
                }

            } catch (IOException ex) {
                // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                return false;
            }

            //abundance file
            try {
                br = new BufferedReader(new FileReader(abundance));
            } catch (FileNotFoundException ex) {
                //         Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);\
                return false;
            }
            isHeader = true;
            LinkedHashMap<String, String> abundances = new LinkedHashMap();
            HashMap<String, Integer> name2id = new HashMap();
            try {
                String line = br.readLine();
                int id = 0;
                while (line != null) {
                    if (isHeader) {
                        isHeader = false;
                    } else {
                        String[] col = line.split(",");
                        if(envVar.containsKey(col[0])){
                            envVar.remove(col[0]);
                        }
                        if (hasLink.containsKey(col[0])) {
                   //     if (!(col[0].equals("Unclassified")) && hasLink.containsKey(col[0])) {
                            abundances.put(col[0], col[1]);
                            name2id.put(col[0], id);
                            id++;
                        }
                    }
                    line = br.readLine();
                }
                for (Map.Entry<String, Integer> entry : envVar.entrySet()) {
                    name2id.put(entry.getKey(),id);
                    id++;
                }
            } catch (IOException ex) {
                // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                return false;
            }

            //generate json file for d3 visualization
            StringBuilder jsonGraph = new StringBuilder();
            jsonGraph.append("{\"nodes\":[");
            StringBuilder links = new StringBuilder();
            links.append("[");
            int objectId = 0;
            boolean isHeaderLink = true;
            isHeader = true;

            int colorId = 0;
            String[] colors;
            if (background.equals("black")) {
                colors = new String[]{"darkred", "darkblue", "darkgrey", "orange", "salmon", "white", "gold", "darkgreen", "blue",  "lightblue", "pink", "#CCFF00", "#6600FF", "#0066FF", "#00FFCC", "yellow", "aquamarine4", "green", "grey", "lightgoldenrod1", "orangered", "lightsalmon2", "tan2"};
            } else {
                colors = new String[]{"darkred", "darkblue", "darkgrey", "orange", "salmon", "black", "gold", "darkgreen", "blue",  "lightblue", "pink", "#CCFF00", "#6600FF", "#0066FF", "#00FFCC", "yellow", "aquamarine4", "green", "grey", "lightgoldenrod1", "orangered", "lightsalmon2", "tan2"};
            }
            HashMap<String, String> parent2color = new HashMap<String, String>();
            HashMap<String, String> otu2parent = new HashMap<String, String>();
            HashMap<String, String> rank2letter = new HashMap<String, String>();
            rank2letter.put("superkingdom", "k");
            rank2letter.put("domain", "k");
            rank2letter.put("phylum", "p");
            rank2letter.put("class", "c");
            rank2letter.put("family", "f");
            rank2letter.put("order", "o");
            double sum = Math.abs(maxX)+Math.abs(minY);

            int namewidth = 100;
            for (Map.Entry<String, String> entry : abundances.entrySet()) {
                String name = entry.getKey();
                String nodecolor;
                if (colorNodesBy.equals("Lightblue")) {
                    nodecolor = "lightblue";
                } else {
                    
                    //get color for nodes
                    String parent = "Unknown";
                    if (level.toLowerCase().startsWith("otu")) {
                        String lowestTaxon = "";
                        String lowestRank = "";
                        String lowestRankTaxon = hierarchy.getLowestRankTaxon(name);
                        if (lowestRankTaxon.equals("-1")) {
                            this.errorm = "wrong OTU format for " + name + "; ";
                            continue;
                        } else {
                            if (otu2parent.containsKey(lowestRankTaxon)) {
                                parent = otu2parent.get(lowestRankTaxon);
                            } else {
                                parent = hierarchy.getParent(lowestRankTaxon);
                                String starter = rank2letter.get(colorNodesBy.toLowerCase());
                                while (!(parent.equals("-1") || parent.startsWith(starter))) {
                                    parent = hierarchy.getParent(parent);
                                }
                                otu2parent.put(lowestRankTaxon, parent);
                            }
                        }
                    } else {  //not otu level
                        parent = hierarchy.getParent(level.toLowerCase() + "__" + name);
                        String starter;
                        if (rank2letter.containsKey(colorNodesBy.toLowerCase())) {
                            starter = rank2letter.get(colorNodesBy.toLowerCase());
                        } else {
                            starter = "k";
                        }
                        while (!(parent.equals("-1") || parent.startsWith(starter))) {
                            parent = hierarchy.getParent(parent);
                        }
                    }
                    if (parent.equals("-1")) {
                        parent = "Unknown";
                    }
                    if (parent2color.containsKey(parent)) {
                        nodecolor = parent2color.get(parent);
                    } else {
                        if (colorId < colors.length) {
                            nodecolor = colors[colorId];
                            colorId++;
                        } else {
                            colorId = 0;
                            nodecolor = colors[colorId];
                        }
                        parent2color.put(parent, nodecolor);
                    }
                }
                
                //write nodes and links to json
                double ab = Double.parseDouble(entry.getValue());
                String stringpos;
                if (layoutMap.containsKey(name)) {
                    String[] position = layoutMap.get(name);
                    double x = Double.parseDouble(position[0]);
                    double y = Double.parseDouble(position[1]);
                    if(colorNodesBy.equals("Lightblue")){
                        x = (x + Math.abs(minX)) * (mm2px(Integer.parseInt(width)) -20-namewidth) / (Math.abs(maxX)+Math.abs(minX)) + 20;  //before ranged from -1 to 1
                        y = (y + Math.abs(minY)) * (mm2px(Integer.parseInt(height))-30)/ (Math.abs(maxY)+Math.abs(minY)) + 15;
                    }else{
                        x = (x + Math.abs(minX)) * (mm2px(Integer.parseInt(width))-100-namewidth) / (Math.abs(maxX)+Math.abs(minX)) + 100;  //before ranged from -1 to 1
                        y = (y + Math.abs(minY)) * (mm2px(Integer.parseInt(height))-30)/ (Math.abs(maxY)+Math.abs(minY)) + 15;
                    }
                    stringpos = "\"x\":" + x + ",\"y\":" + y;

                } else {
                    Random rand = new Random();
                    if(colorNodesBy.equals("Lightblue")){
                        int randomNumX = rand.nextInt(mm2px(Integer.parseInt(width)) - 20-namewidth) +20; 
                        int randomNumY = rand.nextInt(mm2px(Integer.parseInt(height))- 30) +15; 
                        stringpos = "\"x\":" + randomNumX + ",\"y\":" + randomNumY;
                    }else{
                        int randomNumX = rand.nextInt(mm2px(Integer.parseInt(width)) - 100 - namewidth) +20; 
                        int randomNumY = rand.nextInt(mm2px(Integer.parseInt(height))- 30) +15; 
                        stringpos = "\"x\":" + randomNumX + ",\"y\":" + randomNumY;
                    }

                }

                if (corMatrix.containsKey(name)) {
                    HashMap<String, String> nameCor = corMatrix.get(name);
                    for (Map.Entry<String, String> entry2 : nameCor.entrySet()) {
                        String name2 = entry2.getKey();
                        String corValue = entry2.getValue();
                        if (isHeaderLink) {
                            links.append("{\"corr\":").append(corValue).append(",\"source\":").append(name2id.get(name)).append(",\"target\":").append(name2id.get(name2)).append("}");
                            isHeaderLink = false;
                } else {
                            links.append(",{\"corr\":").append(corValue).append(",\"source\":").append(name2id.get(name)).append(",\"target\":").append(name2id.get(name2)).append("}");                           
                        }
                    }
                }

                if (isHeader) {
                    isHeader = false;
                    jsonGraph.append("{\"label\":\"").append(name).append("\",\"color\":\"").append(nodecolor).append("\",\"size\":\"").append(ab).append("\",").append(stringpos).append("}");
                } else {
                    jsonGraph.append(",{\"label\":\"").append(name).append("\",\"color\":\"").append(nodecolor).append("\",\"size\":\"").append(ab).append("\",").append(stringpos).append("}");
                }

                objectId++;
            }
            for (Map.Entry<String, Integer> entry : envVar.entrySet()) {
                String name = entry.getKey();
                String nodecolor;
                nodecolor = "red";
    
               
                //write nodes and links to json
                double ab = 2.0;
                String stringpos;
                if (layoutMap.containsKey(name)) {
                      String[] position = layoutMap.get(name);
                    double x = Double.parseDouble(position[0]);
                    double y = Double.parseDouble(position[1]);
                    if(colorNodesBy.equals("Lightblue")){
                        x = (x + Math.abs(minX)) * (mm2px(Integer.parseInt(width))-20-namewidth) / (Math.abs(maxX)+Math.abs(minX)) + 20;  //before ranged from -1 to 1
                        y = (y + Math.abs(minY)) * (mm2px(Integer.parseInt(height))-30)/ (Math.abs(maxY)+Math.abs(minY)) + 15;
                    }else{
                        x = (x + Math.abs(minX)) * (mm2px(Integer.parseInt(width))-100-namewidth) / (Math.abs(maxX)+Math.abs(minX)) + 100;  //before ranged from -1 to 1
                        y = (y + Math.abs(minY)) * (mm2px(Integer.parseInt(height))-30)/ (Math.abs(maxY)+Math.abs(minY)) + 15;
                    }
                    stringpos = "\"x\":" + x + ",\"y\":" + y;

                } else {
                    Random rand = new Random();
                    if(colorNodesBy.equals("Lightblue")){
                        int randomNumX = rand.nextInt(mm2px(Integer.parseInt(width)) - 20-namewidth) +20; 
                        int randomNumY = rand.nextInt(mm2px(Integer.parseInt(height))- 30) +15; 
                    stringpos = "\"x\":" + randomNumX + ",\"y\":" + randomNumY;
                    }else{
                        int randomNumX = rand.nextInt(mm2px(Integer.parseInt(width)) - 100 - namewidth) +20; 
                        int randomNumY = rand.nextInt(mm2px(Integer.parseInt(height))- 30) +15; 
                        stringpos = "\"x\":" + randomNumX + ",\"y\":" + randomNumY;
                    }

                }

                if (corMatrix.containsKey(name)) {
                    HashMap<String, String> nameCor = corMatrix.get(name);
                    for (Map.Entry<String, String> entry2 : nameCor.entrySet()) {
                        String name2 = entry2.getKey();
                        String corValue = entry2.getValue();
                        if (isHeaderLink) {
                            links.append("{\"corr\":").append(corValue).append(",\"source\":").append(name2id.get(name)).append(",\"target\":").append(name2id.get(name2)).append("}");
                            isHeaderLink = false;
                        } else {
                            links.append(",{\"corr\":").append(corValue).append(",\"source\":").append(name2id.get(name)).append(",\"target\":").append(name2id.get(name2)).append("}");                           
                        }
                    }
                }

                if (isHeader) {
                    isHeader = false;
                    jsonGraph.append("{\"label\":\"").append(name).append("\",\"color\":\"").append(nodecolor).append("\",\"size\":\"").append(ab).append("\",").append(stringpos).append("}");
                } else {
                    jsonGraph.append(",{\"label\":\"").append(name).append("\",\"color\":\"").append(nodecolor).append("\",\"size\":\"").append(ab).append("\",").append(stringpos).append("}");
                }

                objectId++;
            }
                        
            jsonGraph.append(",{\"label\":\"").append(level).append("\",\"color\":\"").append(background).append("\",\"size\":\"leg\",\"x\":").append((Double.parseDouble(width) * 5 / 2) - 3).append(",\"y\":7").append("}");
            
            //draw legend if colored nodes
            if (!(colorNodesBy.equals("Lightblue"))) {
                int nodeY = 10;
                jsonGraph.append(",{\"label\":\"Legend: ").append(colorNodesBy).append("\",\"color\":\"").append(background).append("\",\"size\":\"leg\",\"x\":5,\"y\":").append(nodeY).append("}");

                for (Map.Entry entrycolor : parent2color.entrySet()) {
                    String parent = (String) entrycolor.getKey();
                    nodeY += 15;

                    int index = parent.indexOf("__");
                    if (index > 0) {
                        index += 2;
                        parent = parent.substring(index);
                    }
                    jsonGraph.append(",{\"label\":\"").append(parent).append("\",\"color\":\"").append(entrycolor.getValue()).append("\",\"size\":\"leg\",\"x\":5,\"y\":").append(nodeY).append("}");

                }
            }
            jsonGraph.append("],\"links\":").append(links).append("]}");
            
            //write into file
            BufferedWriter hierarchyWriter;
            try {
                hierarchyWriter = new BufferedWriter(new FileWriter(jsonNetwork));
                hierarchyWriter.write(jsonGraph.toString());
                hierarchyWriter.close();
            } catch (IOException ex) {
                //     Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
            }
            firstDraw = false;
            return true;
        }else if(visualization.equals("krona")){
            level = "OTU";
            rsselected.addAll(Arrays.asList(rankssorted));
            Collections.reverse(rsselected);

     
            int tF = Integer.parseInt(taxFilter);
            String tableFile = conf.getTmpDirWeb() + conf.tempFileName("_abundance.csv");
            jsonFileName = conf.tempFileName(".json");

            JavaR jr = new JavaR();

            if (!jr.writeNormA(dataMatrix, annotFile, tF, "GTS", groupBy,tableFile,  level)) {
                errorm = jr.getError();
            }
            //parse layout
            BufferedReader br;
            try {
                br = new BufferedReader(new FileReader(tableFile));
            } catch (FileNotFoundException ex) {
                //         Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);\
                return false;
            }
            HashMap<String, HashMap<String, Integer>> kronatext = new HashMap();
            int lineNr = 0;
            String[] header  =null;
            HashMap<String, Integer> groupCounts = new HashMap();
            try {
                String line = br.readLine();
                while (line != null) {
                    String[] counts = line.split(",");
                    line = br.readLine(); 
               
                    if (lineNr == 0) {
                        lineNr = 1;
                        header = counts;              
                    } else if (counts[0].equals("sum_sample") && header != null) {
                        for (int i = 1; i < header.length; i++) {
                            groupCounts.put(header[i], Integer.parseInt(counts[i]));                            
                        }
                    } else {
                        
                        String taxon = counts[0];
                        if (header != null) {
                            String lowestRankTaxon = hierarchy.getLowestRankTaxon(taxon);
                            if (lowestRankTaxon.equals("-1")) {
                                //  this.errorm = "wrong taxon format in hierarchy file " + taxon;
                                continue;
                            }
                            //determine lineage for each lowest taxon
                            List<String> taxonLineage = new ArrayList();
                            taxonLineage.add(lowestRankTaxon);
                            String parent = hierarchy.getParent(lowestRankTaxon);
                            while (!(parent.equals("-1"))) {
                                taxonLineage.add(parent);
                                parent = hierarchy.getParent(parent);
                            }
                            String taxonLineageString = "";
                            Collections.reverse(taxonLineage);
                            for (String taxRank : taxonLineage) {
                                String[] rank_tax = taxRank.split("__");  //p__Proteobacteria
                                if (rank_tax.length == 0) {
                                        this.errorm = "wrong taxon format in hierarchy file " + taxRank + " for child " + taxon;
                                }else{
                                    taxonLineageString = taxonLineageString.concat(rank_tax[1]).concat("\t");
                                }
                                
                            }
                            for (int i = 1; i < header.length; i++) {
                                Integer count = Integer.parseInt(counts[i]);
                                if(count > 0){
                                    if(kronatext.containsKey(header[i])){
                                        if(kronatext.get(header[i]).containsKey(taxonLineageString)){
                                            HashMap<String, Integer> tmphash = kronatext.get(header[i]);
                                            tmphash.put(taxonLineageString, kronatext.get(header[i]).get(taxonLineageString)+count ); 
                                            kronatext.put(header[i], tmphash);                                                                                        
                                        }else{
                                            HashMap<String, Integer> tmphash = kronatext.get(header[i]);
                                            tmphash.put(taxonLineageString, count); 
                                            kronatext.put(header[i], tmphash);                                           
                                            
                                        }
                                    }else{
                                        HashMap<String, Integer> tmphash = new HashMap<>();
                                        tmphash.put(taxonLineageString, count);
                                        kronatext.put(header[i], tmphash);                                        
                                    }                                    
                                }                               
                            }
                        }
                    }   
                }            
                br.close();
            } catch (IOException ex) {
            // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                return false;
            }
            StringBuilder kronaInput = new StringBuilder();
            for (Map.Entry kronaEntry : kronatext.entrySet()) {
                HashMap<String, Integer> sample = (HashMap) kronaEntry.getValue();
                StringBuilder writeLine = new StringBuilder();
                if (!(kronaEntry.getKey().equals("total"))) {
                    for (Map.Entry entrytaxon : sample.entrySet()) {
                        Integer count = (Integer) entrytaxon.getValue();
                        writeLine.append(count).append("\t").append(entrytaxon.getKey()).append("\n");
                    }
                    String kronafilepath = conf.tempFile(".txt");
                    kronaInput.append(" ").append(kronafilepath).append(",").append(kronaEntry.getKey());
                    BufferedWriter kronaWriter = null;
                    try {
                        kronaWriter = new BufferedWriter(new FileWriter(kronafilepath));
                        kronaWriter.write(writeLine.toString());
                        kronaWriter.close();
                    } catch (IOException ex) {
                        Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            }
         
            String kronaFile = conf.tempFileName(".html");
            kronaFileLink = conf.getTmpDirUrl() + kronaFile;
            //String[] command = {config.getKtImportText() , " -o " , conf.getTmpDirWeb() + kronaFile , kronaInput.toString()};
            
           // String[] command = {"/bin/sh", "-c", config.getKtImportText() + " -o " + conf.getTmpDirWeb() + kronaFile + kronaInput.toString()};  //String[] version
           // System.out.println("Running command " +Arrays.toString(command)+ "\n");                
            String command = config.getPerl() + config.getKtImportText() + " -o " + conf.getTmpDirWeb() + kronaFile + kronaInput.toString();                      //String version
            
     
            
            System.out.println("Running command " +command+ "\n");           
    

            try {
                Process process = Runtime.getRuntime().exec(command);

                System.out.println("Runtime obtained");

                System.out.println("Waiting ...");
                process.waitFor();
                System.out.println(" Done.");

                if (!(process.exitValue() == 0)) {
                  //  System.out.println("ERROR running " + Arrays.toString(command));
                    System.out.println("ERROR running "+ command);
                   
                   return false;
                }
            } catch (Exception err) {
              //  System.out.println("Krona plot failed: " + Arrays.toString(command));
                System.out.println("Krona plot failed: " + command);
                
                return false;
            }
            System.out.println("Krona plot completed successfully.");
            firstDraw = false;
            return true;
        }
        level = "OTU";
        if (level.toLowerCase().startsWith("otu")) {
            
            
            rsselected.addAll(Arrays.asList(rankssorted));
            Collections.reverse(rsselected);

     
            int tF = Integer.parseInt(taxFilter);
            String tableFile = conf.getTmpDirWeb() + conf.tempFileName("_abundance.csv");
            jsonFileName = conf.tempFileName(".json");

            JavaR jr = new JavaR();

            if (!jr.writeNormA(dataMatrix, annotFile, tF, "GTS", groupBy,tableFile,  level)) {
                errorm = jr.getError();
            }

            /**
             * *************parse files************
             */
            
            
            //parse layout
            BufferedReader br;
            try {
                br = new BufferedReader(new FileReader(tableFile));
            } catch (FileNotFoundException ex) {
                //         Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);\
                return false;
            }           
            int lineNr = 0;
            String[] header  =null;
            HashMap<String, Integer> groupCounts = new HashMap();
            try {
                String line = br.readLine();
                while (line != null) {
                    String[] counts = line.split(",");
                    line = br.readLine(); 
                    if (lineNr == 0) {
                        lineNr = 1;
                        header = counts;              
                    } else if (counts[0].equals("sum_sample") && header != null) {
                        for (int i = 1; i < header.length; i++) {
                            groupCounts.put(header[i], Integer.parseInt(counts[i]));                            
                        }
                    } else {
                        
                        String taxon = counts[0];
                        if (header != null) {
                            String lowestRankTaxon = hierarchy.getLowestRankTaxon(taxon);
                            if (lowestRankTaxon.equals("-1")) {
                                //  this.errorm = "wrong taxon format in hierarchy file " + taxon;
                                continue;
                            }
                            //determine lineage for each lowest taxon
                            List<String> taxonLineage = new ArrayList();
                            taxonLineage.add(lowestRankTaxon);
                            String parent = hierarchy.getParent(lowestRankTaxon);
                            while (!(parent.equals("-1"))) {
                                taxonLineage.add(parent);
                                parent = hierarchy.getParent(parent);
                            }

                            for (int i = 1; i < header.length; i++) {
                                String count = counts[i];

                                //fill summary hash with lineage of otus
                                for (String taxRank : taxonLineage) {
                                    String[] rank_tax = taxRank.split("__");  //p__Proteobacteria
                                    if (rank_tax.length == 0) {
                                        this.errorm = "wrong taxon format in hierarchy file " + taxRank + " for child " + taxon;
                                    } else {
                                        if (!(summary.containsKey(rank_tax[0]))) {
                                            summary.put(rank_tax[0], new HashMap());
                                        }
                                        if (summary.get(rank_tax[0]).containsKey(rank_tax[1])) {
                                            if (summary.get(rank_tax[0]).get(rank_tax[1]).size() > (i - 1)) {                                                
                                                Integer newValue = Integer.parseInt(summary.get(rank_tax[0]).get(rank_tax[1]).get(i - 1)) + Integer.parseInt(count);
                                                summary.get(rank_tax[0]).get(rank_tax[1]).set((i - 1), newValue.toString());
                                            } else {
                                                summary.get(rank_tax[0]).get(rank_tax[1]).add((i - 1), count);
                                            }
                                        } else {
                                            summary.get(rank_tax[0]).put(rank_tax[1], new ArrayList());
                                            summary.get(rank_tax[0]).get(rank_tax[1]).add(count);
                                        }
                                    }
                                }
                            }
                        }
                    }   
                }            
                br.close();
            } catch (IOException ex) {
            // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                return false;
            }
            for(int i = 2; i< header.length; i++){
                groupList.add(header[i]);
            }
//                      groupCounts  
            for (Map.Entry entryrank : summary.entrySet()) {
                HashMap<String, ArrayList<String>> taxas = (HashMap) entryrank.getValue();
                for (Map.Entry entrytaxon : taxas.entrySet()) {
                    List<String> value = (ArrayList) entrytaxon.getValue();
                    int i = 0;
                    while(i<value.size()){
                        Double newVal = Double.parseDouble(value.get(i))* 100 / groupCounts.get(header[i+1]);
                        value.set(i, newVal.toString());
                        i++;
                    }
                }
            }

        } else {  //if not OTU level
            int tF = Integer.parseInt(taxFilter);
            
            JavaR jr = new JavaR();
           for (String s : rankssorted) {
                for (String t : levels) {
                    if (t.toLowerCase().contains(s)) {
                        rsselected.add(t);
                    }
                    if (s.equals("superkingdom") && t.toLowerCase().contains("domain")) {
                        rsselected.add(t);
                    }
                }
                if (s.equals(level.toLowerCase()) || (level.toLowerCase().equals("domain") && s.toLowerCase().equals("superkingdom"))) {
                    break;
                }

            }
            String[] header = null;
            HashMap<String, HashMap<String,Integer>> groupCounts = new HashMap();
            Collections.reverse(rsselected);
            for (String s : rsselected) {
                dataM = ldm.getDataMatrix(s);
                if (dataM == null) {
                    this.errorm = "Internal ERROR: null dataMatrix";
                    return false;
                }
                if (s.toLowerCase().equals("domain")) {
                    s = "Superkingdom";
                }

                summary.put(s, new HashMap());
                String lowerS = s.toLowerCase();
                String tableFile = conf.getTmpDirWeb() + conf.tempFileName("_abundance.csv");
                jsonFileName = conf.tempFileName(".json");
                String dataMatrixLevel = dataM.getMatrixComp();
                if (!jr.writeNormA(dataMatrixLevel, annotFile, tF, "GTS", groupBy,tableFile,  level)) {
                    errorm = jr.getError();
                }
                BufferedReader br;
                try {
                    br = new BufferedReader(new FileReader(tableFile));
                } catch (FileNotFoundException ex) {
                    //         Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);\
                    return false;
                }
                int lineNr = 0;

                try {
                    String line = br.readLine();
                    while (line != null) {

                        String[] counts = line.split(",");
                        line = br.readLine();

                        if (lineNr == 0) {
                            lineNr = 1;
                            header = counts;

                        } else if (counts[0].equals("sum_sample") && header != null) {
                            groupCounts.put(s,new HashMap<String,Integer>()); 
                             for (int i = 1; i < header.length; i++) {
                                
                                groupCounts.get(s).put(header[i], Integer.parseInt(counts[i]));
                            }
                        } else {
                            String taxon = counts[0];
                            if (header != null) {
                                summary.get(s).put(taxon, new ArrayList());
                                for (int i = 1; i < header.length; i++) {
                                    String count = counts[i];
                                    summary.get(s).get(taxon).add(count);
                                }        
                            }        
                        }        
                    }

                    br.close();
                } catch (IOException ex) {
                    // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
                    return false;
                }
                for (int i = 2; i < header.length; i++) {
                    groupList.add(header[i]);
                }
            }
            for (Map.Entry entryrank : summary.entrySet()) {
                    String rank = (String) entryrank.getKey();
                    HashMap<String, ArrayList<String>> taxas = (HashMap) entryrank.getValue();
                    for (Map.Entry entrytaxon : taxas.entrySet()) {
                        List<String> value = (ArrayList) entrytaxon.getValue();
                        int i = 0;
                        while (i < value.size()) {
                            Double newVal = Double.parseDouble(value.get(i)) * 100 / groupCounts.get(rank).get(header[i + 1]);
                            value.set(i, newVal.toString());
                            i++;
                        }
                    }
            }
            
        }

        //set root for the tree
        if (!(summary.containsKey("rootrank"))) {
            summary.put("rootrank", new HashMap());
            summary.get("rootrank").put("Root", new ArrayList());
            summary.get("rootrank").get("Root").add("100");

        }
        Object[] groupsArray = groupList.toArray();
        String sampleName = "";
        for (int i = 0; i < (groupsArray.length - 1); i++) {
            sampleName = sampleName + "\"" + groupsArray[i] + "\",";
            summary.get("rootrank").get("Root").add("100");
        }
        summary.get("rootrank").get("Root").add("100");
        if (groupsArray.length == 0) {
            this.errorm = "No taxa were assigned to rank " + level + ". Please check the format of the uploaded taxa in your counts file " + dataBean.getCountsFileName();
            this.jsonFileName = "";
            return false;

        }
        sampleName = sampleName + "\"" + groupsArray[(groupsArray.length - 1)] + "\"";

        Collections.reverse(rsselected);
        boolean status = hierarchy.buildTree(sampleName, summary, rsselected);
        if (status) {
            String jsonString = hierarchy.generateJsonTxt();

            String jsonFileName2 = conf.getTmpDirWeb() + jsonFileName;
            BufferedWriter bw = new BufferedWriter(new FileWriter(jsonFileName2));
            bw.write(jsonString);
            bw.close();
        } else {
            if (!(hierarchy.getWarnings().equals(""))) {
                this.errorm = hierarchy.getWarnings();
            }

        }
        firstDraw = false;
        return true;

    }



    public List getLevels() {
        List<SelectItem> l = SessionDataBean.getCurrentInstance().getLevels();
        List newL = new ArrayList();
        int i = 0;
        newL.add(new SelectItem("Lightblue", "Lightblue"));
        if (level.toLowerCase().equals("class")) {
            while (i < l.size()) {
                if (l.get(i).getValue().toString().toLowerCase().equals("phylum")) {
                    newL.add(l.get(i));
                }
                i++;
            }
        } else if (level.toLowerCase().equals("order")) {

            while (i < l.size()) {
                String t = l.get(i).getValue().toString().toLowerCase();
                if ((t.equals("phylum") || t.equals("class"))) {
                    newL.add(l.get(i));
                }
                i++;
            }
        } else if (level.toLowerCase().equals("family")) {


            while (i < l.size()) {
                String t = l.get(i).getValue().toString().toLowerCase();
                if ((t.equals("phylum") || t.equals("class") || t.equals("order"))) {
                    newL.add(l.get(i));
                }
                i++;
            }
        } else if (level.toLowerCase().equals("genus")) {
            while (i < l.size()) {
                String t = l.get(i).getValue().toString().toLowerCase();
                if ((t.equals("phylum") || t.equals("class") || t.equals("order") || t.equals("family"))) {
                    newL.add(l.get(i));
                }
                i++;
            }
        } else if (level.toLowerCase().equals("species")) {
            while (i < l.size()) {
                String t = l.get(i).getValue().toString().toLowerCase();

                if ((t.equals("phylum") || t.equals("class") || t.equals("order") || t.equals("family"))) {
                    newL.add(l.get(i));
                }
                i++;
            }
        } else if (level.toLowerCase().startsWith("otu")) {
            while (i < l.size()) {
                String t = l.get(i).getValue().toString().toLowerCase();
                if ((t.equals("phylum") || t.equals("class") || t.equals("order") || t.equals("family"))) {
                    newL.add(l.get(i));
                }
                i++;
            }
        }


        return newL;
    }

    private int mm2px(int mm) {
 //        double px=  mm*java.awt.Toolkit.getDefaultToolkit().getScreenResolution()/25.4;
        double px=  mm*127/25.4;
        return (int)px;
    }
}
