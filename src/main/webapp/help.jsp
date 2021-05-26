<%-- 
    Document   : help
    Created on : Dec 4, 2015, 2:36:28 PM
    Author     : lutzK
--%>



<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="f" uri="http://java.sun.com/jsf/core"%>
<%@taglib prefix="h" uri="http://java.sun.com/jsf/html"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<f:view>
    
    <f:subview id="calypsoHelp" rendered="#{!SessionDataBean.dataMiner}">
        <h:outputLink value="#{HelpBean.redirectLinkCalypso()}"/>
         <h:outputLabel value="#{HelpBean.redirectLinkCalypso()}"/>
    </f:subview>

    <f:subview id="dataSmartHelp" rendered="#{SessionDataBean.dataMiner}">
        <h:outputLink value="#{HelpBean.redirectLinkDataSmart()}"/>
         <h:outputLabel value="#{HelpBean.redirectLinkDataSmart()}"/>
    </f:subview>
    
</f:view>
