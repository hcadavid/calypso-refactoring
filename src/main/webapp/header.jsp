<%-- 
    Document   : header
    Created on : Sep 8, 2011, 10:13:35 AM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="f" uri="http://java.sun.com/jsf/core"%>
<%@taglib prefix="h" uri="http://java.sun.com/jsf/html"%>



<f:subview id="headerDataMiner" rendered="#{SessionDataBean.dataMiner}">
        <jsp:include page="headerDataMiner.jsp" />
    </f:subview>



<f:subview id="headerCalypso" rendered="#{! SessionDataBean.dataMiner}">
        <jsp:include page="headerCalypso.jsp" />
    </f:subview>