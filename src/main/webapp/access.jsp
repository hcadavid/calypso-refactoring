<%--
    Document   : GroupsPlots
    Created on : Sep 14, 2011, 2:21:27 PM
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

    <div id="topSelect">
        <h1>Access Statistics</h1>
        
        <center>
        <table border="1" cellpadding="2" cellspacing="0" rules="all" style="border:solid 2px"
               class="sortable">
        <h:outputText value="#{ApplicationBean.accessTableRows}" escape="false" />
        </table>
        </center>

        

    </div>




    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
