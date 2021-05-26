/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import CalypsoOnline.CalypsoOConfigs;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author martha
 */
public class Hierarchy {

    HashMap<String, HashMap<String, String>> taxInfo = new HashMap<String, HashMap<String, String>>();
    HashMap<String, String> hierarchyHash = new HashMap<String, String>();
    String ranksTaxonomy;
    public HashMap<String, String> name2id = new HashMap<String, String>();
    String type;
    TreeNode root;
    String warnings = "";

    public Hierarchy(String type) {
        this.type = type;
        root = new TreeNode("sample__name");
        warnings = "";
    }

    public String getParent(String child) {
        if (hierarchyHash.containsKey(child)) {
            return hierarchyHash.get(child);
        } else {
            return "-1";
        }
    }

    public String getRanksTaxonomy() {
        return ranksTaxonomy;
    }

    //build tree for given rank and group combinaton
    public boolean buildTree(String sampleNames, HashMap<String, HashMap<String, ArrayList<String>>> summary, List ranks) {
        //   System.out.println(sampleNames);
        root.setRelAbundances(sampleNames);
        root.setRelAbundance("\"0\"");
        TreeNode activeNode = root;
        boolean state = true;
        for (int r = 0; r < ranks.size(); r++) {

            String rank = ranks.get(r).toString();
            if (rank.toLowerCase().equals("domain")) {
                rank = "Superkingdom";
            }
            String rankLower = rank.toLowerCase();
            int samples = 0;

            if (summary.containsKey(rank)) {
                Iterator it = summary.get(rank).entrySet().iterator();
                while (it.hasNext()) {
                    Map.Entry pairs = (Map.Entry) it.next();
                    String taxname = (String) pairs.getKey();
                    StringBuilder group = new StringBuilder();
                    ArrayList values = summary.get(rank).get(taxname);
                //   String totaltaxon = "\"" + values.get(0).toString() + "\"";
                     String totaltaxon =values.get(0).toString();
                    String groupvalues = "";
                    for (int i = 1; i < (values.size() - 1); i++) {
                //        groupvalues = groupvalues + "\""+ values.get(i).toString() + "\""+ ",";
                        groupvalues = groupvalues + values.get(i).toString() +  ",";

                    }
                //    groupvalues = groupvalues +  "\""+ values.get(values.size() - 1).toString() +"\"";
                    groupvalues = groupvalues +  values.get(values.size() - 1).toString() ;
                    //iterate over group/time
                    taxname = rankLower + "__" + taxname;
                    if (taxname.toLowerCase().contains("unclassified") || taxname.toLowerCase().contains("unassigned") || taxname.toLowerCase().contains("unknown") || taxname.equals("rootrank__Root")) {
                        //   System.out.println("ingnore" + taxname);
                    } else {
                        if (hierarchyHash.containsKey(taxname)) {
                            List<String> lineage = new ArrayList<String>();
                            lineage.add(taxname);
                            String parent = (String) hierarchyHash.get(taxname);
                            while (hierarchyHash.containsKey(parent)) {
                                lineage.add(parent);
                                parent = (String) hierarchyHash.get(parent);
                            }
                            ListIterator li = lineage.listIterator(lineage.size());
                            activeNode = root;
                            while (li.hasPrevious()) {
                                String name = (String) li.previous();
                                Iterator children = activeNode.iterator();
                                boolean flag = true;
                                for (; children.hasNext();) {
                                    TreeNode child = (TreeNode) children.next();
                                    if (name.equals(child.data)) {
                                        activeNode = child;
                                        flag = false;
                                        break;
                                    }

                                }
                                if (flag) {
                                    TreeNode n = activeNode.addChild(name);
                                    n.setRelAbundances(groupvalues);
                                    n.setRelAbundance(totaltaxon);
                                    activeNode = n;

                                }

                            }
                        } else {
                            warnings = warnings + taxname + " taxon/level not found in counts file;";
                            state = false;

                        }
                    }
                }
            } else {
                //warnings = warnings + rank + " rank not found in taxonomy file; ";
                warnings = warnings + rank + " rank not found in counts file; ";
                state = false;

            }

        }
        System.out.println(warnings);
        if (root.children.size() > 0) {
            return true;
        } else {
            return false;
        }
    }

    public static String join(List<String> list, String value) {

        StringBuilder sb = new StringBuilder();
        String loopValue = "";

        for (String s : list) {
            sb.append(loopValue);
            sb.append(s);

            loopValue = value;
        }

        return sb.toString();
    }

    public String generateJsonTxt() {
        return (treeToJsonTxt(root));
    }

