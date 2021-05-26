/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import CalypsoOnline.CalypsoOConfigs;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author lutzK
 */
public class LevelDataMatrix {

    HashMap<String, DataMatrix> dataM = new HashMap();
    HashMap<String, HashMap<String, Double>> sampleTotal = new HashMap<String, HashMap<String, Double>>();
    SampleAnnotation sAnnot = new SampleAnnotation();
    String error = "";
    
    Double minFrac = 0.0;
    boolean relative = false;
    String normalization = "none";
    Double meanFilter = 0.0;
    
    String warning = "";
    int parsedTaxa = 0;

    public LevelDataMatrix(double mfrac, String norm, boolean rel,
            double mF) {
        minFrac = mfrac;

        normalization = norm;
        relative = rel;
        meanFilter = mF;
    }

    public String getWarning() {
        if(warning.equals("")){
            return("");
        }
        return "Warnings: " + warning;
    }

    public void addWarning(String warning){
        if(! warning.equals("")){
            warning += "; ";
        }    

        this.warning += warning;
    }

    public void setWarning(String warning) {
        this.warning = warning;
    }

    public DataMatrix getDataMatrix(String level) {
        DataMatrix dm = dataM.get(level);

        if (dm == null) {
            dm = new DataMatrix(sAnnot);
             
        }
        return (dm);
    }

    public HashMap getDataM() {
        return dataM;
    }

    public SampleAnnotation getSAnnot() {
        return sAnnot;
    }

    public boolean clearAnnot() {
        sAnnot = null;

        Iterator it = dataM.keySet().iterator();

        while (it.hasNext()) {
            String level = (String) it.next();

            dataM.get(level).clearAnnot();
        }

        return true;
    }

    public boolean setSAnnot(SampleAnnotation s) {
        sAnnot = s;

        if (!this.validateAnnotation()) {
            sAnnot = new SampleAnnotation();
            return false;
        }

        Iterator it = dataM.keySet().iterator();

        while (it.hasNext()) {
            String level = (String) it.next();

            System.out.println("Setting annot " + level);
            dataM.get(level).setAnnot(sAnnot);
        }

        return true;
    }

    public Double getMinFrac() {
        return minFrac;
    }

    public void setMinFrac(Double minFrac) {
        this.minFrac = minFrac;
    }

    public void setDataM(HashMap dataM) {
        this.dataM = dataM;
    }

    public int getParsedTaxa() {
        return parsedTaxa;
    }

