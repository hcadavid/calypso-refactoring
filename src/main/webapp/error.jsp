    <%-- 
    Document   : error
    Created on : Oct 13, 2011, 8:13:49 PM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="f" uri="http://java.sun.com/jsf/core"%>
<%@taglib prefix="h" uri="http://java.sun.com/jsf/html"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<f:view>
    <f:subview id="header">
        <jsp:include page="header.jsp" />
    </f:subview>

    <div align="left" style="padding-left:2cm; padding-right:2cm;">

    
            <h1><h:outputText value="The following error occured:"/>
                <h:outputText value="#{SessionDataBean.error}"/></h1>
         </div>

             <div id="content">
</f:view>
