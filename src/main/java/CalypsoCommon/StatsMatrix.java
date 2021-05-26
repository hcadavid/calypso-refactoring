/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package CalypsoCommon;

import java.io.File;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Scanner;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author lutzK
 */
public class StatsMatrix {
    LinkedHashMap<String, HashMap<String, String>> statsMatrix = new LinkedHashMap<String, HashMap<String, String>>();
    String errorM = "";
    HashSet groupNames = new HashSet();
     HashSet sampleNames = new HashSet();

    int ROUND = 6;

    public StatsMatrix() {
    }

    public HashSet getSampleNames() {
        return sampleNames;
    }

    public void setSampleNames(HashSet sampleNames) {
        this.sampleNames = sampleNames;
    }


    public HashSet getGroupNames() {
        return groupNames;
    }

    public void setGroupNames(HashSet groupNames) {
        this.groupNames = groupNames;
    }

    public String getP(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        String p = statsMatrix.get(id).get("p");

         return(p);
    }
    
    public String getSampleValue(String feature, String sample){
        if(! statsMatrix.containsKey(feature)){
            return "";
        }

        String value = statsMatrix.get(feature).get(sample);

         return(value);
    }
            
         

    public String getP34(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        String p = statsMatrix.get(id).get("p34");

         return(p);
    }

    public String getPAdj(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        return(statsMatrix.get(id).get("pa"));
    }

    public String getFDR(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        return(statsMatrix.get(id).get("fdr"));
    }
    
    public String getBH(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        return(statsMatrix.get(id).get("bh"));
    }

    public String getGroup(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        return(statsMatrix.get(id).get("group"));

    }

    public String getTaxa(String id){
        if(! statsMatrix.containsKey(id)){
            return "";
        }

        return(statsMatrix.get(id).get("taxa"));

    }

    public Set<String> getIDs(){
        return(statsMatrix.keySet());
    }

    public String getMean(String id, String group){
        if(! statsMatrix.containsKey(id)) {
            System.out.println("Warning no mean for id " + id);
            return null;
        }
        if(! statsMatrix.get(id).containsKey(group)) {
            System.out.println("Warning no mean for id " + id + " and group " + group);
            return null;
        }
        
        return(statsMatrix.get(id).get(group));
    }
    
    public boolean parseData(String fileName){
        statsMatrix = new LinkedHashMap<String, HashMap<String, String>>();
       

        errorM = "";

        File file = new File(fileName);

       int lineN = 0;
        try {
            Scanner scanner = new Scanner(file);
            scanner.useDelimiter("\n");

           String[] samples = new String[0];

            boolean first = true;
            String[] firstFields;

            //first use a Scanner to get each line
             while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;
                if(line.startsWith("#")) continue;

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if(mE.matches()) continue;

                String[] fields = line.split(",");

                if(fields.length < 2 ){
                    errorM = "ERROR: wrong format line " + lineN + " wrong field number.";
                    System.out.println(errorM + "\n");
                    return false;
                }

                // get header
                if(first){
                    samples = new String[fields.length];
                    first = false;
                     for(int i = 1; i < fields.length; i++){
                        String sample = fields[i].trim();
                        samples[i] = sample;
                        String s = samples[i];
                        sampleNames.add(s);
                       
                    }
                    continue;
                }

                String feature = fields[0].trim();

                if(! statsMatrix.containsKey(feature)){
                    statsMatrix.put(feature,new HashMap<String, String>());
                }
                else{
                    errorM = "ERROR: feature not unique " + feature;
                    System.out.println(errorM + "\n");
                    return false;
                }
               

                for(int i = 1; i < fields.length; i++){
                   String value = fields[i].trim();
                    String sample = samples[i];
                 
                    statsMatrix.get(feature).put(sample,value);
                }
            }
            scanner.close();
        } catch (Exception err) {
            errorM = "parseAnnotation: Error while parsing file " + file.getName() + " line " + lineN + ": " + err.toString();
            System.out.println(err.toString());
            System.out.println(err.getStackTrace().toString());
            return false;
        }

        System.out.println("Parsing file " + file.getName() + " Done.");