    public String getLowestRankTaxon(String name) {
       HashMap<String, String> ranks = new HashMap<String, String>();
            ranks.put("k", "superkingdom");
            ranks.put("p", "phylum");
            ranks.put("c", "class");
            ranks.put("o", "order");
            ranks.put("f", "family");
            ranks.put("g", "genus");
            ranks.put("s", "species");
            ranks.put("d", "superkingdom");
        String lowestTaxon = "";
        String lowestRank = "";
        
        if (name.contains("Unclassified")) {      //OTU,Unclassified 759,1  
            return "-1";
        } else if (name.contains("__")) {

            name = name.replace(" ", "_");
            String[] col = name.split("__");
            if (col.length == 6) {  //species level
                if (col[4].equals("s") && col[2].equals("g")) {
                    int index = col[5].lastIndexOf("_");
                    lowestTaxon = col[3] + "_" + col[5].substring(0, index);
                    lowestRank = "species";
                } 
            } else if (col.length == 4) {  //OTU, p__Firmicutes__g__Clostridium_334
                lowestRank = ranks.get(col[2]);
                int index = col[3].lastIndexOf("_");
                lowestTaxon = col[3].substring(0, index);

            } else if (col.length == 2) {   //OTU, p__Proteobacterium_333,...
                lowestRank = ranks.get(col[0]);
                int index = col[1].lastIndexOf("_");
                lowestTaxon = col[1].substring(0, index);
            } else {
                return "-1";
            }
        } else {
            return "-1";
        }
        
        return lowestRank.toLowerCase()+"__"+lowestTaxon;
    }

    public String treeToJsonTxt(TreeNode<String> tn) {
        String jso = "";
        StringBuilder sb = new StringBuilder();

        List<String> ret = new ArrayList<String>();
        String nodename = tn.data;
        String[] nodename2 = nodename.split("__"); // –> splitten an den Leerzeichen
        nodename = nodename2[1];
        if (tn.isLeaf()) {
            sb.append("{\"name\": \"").append(nodename).append("\", \"relAbundance\": [").append(tn.relAbundances).append("], \"size\":").append(tn.relAbundance).append("}");
        } else {
            sb.append("{\"name\": \"").append(nodename).append("\",  \"relAbundance\": [").append(tn.relAbundances).append("], \"size\":").append(tn.relAbundance).append(", \"children\":[");

            List<TreeNode<String>> children = tn.children;
            Iterator childItr = children.iterator();

            while (childItr.hasNext()) {
                TreeNode child = (TreeNode) childItr.next();
                ret.add(treeToJsonTxt(child));
            }
            Iterator iter = ret.iterator();
            sb.append(iter.next());
            while (iter.hasNext()) {
                sb.append(",");
                sb.append(iter.next());
            }
            sb.append("]}");
        }


        return sb.toString();
    }

    public String getTaxId(String tax) {
        if (name2id.containsKey(tax)) {
            String taxid = (String) name2id.get(tax);
            return taxid;
        } else {
            //     System.out.println("no " + tax);
            return "";
        }
    }

