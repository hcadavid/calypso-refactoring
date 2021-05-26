/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package CalypsoCommon;

import java.util.Comparator;

/**
 *
 * @author lutzK
 */
public class SampleSorter  implements Comparator<String>{
    String orderBy;
    SampleAnnotation sAnnot = new SampleAnnotation();

    public String getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    public SampleAnnotation getsAnnot() {
        return sAnnot;
    }

    public void setSAnnot(SampleAnnotation sAnnot) {
        this.sAnnot = sAnnot;
    }



     public int compare(String s1, String s2) {
         String su1 = sAnnot.getSamplePair(s1);
         String su2 = sAnnot.getSamplePair(s2);
         String g1 = sAnnot.getSampleGroup(s1);
         String g2 = sAnnot.getSampleGroup(s2);
         String t1 = sAnnot.getSampleGroupS(s1);
         String t2 = sAnnot.getSampleGroupS(s2);

        if(orderBy.equals("STG")){
         if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
         if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
         if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
         return 0;
        }
        else if (orderBy.equals("SGT")) {
         if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
         if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
         if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
         return 0;
        }
        else if (orderBy.equals("TSG")) {
         if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
            if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
         if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
         return 0;
        }
        else if (orderBy.equals("TGS")) {
         if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
         if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
         if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
         return 0;
        }
        else if(orderBy.equals("GST")){
            if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
            if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
            if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
            return 0;
        }
         else if(orderBy.equals("GTS")){
            if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
            if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
            if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
            return 0;
        }
         else if(orderBy.equals("SSGT")){
            if(s1.compareTo(s2) != 0) return s1.compareTo(s2);
            if(g1.compareTo(g2) != 0) return g1.compareTo(g2);
            if(t1.compareTo(t2) != 0) return t1.compareTo(t2);
            if(su1.compareTo(su2) != 0) return su1.compareTo(su2);
            return 0;
        }
        return s1.compareTo(s2);
    }
}
