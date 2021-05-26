 /*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import CalypsoOnline.CalypsoOConfigs;
import java.io.File;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.Set;


/**
 *
 * @author lutzK
 */
public class DataMatrix {

    LinkedHashMap<String, HashMap<String, Double>> matrix = new LinkedHashMap<String, HashMap<String, Double>>();
    LinkedHashMap<String, HashMap<String, Double>> matrixRel = new LinkedHashMap<String, HashMap<String, Double>>();
    LinkedHashSet<String> allTaxa = new LinkedHashSet();
    LinkedHashSet<String> allSamples = new LinkedHashSet();
    SampleAnnotation annot = new SampleAnnotation();
    HashMap<String, Double> sampleTotal = new HashMap<String, Double>();
    HashMap<Double, ArrayList<String>> remaining = new HashMap<Double, ArrayList<String>>();
    HashMap<Double, HashMap<String, Double>> remainCount = new HashMap<Double, HashMap<String, Double>>();
    HashMap<Double, LinkedHashSet<String>> orderedTaxa = new HashMap<Double, LinkedHashSet<String>>();
    HashMap<Double, LinkedHashSet<String>> orderedTaxaNSN = new HashMap<Double, LinkedHashSet<String>>();
    String errorM = "";
       
    String matrixComp;
    String matrixCompNorm;
    String matrixCompNormAnnot;
    

    public DataMatrix(SampleAnnotation an) {
        annot = an;
    }

    public boolean clearAnnot() {
        annot = new SampleAnnotation();
        return true;
    }

    public void clean() {
        matrix = new LinkedHashMap();
        matrixRel = new LinkedHashMap<String, HashMap<String, Double>>();
        allTaxa = new LinkedHashSet();
        allSamples = new LinkedHashSet();
        annot = new SampleAnnotation();
        sampleTotal = new HashMap<String, Double>();
        remaining = new HashMap<Double, ArrayList<String>>();
        remainCount = new HashMap<Double, HashMap<String, Double>>();
        orderedTaxa = new HashMap<Double, LinkedHashSet<String>>();
        orderedTaxaNSN = new HashMap<Double, LinkedHashSet<String>>();

        File f = new File(matrixComp);
        f.delete();

        f = new File(matrixCompNorm);
        f.delete();
        
        f = new File(matrixCompNormAnnot);
        f.delete();

       
        matrixComp = null;
        matrixCompNorm = null;
        matrixCompNormAnnot = null;
    }

   
    

    // samples,taxa,count
    public boolean addCount(String sample, String taxa, Double count) {

        if (taxa.toLowerCase().equals("remaining")) {
            errorM = "ERROR: remaining is a protected tag";
            System.out.println(errorM + "\n");
            return false;
        }

        if (sample == null) {
            errorM = "ERROR sample is null";
            System.out.println(errorM);
            return false;
        }

        if (matrix == null) {
            errorM = "ERROR: matrix is null";
            System.out.println("ERROR: matrix is null");
            return false;
        }

        allTaxa.add(taxa);

        allSamples.add(sample);

        if (!matrix.containsKey(sample)) {
            matrix.put(sample, new HashMap<String, Double>());
        }
        double c;

        if (matrix.get(sample).containsKey(taxa)) {
            c = matrix.get(sample).get(taxa);
        } else {
            c = 0;
        }

        c += count;

        matrix.get(sample).put(taxa, c);
        return true;
    }

    public boolean containsTaxa(String t) {
        if (allTaxa.contains(t)) {
            return true;
        }
        return false;
    }

    public String getErrorM() {
        return errorM;
    }

    public void setErrorM(String errorM) {
        this.errorM = errorM;
    }

    public String getMatrixCompNormAnnot() {
        return matrixCompNormAnnot;
    }

    public void setMatrixCompNormAnnot(String matrixCompNormAnnot) {
        this.matrixCompNormAnnot = matrixCompNormAnnot;
    }
    
    

    public String getMatrixCompNorm() {
        return matrixCompNorm;
    }

    public String getMatrixComp() {
        return matrixComp;
    }

