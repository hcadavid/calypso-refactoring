/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoCommon;

import java.io.*;
import java.util.Arrays;
import java.util.Scanner;
import java.util.HashMap;
import java.util.LinkedHashSet;
import javax.servlet.http.Part;

/**
 *
 * @author lutzK
 */
public class Utils {

    String error = "";

    public void Utils() {
    }

    public static String mmToPX(String mm) {
        Integer px = Integer.parseInt(mm) * 3;
        return Integer.toString(px);
    }

    public boolean convertDataMiner(String input, String converted, String delimiter) {
        Configs configs = new Configs();

        String converter = configs.dataminer2calypso;
        String del = configs.perl + " " + converter + " " + input + " " + converted + " " + delimiter;

        String[] command = {configs.perl, converter, input, converted, delimiter};

        System.out.println("Running comand " + Arrays.toString(command) + "\n");

        try {
            Process process = Runtime.getRuntime().exec(command);
            OutputStream stdin = process.getOutputStream();
            InputStream stderr = process.getErrorStream();
            InputStream stdout = process.getInputStream();

            process.waitFor();
            System.out.println(" Done.");

            if (!(process.exitValue() == 0)) {
                System.out.println("ERROR running " + Arrays.toString(command));
                System.out.println(stderr);
                setError("ERROR running " + Arrays.toString(command));

                return false;
            }
        } catch (Exception err) {
            setError("ERROR while running " + Arrays.toString(command));

            return false;
        }
        File f = new File(converted);
        if (!f.exists()) {
            System.out.println("ERROR converting file " + f.getAbsolutePath() + " " + f.getName() + " does not exist!");
            return false;
        }

        return true;
    }

    public boolean convert(String input, String converted, String format, String taxonomy, String delimiter) {
        error = "";

        if (format.equals("dataminer")) {
            return (convertDataMiner(input, converted, delimiter));
        }

        Configs configs = new Configs();

        String option;

        String converter = configs.qiime2calypso;

        switch (format) {
            case "qmap":
                option = " -m ";
                break;
            case "qtax":
                option = " -m ";
                break;
            case "qotu":
                option = " -o ";
                break;
            case "mothur":
                option = " -u ";
                break;
            case "calypso2annot":
                option = " -c ";
                converter = configs.calypsoTools;
                break;
            case "biom":
                option = " -o ";
                break;
            default:
                setError("ERROR: unknown format " + format);
                return false;
        }

        String option2 = "";
        if (taxonomy == null || taxonomy.equals("")) {
        } else {
            option2 = "-c " + taxonomy + " ";
        }
        String command = configs.perl + " " + converter + option + option2 + input + " " + converted;

        System.out.println("Running comand " + command + "\n");

        try {
            Process process = Runtime.getRuntime().exec(command);

            System.out.println("Runtime obtained");

            System.out.println("Waiting ...");
            process.waitFor();
            System.out.println(" Done.");

            if (!(process.exitValue() == 0)) {
                System.out.println("ERROR running " + command);

                setError("ERROR running " + command);

                return false;
            }
        } catch (Exception err) {
            setError("ERROR while running " + command);

            System.out.println("Conversion failed.");

            return false;
        }
        System.out.println("Conversion completed successfully.");

        return true;
    }

    public boolean fileCopy(String from, String to) {
        File inputFile = new File(from);
        File outputFile = new File(to);

        System.out.println("Copy from " + from + " to " + to);

        FileReader in;
        FileWriter out;
        try {
            in = new FileReader(inputFile);
            out = new FileWriter(outputFile);
            int c;

            while ((c = in.read()) != -1) {
                out.write(c);
            }
            in.close();
            out.close();
        } catch (Exception ex) {
            return false;
        }

        return true;
    }

    public void setError(String e) {
        error = e;
        if (e != null) {
            System.out.println(e);
        }
    }

    public String getError() {
        return error;
    }

    public HashMap[] parseReadAnnotation(String file) {
        setError(null);

        System.out.println("Parsing read annotations. File: " + file);

        File f = new File(file);

        HashMap<String, String> map = new HashMap<>();
        HashMap<String, LinkedHashSet<String>> groups = new HashMap<String, LinkedHashSet<String>>();

        try {
            Scanner scanner = new Scanner(f);
            scanner.useDelimiter(System.getProperty("line.separator"));

            //first use a Scanner to get each line
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                //System.out.println("line: " + line);
                Scanner lSc = new Scanner(line);
                lSc.useDelimiter(",");
                String id = lSc.next().trim();
                String sample = lSc.next().trim();
                //System.out.println("id " + id + " sample " + sample);

                if (!groups.containsKey(sample)) {
                    groups.put(sample, new LinkedHashSet());
                }

                while (lSc.hasNext()) {
                    String group = lSc.next().trim();
                    //System.out.println(id + " sample:" + sample + " group:" + group);

                    if (!groups.get(sample).contains(group)) {
                        LinkedHashSet grps = groups.get(sample);
                        grps.add(group);
                        groups.put(sample, grps);
                    }
                }
                if (map.containsKey(id)) {
                    setError("Error: read " + id + " defined more than once in file " + file);
                    return null;
                }
                map.put(id, sample);
            }
            scanner.close();
        } catch (Exception err) {
            setError("Error while parsing file " + file + ": " + err.toString());
            return null;
        }
        System.out.println("Parsing rdp file " + file + " Done.");

        HashMap[] rVal = {map, groups};

        return rVal;
    }

    public boolean runRDP(String classifier, String query, String output) {
        setError(null);

        String cmd = "java -Xmx1g -jar " + classifier + " -q " + query + " -o " + output;

        OutputStream stdin = null;
        InputStream stderr = null;
        InputStream stdout = null;

        try {
            String line;
            System.out.print("Running " + cmd + "...");
            String[] c = {"/bin/sh", "-c", cmd};

            Process process = Runtime.getRuntime().exec(c);

            stdin = process.getOutputStream();
            stderr = process.getErrorStream();
            stdout = process.getInputStream();

            process.waitFor();

            System.out.println(" Done.");
            if (!(process.exitValue() == 0)) {
                System.out.println("ERROR running " + cmd);
                System.out.println(stderr);
                setError("ERROR running " + cmd);
                return false;
            }
            return true;
        } catch (Exception err) {
            setError("ERROR while running " + cmd);
            return false;
        }
    }

    public boolean validateFile(Part file) {
        error = "";

        if(file == null){
            error = "Please select a file first.";
            return false;
        }
        
        System.out.println("in validating");
        System.out.println("File name: " + file.getSubmittedFileName());
        System.out.println("Size: " + file.getSize());

        if(file.getSubmittedFileName().isEmpty()){
            error = "ERROR: No file selected.";
            return false;
        }
        
        if (file.getSize() == 0) {
            error = "ERROR: Empty file";
            return (false);
        }

        if (file.getSize() > 2000000) {
            error = "ERROR: File too big.";
            return (false);
        }
        if ("text/plain".equals(file.getContentType()) || 
                "text/csv".equals(file.getContentType())) {
        } else {
            error = "ERROR: Not a text file (" + file.getContentType() + ")";
            return (false);
        }

        return (true);
    }
}
