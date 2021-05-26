/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package CalypsoOnline;

import java.net.InetAddress;
import java.net.UnknownHostException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

/**
 *
 * @author lutzK
 */
@ManagedBean(name = "TestBean")
@SessionScoped
public class TestBean {

    /**
     * Creates a new instance of TestBean
     */
    public TestBean() {
    }
    
    public String getTest(){
        return ("geht doch");
    }
            
            
    public String getHost(){
        String hostname;
        
        try {
            InetAddress addr = InetAddress.getLocalHost();
            hostname = addr.getHostName();
        } catch (UnknownHostException e) {
            System.out.println("ERROR While getting host name" + e.getMessage());
            return "Shoot";
        }
        return hostname;
    }
    
}
