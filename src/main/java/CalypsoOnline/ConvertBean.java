/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Utils;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import org.apache.commons.io.IOUtils;
import org.apache.myfaces.custom.fileupload.UploadedFile;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "ConvertBean")
@SessionScoped
public class ConvertBean {

    private String format = "";
    private UploadedFile file;
    private Boolean converted = false;
    private String convertedLink = "";
    private String errorm = "";
    private String fileName = "";

    /** Creates a new instance of ConvertBean */
    public ConvertBean() {
    }

    public UploadedFile getFile() {
        return file;
    }

    public void setFile(UploadedFile file) {
        this.file = file;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public Boolean getConverted() {
        return converted;
    }

    public void setConverted(Boolean converted) {
        this.converted = converted;
    }

    public String getConvertedLink() {
        return convertedLink;
    }

    public void setConvertedLink(String convertedLink) {
        this.convertedLink = convertedLink;
    }

    public String getErrorm() {
        return errorm;
    }

    public void setErrorm(String errorm) {
        this.errorm = errorm;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    

    

    public boolean convert() {
        converted = false;
        convertedLink = "";
        errorm = "";
        fileName = "";

        CalypsoOConfigs configs = new CalypsoOConfigs();

        InputStream input;
        fileName = file.getName();

        try {
            input = file.getInputStream();
        } catch (IOException ex) {
            FacesContext.getCurrentInstance().addMessage("uploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "File upload failed: file not found " + file.getName(), null));
            Logger.getLogger(FileUploadBean.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }

        String localFile = null;
        FileOutputStream output = null;

        // write uploaded file to harddisk
        try {
            // Create file with unique name in upload folder and write to it.

            String ext = fileName.substring(fileName.lastIndexOf('.'),fileName.length());

            localFile = configs.tempFile(ext);

            output = new FileOutputStream(localFile);

            IOUtils.copy(input, output);

            // Show succes message.
            // FacesContext.getCurrentInstance().addMessage("countsUploadForm", new FacesMessage(
            //     FacesMessage.SEVERITY_INFO, "File upload succeed!", null));
        } catch (IOException e) {
            // Cleanup.
            File tmp = new File(localFile);
            tmp.delete();

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

        // convert uploaded file to calypso
        Utils utils = new Utils();

        String prefix = "";

        if(format.equals("qmap")){
            prefix = "annotation";
        }
        else if(format.equals("qtax")){
            prefix = "taxa";
        }
        else if(format.equals("qotu")){
            prefix = "otu";
        }
        else if(format.equals("calypso2annot")){
            prefix = "anotation";
        }
        else{
            String error = "ERROR: unknown format " + format;

            FacesContext.getCurrentInstance().addMessage("uploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "Error, unknown format " + format, null));
            return false;
        }

        String convertedName = configs.tempFileName(".csv",prefix);
        String convertedFile = configs.tempFileWeb(convertedName);

        //converted
        if(! utils.convert(localFile, convertedFile, format, null,",")){
            // Show error message.
            FacesContext.getCurrentInstance().addMessage("uploadForm", new FacesMessage(
                    FacesMessage.SEVERITY_ERROR, "Error converting file " + fileName, null));
            return false;
        }

        // clean up
        File tmp = new File(localFile);
        tmp.delete();

        convertedLink = configs.getTmpDirUrl() + convertedName;
        converted = true;

        String message = "Successfully converted file " + fileName;
        FacesContext.getCurrentInstance().addMessage("uploadForm", new FacesMessage(
                FacesMessage.SEVERITY_INFO, message, null));

        return true;
    }

    public void uploadREM() {
    }

    public List getFormats() {
        List l = new ArrayList();
        l.add(new SelectItem("qmap", "QIIME Mapping"));
        l.add(new SelectItem("qtax", "QIIME assign_taxonomy.py"));
        l.add(new SelectItem("qotu", "QIIME OTU table"));
        l.add(new SelectItem("calypso2annot", "Calypso annotation file v2 to v3"));
        return (l);
    }
}
