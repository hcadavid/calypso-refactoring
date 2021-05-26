/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package CalypsoOnline;

import CalypsoCommon.Configs;
import java.io.File;
import java.io.IOException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ApplicationScoped;
import org.apache.commons.io.FileUtils;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "ApplicationBean", eager = true)
@ApplicationScoped
public class ApplicationBean {

    
    
    HashMap<String, HashMap<String, Integer>> access =
            new HashMap<String, HashMap<String, Integer>>();

    public String getAccessTableRows() {
        //Iterator it = Arrays.sort(access.keySet().toArray()).iterator()
        Iterator it = access.keySet().iterator();

        String text = "<thead><tr><th>Day</th><th>Sessions</th><th>Requests</th></thead><tbody>";

        while (it.hasNext()) {
            String date = (String) it.next();
            int session = access.get(date).get("session");
            int request = access.get(date).get("request");

            text = text + "<tr><td>" + date + "</td><td>" + session + "</td><td>" + request
                    + "</td></tr><br>";
        }
        text = text + "</tbody>";
        return text;
    }

    public String getSessionNumber() {

        String today = getDay();
        return Integer.toString(getSessionNumber(today));
    }

    public Integer getSessionNumber(String day) {
        int sN = 0;

        if (access.containsKey(day)) {
            sN = access.get(day).get("session");
        }
        return sN;
    }

    public Integer getRequestNumber(String day) {
        int rN = 0;

        if (access.containsKey(day)) {
            rN = access.get(day).get("request");
        }
        return rN;
    }

    public String getIncreaseRequestNumber() {
        increaseRequestNumber();
        return "";
    }

    public void setSessionNumber(String day, Integer sN) {
        if (!access.containsKey(day)) {
            HashMap<String, Integer> map = new HashMap<String, Integer>();
            map.put("session", sN);
            map.put("request", 0);
            access.put(day, map);
        }
        else{
           access.get(day).put("session",sN);
        }
    }

    public void setRequestNumber(String day, Integer rN) {
        if (!access.containsKey(day)) {
            HashMap<String, Integer> map = new HashMap<String, Integer>();
            map.put("session", 0);
            map.put("request", rN);
            access.put(day, map);
        }
        else{
           access.get(day).put("request",rN);
        }
    }

    public void increaseSessionNumber() {
        String today = getDay();

        int sN = this.getSessionNumber(today) + 1;

        this.setSessionNumber(today, sN);

        System.out.println("Session number: " + sN + " day: " + today);
    }

    public void increaseRequestNumber() {
        String today = getDay();

        int rN = this.getRequestNumber(today) + 1;

        this.setRequestNumber(today, rN);

        System.out.println("Request number: " + rN + " day: " + today);
    }

    /** Creates a new instance of ApplicationBean */
    public ApplicationBean() {
      System.out.println(">>>>>>>>>>>>>>>>>>  APP SCOPED BEAN TEST");
    }

    // don't use. othewise, if e.g. datasmart server is restarted, all tmp files
    // of currently active calypso sessions are removed
    private void cleanTmpFilesDeprecated(){
        CalypsoOConfigs config = new CalypsoOConfigs();
        String dir = config.getTmpDirWeb();
        cleanDir(dir);
        dir = config.getTempDir();
        cleanDir(dir);  
        
        Configs con = new Configs();
          
        dir = con.getTmpDir();   
        cleanDir(dir);
    }

            private void cleanDir(String dir) {
                    System.out.println("Deleting all files in dir " + dir);
                    
                    File f = new File(dir);
                    
                    try{
                        FileUtils.cleanDirectory(f);
                    }catch(IOException ex){
                        System.out.println("ERROR deleting files: " + ex);
                    }
        }
    
    
    public String getDay() {
        Calendar cal = Calendar.getInstance();
        int m = cal.get(Calendar.MONTH) + 1;
        String month;
        if (m < 10) {
            month = "0" + Integer.toString(m);
        } else {
            month = Integer.toString(m);
        }
        String today = cal.get(Calendar.DATE) + "." + month + "." + cal.get(Calendar.YEAR);

        return (today);
    }
}