    //parse file in upload manager
    public String parseTaxonomy(File file, LinkedHashMap levelTaxa) {
       // System.out.println("Parsing file " + file.getAbsolutePath());
        CalypsoOConfigs configs = new CalypsoOConfigs();
        Scanner scanner = null;
        try {
            scanner = new Scanner(file);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
        }
        HashMap<String, String> lineage = new HashMap<String, String>();
        String ranksString = "";

        scanner.useDelimiter("\n");
        if (type.equals("rdp25") || type.equals("rdp22") || type.equals("customrdp")) {
            String pattern = "name=\"(.+)\" taxid=\"(\\d+)\" rank=\"(\\w+)\" parentTaxid=\"(-*\\d+)\"";
            Pattern p = Pattern.compile(pattern);
            HashMap<String, String> id2tax = new HashMap<String, String>();
            ranksString = "#rootrank\tsuperkingdom\tphylum\tclass\torder\tfamily\tgenus\n";
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                Matcher m = p.matcher(line);
                while (m.find()) {
                    String rank = m.group(3);
                    rank = rank.replace("norank", "rootrank");
                    rank = rank.replaceAll("(?i)domain", "superkingdom");
                    String taxname = rank + "__" + m.group(1).replace("&quot;", "");
                    lineage.put(taxname, id2tax.get(m.group(4)));
                    id2tax.put(m.group(2), taxname);
                }


            }
        } else if (type.startsWith("gg13_") || type.equals("customgg")) {
            //228054  k__Bacteria; p__Cyanobacteria; c__Synechococcophycideae; o__Synechococcales; f__Synechococcaceae; g__Synechococcus; s__
            String pattern = "\\d+\\s+(.+)";
            Pattern p = Pattern.compile(pattern);
            ranksString = "#rootrank\tsuperkingdom\tphylum\tclass\torder\tfamily\tgenus\tspecies\n";
            HashMap<String, String> ranks = new HashMap<String, String>();
            ranks.put("k", "superkingdom");
            ranks.put("p", "phylum");
            ranks.put("c", "class");
            ranks.put("o", "order");
            ranks.put("f", "family");
            ranks.put("g", "genus");
            ranks.put("s", "species");
            lineage.put("rootrank__Root", "-1");
            int counter = 0;
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                counter++;
                Matcher m = p.matcher(line);
                while (m.find()) {
                    String classification = m.group(1);
                    String[] taxa = classification.split("; ");
                    String parent = "rootrank__Root";
                    for (int i = 0; i < taxa.length; i++) {

                        String[] rank_taxa = taxa[i].split("__");
                        if (rank_taxa.length > 1) {
                            if (rank_taxa.toString().endsWith("__")) {
                                continue;
                            } else {
                                if (rank_taxa[0].equals("s")) {
                                    String[] parent_name = parent.split("__");
                                    lineage.put(ranks.get(rank_taxa[0]) + "__" + parent_name[1] + "_" + rank_taxa[1], parent);
                                    parent = ranks.get(rank_taxa[0]) + "__" + parent_name[1] + "_" + rank_taxa[1];
                                } else {
                                    lineage.put(ranks.get(rank_taxa[0]) + "__" + rank_taxa[1], parent);
                                    parent = ranks.get(rank_taxa[0]) + "__" + rank_taxa[1];
                                }
                            }
                        }
                    }
                }
            }
        } else {
            warnings = warnings + "unknown taxonomy file; ";
        }
        scanner.close();
        List<String> writtenTaxa = new ArrayList<String>();
        StringBuilder writeLine = new StringBuilder();
        writeLine.append(ranksString);
 //      System.out.println(lineage);
        if (lineage.size() < 4) {
            warnings = "Please check your taxonomy file. The uploaded file does not match with selected format.";
            return "";
        }
        for (Object levelName : levelTaxa.keySet()) {
            LinkedHashSet<String> taxa = (LinkedHashSet<String>) levelTaxa.get(levelName);
            for (String taxon : taxa) {
                if (taxon.toLowerCase().equals("unclassified") || taxon.toLowerCase().equals("unknown") || taxon.toLowerCase().equals("unassigned")) {
                } else {
                    if (lineage.containsKey(levelName.toString().toLowerCase() + "__" + taxon)) {
                        if (!(writtenTaxa.contains(levelName.toString().toLowerCase() + "__" + taxon))) { //write taxon, only if its lineage is not present in the calypso taxon file
                            List<String> taxonLineage = new ArrayList();
                            String parent = levelName.toString().toLowerCase() + "__" + taxon;
                            while (lineage.containsKey(parent)) {
                                if (!(parent.startsWith("sub"))) {
                                    taxonLineage.add(parent);
                                    writtenTaxa.add(parent);
                                }
                                parent = (String) lineage.get(parent);
                            }
                            Collections.reverse(taxonLineage);
                            writeLine.append(join(taxonLineage, "\t")).append("\n");
                        }
                    } else {
                        warnings = warnings + levelName.toString().toLowerCase() + "__" + taxon + " not found in selected hierarchy; ";
                    }
                }
            }
        }

        String hierarchyFilePath = configs.tempFile(".txt");
        BufferedWriter hierarchyWriter = null;
        System.out.println(hierarchyFilePath);
        try {
            hierarchyWriter = new BufferedWriter(new FileWriter(hierarchyFilePath));
            hierarchyWriter.write(writeLine.toString());
            hierarchyWriter.close();
        } catch (IOException ex) {
            Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
        }
        //System.out.println("warnings " + warnings);
        return hierarchyFilePath;
    }

    public boolean readCalypso(String taxFileName) {
        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(taxFileName));
        } catch (FileNotFoundException ex) {
            //         Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);\
            return false;
        }

        //norank__Root    domain__Bacteria        phylum__Firmicutes      class__Bacilli  order__Lactobacillales  family__Streptococcaceae        genus__Streptococcus
        try {
            String line = br.readLine();


            while (line != null) {
                if (line.startsWith("#")) {
                    ranksTaxonomy = line.substring(1, line.length());
                    line = br.readLine();
                    continue;
                }
                String[] taxa = line.split("\t");

                String child = taxa[taxa.length - 1];
                for (int i = taxa.length - 2; i >= 0; i--) {
                    hierarchyHash.put(child, taxa[i]);
                    child = taxa[i];

                }
                hierarchyHash.put(child, "-1");
                line = br.readLine();

            }
            br.close();
        } catch (IOException ex) {
            // Logger.getLogger(Hierarchy.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
        return true;

    }

    public void setWarnings(String warnings) {
        this.warnings = warnings;
    }

    public String getWarnings() {
        return warnings;
    }

    private static class TreeNode<T> implements Iterable<TreeNode<T>> {

        public T data;
        public TreeNode<T> parent;
        public List<TreeNode<T>> children;
        public String relAbundances;
        public String relAbundance;

        public String getRelAbundances() {
            return relAbundances;
        }

        public void setRelAbundances(String relAbundances) {
            this.relAbundances = relAbundances;
        }

        public String getRelAbundance() {
            return relAbundance;
        }

        public void setRelAbundance(String relAbundance) {
            this.relAbundance = relAbundance;
        }

        public boolean isRoot() {
            return parent == null;
        }

        public boolean isLeaf() {
            return children.size() == 0;
        }
        private List<TreeNode<T>> elementsIndex;

        public TreeNode(T data) {
            this.data = data;
            this.children = new LinkedList<TreeNode<T>>();
            this.elementsIndex = new LinkedList<TreeNode<T>>();
            this.elementsIndex.add(this);
        }

        public TreeNode(T data, String relAbundances, String relAbundance) {
            this.data = data;
            this.relAbundance = relAbundance;
            this.relAbundances = relAbundances;
            this.children = new LinkedList<TreeNode<T>>();
            this.elementsIndex = new LinkedList<TreeNode<T>>();
            this.elementsIndex.add(this);
        }

        public TreeNode<T> addChild(T child) {
            TreeNode<T> childNode = new TreeNode<T>(child);
            childNode.parent = this;
            this.children.add(childNode);
            this.registerChildForSearch(childNode);
            return childNode;
        }

        public TreeNode<T> getChildByName(String name) {
            if (this.isLeaf()) {
                return null;
            } else {
                List<TreeNode<T>> children = this.children;
                for (TreeNode<T> tn : children) {
                    if (tn.data.equals(name)) {
                        return tn;
                    }
                }
            }
            return null;
        }

        public TreeNode<T> getFirstChild() {
            if (this.isLeaf()) {
                return null;
            } else {
                TreeNode first = (TreeNode) this.children.get(0);
                return first;
                //return this;
            }

        }

        public int getLevel() {
            if (this.isRoot()) {
                return 0;
            } else {
                return parent.getLevel() + 1;
            }
        }

        private void registerChildForSearch(TreeNode<T> node) {
            elementsIndex.add(node);
            if (parent != null) {
                parent.registerChildForSearch(node);
            }
        }

        public TreeNode<T> findTreeNode(Comparable<T> cmp) {
            for (TreeNode<T> element : this.elementsIndex) {
                T elData = element.data;
                if (cmp.compareTo(elData) == 0) {
                    return element;
                }
            }

            return null;
        }

        @Override
        public String toString() {
            return data != null ? data.toString() : "[data null]";
        }

        @Override
        public Iterator<TreeNode<T>> iterator() {
            TreeNodeIter<T> iter = new TreeNodeIter<T>(this);
            return iter;
        }
    }

    private static class TreeNodeIter<T> implements Iterator<TreeNode<T>> {

        enum ProcessStages {

            ProcessParent, ProcessChildCurNode, ProcessChildSubNode
        }
        private TreeNode<T> treeNode;

        public TreeNodeIter(TreeNode<T> treeNode) {
            this.treeNode = treeNode;
            this.doNext = ProcessStages.ProcessParent;
            this.childrenCurNodeIter = treeNode.children.iterator();
        }
        private ProcessStages doNext;
        private TreeNode<T> next;
        private Iterator<TreeNode<T>> childrenCurNodeIter;
        private Iterator<TreeNode<T>> childrenSubNodeIter;

        @Override
        public boolean hasNext() {

            if (this.doNext == ProcessStages.ProcessParent) {
                this.next = this.treeNode;
                this.doNext = ProcessStages.ProcessChildCurNode;
                return true;
            }

            if (this.doNext == ProcessStages.ProcessChildCurNode) {
                if (childrenCurNodeIter.hasNext()) {
                    TreeNode<T> childDirect = childrenCurNodeIter.next();
                    childrenSubNodeIter = childDirect.iterator();
                    this.doNext = ProcessStages.ProcessChildSubNode;
                    return hasNext();
                } else {
                    this.doNext = null;
                    return false;
                }
            }

            if (this.doNext == ProcessStages.ProcessChildSubNode) {
                if (childrenSubNodeIter.hasNext()) {
                    this.next = childrenSubNodeIter.next();
                    return true;
                } else {
                    this.next = null;
                    this.doNext = ProcessStages.ProcessChildCurNode;
                    return hasNext();
                }
            }

            return false;
        }

        @Override
        public TreeNode<T> next() {
            return this.next;
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
    }
}
