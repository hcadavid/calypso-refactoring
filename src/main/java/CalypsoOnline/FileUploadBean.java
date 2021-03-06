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

import CalypsoCommon.Utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;

import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.myfaces.custom.fileupload.UploadedFile;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "FileUploadBean")
@SessionScoped
public class FileUploadBean {

    private Part countsFile;
    private Part annotationFile;
    private Part taxFile;
    private Part distFile;

    private UploadedFile countsFileUF;
    private UploadedFile annotationFileUF;
    private UploadedFile taxFileUF;
    private UploadedFile distFileUF;

    private String warnings = "";

    private String taxFilter = "0.5";

    private boolean relative = true;
    private String normalization = "sqrt";
    private String meanFilter = "0.0";

    private String format = "";
    private String tax = "";
    private String taxSelection = "NoTax";
    private String delimiter = ",";
    private String distDelimiter = "\t";
    private String filtertaxa = "None";
    private Boolean taxMode = true;
    private boolean visibilityDelimiterMode = false;
    private final Configs config;
    private final CalypsoOConfigs configOL;
    private final Utils utils;

    public FileUploadBean() {
        this.utils = new Utils();
        config = new Configs();
        configOL = new CalypsoOConfigs();

        if (config.isDataMiner()) {
            taxFilter = "0.0";

            relative = false;
            normalization = "none";
            taxSelection = "NoTax";
            filtertaxa = "None";
        }
    }

    public String getWarnings() {
        return warnings;
    }

    public void setWarnings(String warnings) {
        this.warnings = warnings;
    }

    public boolean isRelative() {
        return relative;
    }

    public void setRelative(boolean relative) {
        this.relative = relative;
    }

    public String getNormalization() {
        return normalization;
    }

    public void setNormalization(String normalization) {
        this.normalization = normalization;
    }

    public String getMeanFilter() {
        return meanFilter;
    }

    public void setMeanFilter(String meanFilter) {
        this.meanFilter = meanFilter;
    }

    public String getDelimiter() {
        return delimiter;
    }

    public void setDelimiter(String delimiter) {
        this.delimiter = delimiter;
    }

    public String getDistDelimiter() {
        return distDelimiter;
    }

    public void setDistDelimiter(String distDelimiter) {
        this.distDelimiter = distDelimiter;
    }

    public String getFiltertaxa() {
        return filtertaxa;
    }

