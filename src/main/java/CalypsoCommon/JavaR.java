    /*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import CalypsoOnline.CalypsoOConfigs;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author lutzK
 */
public class JavaR {

    String p = "";
    String errorM = "";
    String[] colors = {"blue", "red", "black", "orange", "grey", "yellow", "green", "pink", "darkred", "gold", "tan2", "darkgreen", "aquamarine4", "lightblue4", "lightgoldenrod1", "orangered", "lightsalmon2"};
    // alternative: rainbow(#colors)
    StatsMatrix statsMatrix;

    public void setError(String e) {
        errorM = e;
    }

    public String getError() {
        return errorM;
    }

    public StatsMatrix getStatsMatrix() {
        return statsMatrix;
    }

    public void setStatsMatrix(StatsMatrix statsMatrix) {
        this.statsMatrix = statsMatrix;
    }

    public String getErrorM() {
        return errorM;
    }

    public void setErrorM(String errorM) {
        this.errorM = errorM;
    }

    public String getP() {
        return p;
    }

    public void setP(String p) {
        this.p = p;
    }

    public boolean runR(ArrayList<String> cmdArray, String rOUT) {

        System.out.println("In runR");

        setError("");
        File rTMP;
        Configs conf = new Configs();

        try {
            CalypsoOConfigs configs = new CalypsoOConfigs();
            rTMP = File.createTempFile("calypso-", ".rout", new File(configs.getTempDir()));

            if (!conf.getDebug()) {
                rTMP.deleteOnExit();
            }

            // Write to temp file
            BufferedWriter outB = new BufferedWriter(new FileWriter(rTMP));

            for (String cmd : cmdArray) {
                System.out.println("Writing " + cmd + " to file " + rTMP.getPath());
                outB.write(cmd + "\n");
            }

            outB.close();

        } catch (IOException e) {
            String errM = "ERROR while writing to file";
            System.out.println(errM);
            setError(errM);
            return false;
        }
        Configs configs = new Configs();
        String command;
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            //   command = configs.getR() + " --slave --vanilla  " + rTMP.getAbsolutePath().replace("\\", "/") ;

            command = configs.getR() + " --slave --vanilla  " + rTMP.getAbsolutePath().replace("/", "\\");
        } else {
            command = configs.getR() + " --slave --vanilla < " + rTMP.getAbsolutePath() + " > " + rOUT + " 2>> /var/tmp/rlog.log";
        }

        command = "nice -n 1 " + command;

        System.out.println("Running comand " + command + "\n");

        OutputStream stdin = null;
        InputStream stderr = null;
        InputStream stdout = null;

