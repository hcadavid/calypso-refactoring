<%--
    Document   : getTable
    Created on : Sep 14, 2011, 4:36:17 PM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="f" uri="http://java.sun.com/jsf/core"%>
<%@taglib prefix="h" uri="http://java.sun.com/jsf/html"%>


<f:view>
    <h:outputText value="#{BarChartsBean.tableAsTxt}" escape="false"/>
</f:view>