    public boolean setMatrixComp(String matrixFile, Double minFrac, boolean relative, 
            String method) {

        CalypsoOConfigs configO = new CalypsoOConfigs();
         
        String nf = configO.tempFileWeb(configO.tempFileName(".csv"));
        String nfAnnot = configO.tempFileWeb(configO.tempFileName(".csv"));

        String annotF = annot.getAnnotFile();
        
        JavaR jr = new JavaR();

        
         System.out.println("Normalizing data..." + " " + relative + " " +  method);
        
        if (!jr.normalize(matrixFile, annotF, nf, nfAnnot,
                method, relative, minFrac.toString())) {
           
            this.errorM = "INTERNAL ERROR: data normalization!!";
            return (false);
        }
        
        this.matrixCompNormAnnot = nfAnnot;
        this.matrixCompNorm = nf;
        this.matrixComp = matrixFile;

        return (true);
    }

    

    public SampleAnnotation getAnnot() {
        return annot;
    }

    public void setAnnot(SampleAnnotation annot) {
        this.annot = annot;
    }

    public ArrayList getRemaining(double minFrac) {

        if (remaining.containsKey(minFrac)) {

            return (remaining.get(minFrac));
        }

        ArrayList rem = new ArrayList();

        Iterator iT = this.getOrderedTaxa().iterator();

        LinkedHashSet included = getOrderedTaxa(minFrac, false);

        // iterate over all taxa
        while (iT.hasNext()) {
            String tax = (String) iT.next();

            if (tax.equals("remaining")) {
                continue;
            }

            if (included.contains(tax)) {
                continue;
            }
            rem.add(tax);
        }
        remaining.put(minFrac, rem);

        return rem;
    }

    public Double getRemainingCount(Double minFrac, String sample, Boolean relative) {
        if (minFrac <= 0) {
            return 0.0;
        }

        Double rem = 0.0;

        if (remainCount.containsKey(minFrac) && remainCount.get(minFrac).containsKey(sample)) {

            rem = remainCount.get(minFrac).get(sample);
        } else {
            ArrayList remain = this.getRemaining(minFrac);

            Iterator rIT = remain.iterator();

            double sum = 0;

            while (rIT.hasNext()) {
                String rTax = (String) rIT.next();
                sum += getCount(sample, rTax, minFrac);
            }
            if (!remainCount.containsKey(minFrac)) {
                remainCount.put(minFrac, new HashMap<String, Double>());
            }

            remainCount.get(minFrac).put(sample, sum);
            rem = sum;
        }

        if (relative) {
            rem = rem / this.getSampleTotal(sample) * 100;
        }

        return rem;
    }

    public Double getCount(String sample, String taxa, double minFrac) {
        if (!matrix.containsKey(sample)) {
            return 0.0;
        }
        if (taxa.equals("remaining")) {
            System.out.println("calling getRemainingCount in getCount " + minFrac);
            return getRemainingCount(minFrac, sample, false);
        }
        if (!matrix.get(sample).containsKey(taxa)) {
            return 0.0;
        }
        return matrix.get(sample).get(taxa);
    }

    public Double getCount(String sample, String taxa) {
        return getCount(sample, taxa, 0);
    }

    public double getCount(String sample, String taxa, double minFrac, Boolean relative) {
        if (relative) {
            if (matrixRel.containsKey(sample) && matrixRel.get(sample).containsKey(taxa)) {

                return matrixRel.get(sample).get(taxa);
            }

            double total = getSampleTotal(sample);
            double value = (getCount(sample, taxa, minFrac) / total) * 100;

            if (!matrixRel.containsKey(sample)) {
                matrixRel.put(sample, new HashMap<String, Double>());
            }
            matrixRel.get(sample).put(taxa, value);

            return (value);

//            return(value/total * 100);
            //System.out.println("BigDecimal for " + sample + " " + taxa + " " + minFrac + " value " + value);
            // return String.valueOf(value);
            //BigDecimal bd = new BigDecimal(String.valueOf(getCount(sample, taxa, minFrac) / total * 100)).setScale(2, BigDecimal.ROUND_HALF_UP);
            //return bd.toString();
        } else {
            return (this.getCount(sample, taxa, minFrac));
        }
    }