        try {
            Process process;
            if (operating_system.contains("windows")) {
                process = Runtime.getRuntime().exec(command);
            } else {
                String[] c = {"/bin/sh", "-c", command};
                process = Runtime.getRuntime().exec(c);
            }

            stdin = process.getOutputStream();
            stderr = process.getErrorStream();
            stdout = process.getInputStream();

            process.waitFor();
            System.out.println(" Done.");

            if (!conf.getDebug()) {
                rTMP.delete();
            }

            if (!(process.exitValue() == 0)) {
                System.out.println("ERROR running " + command);
                //System.out.println(stderr);
                setError("ERROR running " + command);

                return false;
            }
        } catch (Exception err) {
            System.out.println("ERROR while running " + command);
            setError("ERROR while running " + command);
            if (!conf.getDebug()) {
                rTMP.delete();
            }
            return false;
        }
        return true;
    }

    public boolean factorAnalysis(String matrixFile, String annotFile,
            String chartFile1, String chartFile2, String factorMatrix,
            String factorFile,
            Integer factors,
            Integer width, Integer height, Integer res, String title,
            String level, String method) {

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();

        ArrayList cmd = new ArrayList();
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\")");

        String cal = "T";
        if (configs.isDataMiner()) {
            cal = "F";
        }

        String c = "r<-c.FactorAnalysis(cal,\"" + chartFile1 + "\",\""
                + chartFile2 + "\",basisFile=\"" + factorMatrix
                + "\",coefFile=\"" + factorFile + "\",factors=" + factors
                + ",width=" + width
                + ",height=" + height + ",res=" + res
                + ",title=\"" + title
                + "\",level=\"" + level
                + "\",calypso=" + cal + ",method=\"" + method + "\")";

        cmd.add(c);
        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean taxaChart(String matrixFile, String annotFile, String out, String orderBy,
            int taxFilter, String color, Boolean transpose, Boolean beside, String type,
            int width, int height, int resolution, Boolean reOrder, String title,
            String groupS, String figureFormat, Boolean legend,
            Double signLevel, Boolean scale, Double trim, Boolean relative,
            Double colorCenter) {
        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        String trans = "F";
        if (transpose) {
            trans = "T";
        }

        String bes = "F";
        if (beside) {
            bes = "T";
        }

        String reOrd = "F";
        if (reOrder) {
            reOrd = "T";
        }

        String scaleO = "T";
        if (!scale) {
            scaleO = "F";
        }

        String er = "G";

        if (orderBy.startsWith("S")) {
            er = "P";
        } else if (orderBy.startsWith("T")) {
            er = "T";
        }

        String le = "T";

        if (!legend) {
            le = "F";
        }

        String cc = colorCenter.toString();
        if (colorCenter == 0.0) {
            cc = "NA";
        }

        Utils ut = new Utils();

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\",taxFilter=" + taxFilter
                + ",color=\"" + color + "\",time=\"" + groupS + "\")");

        if (relative) {
            cmd.add("c<-c.norm(c,method=\"none\",relative=T)");
        }

        cmd.add("r<-taxa.chart(c,\"" + out + "\",\"" + type + "\",\"" + color + "\","
                + trans + "," + bes + ","
                + width + "," + height + "," + resolution + ","
                + reOrd + ",\"" + title + "\",orderBy=\"" + orderBy
                + "\",er=\"" + er
                + "\",figureFormat=\"" + figureFormat + "\",legend=" + le
                + ",p=" + signLevel + ",scale=" + scaleO + ",trim=" + trim
                + ",center=" + cc + ")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean checkDist(String matrixFile, String annotFile, String dist) {
        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            cmd.add("c<-calypso(\"" + matrixFile.replace("\\", "/") + "\",\"" + annotFile.replace("\\", "/")
                    + "\",dist=\"" + dist.replace("\\", "/") + "\")");
        } else {
            cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile
                    + "\",dist=\"" + dist + "\")");
        }

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean svm(String matrixFile, String annotFile, String out,
            int taxFilter, String color, int width, int height,
            int resolution, String title, String groupBy) {
        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            cmd.add("cal<-calypso(\"" + matrixFile.replace("\\", "/") + "\",\"" + annotFile.replace("\\", "/")
                    + "\",taxFilter=" + taxFilter + ",color=\"" + color + "\")");
        } else {
            cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile
                    + "\",taxFilter=" + taxFilter + ",color=\"" + color + "\")");
        }

        cmd.add("r<-c.svm(cal,out=\"" + out + "\",groupBy=\"" + groupBy + "\")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean summary(String matrixFile, String annotFile, String out, String color, String type, int width, int height, int resolution, String title, String groupS, boolean logScale, boolean boxplot) {
        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        String log = "F";
        if (logScale) {
            log = "T";
        }

        String box = "F";

        if (boxplot) {
            box = "T";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            cmd.add("c<-calypso(\"" + matrixFile.replace("\\", "/") + "\",\"" + annotFile.replace("\\", "/")
                    + "\",color=\"" + color + "\",time=\"" + groupS + "\")");
        } else {
            cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile
                    + "\",color=\"" + color + "\",time=\"" + groupS + "\")");
        }

        cmd.add("r<-calypso.summary(c,\"" + out + "\",\"" + type + "\",T,\""
                + color + "\"," + width + "," + height + "," + resolution + ",\"" + title + "\",log=" + log + ",box=" + box + ")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean stripChart(String matrixFile, String annotFile, String out, int taxFilter, String color,
            Boolean log, int width, int height, int res, boolean vertical, boolean grid,
            String groupMode, String taxa, String groupS, String figureFormat) {
        File file = new File(matrixFile);

        // Get the number of bytes in the file
        long length = file.length();

        if (length > 5000000) {
            String err = "ERROR: input file too large to generate stripChart";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;

        }

        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        String loga = "F";

        if (log) {
            loga = "T";
        }

        String horiz = "T";
        if (vertical) {
            horiz = "F";
        }

        String tString = "";

        if (taxa != null) {
            tString = "taxa=\"" + taxa + "\"";
        }

        String plotGrid = "T";

        if (!grid) {
            plotGrid = "F";
        }

        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        cmd.add("source(\"" + configs.getRCharts() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            cmd.add("cal<-calypso(\"" + matrixFile.replace("\\", "/") + "\",\"" + annotFile.replace("\\", "/")
                    + "\",taxFilter=" + taxFilter + ",color=\"" + color + "\")");
        } else {
            cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile
                    + "\",taxFilter=" + taxFilter + ",color=\"" + color + "\")");
        }

        cmd.add("r<-taxa.stripchart(cal,\"" + out + "\",\"" + color + "\"," + loga + ","
                + horiz + "," + plotGrid + "," + height + "," + width + "," + res
                + ",figureFormat=\"" + figureFormat + "\")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean rankPlot(String matrixFile, String annotFile, String out, int taxFilter, double signLevel, String color,
            Boolean log, int width, int height, int res, boolean vertical, boolean grid,
            String groupMode, String taxa, String groupS, String title,
            String type, String figureFormat) {

        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        String loga = "F";

        if (log) {
            loga = "T";
        }

        String horiz = "T";
        if (vertical) {
            horiz = "F";
        }

        String tString = "";

        if (taxa != null) {
            tString = ",taxa=\"" + taxa + "\"";
        }

        String plotGrid = "T";

        if (!grid) {
            plotGrid = "F";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }

        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\")");

        cmd.add("r<-rankPlot(cal,\"" + out + "\",\"" + color + "\"," + height + ","
                + width + "," + res + ",title=\"" + title + "\",type=\""
                + type + "\",figureFormat=\"" + figureFormat + "\",groupBy=\"" + groupMode
                + "\",sign=" + signLevel + ")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R ";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean diversityChart(String matrixFile, String annotFile, String orderBy,
            String out, String color, String colorBy, String type,
            String index, String title, boolean unclassified, int width, int height,
            int res, String groupS, String figureFormat) {

        p = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        String outP = co.tempFile(".csv");

        String uncl = "F";

        if (unclassified) {
            uncl = "T";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
            outP = outP.replace("\\", "/");
        }

        cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",taxFilter=0,color=\"" + color + "\",colorBy=\"" + colorBy
                + "\",time=\"" + groupS + "\",unclassified=" + uncl + ")");

        String c = "r<-getDiversity(c,\"" + out + "\",\"" + outP + "\",\""
                + index + "\",\"" + title + "\"," + width + "," + height + "," + res
                + ",plot=\"" + type + "\",color=\"" + color + "\",groupBy=\"" + colorBy
                + "\",orderBy=\"" + orderBy + "\",figureFormat=\"" + figureFormat + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        // parse p
        File f = new File(outP);
        f.deleteOnExit();

        if (type.equals("box")) {
            try {
                Scanner scanner = new Scanner(f);
                scanner.useDelimiter("\n");
                //first use a Scanner to get each line

                // get first line
                scanner.nextLine();

                String line = scanner.nextLine();
                String[] fields = line.split(",");

                if (fields.length != 2) {
                    String message = "ERROR wrong format, expecting 2 line elements.";
                    this.setError(message);
                    return false;
                }

                p = fields[1].trim();
                scanner.close();
            } catch (Exception err) {
                setError("parseCounts: Error while parsing p-value file " + f.getName() + err.toString());
                return false;
            }
        }
        f.delete();
        return true;
    }

    public boolean regression(String matrixFile, String annotFile, int taxFilter,
            String out, String outList, String outRegression, String color, String title,
            int width, int height, int res, String groupS, String taxa, String groupMode,
            String groupA, String groupB, boolean paired, String index,
            String distance, String timeBy, String corIndex) {
        p = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        if (!taxa.equals("all")) {
            taxFilter = 0;
        }

        if (paired && groupMode.equals("taxa")) {
            groupMode = "taxaLMEM";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        String gA = "NA";
        String gB = "NA";

        if (groupMode.equals("group") | groupMode.equals("pair")
                | groupMode.equals("time")
                | (paired
                && (groupMode.equals("taxa") | groupMode.equals("diversity")
                | groupMode.equals("distance") | groupMode.equals("diversityDist")))) {
            gA = "\"" + groupA + "\"";
            gB = "\"" + groupB + "\"";
        }

        String pa = "F";

        if (paired) {
            pa = "T";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
            distance = distance.replace("\\", "/");
        }

        cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\")");

        String c = "r<-regression(c,\"" + out + "\",\"" + title + "\"," + width + ","
                + height + "," + res + ",color=\"" + color + "\",taxa=\"" + taxa
                + "\",outCoef=\"" + outRegression + "\",outList=\"" + outList
                + "\",gA=" + gA + ",gB=" + gB + ",rby=\"" + groupMode + "\",paired=" + pa
                + ",index=\"" + index + "\""
                + ",dist=\"" + distance + "\",timeBy=\"" + timeBy + "\",corIndex=\"" + corIndex + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean pairwise(String matrixFile, String annotFile, int taxFilter,
            String plotFile, String color, String type, String test,
            String alternative, String index, String title, Boolean label,
            Boolean legend, String firstT, String secondT, String thirdT,
            String fourthT, String taxa, int width, int height, int res) {
        p = "";
        statsMatrix = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        String outP = co.tempFile(".csv");

        String lab = "F";

        if (label) {
            lab = "T";
        }

        String leg = "F";

        if (legend) {
            leg = "T";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
            outP = outP.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\",taxFilter=" + taxFilter
                + ",color=\"" + color + "\")");

        String c = "r<-c.pairwise(cal,\"" + plotFile + "\",\"" + outP
                + "\",tA=\"" + firstT + "\",tB=\"" + secondT + "\",tC=\""
                + thirdT + "\",tD=\"" + fourthT + "\",type=\"" + type
                + "\",index=\"" + index + "\",test=\"" + test + "\",color=\""
                + color + "\",title=\"" + title + "\",tax=\"" + taxa + "\",labels="
                + lab + ",legend=" + leg + "," + width + "," + height + ","
                + res + ",alternative=\"" + alternative + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        if (type.equals("table") || type.equals("table3")) {
            StatsMatrix matrix = new StatsMatrix();

            if (!matrix.parseRPairwiseStats(outP, type)) {
                String err = "ERROR pairwise parsing R output " + outP;
                System.out.println(err);
                this.setError(this.getError() + " " + err);
                return false;
            }

            File f = new File(outP);
            f.deleteOnExit();

            statsMatrix = matrix;
        } else if (type.equals("taxas")) {
            // parse p
            File f = new File(outP);
            f.deleteOnExit();

            try {
                Scanner scanner = new Scanner(f);
                scanner.useDelimiter("\n");
                //first use a Scanner to get each line

                // get header line
                scanner.nextLine();

                while (scanner.hasNext()) {
                    String line = scanner.nextLine();
                    String[] fields = line.split(",");

                    if (fields.length != 3) {
                        String message = "ERROR wrong format, expecting 3 line elements.";
                        this.setError(message);
                        return false;
                    }
                    String group = fields[1].trim();
                    String pvalue = fields[2].trim();

                    p = p + group + " p=" + pvalue + "; ";
                }
            } catch (Exception err) {
                setError("parseCounts: Error while parsing p-value file " + f.getName() + err.toString());
                return false;
            }
        }

        File f = new File(outP);
        f.delete();
        return true;
    }

    public boolean rarefaction(String matrixFile, String annotFile,
            String plotFile, String color, String title, String colorBy,
            int width, int height, int res) {
        p = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        System.out.println("Width: " + width);

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }

        cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",color=\"" + color + "\")");

        String c = "r<-rarefaction(c,pngFile=\"" + plotFile + "\",width="
                + width + ",height=" + height + ",res=" + res + ",rank=\"" + title
                + "\",groupBy=\"" + colorBy + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean correlationplot(String matrixFile, String annotFile, int taxFilter,
            String type,
            String orderBy, String outFile, String color, String title, int width,
            int height, int res, String corIndex, String figureFormat,
            String first, String second, String third) {
        p = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        color = "heat";

        String grid = "c(" + 3 + "," + 2 + ")";

        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\",taxFilter=" + taxFilter + ",color=\"" + color
                + "\")");
        String c = "r<-correlationplot(cal,\"" + outFile + "\",\"" + color + "\",\""
                + title + "\"," + width + "," + height + "," + res + ",type=\"" + type
                + "\",method=\"" + corIndex + "\",orderBy=\"" + orderBy
                + "\",figureFormat=\""
                + figureFormat + "\",grid=" + grid + ",first=\"" + first
                + "\",second=\"" + second + "\",third=\"" + third
                + "\")";

        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean correlation(String matrixFile, String annotFile, int taxFilter,
            String type,
            String orderBy, String outFile, String color, String title, int width,
            int height, int res, Double minSim, int vSize, String corIndex, Boolean corLayout,
            Boolean avoidOverlap, String corMatrix, String layoutMatrix,
            String abundanceMatrix, String figureFormat, String nodeX, String nodeY) {
        p = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        String lbd = "T";

        if (!corLayout) {
            lbd = "F";
        }
        String aol = "F";
        if (avoidOverlap) {
            aol = "T";
        }

        String grid = "c(" + nodeX + "," + nodeY + ")";

        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\",taxFilter=" + taxFilter + ",color=\"" + color
                + "\")");

        String c = "r<-correlation(cal,\"" + outFile + "\",\"" + color + "\",\""
                + title + "\"," + width + "," + height + "," + res + ",type=\"" + type
                + "\",minSim=" + minSim + ",lbd=" + lbd + ",vSize=" + vSize
                + ",method=\"" + corIndex + "\",orderBy=\"" + orderBy
                + "\",avoidOverlap=" + aol + ",corMatrix=\"" + corMatrix
                + "\",layoutMatrix=\"" + layoutMatrix
                + "\",abundanceMatrix=\"" + abundanceMatrix + "\",figureFormat=\""
                + figureFormat + "\",grid=" + grid + ")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean multivariat(String matrixFile, String plotType, String plotFile,
            String annotFile, String ccaTableFile,
            int taxFilter, String orderBy, String colorBy, String color, String type,
            String method, String title, Boolean scale, int width, int height, int res,
            Boolean legend, String groupS, Boolean label,
            Boolean loadings, String firstC, String secondC,
            Double minSim, int vSize, String figureFormat, String hull,
            String symbolBy, String dist) {
        p = null;

        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        if (dist.equals("")) {
            dist = "NULL";
        } else {
            dist = "\"" + dist + "\"";
        }

        Configs configs = new Configs();
        CalypsoOConfigs co = new CalypsoOConfigs();

        String sc = "F";

        if (scale) {
            sc = "T";
        }

        String sl = "F";

        if (legend) {
            sl = "T";
        }

        String lab = "F";

        if (label) {
            lab = "T";
        }

        String lod = "F";

        if (loadings) {
            lod = "T";
        }

        String components = "c(" + firstC + "," + secondC + ")";

        String colorlegend = "F";
        String grpS = "T";

        if (colorBy.equals("response")) {
            colorlegend = "T";
            sl = "F";
            grpS = "F";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
            dist = dist.replace("\\", "/");
        }
        cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\",dist=" + dist + ")");
        String c = "r<-multivariat(c,\"" + plotFile + "\",type=\"" + plotType + "\",color=\"" + color
                + "\",method=\"" + method + "\",title=\"" + title + "\",loadings=" + lod
                + ",labels=" + lab + "," + width + "," + height + "," + res + ",scale=" + sc
                + ", components=" + components + ",colorlegend=" + colorlegend + ",legend=" + sl
                + ",groupSymbols=" + grpS + ",minSim=" + minSim + ",vSize=" + vSize
                + ",groupBy=\"" + colorBy + "\",ccaTableFile=\"" + ccaTableFile
                + "\",figureFormat=\"" + figureFormat + "\",hull=\"" + hull + "\",symbolBy=\"" + symbolBy
                + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean globalGroupComparison(String matrixFile, String annotFile,
            String statsFile, String distFile,
            String corFile, int taxFilter, String title, int width, int height,
            int res, String groupMode, String distMethod,
            String groupS, boolean chis) {

        Configs configs = new Configs();

        ArrayList cmd = new ArrayList();
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",time=\"" + groupS
                + "\",taxFilter=" + taxFilter + ")");

        String chi = "F";

        if (chis) {
            chi = "T";
        }

        String c = "r<-global.group.difference(cal,\"" + statsFile + "\",\""
                + distFile + "\",\"" + corFile + "\",method=\"" + distMethod
                + "\",title=\"" + title + "\"," + width + "," + height + "," + res
                + ",groupBy=\"" + groupMode + "\",chis=" + chi + ")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean anosim(String matrixFile, String annotFile,
            String out, int taxFilter, int width, int height,
            int res, String groupMode, String distMethod,
            String groupS, String figureFormat) {

        Configs configs = new Configs();

        ArrayList cmd = new ArrayList();
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",time=\"" + groupS
                + "\",taxFilter=" + taxFilter + ")");

        String c = "r<-c.anosim(cal,\"" + out + "\",method=\"" + distMethod
                + "\",width=" + width + ",height=" + height + ",res=" + res
                + ",groupBy=\"" + groupMode + "\",figureFormat=\"" + figureFormat + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean distplot(String matrixFile, String annotFile,
            String out, int taxFilter, int width, int height,
            int res, String groupMode, String distMethod,
            String groupS, String figureFormat, String dist) {

        Configs configs = new Configs();

        if (dist.equals("")) {
            dist = "NULL";
        } else {
            dist = "\"" + dist + "\"";
        }

        ArrayList cmd = new ArrayList();
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
            dist = dist.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",time=\"" + groupS
                + "\",taxFilter=" + taxFilter + ",dist=" + dist + ")");

        String c = "r<-c.distplot(cal,\"" + out + "\",method=\"" + distMethod
                + "\",width=" + width + ",height=" + height + ",res=" + res
                + ",groupBy=\"" + groupMode + "\",figureFormat=\"" + figureFormat + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean normalize(String matrixFile, String annotFile, String normFile,
            String normFileAnnot, String method, boolean relative, String minFrac) {

        Configs configs = new Configs();

        String rel = "F";
        if (relative) {
            rel = "T";
        }

        ArrayList cmd = new ArrayList();
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();

        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
            normFile = normFile.replace("\\", "/");
            normFileAnnot = normFileAnnot.replace("\\", "/");
        }

        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\")");

        cmd.add("cal<-c.norm(cal,\"" + method + "\",relative=" + rel
                + ",minFrac=" + minFrac + ")");

        cmd.add("calypso2csv(cal,\"" + normFile + "\",calypso=F)");

        cmd.add("calypso2csv(cal,\"" + normFileAnnot + "\",annot=T,calypso=F)");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R ";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return (true);
    }

    public boolean groupChart(String matrixFile, String annotFile,
            String chartFile, String statsFile, String distFile, String corFile,
            int taxFilter, double signLevel, String color, Boolean log, String type, Boolean vertical,
            Boolean grid, String title, int width, int height, int res, String groupMode,
            String taxa, String groupS,
            String distMethod, String figureFormat, double coreMin,
            boolean tss, String dist) {

        // do pairwise comparison
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }

        System.out.println("groupChart " + type + " " + taxa);

        switch (type) {
            case "strip":
                return this.stripChart(matrixFile, annotFile, chartFile, taxFilter, color, log, width, height, res,
                        vertical, grid, groupMode, taxa, groupS, figureFormat);
            case "rankplot":
                return this.rankPlot(matrixFile, annotFile, chartFile, taxFilter, signLevel, color,
                        log, width, height, res,
                        vertical, grid, groupMode, taxa, groupS, title, type, figureFormat);
            case "aovplot":
                return this.rankPlot(matrixFile, annotFile, chartFile, taxFilter, signLevel, color, log, width, height, res,
                        vertical, grid, groupMode, taxa, groupS, title, type, figureFormat);
            case "nestedanova":
                return this.rankPlot(matrixFile, annotFile, chartFile, taxFilter, signLevel, color, log, width, height, res,
                        vertical, grid, groupMode, taxa, groupS, title, type, figureFormat);
            case "bubble":
                return this.bubbleMedianPlot(matrixFile, annotFile, chartFile, taxFilter, color, log,
                        vertical, grid, title, height, width, res, groupMode, taxa, groupS,
                        figureFormat);
            case "barchart":
                return this.barchartMedianPlot(matrixFile, annotFile, chartFile, taxFilter, color, log,
                        vertical, grid, title, height, width, res, groupMode, taxa, groupS,
                        figureFormat);
            case "anosim":
                return this.anosim(matrixFile, annotFile, chartFile,
                        taxFilter, width, height, res, groupMode,
                        distMethod, groupS, figureFormat);
            case "distplot":
                return this.distplot(matrixFile, annotFile, chartFile,
                        taxFilter, width, height, res, groupMode,
                        distMethod, groupS, figureFormat, dist);
            case "globalStats":
                return this.globalGroupComparison(matrixFile, annotFile, statsFile, distFile,
                        corFile, taxFilter, title, width, height, res, groupMode,
                        distMethod, groupS, false);
            case "globalStatsChis":
                return this.globalGroupComparison(matrixFile, annotFile, statsFile, distFile,
                        corFile, taxFilter, title, width, height, res, groupMode,
                        distMethod, groupS, true);
            case "core":
                return this.venndiagram(matrixFile, annotFile, chartFile, statsFile, taxFilter, coreMin, color, log, grid, title, height, width, res,
                        groupMode, groupS, figureFormat);
            default:
                return this.boxPlot(matrixFile, annotFile, chartFile, taxFilter, signLevel, color, log,
                        vertical, grid, title, height, width, res, groupMode, taxa, groupS,
                        type, figureFormat, tss);
        }
    }

    public boolean venndiagram(String matrixFile, String annotFile, String out, String outtable, int taxFilter,
            double coreMin, String color, Boolean log, Boolean grid, String title,
            int height, int width, int res, String groupMode, String groupS, String figureFormat) {
        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();

        String loga = "F";

        if (log) {
            loga = "T";
        }

        String plotGrid = "T";

        if (!grid) {
            plotGrid = "F";
        }

        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\",colorBy=\"" + groupMode + "\")");

        String c = "r<-coreAnalysis(cal,\"" + out + "\",\"" + outtable + "\",\"" + color + "\","
                + plotGrid + ",\"" + title + "\"," + width + ","
                + height + "," + res + ",coreMin=" + coreMin + ",groupBy=\"" + groupMode
                + "\",figureFormat=\"" + figureFormat + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;

    }

    public boolean boxPlot(String matrixFile, String annotFile, String out, int taxFilter,
            double signLevel, String color, Boolean log, Boolean vertical, Boolean grid, String title,
            int height, int width, int res, String groupMode, String taxa, String groupS,
            String type, String figureFormat, boolean relative) {
        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();

        String loga = "F";

        if (log) {
            loga = "T";
        }

        String plotGrid = "T";

        if (!grid) {
            plotGrid = "F";
        }

        String tString = "";

        if (taxa != null) {
            tString = ",tax=\"" + taxa + "\"";
            taxFilter = 0;
        }

        System.out.println("title: " + title);

        String horiz = "T";
        if (vertical) {
            horiz = "F";
        }

        String stripchart = "F";

        if (type.equals("stripchart")) {
            stripchart = "T";
        }

        double sl = 1;

        if (type.equals("rankbox")) {
            sl = signLevel;
        }

        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\",colorBy=\"" + groupMode + "\")");

        if (relative) {
            cmd.add("cal<-c.norm(cal,method=\"none\",relative=T)");
        }

        String c = "r<-taxa.boxplot(cal,\"" + out + "\",\"" + color + "\","
                + loga + "," + horiz + "," + plotGrid + ",\"" + title + "\"," + width + ","
                + height + "," + res + ",groupBy=\"" + groupMode + "\",p=" + sl
                + ",figureFormat=\"" + figureFormat + "\",stripchart=" + stripchart
                + tString + ")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean normalizeChart(String matrixFile, String annotFile,
            String chartFile1, String chartFile2,
            String orderBy, String normalization, boolean tss,
            int width, int height, int res, String title,
            String outCSV, String level) {

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();

        String tssS = "F";

        if (tss) {
            tssS = "T";
        }

        ArrayList cmd = new ArrayList();
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\")");

        String cal = "T";
        if (configs.isDataMiner()) {
            cal = "F";
        }

        String c = "r<-c.normChart(cal,\"" + chartFile1
                + "\",method=\"" + normalization
                + "\",tss=" + tssS
                + ",width=" + width
                + ",height=" + height + ",res=" + res
                + ",title=\"" + title + "\",orderBy=\"" + orderBy
                + "\",level=\"" + level
                + "\",csv=\"" + outCSV + "\",calypso=" + cal + ")";

        cmd.add(c);
        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean barchartMedianPlot(String matrixFile, String annotFile, String out,
            int taxFilter, String color, Boolean log, Boolean vertical, Boolean grid,
            String title, int height, int width, int res, String groupMode, String taxa,
            String groupS, String figureFormat) {
        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();

        String loga = "F";

        if (log) {
            loga = "T";
        }

        String plotGrid = "T";

        if (!grid) {
            plotGrid = "F";
        }

        String tString = "";

        if (taxa != null) {
            tString = ",taxa=\"" + taxa + "\"";
            taxFilter = 0;
        }

        System.out.println("title: " + title);

        String horiz = "T";
        if (vertical) {
            horiz = "F";
        }

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\",colorBy=\"" + groupMode + "\")");

        String c = "r<-taxa.chart(cal,\"" + out + "\",\"bar\",\"" + color
                + "\",width=" + width + ",height=" + height + ",res=" + res
                + ",title=\"" + title + "\",er=\"N\",medianPlot=T,groupBy=\"" + groupMode
                + "\",figureFormat=\"" + figureFormat + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean bubbleMedianPlot(String matrixFile, String annotFile, String out,
            int taxFilter, String color, Boolean log, Boolean vertical, Boolean grid,
            String title, int height, int width, int res, String groupMode, String taxa,
            String groupS, String figureFormat) {
        ArrayList cmd = new ArrayList();

        if (title == null) {
            title = "";
        }

        Configs configs = new Configs();

        String loga = "F";

        if (log) {
            loga = "T";
        }

        String plotGrid = "T";

        if (!grid) {
            plotGrid = "F";
        }

        String tString = "";

        if (taxa != null) {
            tString = ",taxa=\"" + taxa + "\"";
            taxFilter = 0;
        }

        System.out.println("title: " + title);

        String horiz = "T";
        if (vertical) {
            horiz = "F";
        }

        Utils ut = new Utils();
        //     ut.fileCopy(matrixFile, "~/matrixBox.csv");

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\""
                + ",taxFilter=" + taxFilter + ",color=\"" + color
                + "\",time=\"" + groupS + "\",colorBy=\"" + groupMode + "\")");

        String c = "r<-taxa.chart(cal,\"" + out + "\",\"bubble\",\"" + color
                + "\",width=" + width + ",height=" + height + ",res=" + res
                + ",er=\"N\",medianPlot=T,groupBy=\"" + groupMode
                + "\",figureFormat=\"" + figureFormat
                + "\")";
        cmd.add(c);

        System.out.println("Running " + c);

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R " + c;
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public Boolean doStats(String matrixFile, String annotFile, String histFile,
            String test, String out, String title, int taxFilter, String groupBy,
            String groupS) {

        statsMatrix = null;

        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        String errorFile = configs.tempFile(".txt");

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        cmd.add("source(\"" + configs.getRCyberT() + "\")");

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\",taxFilter=" + taxFilter + ",time=\"" + groupS
                + "\",colorBy=\"" + groupBy + "\",errorM=\""
                + errorFile + "\")");

        cmd.add("cal<-c.setGroups(cal,groupBy=\"" + groupBy + "\")");

        cmd.add("r<-taxa.test.matrix(cal,\"" + out + "\",\"" + histFile
                + "\",title=\"" + title + "\""
                + ",test=\"" + test + "\")");

        if (!runR(cmd, "/dev/null")) {
            String err = parseError(errorFile);
            if (err == null) {
                err = "ERROR running R";
            }
            System.out.println(err);
            this.setError(err);
            return false;
        }

        if (test.contains("anova+")) {
            return (true);
        }

        StatsMatrix matrix = new StatsMatrix();

        if (test.equals("aldex")) {
            if (!matrix.parseData(out)) {
                String err = "ERROR parsing aldex output";
                System.out.println(err);
                this.setError(this.getError() + " " + err);
                return false;
            }
        } else {
            if (!matrix.parseRStats(out)) {
                String err = "ERROR parsing R output";
                System.out.println(err);
                this.setError(this.getError() + " " + err);
                return false;
            }
        }
        statsMatrix = matrix;

        return true;
    }

    private ArrayList initCMD(boolean cyberT) {
        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        //String out = configs.tempFileName("csv");
        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");

        if (cyberT) {
            cmd.add("source(\"" + configs.getRCyberT() + "\")");
        }

        return cmd;
    }

    public Boolean doBiomarker(String matrixFile, String annotFile, String histFile,
            String orFile, String test, String out, String title, int taxFilter, String groupBy,
            boolean inverseOR) {

        String iOR = "F";
        if (inverseOR) {
            iOR = "T";
        }

        ArrayList cmd = initCMD(true);

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\",taxFilter=" + taxFilter
                + ",colorBy=\"" + groupBy + "\")");

        cmd.add("r<-biomarker(cal,\"" + out + "\",histFile=\"" + histFile
                + "\",orFile=\"" + orFile + "\",groupBy=\"" + groupBy
                + "\",invertGroups=" + iOR
                + ",test=\"" + test + "\")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public Boolean doFeatureSelection(String matrixFile, String annotFile,
            String method, String out, String title, int taxFilter, String groupBy,
            int top, String direction, String corIndex) {

        ArrayList cmd = initCMD(true);

        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }
        cmd.add("cal<-calypso(\"" + matrixFile + "\",\"" + annotFile + "\",taxFilter=" + taxFilter
                + ",colorBy=\"" + groupBy + "\")");

        cmd.add("r<-feature.selection(cal,\"" + out + "\",direction=\"" + direction + "\",top=" + top
                + ",corIndex=\"" + corIndex + "\",rby=\"" + groupBy
                + "\",method=\"" + method + "\")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }

        return true;
    }

    public boolean writeNormA(String matrixFile, String annotFile, int taxFilter, String orderBy, String groupBy, String out, String level) {
        ArrayList cmd = new ArrayList();

        Configs configs = new Configs();

        String er = "group";

        if (groupBy.equals("group")) {
            er = "group";
        } else if (groupBy.equals("time")) {
            er = "time";
        }

        Utils ut = new Utils();

        cmd.add("source(\"" + configs.getRCharts() + "\")");
        cmd.add("source(\"" + configs.getRCalypso() + "\")");
        String operating_system = System.getProperty("os.name").toLowerCase();
        if (operating_system.contains("windows")) {
            matrixFile = matrixFile.replace("\\", "/");
            annotFile = annotFile.replace("\\", "/");
        }

        cmd.add("c<-calypso(\"" + matrixFile + "\",\"" + annotFile
                + "\",taxFilter=" + taxFilter
                + ")");

        cmd.add("c<-c.norm(c,method=\"none\",relative=T)");

        cmd.add("r<-writeAnorm(c,\"" + out + "\",\"" + orderBy
                + "\",er=\"" + er + "\")");

        if (!runR(cmd, "/dev/null")) {
            String err = "ERROR running R";
            System.out.println(err);
            this.setError(this.getError() + " " + err);
            return false;
        }
        return true;
    }

    public String parseError(String fileName) {
        File file = new File(fileName);

        if (!file.exists()) {
            return (null);
        }

        try {
            Scanner input = new Scanner(file);

            String line = "";
            if (input.hasNext()) {
                line = input.nextLine();
            }
            input.close();
            return (line);
        } catch (FileNotFoundException e) {
            return ("ERROR parsing error file");
        }
    }
}
