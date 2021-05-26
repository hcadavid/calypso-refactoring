/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;


import javax.inject.Named;
import javax.enterprise.context.SessionScoped;
import java.io.Serializable;
import javax.faces.context.FacesContext;

import javax.servlet.http.Part;

/**
 *
 * @author lutzK
 */
@Named(value = "Bean")
@SessionScoped
public class Bean implements Serializable {

     private Part file;
  private String fileContent;
  private String fileName = "init";
 
  public void upload() {
    if(file==null) {
        System.out.println("null file");
        fileName = "-";
    }
    else{
        System.out.println(file.getSubmittedFileName());
        fileName = file.getSubmittedFileName();
    }
    file = null;
  }
 
  public Part getFile() {
    return file;
  }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
  
 
 
  public void setFile(Part file) {
    this.file = file;
  }
  
  public String version(){
      String version = FacesContext.class.getPackage().getImplementationVersion();
      return(version);
  }
  
    /**
     * Creates a new instance of Bean
     */
    public Bean() {
    }
    
}
