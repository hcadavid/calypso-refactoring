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
                <h:selectOneMenu id="levelSelect" value="#{StatsSTDBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                </h:panelGroup>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:outputLabel for="test" value="Test: " />
                <h:selectOneMenu id="test" value="#{StatsSTDBean.test}"  >
                    <f:selectItems value="#{StatsSTDBean.tests}" />
                </h:selectOneMenu>



                <h:outputLabel value="&nbsp;" escape="false"/>
                <h:commandButton id="submitMode" value="Select Mode" action="#{StatsSTDBean.setSelectedMode}" />

            </h:panelGrid>

        </h:form>

        <p></p>


        <h:form rendered="#{! (StatsSTDBean.selectMode)}">

            <p></p>


            <h:panelGrid columns="15">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>


                <h:panelGroup rendered="#{StatsSTDBean.iSGroupByopt()}">
                    <h:outputLabel for="groupBy" value="Group by: " />
                    <h:selectOneMenu id="groupBy" value="#{StatsSTDBean.groupBy}"  >
                        <f:selectItems value="#{SessionDataBean.colorBy}" />
                    </h:selectOneMenu>

                </h:panelGroup>


                <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="groupS" value="Secondary Group Filter:" />
                <h:selectOneMenu id="groupS" value="#{StatsSTDBean.groupS}"  >
                    <f:selectItems value="#{StatsSTDBean.allGroupS}" />
                </h:selectOneMenu>



                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Filter (0-1000)" />
                    <h:inputText id="taxFilter" value="#{StatsSTDBean.taxFilter}" required="true" size="3" >
                        <f:validateLongRange minimum="0" maximum="1000"/>
                    </h:inputText>

                </h:panelGroup>


                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Do stats" action="#{StatsSTDBean.getStats}" />

            </h:panelGrid>

            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
        </h:form>

    </div>

    <p></p>
    <div id="data">


        <%--
         <h:outputLink value="#{StatsSTDBean.chartLink}" rendered="#{StatsSTDBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

        <p></p> 


        <div id="intro">

            <f:subview id="inCA" rendered="#{!SessionDataBean.dataMiner}">
                <%@ include file="introCA/stats.html" %>
            </f:subview>
            
            <f:subview id="inDS" rendered="#{SessionDataBean.dataMiner}">
                <%@ include file="introDS/stats.html" %>
            </f:subview>
            
        </div>

        

        <h1><h:outputText value="#{StatsSTDBean.errorm}" style="color: red;"/></h1>
        <p/>

        <center>

            <h:outputText rendered="#{StatsSTDBean.filesGenerated}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
            <h:outputText value="#{StatsSTDBean.tableRows}" escape="false" rendered="#{StatsSTDBean.filesGenerated}"/>
            <h:outputText rendered="#{StatsSTDBean.filesGenerated}" escape="false" value="</table>" />

            <h:outputText value="Click on table header to sort table (Javascript has to be activated)." escape="false" rendered="#{StatsSTDBean.filesGenerated}"/>



            <p></p>

            <h:outputLink value="#{StatsSTDBean.statsFileLink}" rendered="#{StatsSTDBean.filesGenerated}">
                <f:verbatim>Download table in coma separated format</f:verbatim>
            </h:outputLink>

            <p></p><p></p>

            <h:graphicImage id="imageHist"
                            alt=""
                            width="800"
                            height="400"
                            url="#{StatsSTDBean.histLink}"
                            rendered="#{StatsSTDBean.showImage()}">
            </h:graphicImage>

        </center>
    </div>


    <div id="nutshell">

        <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="nutshell/stats.html" %>
        </f:subview>
    </div>


    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