       return true;
    }
    

    public boolean parseRStats(String fileName){
        statsMatrix = new LinkedHashMap<String, HashMap<String, String>>();
        groupNames = new HashSet();

        errorM = "";

        File file = new File(fileName);

       int lineN = 0;
        try {
            Scanner scanner = new Scanner(file);
            scanner.useDelimiter("\n");

           String[] groups = new String[0];

            boolean first = true;
            String[] firstFields;

            //first use a Scanner to get each line
             while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;
                if(line.startsWith("#")) continue;

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if(mE.matches()) continue;

                String[] fields = line.split(",");

                if(fields.length < 9 ){
                    errorM = "ERROR: wrong format line " + lineN + " wrong field number.";
                    System.out.println(errorM + "\n");
                    return false;
                }

                // get header
                if(first){
                    groups = new String[fields.length];
                    first = false;
                            for(int i = 5; i < fields.length; i++){
                        String group = fields[i].trim();
                        groups[i] = group;
                        String g = groups[i];
                        groupNames.add(group);
                    }
                    continue;
                }

                String taxa = fields[0].trim();

                if(! statsMatrix.containsKey(taxa)){
                    statsMatrix.put(taxa,new HashMap<String, String>());
                }
                else{
                    errorM = "ERROR: taxa not unique " + taxa;
                    System.out.println(errorM + "\n");
                    return false;
                }
               
                
                
                String p = parseNumber(fields[1]);
                String pAdj = parseNumber(fields[2]);
                String fdr = parseNumber(fields[3]);
                String bh = parseNumber(fields[4]);
                
                statsMatrix.get(taxa).put("p", p);
                statsMatrix.get(taxa).put("pa", pAdj);
                statsMatrix.get(taxa).put("fdr", fdr);
                statsMatrix.get(taxa).put("bh", bh);
                statsMatrix.get(taxa).put("taxa", taxa);

                for(int i = 5; i < fields.length; i++){
                   
                    String group = groups[i];

                    String mean = parseNumber(fields[i]);
                 
                    statsMatrix.get(taxa).put(group,mean);
                }
            }
            scanner.close();
        } catch (Exception err) {
            errorM = "parseAnnotation: Error while parsing file " + file.getName() + " line " + lineN + ": " + err.toString();
            System.out.println(err.toString());
            System.out.println(err.getStackTrace().toString());
            return false;
        }

        System.out.println("Parsing pairwise stats file " + file.getName() + " Done.");

       return true;
    }

    public String parseNumber(String number){
        
        number = number.trim();
        
         if(number.equals("NA")) return("NA");
        
          double db = Double.parseDouble(number);
         
         BigDecimal bd = new BigDecimal(String.valueOf(db)).setScale(ROUND, BigDecimal.ROUND_HALF_UP);
         return(bd.toString());
    }

    public boolean parseRPairwiseStats(String fileName, String type){
        statsMatrix = new LinkedHashMap<String, HashMap<String, String>>();
        groupNames = new HashSet();

        errorM = "";

        File file = new File(fileName);

       int lineN = 0;
        try {
            Scanner scanner = new Scanner(file);
            scanner.useDelimiter("\n");

           String[] groups = new String[0];

            // remove header
            scanner.nextLine();

            //first use a Scanner to get each line
             while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;
                if(line.startsWith("#")) continue;

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if(mE.matches()) continue;

                String[] fields = line.split(",");

                if(fields.length < 5 ){
                    errorM = "ERROR: wrong format line " + lineN + " wrong field number.";
                    System.out.println(errorM + "\n");
                    return false;
                }

                String taxa = fields[0].trim();
                String group;
                String paDS;
                String fdrS;
                String pDC = "2";
                String meanG1="2";
                String meanG2="2";

                if(type.equals("table3")){
                    group = fields[3].trim();
                    paDS = fields[4].trim();
                    fdrS = fields[5].trim();
                    pDC = fields[2].trim();
                }
                else{
                    group = fields[2].trim();
                    paDS = fields[3].trim();
                    fdrS = fields[4].trim();
                    meanG1 = fields[5].trim();
                    meanG2 = fields[6].trim();
                 }

                String id = taxa + " " + group;

                if(! statsMatrix.containsKey(id)){
                    statsMatrix.put(id,new HashMap<String, String>());
                }
                else{
                    errorM = "ERROR: id not unique " + id;
                    System.out.println(errorM + "\n");
                    return false;
                }


                String pDS = fields[1].trim();

                if(pDS.equals("NA")){
                pDS = "1";
                 }

                if(pDC.equals("NA")){
                pDC = "1";
                 }

                if(paDS.equals("NA")){
                paDS = "1";
                 }

                if(fdrS.equals("NA")){
                fdrS = "1";
                 }

                double pD = Double.parseDouble(pDS);
                double pDCD = Double.parseDouble(pDC);
                double pAdjD = Double.parseDouble(paDS);
                double fdrD = Double.parseDouble(fdrS);
                double mG1 = Double.parseDouble(meanG1);
                double mG2 = Double.parseDouble(meanG2);

                BigDecimal bd = new BigDecimal(String.valueOf(pD)).setScale(4, BigDecimal.ROUND_HALF_UP);
                String p = bd.toString();

                bd = new BigDecimal(String.valueOf(pAdjD)).setScale(4, BigDecimal.ROUND_HALF_UP);
                String pAdj = bd.toString();

                bd = new BigDecimal(String.valueOf(fdrD)).setScale(4, BigDecimal.ROUND_HALF_UP);
                String fdr = bd.toString();

                bd = new BigDecimal(String.valueOf(pDCD)).setScale(4, BigDecimal.ROUND_HALF_UP);
                pDC = bd.toString();
                
                 bd = new BigDecimal(String.valueOf(mG1)).setScale(4, BigDecimal.ROUND_HALF_UP);
                meanG1 = bd.toString();
                
                 bd = new BigDecimal(String.valueOf(mG2)).setScale(4, BigDecimal.ROUND_HALF_UP);
                meanG2 = bd.toString();

                
                statsMatrix.get(id).put("p", p);
                statsMatrix.get(id).put("p34", pDC);
                statsMatrix.get(id).put("pa", pAdj);
                statsMatrix.get(id).put("fdr", fdr);
                statsMatrix.get(id).put("group", group);
                statsMatrix.get(id).put("taxa", taxa);
                statsMatrix.get(id).put("meanG1", meanG1);
                statsMatrix.get(id).put("meanG2", meanG2);
            }
            scanner.close();
        } catch (Exception err) {
            errorM = "parseAnnotation: Error while parsing file " + file.getName() + " line " + lineN + ": " + err.toString();
            System.out.println(err.toString());
            System.out.println(err.getStackTrace().toString());
            return false;
        }

        System.out.println("Parsing pairwise stats file " + file.getName() + " Done.");

       return true;
    }
}