    public String getCount(String sample, String taxa, Boolean relative, double minFrac) {

        return Double.toString(getCount(sample, taxa, minFrac, relative));

        //System.out.println("BigDecimal for " + sample + " " + taxa + " " + minFrac + " value " + value);
        // return String.valueOf(value);
        //BigDecimal bd = new BigDecimal(String.valueOf(getCount(sample, taxa, minFrac) / total * 100)).setScale(2, BigDecimal.ROUND_HALF_UP);
    }

    public double taxaSum(String tax, boolean relative, double minFrac) {
        Set<String> samples = getSamples();
        Iterator sIt = samples.iterator();

        double sum = 0.0;

        while (sIt.hasNext()) {
            String sample = (String) sIt.next();
            double count = getCount(sample, tax, minFrac, relative);
            sum += count;
        }
        return sum;
    }

    public Set<String> getSamples() {
        Iterator sIT = allSamples.iterator();

        HashSet<String> all = new HashSet();

        while (sIT.hasNext()) {
            String sample = (String) sIT.next();

            if (annot.keepSample(sample)) {
                all.add(sample);
            }
        }

        return all;
    }

    public Set<String> getSamplesAll() {

        return allSamples;
    }

    public LinkedHashSet<String> getOrderedSamples() {

        Iterator sIT = allSamples.iterator();

        LinkedHashSet<String> ordered = new LinkedHashSet();

        while (sIT.hasNext()) {
            String sample = (String) sIT.next();

            System.out.println("SAmple:: " + sample);

            if (annot.keepSample(sample)) {
                ordered.add(sample);
            }

        }
        return ordered;
    }

    public ArrayList<String> getOrderedSamples(String orderBy) {

        Iterator it = allSamples.iterator();

        ArrayList<String> ordered = new ArrayList();

        while (it.hasNext()) {
            String sample = (String) it.next();

            if (annot.keepSample(sample)) {
                ordered.add(sample);

            }
        }
        SampleSorter samSort = new SampleSorter();
        samSort.setOrderBy(orderBy);
        samSort.setSAnnot(annot);

        Collections.sort(ordered, samSort);

        return ordered;
    }

    public LinkedHashSet<String> getOrderedTaxa() {
        return getOrderedTaxa(0);
    }

    public LinkedHashSet<String> getOrderedTaxa(double minFrac) {
        return this.getOrderedTaxa(minFrac, false, true);
    }

    public LinkedHashSet<String> getOrderedTaxa(double minFrac, boolean sumNotNull) {
        return this.getOrderedTaxa(minFrac, sumNotNull, true);
    }
    
    public LinkedHashSet<String> getOrderedTaxa(double minFrac, boolean sumNotNull, boolean relative) {
        System.out.println("Getting ordered taxa ... " + minFrac + " " + sumNotNull);

        LinkedHashSet<String> oTax;

        if (sumNotNull) {
            if (orderedTaxaNSN.containsKey(minFrac)) {

                return orderedTaxaNSN.get(minFrac);
            }
        } else {
            if (orderedTaxa.containsKey(minFrac)) {

                return orderedTaxa.get(minFrac);
            }
        }

        if ((!(minFrac > 0)) && (!sumNotNull)) {
            return allTaxa;
        }

        LinkedHashSet<String> ordered = new LinkedHashSet();

        Iterator iT = allTaxa.iterator();

        double minFracSum = -1;

        boolean getFrac = false;
        if (sumNotNull) {
            getFrac = true;
            minFracSum = 0;
        }
        if (minFrac > 0) {
            getFrac = true;
        }

        // iterate over all taxa
        while (iT.hasNext()) {
            String taxa = (String) iT.next();

            // iterate over all samples
            for (String s : this.getSamples()) {

                double frac = 1;
                if (getFrac) {                   
                    frac = getCount(s, taxa, minFrac, relative);
                }

                if ((frac >= minFrac) && (frac > minFracSum)) {
                    ordered.add(taxa);
                    break;
                }
            }
        }

        if (sumNotNull) {
            orderedTaxaNSN.put(minFrac, ordered);
        } else {
            orderedTaxa.put(minFrac, ordered);
        }


        return ordered;
    }