    public void setParsedTaxa(int parsedTaxa) {
        this.parsedTaxa = parsedTaxa;
    }

    
    
    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }

    public int getNumLevels(){
        return dataM.keySet().size();       
    }

    public boolean addCount(String level, String sample, String tax, Double count) {
        if (tax.toLowerCase().equals("remaining")) {
            String errorM = "ERROR: remaining is protected tag";
            System.out.println(errorM);
            setError(errorM);
            return false;
        }


        if (!dataM.containsKey(level)) {
            DataMatrix dm = new DataMatrix(sAnnot);
            
            dataM.put(level, dm);
        }
        if (!dataM.get(level).addCount(sample, tax, count)) {
            String errorM = dataM.get(level).getErrorM();
            setError(errorM);
            return false;
        }

        return true;
    }

    public boolean getSampleTotal(File f, String delimiter, String filtertaxa) {
        System.out.println("getSampleTotal...");
        
        sampleTotal = new HashMap();

        setError("");

        CalypsoOConfigs configs = new CalypsoOConfigs();

        System.out.println("Parsing counts file " + f.getName());

        int lineN = 0;
        try {
            HashMap<String, String[]> sampleMap = new HashMap();
            HashMap<String, Boolean> header = new HashMap();
            Scanner scanner = new Scanner(f);
            scanner.useDelimiter("\r\n");

            //first use a Scanner to get each line
            boolean first = true;
            int taxaN = 0;
            String lastLevel = "";

            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;

                // skip lines beginning with #
                if (line.startsWith("#")) {
                    continue;
                }

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if (mE.matches()) {
                    continue;
                }
                
                pE = Pattern.compile("^"+delimiter+"*$");
                mE = pE.matcher(line);
                if (mE.matches()) {
                    continue;
                }
                
                String bla = "" + "";
                
                if ((!filtertaxa.equals("None")) && line.contains(filtertaxa)) {
                    continue;
                }
                // check if line is header
                String[] fields = line.split(delimiter);

                
                
                if (fields.length < 2) {
                    String message = "ERROR line " + lineN + " wrong format, less than 2 elements: " + line;
                    this.setError(message);
                    System.out.println(line);
                    System.out.println(fields);
                    System.out.println(fields.length);
                    return false;
                }




                String hs = fields[1].trim();


                boolean isHeader = false;
                Pattern p = Pattern.compile("header", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
                Matcher m = p.matcher(hs);
                if (m.matches()) {
                    isHeader = true;
                    first = false;
                    taxaN = 0;
                }




                String level = fields[0].trim();
                lastLevel = level;

                // get samples
                if (isHeader) {

                    // check if header is redefined
                    if (header.containsKey(level)) {
                        String errorM = "ERROR: redefined header line " + lineN + ". Header can only be defined once per level.";
                        this.setError(errorM);
                        return false;
                    }

                    header.put(level, true);

                    if (fields.length < 3) {
                        String errorM = "ERROR: wrong line format line " + lineN + ".";
                        System.out.println(errorM + "\n");
                        this.setError(errorM);
                        return false;
                    }

                    String[] samples = new String[fields.length];


                    // trim sample names
                    for (int i = 0; i < fields.length; i++) {
                        String sample = fields[i].trim().toLowerCase();

                        if (sample.startsWith("0")) {
                            sample = "S" + sample;
                        }


                        samples[i] = sample;
                    }

                    sampleMap.put(level, samples);

                    continue;
                }

                if (!header.containsKey(level)) {
                    String errorM = "ERROR: wrong format line " + lineN + ", header is missing (no header tag for level " + level + ")";
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                if (!sampleMap.containsKey(level)) {
                    String errorM = "INTERNAL ERROR: no samples for level " + level;
                    setError(errorM);
                    System.out.println(errorM);
                    return false;
                }

                if (fields.length > sampleMap.get(level).length) {
                    String errorM = "ERROR: wrong format line " + lineN + ", countN > Sample number " + fields.length + ">" + sampleMap.get(level).length + " (" + line + ")";
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                String tax = fields[1].trim();
                tax = tax.replace("\"", "");
                tax = tax.replaceAll("\\s", "_");


                if ((dataM.get(level) != null) && (dataM.get(level).containsTaxa(tax))) {
                    Configs config = new Configs();
                    
                    String errorM = "ERROR: taxa " + tax + " not unique level " + level + " line " + lineN;
                    if(config.isDataMiner()) errorM = "ERROR: feature " + tax + " not unique line " + lineN;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                taxaN++;

                for (int i = 2; i < sampleMap.get(level).length; i++) {
                    String c = "0";

                    if (fields.length > i) {
                        c = fields[i].trim();
                    }
                    if (c.length() == 0) {
                        c = "0";
                    }
                    Double count = Double.parseDouble(c);
                    String sample = sampleMap.get(level)[i];

                    if (!sampleTotal.containsKey(level)) {
                        sampleTotal.put(level, new HashMap());
                    }
                    Double sum = 0.0;
                    if (sampleTotal.get(level).containsKey(sample)) {
                        sum = sampleTotal.get(level).get(sample);
                    }
                    sum = sum + count;
                    sampleTotal.get(level).put(sample, sum);
                    //System.out.println("Sample total " + sample + " " + sum);

                }

            }
            scanner.close();




        } catch (Exception err) {
            setError("parseCounts (getSampleTotals): Error while parsing file " + f.getName() + " line " + lineN + ": " + err.toString());
            return false;
        }

        System.out.println("Parsing counts file " + f.getName() + " Done.");



        return true;
    }

    public boolean parseCounts(String file, String delimiter, String filtertaxa) {
        setError(null);
        File f = new File(file);
        return (parseCounts(f, delimiter, filtertaxa));
    }

    public boolean parseCounts(File f, String delimiter, String filtertaxa) {
        this.parsedTaxa = 0;
        
        if (!this.getSampleTotal(f, delimiter, filtertaxa)) {
            return false;
        }

        if(! f.exists()){
            System.out.println("ERROR: file " + f.getAbsolutePath() + " " + f.getName() + " does not exist!");
            return false;
        } 
        
        dataM = new HashMap();

        setError("");

        CalypsoOConfigs configs = new CalypsoOConfigs();

        System.out.println("Parsing counts file " + f.getName());

        // parse counts
        int lineN = 0;
        try {
            HashMap<String, BufferedWriter> outFilesMatrix = new HashMap<String, BufferedWriter>();
            HashMap<String, String> matrixFileNames = new HashMap<String, String>();

            

            Scanner scanner = new Scanner(f);
            scanner.useDelimiter("\r\n");

            //first use a Scanner to get each line

            HashMap<String, String[]> sampleMap = new HashMap();

            HashMap<String, Boolean> header = new HashMap();

//            HashMap<String,HashMap<String>> readTaxa = new HashMap<String,String>();

            boolean first = true;
            int taxaN = 0;
            String lastLevel = "";

            // iterate over all lines
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                lineN++;

                // skip lines beginning with #
                if (line.startsWith("#")) {
                    continue;
                }

                // skip emtpy lines
                Pattern pE = Pattern.compile("^\\s*$");
                Matcher mE = pE.matcher(line);
                if (mE.matches()) {
                    continue;
                }
                
                pE = Pattern.compile("^"+delimiter+"*$");
                mE = pE.matcher(line);
                if (mE.matches()) {
                    continue;
                }
                
                if ((!filtertaxa.equals("None")) && line.contains(filtertaxa)) {
                    continue;
                }
                // check if line is header
                String[] fields = line.split(delimiter);
                String hs = fields[1].trim();

                boolean isHeader = false;
                Pattern p = Pattern.compile("header", Pattern.CASE_INSENSITIVE | Pattern.UNICODE_CASE);
                Matcher m = p.matcher(hs);
                if (m.matches()) {
                    isHeader = true;
//
//                    if((! first) && (taxaN < 2)){
//                        String message = "ERROR line " + lineN + " wrong format, less than 2 taxa with counts > 0 for level " + lastLevel;
//                        this.setError(message);
//                        return false;
//                    }
                    first = false;
                    taxaN = 0;
                }

                if (fields.length < 2) {
                    String message = "ERROR line " + lineN + " wrong format, less than 2 elements.";
                    this.setError(message);
                    return false;
                }

                String level = fields[0].trim();
                lastLevel = level;

                if (!outFilesMatrix.containsKey(level)) {
                    String matrixFile = configs.tempFile(".csv");
                    BufferedWriter outMatrix = new BufferedWriter(new FileWriter(matrixFile));
                    outFilesMatrix.put(level, outMatrix);
                    matrixFileNames.put(level, matrixFile);
                    File fm = new File(matrixFile);
                    fm.deleteOnExit();
                }

                

                BufferedWriter outMatrix = outFilesMatrix.get(level);
                

                // get samples
                if (isHeader) {

                    // check if header is redefined
                    if (header.containsKey(level)) {
                        String errorM = "ERROR: redefined header line " + lineN + ". Header can only be defined once per level.";
                        this.setError(errorM);
                        return false;
                    }

                    header.put(level, true);

                    if (fields.length < 3) {
                        String errorM = "ERROR: wrong line format line " + lineN + ".";
                        System.out.println(errorM + "\n");
                        this.setError(errorM);
                        return false;
                    }

                    String[] samples = new String[fields.length];

                    // writer header to compact data matrix
                    outMatrix.write("Taxa");



                    // trim sample names
                    for (int i = 2; i < fields.length; i++) {
                        String sample = fields[i].trim().toLowerCase();

                        if (sample.startsWith("0")) {
                            sample = "S" + sample;
                        }

                        if (!sAnnot.definedSample(sample)) {
                            String errorM = "ERROR: sample " + sample +
                                    " in counts file but not defined in meta data file, line " + lineN +
                                    ". The following samples are defined:";
                            errorM += sAnnot.keepSample.keySet();
                            System.out.println(errorM + "\n");
                            this.setError(errorM);
                            return false;
                        }

                        samples[i] = sample;
                        if ((i >= 2) && sAnnot.keepSample(sample)) {
                            outMatrix.write("," + sample + "X");
                        }
                    }
                    outMatrix.write("\n");

                    // write totals to out matrix
                    outMatrix.write("Total");

                    for (int i = 2; i < fields.length; i++) {
                        String sample = fields[i].trim().toLowerCase();

                        if (sample.startsWith("0")) {
                            sample = "S" + sample;
                        }

                        if (sAnnot.keepSample(sample)) {

                            if (sampleTotal == null) {
                                String errorM = "ERROR: no sampleTotal";
                                System.out.println(errorM + "\n");
                                this.setError(errorM);
                                return (false);
                            }
                            if (sampleTotal.get(level) == null) {
                                String errorM = "ERROR: no sampleTotal for level " + level;
                                System.out.println(errorM + "\n");
                                this.setError(errorM);
                                return (false);
                            }
                            if (sampleTotal.get(level).get(sample) == null) {
                                String errorM = "ERROR: no sampleTotal for level " + level + " and sample " + sample;
                                System.out.println(errorM + "\n");
                                this.setError(errorM);
                                return (false);
                            }
                            double total = sampleTotal.get(level).get(sample);
                            samples[i] = sample;

                            outMatrix.write("," + total);
                        }
                    }
                    outMatrix.write("\n");

                    sampleMap.put(level, samples);

                    continue;
                }

                if (!header.containsKey(level)) {
                    String errorM = "ERROR: wrong format line " + lineN + ", header is missing (no header tag for level " + level + ")";
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }


                if (!sampleMap.containsKey(level)) {
                    String errorM = "INTERNAL ERROR: no samples for level " + level;
                    setError(errorM);
                    System.out.println(errorM);
                    return false;
                }

                if (fields.length > sampleMap.get(level).length) {
                    String errorM = "ERROR: wrong format line " + lineN + ", countN > Sample number " + fields.length + ">" + sampleMap.get(level).length + " (" + line + ")";
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }

                String tax = fields[1].trim();
                tax = tax.replaceAll("\\s", "_");
                tax = tax.replaceAll("\"", "");
                tax = tax.replaceAll(";", "_");

                if ((dataM.get(level) != null) && (dataM.get(level).containsTaxa(tax))) {
                    Configs config = new Configs();
                    
                    String errorM = "ERROR: taxa " + tax + " not unique level " + level + " line " + lineN;
                    if(config.isDataMiner()) errorM = "ERROR: feature " + tax + " not unique line " + lineN;
                   
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }


                // remove taxa with 0 assigned reads
                double sum = 0;
                double maxFrac = 0;
                double sampleN = 0;

                if (fields.length < 2) {
                    String errorM = "ERROR: less than 2 columns level " + level + " line " + lineN;
                    System.out.println(errorM + "\n");
                    this.setError(errorM);
                    return false;
                }
                int keep = 0;
                for (int i = 2; i < sampleMap.get(level).length; i++) {
                    String sample = sampleMap.get(level)[i];

                    if (sAnnot.keepSample(sample)) {

                        keep++;

                        String c = "0";

                        if (fields.length > i) {
                            c = fields[i].trim();
                        }


                        if (c.length() == 0) {
                            c = "0";
                        }

                        Double count = Double.parseDouble(c);

                        double total = sampleTotal.get(level).get(sample);

                        double frac = count / total;
                        if (frac > maxFrac) {
                            maxFrac = frac;
                        }

                        sum += count;
                        sampleN += 1;
                    }
                }

//                if (keep < 2) {
//                    String errorM = "ERROR: less than 2 samples to keep, level " + level + " line " + lineN;
//                    System.out.println(errorM + "\n");
//                    this.setError(errorM);
//                    return false;
//                }
                Double mean=sum/sampleN;
                
               
                
                if (sum > 0 && (maxFrac * 100 >= minFrac)) {
                    outMatrix.write(tax);
                    taxaN++;
                    parsedTaxa++;

                    for (int i = 2; i < sampleMap.get(level).length; i++) {
                        String sample = sampleMap.get(level)[i];

                        if (sAnnot.keepSample(sample)) {
                            String c = "0";

                            if (fields.length > i) {
                                c = fields[i].trim();
                            }
                            if (c.length() == 0) {
                                c = "0";
                            }
                            Double count = Double.parseDouble(c);
                            //Integer.parseInt(fields[i].trim());


                            if (!this.addCount(level, sample, tax, count)) {
                                return false;
                            }
                            String label = sAnnot.getSampleLabel(sample);
                            String indiv = sAnnot.getSamplePair(sample);
                            String groupS = sAnnot.getSampleGroupS(sample);
                            String group = sAnnot.getSampleGroup(sample);

                            outMatrix.write("," + count);

                            
                        }
                    }

                    outMatrix.write("\n");
                }
            }
            scanner.close();



            // iterate over all compact dataMatrix files, close file handle, set file in DataMatrix
            Iterator it = outFilesMatrix.keySet().iterator();

            while (it.hasNext()) {

                String level = (String) it.next();
                BufferedWriter outMatrix = outFilesMatrix.get(level);
                outMatrix.close();

                String fileName = matrixFileNames.get(level);

                DataMatrix dm = this.getDataMatrix(level);
                if (dm == null) {
                    String err = "ERROR: datamatrix == null for level " + level;
                    this.setError(err);
                    return (false);
                }
                System.out.println(this.sAnnot.annotFile);
                System.out.println("Setting matrix comp ...");
               
                if(!dm.setMatrixComp(fileName, minFrac, relative, normalization)){
                    String err = "ERROR: could not set data matrix " + level;
                    this.setError(err);
                    return (false);
                }

                this.getDataMatrix(level).setSampleTotal(sampleTotal.get(level));
            }

        } catch (Exception err) {
            setError("parseCounts: Error while parsing file " + f.getName() + " line " + lineN + ": " + err.toString());
            return false;
        }

        System.out.println("Parsing counts file " + f.getName() + " Done.");

        if (!this.validateAnnotation()) {
            setError("Error validating annotation!!!!");
            this.clear();
            return false;
        }

        return true;
    }

    public boolean validateAnnotation() {
        this.setError("");
        this.warning = "";

       
        // iterate over levels
        Iterator rit = dataM.keySet().iterator();
     

        // iterate over ranks
        while (rit.hasNext()) {
            String rank = (String) rit.next();

            DataMatrix d = (DataMatrix) dataM.get(rank);

            // iterate over samples
            Iterator sit = d.getSamplesAll().iterator();

            while (sit.hasNext()) {
                String sample = (String) sit.next();


                // check if group, pair and groupS is defined
                if (!sAnnot.getSampleGroup().containsKey(sample)) {
                    this.setError("ERROR: no group defined for sample " + sample);
                    System.out.println("ERROR: no group defined for sample " + sample);
                    return false;
                }
                if (!sAnnot.getSamplePair().containsKey(sample)) {
                    this.setError("ERROR: no pair defined for sample " + sample);
                    return false;
                }
                if (!sAnnot.getSampleGroupS().containsKey(sample)) {
                    this.setError("ERROR: no secondary group defined for sample " + sample);
                    return false;
                }
                if (!sAnnot.getKeepSample().containsKey(sample)) {
                    this.setError("ERROR: keep not defined for sample " + sample);
                    return false;
                }
            }

            // iterate over all samples defined in annotation file
            Iterator sait = sAnnot.keepSample.keySet().iterator();

            while(sait.hasNext()){
                String sample = (String) sait.next();
                if(sAnnot.keepSample.get(sample)){
                  if(! d.getSamplesAll().contains(sample)){
                      String wa = "No data for sample " + sample + " at level " + rank;

                      this.addWarning(wa);
                  }
                }
            }

        }
        return true;
    }

    public void clear() {
        sAnnot.clear();
        dataM = new HashMap();
    }
}