    public void setFiltertaxa(String filtertaxa) {
        this.filtertaxa = filtertaxa;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public Part getAnnotationFile() {
        System.out.println("getAnnotationFile");
        return annotationFile;
    }

    public void setAnnotationFile(Part annotationFile) {
        System.out.println("setting annotation file ....");
        this.annotationFile = annotationFile;
    }

    public Part getCountsFile() {
        return countsFile;
    }

    public void setCountsFile(Part countsFile) {
        this.countsFile = countsFile;
    }

    public UploadedFile getCountsFileUF() {
        return countsFileUF;
    }

    public void setCountsFileUF(UploadedFile countsFileUF) {
        this.countsFileUF = countsFileUF;
    }

    public UploadedFile getAnnotationFileUF() {
        return annotationFileUF;
    }

    public void setAnnotationFileUF(UploadedFile annotationFileUF) {
        this.annotationFileUF = annotationFileUF;
    }

    public UploadedFile getTaxFileUF() {
        return taxFileUF;
    }

    public void setTaxFileUF(UploadedFile taxFileUF) {
        this.taxFileUF = taxFileUF;
    }

    public UploadedFile getDistFileUF() {
        return distFileUF;
    }

    public void setDistFileUF(UploadedFile distFileUF) {
        this.distFileUF = distFileUF;
    }

    public Part getDistFile() {
        return distFile;
    }

    public void setDistFile(Part distFile) {
        this.distFile = distFile;
    }

    public Part getTaxFile() {
        return taxFile;
    }

    public void setTaxFile(Part taxFile) {
        this.taxFile = taxFile;
    }

    public String getTaxFilter() {
        return taxFilter;
    }

    public void setTaxFilter(String taxFilter) {
        this.taxFilter = taxFilter;
    }

    public String getTax() {
        return tax;
    }

    public void setTax(String tax) {
        this.tax = tax;
    }

    public String getTaxSelection() {
        return this.taxSelection;
    }

    public void setTaxSelection(String taxSelection) {
        this.taxSelection = taxSelection;
    }

    public void setSelectionMode() {
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();
        dataBean.setTaxFileType(taxSelection);
        warnings = "";

        if (taxSelection.equals("NoTax") || taxSelection.startsWith("custom")) {
            dataBean.setVisibilityMode(false);
        }
        if (taxSelection.equals("NoTax") || taxSelection.equals("rdp25") || taxSelection.equals("rdp22") || taxSelection.equals("gg13_5") || taxSelection.equals("gg13_8")) {
            this.taxMode = false;

            uploadTaxonomy();
        }

    }

    public void setTaxMode(Boolean taxMode) {
        if (taxSelection.equals("NoTax") || taxSelection.equals("rdp25") || taxSelection.equals("rdp22") || taxSelection.equals("gg13_5") || taxSelection.equals("gg13_8")) {
            this.taxMode = true;
            uploadTaxonomy();
        }
        this.taxMode = false;
    }

    public List getTaxSelections() {
        List l = new ArrayList();
        l.add(new SelectItem("NoTax", "No taxonomy"));
        l.add(new SelectItem("rdp25", "RDP v2.5"));
        l.add(new SelectItem("rdp22", "RDP v2.2"));
        l.add(new SelectItem("gg13_5", "Greengenes v13_5"));
        l.add(new SelectItem("gg13_8", "Greengenes v13_8"));
        l.add(new SelectItem("customrdp", "Custom RDP file"));
        l.add(new SelectItem("customgg", "Custom Greengenes file"));
        //  l.add(new SelectItem("otutable", "From counts file (OTU table)"));

        return l;
    }

    public Boolean getTaxMode() {

        return taxSelection.equals("NoTax") || taxSelection.equals("rdp25") || taxSelection.equals("rdp22") || taxSelection.equals("gg13_5") || taxSelection.equals("gg13_8");
    }

    public boolean doUploadDist(InputStream input, String fileName, String delimiter) {
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        if (dataBean == null) {
            FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed: No SessionDataBean.", null));
            return false;
        }

        dataBean.clearDist();

        // check if annotation has already bean uploaded
        String annotationFileName = dataBean.getAnnotFileName();
        if (annotationFileName.isEmpty() || (annotationFileName.length() == 0)) {
            FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed, please first upload annotation file.", null));
            return false;
        }

        String countsFileName = dataBean.getCountsFileName();

        if (countsFileName.isEmpty() || (countsFileName.length() == 0)) {
            FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed, please first upload counts file.", null));
            return false;
        }

        // Prepare file and outputstream.
        File file = null;
        OutputStream output = null;

        String localFile = "";
        String prefix = "";

        try {
            // Create file with unique name in upload folder and write to it.
            String tmpFN = configOL.tempFileWeb(configOL.tempFileName(".txt"));

            file = new File(tmpFN);
            file.deleteOnExit();

            output = new FileOutputStream(file);

            IOUtils.copy(input, output);
            System.out.println("successuflly copied dist file");
        } catch (IOException e) {
            // Cleanup.
            if (file != null) {
                file.delete();
            }
            this.clearDistFile();
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed with I/O error.", null));

            // Always log stacktraces (with a real logger).
            System.out.println(e.toString());
            e.printStackTrace();
            return false;
        } finally {
            IOUtils.closeQuietly(output);
        }

        LevelDataMatrix ldm = dataBean.getDataM();

        Set<String> levels = ldm.getDataM().keySet();
        Object[] lO = new String[levels.size()];
        lO = levels.toArray();

        String level = lO[0].toString();

        System.out.println("level: " + level);

        DataMatrix dataM = ldm.getDataMatrix(level);

        if (dataM == null) {
            String errorm = "Internal ERROR: null dataMatrix";
            System.out.println(errorm);
            return false;
        }

        String dfFile = dataM.getMatrixCompNorm();

        if (dfFile == null) {
            String errorm = "ERROR: no dataMatrix: " + dataM.getErrorM();
            System.out.println(errorm);
            return false;
        }

        String annotFile = dataM.getAnnot().getAnnotFile();

        JavaR jr = new JavaR();

        System.out.println("running checkDist ...");
        if (!jr.checkDist(dfFile, annotFile, file.getAbsolutePath())) {
            if (!config.getDebug()) {
                file.delete();
            }

            this.clearDistFile();

            FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed, please check file format.", null));

            return false;
        }

        dataBean.setDistDelim(delimiter);
        dataBean.setDistFile(file.getAbsolutePath());
        dataBean.setDistFileName(fileName);

        System.out.println("Successfully uploaded dist file "
                + file.getAbsolutePath());

        String message = "Successfully parsed distance file";

        FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                FacesMessage.SEVERITY_INFO, message, null));