    public HashMap<String, Double> getSampleTotal() {
        return sampleTotal;
    }

    public void setSampleTotal(HashMap<String, Double> sampleTotal) {
        this.sampleTotal = sampleTotal;
    }

    public Double getSampleTotal(String s) {
        if (sampleTotal == null) {
            System.out.println("ERROR: sampleTotal==null");
            return (-1.0);
        }

        if (sampleTotal.containsKey(s)) {

            return sampleTotal.get(s);

        }

        if (!matrix.containsKey(s)) {
            sampleTotal.put(s, 0.0);
            return 0.0;
        }

        return 0.0;
    }

    public String toString(double minFrac, String orderBy, Boolean relative, Boolean fullSample, Boolean printAnnot) {


        String table = "";

        ArrayList<String> samples = getOrderedSamples(orderBy);

        // print header, i.e. sample name
        Iterator sIt = samples.iterator();
        while (sIt.hasNext()) {

            String sampleName = (String) sIt.next();
            String sample = "";


            if (fullSample) {
                String group = annot.getSampleGroup(sampleName);
                String pair = annot.getSamplePair(sampleName);
                String groupS = annot.getSampleGroupS(sampleName);
                sample = pair + " " + group + " " + groupS + " ";
            }

            sample += sampleName;

            table += "," + sample;
        }
        table += "\n";

        // print sample annotation
        if (printAnnot) {
            // add label
            sIt = samples.iterator();
            while (sIt.hasNext()) {
                String sample = (String) sIt.next();
                String label = annot.getSampleLabel(sample);
                table += "," + label;
            }

            table += "\n";
            // add group
            sIt = samples.iterator();
            while (sIt.hasNext()) {
                String sample = (String) sIt.next();
                String group = annot.getSampleGroup(sample);
                table += "," + group;
            }

            table += "\n";

            // add pair
            sIt = samples.iterator();
            while (sIt.hasNext()) {
                String sample = (String) sIt.next();
                String pair = annot.getSamplePair(sample);
                table += "," + pair;
            }

            table += "\n";

            // print sample groupS
            sIt = samples.iterator();
            while (sIt.hasNext()) {
                String sample = (String) sIt.next();
                String groupS = annot.getSampleGroupS(sample);
                table += "," + groupS;
            }

            table += "\n";
        }

        //print counts
        LinkedHashSet<String> taxa = getOrderedTaxa(minFrac, true);
        Iterator tIt = taxa.iterator();
        while (tIt.hasNext()) {
            String tax = (String) tIt.next();

            table += tax;

            sIt = samples.iterator();
            while (sIt.hasNext()) {
                String sample = (String) sIt.next();
                String count = getCount(sample, tax, relative, minFrac);
                table += "," + count;
            }
            table += "\n";
        }

        // add remaining
        String tax = "Remaining";

        table += tax;

        sIt = samples.iterator();
        while (sIt.hasNext()) {
            String sample = (String) sIt.next();
            Double count = getRemainingCount(minFrac, sample, relative);

            table += "," + count;
        }
        table += "\n";

        return table;
    }

    private boolean _filterGroupGroupS(String groupA, String groupB, String tA, String tB) {
        if ((groupA == null || groupA.equals("all")) && (groupB == null || groupB.equals("all"))) {
            if ((tA == null || tA.equals("all")) && (tB == null || tB.equals("all"))) {
                return false;
            }
        }

        return true;
    }

    private boolean _matchGroupGroupS(String g, String t, String gG, String tG) {
        if (!gG.equals("all")) {
            if (!gG.equals(g)) {
                return false;
            }
        }
        if (!tG.equals("all")) {
            if (!tG.equals(t)) {
                return false;
            }
        }

        return true;
    }

    private String _newGroup(String g, String t, String gG, String tG) {
        String newG = null;

        if (!gG.equals("all")) {
            newG = g;
        }
        if (!tG.equals("all")) {
            if (newG == null) {
                newG = t;
            } else {
                newG = newG + " " + t;
            }
        }
        if (newG == null) {
            newG = g;
        }

        return newG;
    }
}
