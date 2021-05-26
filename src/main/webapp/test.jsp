<%-- 
    Document   : test
    Created on : Mar 10, 2016, 2:38:18 PM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>



<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t" %>


<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Hello World!</h1>
        <f:view>
        
            <h:outputLabel value="Annotation File:" style="font-weight:bold;"></h:outputLabel>
    <h:outputText escape="false" value="#{Bean.fileName}" style="font-weight:bold;"/>
    
    <p/>
    
    <h:outputText escape="false" value="#{Bean.version()}" style="font-weight:bold;"/>
            
            <h:form id="form" enctype="multipart/form-data">
               
  <h:inputFile id="file" value="#{Bean.file}"/>
  <h:commandButton value="Upload"
      action="#{Bean.upload}"/>
</h:form>
            
            
        </f:view>
    </body>
</html>