        return true;
    }

    public void uploadDist() {
        InputStream distIS;
        String fileName;

        try {
            if (this.configOL.hInputFile) {
                if (distFile == null) {
                    FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                            FacesMessage.SEVERITY_ERROR, "Please select file first.", null));
                    return;
                }

                if (!utils.validateFile(distFile)) {

                    FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                            FacesMessage.SEVERITY_ERROR, utils.getError(), null));
                    Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, utils.getError());

                    return;
                }
                distIS = distFile.getInputStream();
                fileName = distFile.getSubmittedFileName();
            } else {
                distIS = distFileUF.getInputStream();
                fileName = distFileUF.getName();
            }

        } catch (IOException ex) {
            FacesContext.getCurrentInstance().addMessage("distUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "Internal error. File upload failed.  " + ex.getMessage(), null));
            Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, ex);
            return;
        }
        doUploadDist(distIS, fileName, delimiter);
    }

    public void uploadTaxonomy() {

        //   System.out.println(taxSelection + " uploadTaxonomy function");
        try {
            if (taxSelection.startsWith("custom")) {
                InputStream distIS;
                String fileName;

                if (this.configOL.hInputFile) {

                    if (!utils.validateFile(taxFile)) {

                        FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                                FacesMessage.SEVERITY_ERROR, utils.getError(), null));
                        Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, utils.getError());

                        return;
                    }
                    distIS = taxFile.getInputStream();
                    fileName = taxFile.getSubmittedFileName();
                } else {
                    distIS = taxFileUF.getInputStream();
                    fileName = taxFileUF.getName();
                }
                doUploadTax(distIS, fileName, taxSelection);

            } else if (taxSelection.equals("rdp25")) {
                //File is = new File(configOL.rdp25);
                //System.out.println(configOL.rdp25);

                FileInputStream stream = new FileInputStream(configOL.rdp25);
                doUploadTax(stream, configOL.rdp25, taxSelection);
            } else if (taxSelection.equals("rdp22")) {
                FileInputStream stream = new FileInputStream(configOL.rdp25);
                doUploadTax(stream, configOL.rdp22, taxSelection);
            } else if (taxSelection.equals("gg13_5")) {
                FileInputStream stream = new FileInputStream(configOL.gg13_5);
                doUploadTax(stream, configOL.gg13_5, taxSelection);
            } else if (taxSelection.equals("gg13_8")) {
                FileInputStream stream = new FileInputStream(configOL.gg13_8);
                doUploadTax(stream, configOL.gg13_8, taxSelection);
            } else if (taxSelection.equals("NoTax")) {
                //do nothing todo
            }
        } catch (IOException ex) {
            FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed " + ex.getMessage(), null));
            Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, ex);
        }

    }

    public void uploadAnnot() {

        System.out.println("in uploadAnnot()...");

        InputStream annotIS;
        String fileName;

        try {
            if (configOL.hInputFile) {
                if (annotationFile == null) {
                    System.out.println("annotationFile is null");
                }

                if (!utils.validateFile(annotationFile)) {

                    FacesContext.getCurrentInstance().addMessage("annotUploadForm", new FacesMessage(
                            FacesMessage.SEVERITY_ERROR, utils.getError(), null));
                    Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, utils.getError());

                    return;
                }

                annotIS = annotationFile.getInputStream();
                fileName = annotationFile.getSubmittedFileName();
            } else {
                System.out.println("getting input stream...");
                annotIS = annotationFileUF.getInputStream();
                fileName = annotationFileUF.getName();
                System.out.println("getting input stream....done.");
            }
        } catch (IOException ex) {
            FacesContext.getCurrentInstance().addMessage("annotUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "Internal error. File upload failed.  " + ex.getMessage(), null));
            Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, ex);
            return;
        }
        System.out.println("calling doUploadAnnot");
        doUploadAnnot(annotIS, fileName, delimiter);
    }

    public void uploadExample() {

        if (configOL.exampleCounts == null) {
            String errorM = "ERROR: exampleCounts == null!!!";
            System.out.println(errorM);
            return;
        }

        String cFileName;
        String aFileName;
        String dFileName;
        String tFileName = "";

        cFileName = FilenameUtils.getName(configOL.getExampleCounts());
        aFileName = FilenameUtils.getName(configOL.getExampleAnnot());
        dFileName = FilenameUtils.getName(configOL.getExampleDistanceMatrix());

        Configs config = new Configs();

        if (config.isDataMiner()) {
            format = "dataminer";
            this.normalization = "none";
            this.relative = false;
        } else {
            tFileName = FilenameUtils.getName(configOL.getExampleTaxa());
            format = "calypso3";
            this.normalization = "sqrt";
            this.relative = true;
        }

        FileInputStream inputCounts;
        FileInputStream inputAnnot;
        FileInputStream inputTax;
        FileInputStream inputDM;

        //System.out.println(configOL.exampleTax);
        try {
            inputCounts = new FileInputStream(configOL.getExampleCounts());
            inputAnnot = new FileInputStream(configOL.getExampleAnnot());

            if (!doUploadAnnot(inputAnnot, aFileName, ",")) {
                return;
            }

            if (!doUploadCounts(inputCounts, cFileName, ",")) {
                return;
            }

            if (!config.isDataMiner()) {
                inputTax = new FileInputStream(configOL.getExampleTaxa());

                if (!doUploadTax(inputTax, tFileName, "customgg")) {
                    return;
                }

                inputDM = new FileInputStream(configOL.getExampleDistanceMatrix());
                if (!this.doUploadDist(inputDM, dFileName, ",")) {
                    return;
                }
            }

        } catch (FileNotFoundException ex) {
            System.out.println("File not found " + ex);
            FacesContext.getCurrentInstance().addMessage("exampleUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed, file not found ", null));
            Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, ex);
            return;
        }

    }

    private boolean doUploadAnnot(InputStream input, String fileName, String delimiter) {
        FacesContext context = FacesContext.getCurrentInstance();
        HttpSession session = (HttpSession) context.getExternalContext().getSession(false);

        warnings = "";

        System.out.println("Warning: terminating session in FileUploadBean");
        session.invalidate();

        // get session data bean
        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();
        // SessionDataBean dataBean = (SessionDataBean) FacesContext.getCurrentInstance().getExternalContext()
        //    .getSessionMap().get("SessionDataBean");

        // This only works if myBean2 is session scoped and already created.
        if (dataBean == null) {
            this.clearAnnotationFile();
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("annotUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload error: No SessionDataBean.", null));
            return false;
        }

        dataBean.clearAnnot();
        dataBean.clearCounts();

        // Prepare file and outputstream.
        File file = null;
        OutputStream output = null;

        String prefix = "";

        try {
            // Create file with unique name in upload folder and write to it.
            file = configOL.getTempFile(".csv");
            output = new FileOutputStream(file);
            IOUtils.copy(input, output);

            // Show succes message.
            // FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
            //     FacesMessage.SEVERITY_INFO, "File upload succeed!", null));
        } catch (IOException e) {
            // Cleanup.
            if (file != null) {
                file.delete();
            }
            this.clearAnnotationFile();
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("annotUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed with I/O error.", null));

            // Always log stacktraces (with a real logger).
            e.printStackTrace();
            return false;
        } finally {
            IOUtils.closeQuietly(output);
        }

        SampleAnnotation sAnnot = new SampleAnnotation();

        boolean uploadOK = false;
        String error = "";

        if (sAnnot.parseAnnotation(file, delimiter)) {
            file.delete();

            int n = sAnnot.getAllSamples().size();
            int in = sAnnot.getAllIncludedSamples().size();

            String message = "Successfully parsed annotation file, " + n + " samples read, "
                    + in + " samples included.";

            FacesContext.getCurrentInstance().addMessage("annotUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_INFO, message, null));

            // check for warning messages
            String wm = sAnnot.getWarning();
            if (wm.length() > 0) {

                this.warnings = wm;

                FacesContext.getCurrentInstance().addMessage("annotUploadErrors", new FacesMessage(
                        FacesMessage.SEVERITY_ERROR, wm, null));
            }

            dataBean.setAnnotFileName(fileName);
            dataBean.setsAnnot(sAnnot);
            uploadOK = true;

        } else {
            error = sAnnot.getError();
            uploadOK = false;
        }
        if (!uploadOK) {
            file.delete();
            warnings = "Parsing annotation file failed: " + error;
            FacesContext.getCurrentInstance().addMessage("annotUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, warnings, null));
            this.clearAnnotationFile();
            return false;
        }
        if (file != null) {
            file.delete();
        }

        return true;
    }

    private boolean doUploadCounts(InputStream input, String fileName, String delimiter) {
        System.out.println("Uploading counts  ...");
        warnings = "";

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        // This only works if myBean2 is session scoped and already created.
        if (dataBean == null) {
            FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed: No SessionDataBean.", null));
            return false;
        }

        // reset value
        Double minFrac = Double.parseDouble(taxFilter);
        Double meanF = Double.parseDouble(meanFilter);

        dataBean.setNormalization("none");
        dataBean.setTss(false);
        dataBean.setCountsFileName(null);

        this.clearDistFile();

        // set new empty levelDataMatrix
        dataBean.setDataM(new LevelDataMatrix(minFrac,
                normalization, relative, meanF));

        dataBean.setTaxFileType("NoTax");
        dataBean.setTaxfilePath("");

        // check if annotation has already bean uploaded
        String annotationFileName = dataBean.getAnnotFileName();
        if (annotationFileName.isEmpty() || (annotationFileName.length() == 0)) {
            FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed, please first upload annotation file.", null));
            return false;
        }

        // Prepare file and outputstream.
        File file = null;
        OutputStream output = null;

        String localFile = "";
        String prefix = "";

        if (config.isDataMiner()) {
            format = "dataminer";
        } else if (format.isEmpty()) {
            format = "calypso3";
        }

        try {
            // Create file with unique name in upload folder and write to it.

            if (format.equals("calypso3")) {
                file = configOL.getTempFile(".csv");
                output = new FileOutputStream(file);
                IOUtils.copy(input, output);
                System.out.println("successuflly completed for calypso3");
            } // file has to be converted, determin file prefix
            else {
                int i = fileName.lastIndexOf('.');
                String ext;

                System.out.println(i);

                if (i > 0) {
                    ext = fileName.substring(i, fileName.length());
                } else {
                    ext = "";
                }

                localFile = configOL.tempFile(ext);
                output = new FileOutputStream(localFile);

                if (format.equals("qmap")) {
                    prefix = "annotation";

                } else if (format.equals("qtax")) {
                    prefix = "taxa";

                } else if (format.equals("qotu")) {
                    prefix = "taxa";

                } else if (format.equals("calypso2annot")) {
                    prefix = "anotation";

                } else if (format.equals("calypso3annot")) {
                    IOUtils.copy(input, output);
                } else if (format.equals("biom")) {
                    prefix = "anotation";
                } else if (format.equals("mothur")) {
                } else if (format.equals("uclust")) {
                } else if (format.equals("dataminer")) {
                } else {
                    // String error = "ERROR: unknown format " + format;
                    System.out.println("not in the list" + format);
                }
                IOUtils.copy(input, output);
            }

            // Show succes message.
            // FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
            //     FacesMessage.SEVERITY_INFO, "File upload succeed!", null));
        } catch (IOException e) {
            // Cleanup.
            if (file != null) {
                file.delete();
            }
            this.clearCountsFile();
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed with I/O error.", null));

            // Always log stacktraces (with a real logger).
            System.out.println(e.toString());
            e.printStackTrace();
            return false;
        } finally {
            IOUtils.closeQuietly(output);
        }
        LevelDataMatrix dataM = new LevelDataMatrix(minFrac,
                normalization, relative, meanF);

        // convert file into calypso3 format
        if (!format.equals("calypso3")) {
            String convertedName = configOL.tempFileName(".csv", prefix);
            String convertedFile = configOL.tempFileWeb(convertedName);
            String taxonomyName = configOL.getTempFileName(".txt");
            //converted
            if (!utils.convert(localFile, convertedFile, format, taxonomyName, delimiter)) {
                // Show error message
                System.out.println("left with error");
                this.clearCountsFile();
                FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                        FacesMessage.SEVERITY_ERROR, utils.getError() + " Please check the data format of the file " + fileName, null));
                return false;
            }

            file = new File(convertedFile);
            if (format.equals("biom") || format.equals("qotu")) {
                if (new File(taxonomyName).exists()) {
                    dataBean.setTaxFileType("otutable");
                    dataBean.setTaxfilePath(taxonomyName);
                    if (taxonomyName.endsWith("txt")) {
                        this.taxSelection = "NoTax";
                        FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                                FacesMessage.SEVERITY_INFO, "Successfully built taxonomy.", null));
                    } else {
                        FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                                FacesMessage.SEVERITY_ERROR, "File upload failed with I/O error.", null));
                    }

                } else {
                    System.out.println("No taxonomy information available");
                }
            }
        }

        // set the annotation file
        if (!dataM.setSAnnot(dataBean.getsAnnot())) {

            FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "Upload failed.", null));

            String message = "Parsing counts file failed: " + dataM.getError() + ". Check also the format of the count file. Count file should be " + format + ".";
            FacesContext.getCurrentInstance().addMessage("countsUploadErrors", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, message, null));

            this.clearCountsFile();
            return false;

        }

        // parse counts file
        System.out.println("Parsing counts file ...");
        if (dataM.parseCounts(file, delimiter, filtertaxa)) {
            file.delete();

            String message = "Successfully parsed counts file, " + dataM.getParsedTaxa()
                    + " data points per sample included.";
            if (dataM.getNumLevels() == 0) {
                message = "Parsing counts file failed: No level found. Check the format of the data file. Data file format should be " + format + ".";
                if (format.equals("biom")) {
                    message = "Parsing counts file failed: No level found. Suffix of the file name should be biom.";

                }
                FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                        FacesMessage.SEVERITY_ERROR, message, null));
                this.clearCountsFile();

            } else {
                FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                        FacesMessage.SEVERITY_INFO, message, null));
            }

            dataBean.setCountsFileName(fileName);
            dataBean.setDataM(dataM);

            dataBean.setNormalization(normalization);
            dataBean.setTss(relative);

            String wm = dataM.getWarning();
            if (wm.length() > 0) {
                warnings = wm;
                FacesContext.getCurrentInstance().addMessage("countsUploadErrors", new FacesMessage(
                        FacesMessage.SEVERITY_ERROR, wm, null));
            }

        } else {
            if (!config.getDebug()) {
                file.delete();
            }

            FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "Parsing Counts file failed.", null));

            String message = "Parsing counts file failed: " + dataM.getError() + ". Check for right format. Data file format should be " + format;
            FacesContext.getCurrentInstance().addMessage("countsUploadErrors", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, message, null));
            this.clearCountsFile();
            return false;
        }
        if (file != null) {
            file.delete();
        }

        FacesContext context = FacesContext.getCurrentInstance();
        ApplicationBean appBean = (ApplicationBean) context.getELContext().getELResolver().getValue(context.getELContext(), null, "ApplicationBean");
        appBean.increaseSessionNumber();

        return true;
    }

    private boolean doUploadTax(InputStream input, String fileName, String taxonomyType) {

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();
        // This only works if myBean2 is session scoped and already created.
        if (dataBean == null) {
            FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed: No SessionDataBean.", null));
            return false;
        }

        if (dataBean == null) {
            //       this.clearTaxFile();
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload error: No SessionDataBean.", null));
            return false;
        }
        //dataBean.clearTax();
        LevelDataMatrix ldm = dataBean.getDataM();
        HashMap hm = ldm.getDataM();
        Set<String> levelsCounts = hm.keySet();
        List<String> levelsCountsSorted = new ArrayList<String>();
        //collects all level and taxa and store in a hash: level[key] => list of taxa [value]
        LinkedHashMap levelTaxa = new LinkedHashMap();
        HashMap<String, String> ranks = new HashMap<String, String>();
        ranks.put("k", "superkingdom");
        ranks.put("p", "phylum");
        ranks.put("c", "class");
        ranks.put("o", "order");
        ranks.put("f", "family");
        ranks.put("g", "genus");
        ranks.put("s", "species");
        ranks.put("d", "superkingdom");
        //check which level exist and which taxa belong to each level
        for (String s : levelsCounts) {
            String lowerS = s.toLowerCase();
            DataMatrix dataLevel = ldm.getDataMatrix(s);
            if (lowerS.equals("domain")) {
                s = "superkingdom";
            }
            LinkedHashSet<String> taxa = dataLevel.getOrderedTaxa(0, true);
            if (lowerS.startsWith("otu")) {
                for (String otu : taxa) {
                    //possible cases in counts matrix
                    //OTU, p__Bacteroidetes; f__Rikenellaceae 1,1.0,1.0,3.0,5
                    //OTU, p__Bacteroidetes; g__Bacteroides s__eggerthii 20,0.0
                    //OTU, p__Firmicutes 8011,0.0
                    //OTU,k__Bacteria 23,0.0,0
                    if (!(otu.contains("Unclassified"))) {
                        String lowestTaxon = "";
                        String lowestRank = "";
                        String[] col = otu.split("__");
                        if (col[col.length - 1].contains("_")) {
                            //  System.out.println(lowerS+": "+otu + " " + col.length);

                            if (col.length == 6) {
                                if (col[4].equals("s") && col[2].equals("g")) {
                                    int index = col[5].lastIndexOf("_");
                                    lowestTaxon = col[3] + "_" + col[5].substring(0, index);
                                    lowestRank = "species";
                                } else {
                                    String message = "wront otu format: " + otu + "; ";
                                    warnings = warnings + message;
                                    FacesContext.getCurrentInstance().addMessage("taxUploadErrors", new FacesMessage(
                                            FacesMessage.SEVERITY_ERROR, message, null));
                                }
                            } else if (col.length == 4) {
                                lowestRank = ranks.get(col[2]);
                                int index = col[3].lastIndexOf("_");
                                lowestTaxon = col[3].substring(0, index);
                            } else if (col.length == 2) {
                                lowestRank = ranks.get(col[0]);
                                int index = col[1].lastIndexOf("_");
                                lowestTaxon = col[1].substring(0, index);
                            } else {
                                String message = "wrong otu format: " + otu + "; ";
                                warnings = warnings + message;

                                FacesContext.getCurrentInstance().addMessage("taxUploadErrors", new FacesMessage(
                                        FacesMessage.SEVERITY_ERROR, message, null));
                            }

                            if (levelTaxa.containsKey(lowestRank.toLowerCase())) {
                                ((LinkedHashSet) levelTaxa.get(lowestRank.toLowerCase())).add(lowestTaxon);

                            } else {
                                levelTaxa.put(lowestRank.toLowerCase(), new LinkedHashSet());
                                ((LinkedHashSet) levelTaxa.get(lowestRank.toLowerCase())).add(lowestTaxon);

                            }
                        } else {
                            String message = "wrong otu format";
                            warnings = warnings + message;

                            FacesContext.getCurrentInstance().addMessage("taxUploadErrors", new FacesMessage(
                                    FacesMessage.SEVERITY_ERROR, message, null));
                        }

                    }
                }

            } else {
                levelTaxa.put(s.toLowerCase(), taxa);
            }

        }

        // Prepare file and outputstream.
        File file = null;
        OutputStream output = null;
        String prefix = "";

        try {
            // Create file with unique name in upload folder and write to it.
            file = configOL.getTempFile(".txt");
            output = new FileOutputStream(file);
            IOUtils.copy(input, output);
            // Show succes message.
            // FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
            //     FacesMessage.SEVERITY_INFO, "File upload succeed!", null));
        } catch (IOException e) {
            // Cleanup.
            if (file != null) {
                file.delete();
            }

            // this.clearTaxFile();
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed with I/O error.", null));

            // Always log stacktraces (with a real logger).
            e.printStackTrace();
            return false;
        } finally {
            IOUtils.closeQuietly(output);
        }

        Hierarchy taxonomy = new Hierarchy(taxonomyType);
        CalypsoOConfigs config = new CalypsoOConfigs();
        String filePath = taxonomy.parseTaxonomy(file, levelTaxa);

        if (filePath.endsWith("txt")) {
            dataBean.setTaxFileType(taxonomyType);
            dataBean.setTaxfilePath(filePath);

            String uploadwarnings = taxonomy.getWarnings();
            System.out.println(uploadwarnings + "__" + warnings.length() + "__" + warnings);

            dataBean.setVisibilityMode(true);
            if (uploadwarnings.equals("") && warnings.length() == 0) {
                FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                        FacesMessage.SEVERITY_INFO, "Successfully built taxonomy.", null));
            } else {

                warnings = warnings + " " + uploadwarnings;
                if (warnings.length() > 750) {
                    warnings = warnings.substring(0, 750) + "...";
                }
                FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                        FacesMessage.SEVERITY_INFO, "Built taxonomy with warnings!", null));

                if (uploadwarnings.length() > 750) {
                    uploadwarnings = uploadwarnings.substring(0, 750) + "...";
                }
                FacesContext.getCurrentInstance().addMessage("taxUploadErrors", new FacesMessage(
                        FacesMessage.SEVERITY_ERROR, uploadwarnings, null));

            }
        } else {
            dataBean.setTaxFileType("NoTax");
            dataBean.setTaxfilePath("");
            FacesContext.getCurrentInstance().addMessage("taxUploadForm2", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed with I/O error. " + taxonomy.getWarnings(), null));
        }
        return true;
    }

    public void uploadCounts() {
        InputStream countsIS;
        String fileName;

        try {
            if (isHInputFile()) {

                if (countsFile == null) {
                    System.out.println("countsFile is null");
                    FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                            FacesMessage.SEVERITY_ERROR, "Internal error", null));
                    return;
                }

                if (!utils.validateFile(countsFile)) {

                    FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                            FacesMessage.SEVERITY_ERROR, utils.getError(), null));
                    Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, utils.getError());

                    return;
                }
                countsIS = countsFile.getInputStream();
                fileName = countsFile.getSubmittedFileName();
            } else {
                countsIS = this.countsFileUF.getInputStream();
                fileName = countsFileUF.getName();
            }
        } catch (IOException ex) {
            FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed:  " + ex.getMessage(), null));
            Logger
                    .getLogger(FileUploadBean.class
                            .getName()).log(Level.SEVERE, null, ex);
            return;
        }
        doUploadCounts(countsIS, fileName, delimiter);

        //if(!this.configOL.isDataMiner()) uploadTaxonomy();
    }

    public void clear() {
        clearCountsFile();

    }

    public void clearCountsFile() {
        countsFile = null;

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        // This only works if myBean2 is session scoped and already created.
        if (dataBean != null) {
            dataBean.clearCounts();
        }

    }

    public void clearDistFile() {
        distFile = null;

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        // This only works if myBean2 is session scoped and already created.
        if (dataBean != null) {
            dataBean.clearDist();
        }

    }

    public void clearAnnotationFile() {
        annotationFile = null;

        SessionDataBean dataBean = SessionDataBean.getCurrentInstance();

        // This only works if myBean2 is session scoped and already created.
        if (dataBean != null) {
            dataBean.clearAnnot();
        }
    }

    public List getFormats() {
        List l = new ArrayList();
        l.add(new SelectItem("calypso3", "Calypso V3"));
        l.add(new SelectItem("biom", "BIOM"));
        // l.add(new SelectItem("calypso2", "Calypso V2"));
        //   l.add(new SelectItem("qmap", "QIIME Mapping"));
        //   l.add(new SelectItem("qtax", "QIIME assign_taxonomy.py"));
        l.add(new SelectItem("qotu", "QIIME OTU table"));
        l.add(new SelectItem("mothur", "MOTHUR"));
        //     l.add(new SelectItem("UCLUST", "uclust"));
        //     l.add(new SelectItem("mgrast", "MG-RAST"));
        return (l);
    }

    public List getDelimiters() {
        List l = new ArrayList();

        l.add(new SelectItem(",", "Comma Separated"));
        l.add(new SelectItem(";", "Semicolon Separated"));
        l.add(new SelectItem("\t", "Tab Separated"));

        return (l);
    }

    public List getFiltertaxas() {
        List l = new ArrayList();

        l.add(new SelectItem("None", "None"));
        l.add(new SelectItem("Cyanobacteria", "Cyanobacteria"));
        l.add(new SelectItem("Chloroplast", "Chloroplast"));

        return (l);
    }

    public List getNormMethods() {
        List l = new ArrayList();

        l.add(new SelectItem("none", "None"));
        l.add(new SelectItem("sqrt", "SquareRoot"));
        l.add(new SelectItem("clr", "Centred Log-Ratio"));
        l.add(new SelectItem("log", "ln"));
        l.add(new SelectItem("log2", "Log2"));
        l.add(new SelectItem("log10", "Log10"));
        l.add(new SelectItem("logit", "logit"));
        l.add(new SelectItem("asinh", "ASINH"));
        l.add(new SelectItem("quantile", "Quantile"));
        if (config.isDataMiner()) {
            l.add(new SelectItem("vsn", "VSN"));

        }

        return (l);
    }

    public boolean isHInputFile() {
        return (this.configOL.hInputFile);
    }

}
