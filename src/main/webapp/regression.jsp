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
        <h:form rendered="true">
            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                
                 <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
                <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{RegressionBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                </h:panelGroup>

                <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="regressBy" value="Regress by" />
                <h:selectOneMenu id="gregressBy" value="#{RegressionBean.regressBy}"  >
                    <f:selectItems value="#{RegressionBean.regressionModes}" />
                </h:selectOneMenu>

                <h:panelGroup>
                    <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>
                    <h:outputLabel value="&nbsp;" escape="false"/>
                    <h:commandButton id="submitMode" value="Set Mode" action="#{RegressionBean.setSelectedMode}" />
                </h:panelGroup>
            </h:panelGrid>
        </h:form>


        <h:form rendered="#{! (RegressionBean.selectMode)}">
            <h:panelGrid columns="23" >


                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{(RegressionBean.conditionsopt)}">
                    <h:outputLabel value="Conditions to compare: " escape="false"/>
                    <h:outputLabel for="gA" value="A: " />
                    <h:selectOneMenu id="gA" value="#{RegressionBean.groupA}"  >
                        <f:selectItems value="#{RegressionBean.groups}" />
                    </h:selectOneMenu>

                    <h:outputLabel for="gB" value="B: " />
                    <h:selectOneMenu id="gB" value="#{RegressionBean.groupB}"  >
                        <f:selectItems value="#{RegressionBean.groups}" />
                    </h:selectOneMenu>
                </h:panelGroup>

                <h:panelGroup rendered="#{(RegressionBean.diversityopt)}">
                    <h:outputLabel for="indexSelect" value="Index: " />
                    <h:selectOneMenu id="indexSelect" value="#{RegressionBean.index}"  >
                        <f:selectItems value="#{RegressionBean.indexTypes}" />
                    </h:selectOneMenu>
                </h:panelGroup>

                <h:panelGroup rendered="#{(RegressionBean.distopt)}">
                    <h:outputLabel for="distSelect" value="Distance Method: " />
                    <h:selectOneMenu id="distSelect" value="#{RegressionBean.dist}"  >
                        <f:selectItems value="#{SessionDataBean.distmethods}" />
                    </h:selectOneMenu>
                </h:panelGroup>

            </h:panelGrid>




            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{RegressionBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>


                <h:panelGroup rendered="#{RegressionBean.iSTimeByopt()}">
                    <h:outputLabel for="timeP" value="Time variable: " />
                    <h:selectOneMenu id="timep" value="#{RegressionBean.timeBy}"  >
                        <f:selectItems value="#{SessionDataBean.colorBy}" />
                    </h:selectOneMenu>

                </h:panelGroup>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>




                <h:outputLabel for="groupS" value="Secondary Group:" />
                <h:selectOneMenu id="groupS" value="#{RegressionBean.groupS}"  >
                    <f:selectItems value="#{RegressionBean.allGroupS}" />
                </h:selectOneMenu>




                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Run Analysis" action="#{RegressionBean.run}" />
            </h:panelGrid>



            <%-- second row of input fields --%>

            <h:panelGrid columns="23">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>




                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup rendered="#{(RegressionBean.filteropt)}">
                    <h:outputLabel for="taxFilter" value="Filter (0-1000)" />
                    <h:inputText id="taxFilter" value="#{RegressionBean.taxFilter}" required="true" size="3" >
                        <f:validateLongRange minimum="0" maximum="1000"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

                <h:outputLabel for="label" value="Paired: " />
                <h:selectBooleanCheckbox
                    title="label" id="label"
                    value="#{RegressionBean.paired}" >
                </h:selectBooleanCheckbox>


                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{RegressionBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{RegressionBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{RegressionBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>

                <h:panelGroup rendered="#{(RegressionBean.corindexopt)}">
                    <h:outputLabel for="corIndex" value="Correlation: " />
                    <h:selectOneMenu id="corIndex" value="#{RegressionBean.corIndex}"  >
                        <f:selectItems value="#{RegressionBean.corIndexS}" />
                    </h:selectOneMenu>
                    <h:outputLabel value="&nbsp;" escape="false"/>
                </h:panelGroup>

            </h:panelGrid>


            <h:panelGrid columns="23">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{(RegressionBean.taxaopt)}">
                    <h:outputLabel for="taxaSelect" value="Taxa: " rendered="#{!SessionDataBean.dataMiner}"/>
                    <h:outputLabel for="taxaSelect" value="Feature: " rendered="#{SessionDataBean.dataMiner}"/>
                    <h:selectOneMenu id="taxaSelect" value="#{RegressionBean.taxa}"  >
                        <f:selectItems value="#{RegressionBean.allTaxa}" />
                    </h:selectOneMenu>
                </h:panelGroup>



            </h:panelGrid>


            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
        </h:form>

    </div>

    <p></p>

    <div id="intro">

        <f:subview id="inCA" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="introCA/regression.html" %>
        </f:subview>

        <f:subview id="inDS" rendered="#{SessionDataBean.dataMiner}">
            <%@ include file="introDS/regression.html" %>
        </f:subview>

    </div>

    <div id="data">

        
        <p></p>

        <center>
            <h:outputText value="<h2>Correlation:</h2>" escape="false" rendered="#{RegressionBean.showTable}"/>
            <h:outputText rendered="#{RegressionBean.showTable}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
            <h:outputText value="#{RegressionBean.tableRows}" escape="false" rendered="#{RegressionBean.showTable}"/>
            <h:outputText rendered="#{RegressionBean.showTable}" escape="false" value="</table>" />
            <h:outputText value="Click on table header to sort table (Javascript has to be activated)." escape="false" rendered="#{RegressionBean.showTable}"/>

            <p></p>
            <h:outputText value="<h2>Coefficients of fitted multiple linear regression model:</h2>" escape="false" rendered="#{RegressionBean.showTable}"/>

            <h:outputText rendered="#{RegressionBean.showTable}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
            <h:outputText value="#{RegressionBean.tableRegression}" escape="false" rendered="#{RegressionBean.showTable}"/>
            <h:outputText rendered="#{RegressionBean.showTable}" escape="false" value="</table>" />
            <h:outputText value="Click on table header to sort table (Javascript has to be activated).<p></p>Taxa can be missing due to singularities." escape="false" rendered="#{RegressionBean.showTable}"/>

            <p></p>
            <h:outputText value="<h2>P-values of fitted multiple linear regression model:</h2>" escape="false" rendered="#{RegressionBean.showTR}"/>

            <h:outputText rendered="#{RegressionBean.showTR}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
            <h:outputText value="#{RegressionBean.tableTR}" escape="false" rendered="#{RegressionBean.showTR}"/>
            <h:outputText rendered="#{RegressionBean.showTR}" escape="false" value="</table>" />
            <h:outputText value="Click on table header to sort table (Javascript has to be activated).<p></p>" escape="false" rendered="#{RegressionBean.showTR}"/>

            <h:outputLink value="#{RegressionBean.regressionFileLink}" rendered="#{RegressionBean.showTR}">
                <f:verbatim>Download table in coma separated format</f:verbatim>
            </h:outputLink>

        </center>

        <p></p>

        <h:graphicImage id="image"
                        alt=""
                        width="#{RegressionBean.pwidth}"

                        url="#{RegressionBean.chartLink}"
                        rendered="#{RegressionBean.showChart}">
        </h:graphicImage>

        <p></p>


        <h1><h:outputText value="#{RegressionBean.errorm}" style="color: red;"/></h1>

        <%--
         <h:outputLink value="#{RegressionBean.chartLink}" rendered="#{RegressionBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>



    <div id="nutshell">

        <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="nutshell/regression.html" %>
        </f:subview>
    </div>



    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
