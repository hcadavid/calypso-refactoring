/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import CalypsoOnline.CalypsoOConfigs;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.Scanner;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author lutzK
 */
public class SampleAnnotation {
    // samples,list of groups

    HashMap<String, String> sampleGroup = new HashMap();
    // list of sample groupSs
    HashMap<String, String> sampleGroupS = new HashMap();
//    HashMap<String, String> sampleRegression = new HashMap();
    HashMap<String,HashMap<String,String>> sampleEnvironment = new HashMap();
    // list of sample pairs
    HashMap<String, String> samplePair = new HashMap();
    HashMap<String, Boolean> keepSample = new HashMap();
    HashMap<String, String> sampleLabel = new HashMap();
    String error = "";
    String warning = "";
    String annotFile = "";
    String annotFileName = "";

    public String getWarning() {
        return warning;
    }

    public void addWarning(String warning){
        this.warning += warning;
    }

    public void setWarning(String warning) {
        this.warning = warning;
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
    
    public LinkedHashSet getGroupsAll() {
        LinkedHashSet<String> groups = new LinkedHashSet<String>();

        Iterator it = sampleGroup.keySet().iterator();

        while(it.hasNext()){
            String sample = (String)it.next();
            if(this.keepSample(sample)){
                groups.add(this.getSampleGroup(sample));
            }
        }
         
        return (groups);
    }

    public Set getEnvVarsAll() {
        return(this.sampleEnvironment.keySet());
    }

    public LinkedHashSet getGroupSAll() {
        LinkedHashSet<String> groupSs = new LinkedHashSet<String>();

        Iterator it = sampleGroupS.keySet().iterator();

        while(it.hasNext()){
            String sample = (String)it.next();
            if(this.keepSample(sample)){
                groupSs.add(this.getSampleGroupS(sample));
            }
        }

        return (groupSs);
    }

    public LinkedHashSet getPairsAll() {
        LinkedHashSet<String> groupSs = new LinkedHashSet<String>();

        Iterator it = samplePair.keySet().iterator();

        while(it.hasNext()){
            String sample = (String)it.next();
            if(this.keepSample(sample)){
                groupSs.add(this.getSamplePair(sample));
            }
        }

        return (groupSs);
    }

    public boolean definedSample(String s){
        if(keepSample.containsKey(s)){
            return true;
        }
        return false;
    }

    public Set<String> getAllSamples(){
        return (keepSample.keySet());
    }

    public HashSet<String> getAllIncludedSamples(){
        HashSet<String> tmp = new HashSet<String>();

        Iterator it = keepSample.keySet().iterator();

        while(it.hasNext()){
            String sample = (String) it.next();

            if(this.keepSample(sample)){
                tmp.add(sample);
            }
        }

        return (tmp);
    }


    public String getSampleGroup(String s) {
        if (sampleGroup.containsKey(s)) {
            return sampleGroup.get(s);
        }
        return "";
    }

    public String getSamplePair(String s) {
        if (samplePair.containsKey(s)) {
            return samplePair.get(s);
        }
        return "";
    }

    public String getSampleGroupS(String s) {
        if (sampleGroupS.containsKey(s)) {
            return sampleGroupS.get(s);
        }
        return "";
    }

    public String getSampleEnv(String s, String e) {
        if (this.sampleEnvironment.containsKey(e)) {
            return sampleEnvironment.get(e).get(s);
        }
        return "";
    }

    public Collection getEnvironmentValues(String e){
        
        HashMap env = sampleEnvironment.get(e);
        return(env.values());
    }

    public String getSampleLabel(String s) {
        if (sampleLabel.containsKey(s)) {
            return sampleLabel.get(s);
        }
        return "";
    }

    public HashMap<String, Boolean> getKeepSample() {
        return keepSample;
    }

    public void setKeepSample(HashMap<String, Boolean> keepSample) {
        this.keepSample = keepSample;
    }

    public HashMap<String, String> getSampleGroup() {
        return sampleGroup;
    }

    public void setSampleGroup(HashMap<String, String> sampleGroup) {
        this.sampleGroup = sampleGroup;
    }

    public HashMap<String, String> getSamplePair() {
        return samplePair;
    }

    public void setSamplePair(HashMap<String, String> samplePair) {
        this.samplePair = samplePair;
    }

    public HashMap<String, String> getSampleGroupS() {
        return sampleGroupS;
    }

    public void setSampleGroupS(HashMap<String, String> sampleGroupS) {
        this.sampleGroupS = sampleGroupS;
    }

    public String getAnnotFileName() {
        return annotFileName;
    }

    

    
    
    public String getAnnotFile() {
        return annotFile;
    }

    public void setAnnotFile(String annotFile) {
        File tmp = new File(annotFile);
        String name = tmp.getName();
        this.annotFileName = name;
        
        this.annotFile = annotFile;
    }

    public void clear() {
        sampleGroup = new HashMap();
        sampleGroupS = new HashMap();
        samplePair = new HashMap();
        keepSample = new HashMap();
        annotFile = "";
        annotFileName = "";
    }

    public boolean parseAnnotation(File f, String delimiter) {
        this.setError("");
        this.clear();

        CalypsoOConfigs configs = new CalypsoOConfigs();

        System.out.println("Parsing file " + f.getName());

        HashMap<String,String> checkSamples = new HashMap();

        HashMap<String,Integer> checkGroups = new HashMap();

        int lineN = 0;
        try {

            HashMap<String,String> checkAnnot = new HashMap();


            HashMap<String,String> pairGroup = new HashMap();

            annotFileName = configs.tempFileName(".csv");
            annotFile = configs.tempFileWeb(annotFileName);
            
            File frm = new File(annotFile);
            frm.deleteOnExit();
            System.out.println("Annotfile: " + annotFile);
            
           
            

            Scanner scanner = new Scanner(f);

            scanner.useDelimiter("\n");

            HashMap<String,String> checkLabels = new HashMap();

            
            String[] headerFields = {};

            // Get header line
             while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;
                if (line.startsWith("#")) {
                    
                    continue;
                }
                String s="";

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if (mE.matches()) {
                    
                    continue;
                }
                String[] fields = line.split(delimiter);
                headerFields = fields;

                if (fields.length < 6) {
                    String errorM = "ERROR: wrong format line " + lineN + " wrong field number. Expected: >6, observed: " + fields.length;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                break;
            }

            // write header to file
            BufferedWriter outAnnot = new BufferedWriter(new FileWriter(annotFile));
            outAnnot.write("sample,label,pair,group,groupS,keep");

            for(int i = 6; i < headerFields.length; i++){
                String env = headerFields[i];
                System.out.println(env);
                env=env.replaceAll("-",".");
                System.out.println(env);
                outAnnot.write("," + env);
                HashMap<String,String> envhm = new HashMap();
                this.sampleEnvironment.put(env, envhm);

            }
            outAnnot.write("\n");


            //first use a Scanner to get each line
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;
                if (line.startsWith("#")) {
                    continue;
                }

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if (mE.matches()) {
                    continue;
                }

                String[] fields = line.split(delimiter);

                

//                if (fields.length != firstFields.length) {
//                    String errorM = "ERROR: wrong format line " + lineN + " number of field changed.";
//                    System.out.println(errorM + "\n");
//                    this.setError(errorM);
//                    return false;
//                }

                if (fields.length != headerFields.length) {
                    String errorM = "ERROR: wrong format line " + lineN + 
                            " wrong column number, number of columns don't match header line.";
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                String sample = fields[0].trim().toLowerCase();
                String label = fields[1].trim();
                String pair = fields[2].trim();
                String group = fields[3].trim();


                if(pairGroup.containsKey(pair)){
                    if(! group.equals(pairGroup.get(pair))){
                        String errorM = "\nWARNING: pair " + pair + " belongs to different groups! Samples from the same pair should be in the same group for the paired analysis.";
                        this.addWarning(errorM);
                    }
                }
                else{
                    pairGroup.put(pair,group);
                }

                if(sample.startsWith("0")){
                    sample = "S" + sample;
                }

                if(group.equals("NA")){
                    String errorM = "ERROR: group NA is not allowed, as NA is a reserved tag, line " + lineN;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

               if(group.equals("")){
                    String errorM = "ERROR: empty group, sample " + sample + " line " + lineN;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                String groupS = fields[4].trim();
                String keep = fields[5].trim();

                if(! keep.equals("0")){
                    if(checkGroups.containsKey(group)){
                        checkGroups.put(group,checkGroups.get(group) + 1);
                    }
                    else{
                        checkGroups.put(group,1);
                    }
                }

                if(checkLabels.containsKey(label)){
                    String errorM = "ERROR: label " + label + " not unique, line " + lineN;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                checkLabels.put(label,"");

                if(checkSamples.containsKey(sample)){
                    String errorM = "ERROR: sample " + sample + label + group + " not unique, line " + lineN;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                checkSamples.put(sample,"");

                Boolean keepB = true;
                if (keep.equals("0")) {
                    keepB = false;
                }
                else{
                    keep = "1";
                }


                String test = pair + "%" + groupS + "%" + group;

//                if(checkAnnot.containsKey(test)){
//                    String errorM = "ERROR: samples " + sample + " and " + checkAnnot.get(test) + " have the same pair, groupS/location and group, line " + lineN;
//                    System.out.println(errorM + "\n");
//                    this.setError(errorM);
//                    return false;
//                }
                if(keepB){
                    checkAnnot.put(test, sample);
                }

                 outAnnot.write(sample + "X," + label + "," + pair + "," + group + "," + groupS + "," + keep);

                // now get all environmental variables
                for(int i = 6; i < fields.length; i++){
                    String env = headerFields[i].trim().replace("-",".");
                     String value = fields[i].trim();

                     if(value.equals("")) value = "NA";
                     if(value.equals("-")) value = "NA";
                       
                     this.sampleEnvironment.get(env).put(sample, value);
                     outAnnot.write("," + value);
                }


                this.sampleGroup.put(sample, group);
                this.samplePair.put(sample, pair);
                this.sampleGroupS.put(sample, groupS);
                
                this.keepSample.put(sample, keepB);
                this.sampleLabel.put(sample,label);

                outAnnot.write("\n");

            }
            outAnnot.close();
            scanner.close();
        } catch (Exception err) {
            setError("parseAnnotation: Error while parsing file " + f.getName() + " line " + lineN + ": " + err.toString());
            System.out.println(err.toString());
            System.out.println(err.getStackTrace().toString());
            return false;
        }

        int GroupN = checkGroups.keySet().size();

        if(GroupN < 2){

            this.addWarning("Less than 2 groups defined, some statistical analysis, including GroupPlots, may not be functional.");
        }

        System.out.println("Parsing annotation file " + f.getName() + " Done.");

        return true;
    }

    public boolean keepSample(String s) {
        boolean ret = true;

        if (keepSample.containsKey(s)) {
            return keepSample.get(s);
        }

        System.out.println("ERROR: sample " + s + " not defined in keep sample");

        return false;
    }
}
