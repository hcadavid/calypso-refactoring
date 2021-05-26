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
                
                <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{GroupsPlotsBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                </h:panelGroup>

                <h:panelGroup >
                    <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>
                   
                    <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>
                    <h:outputLabel for="groupBy" value="Group by: " />
                    <h:selectOneMenu id="groupBy" value="#{GroupsPlotsBean.groupBy}"  >
                        <f:selectItems value="#{GroupsPlotsBean.groupByMode}" />
                    </h:selectOneMenu>
                    
                    
                    
                    <h:panelGroup >
                    <h:outputLabel value="&nbsp; " escape="false"/>
                    <h:outputLabel for="typeSelect" value="Type: " />
                    <h:selectOneMenu id="typeSelect" value="#{GroupsPlotsBean.type}"  >
                        <f:selectItems value="#{GroupsPlotsBean.types}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                    

                    <h:outputLabel value="&nbsp;" escape="false"/>
                    <h:commandButton id="submitMode" value="Select Mode" action="#{GroupsPlotsBean.setSelectedMode}" />
                </h:panelGroup>
            </h:panelGrid>
        </h:form>

        <p></p>

        <h:form rendered="#{! (GroupsPlotsBean.selectMode)}">           

            <p></p>

            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                
                <h:panelGroup>
                    <h:outputLabel for="figureFormat" value="Figure Format: " />
                    <h:selectOneMenu id="figureFormat" value="#{GroupsPlotsBean.figureFormat}"  >
                        <f:selectItems value="#{SessionDataBean.figureFormats}" />
                    </h:selectOneMenu>                 
                </h:panelGroup>
                
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{GroupsPlotsBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>
                
               

                <h:outputLabel value="&nbsp; " escape="false"/>
                <h:outputLabel for="groupS" value="Secondary Group:" />
                <h:selectOneMenu id="groupS" value="#{GroupsPlotsBean.groupS}"  >
                    <f:selectItems value="#{GroupsPlotsBean.allGroupS}" />
                </h:selectOneMenu>

                
  <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{GroupsPlotsBean.getChart}" />
                
               
            </h:panelGrid>


            <%-- second row of input fields --%>
            <p></p>
            <h:panelGrid columns="23">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
               
                
                <h:panelGroup rendered="#{GroupsPlotsBean.distopt}">
                    <h:outputLabel for="distSelect" value="Distance Method: " />
                    <h:selectOneMenu id="distSelect" value="#{GroupsPlotsBean.distMethod}"  >
                        <f:selectItems value="#{SessionDataBean.distmethods}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                
                <h:panelGroup rendered="#{GroupsPlotsBean.signlopt}">
                    <h:outputLabel for="signLevel" value="Significance level: " />
                    <h:inputText id="signLevel" value="#{GroupsPlotsBean.signLevel}" required="true" size="6">
                        <f:validateDoubleRange minimum="0" maximum="1"/>
                    </h:inputText>                    
                </h:panelGroup>
                
                <h:outputLabel value="&nbsp; " escape="false"/>
                
                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Fitler (0-1000)" />
                    <h:inputText id="taxFilter" value="#{GroupsPlotsBean.taxFilter}" required="true" size="3">
                        <f:validateLongRange minimum="0" maximum="1000"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; " escape="false"/>
                </h:panelGroup>

                <h:panelGroup rendered="#{GroupsPlotsBean.coreopt}">
                    <h:outputLabel for="coreMin" value="core: relation of samples in group" />
                    <h:inputText id="coreMin" value="#{GroupsPlotsBean.coreMin}" required="true" size="3">
                        <f:validateDoubleRange minimum="0" maximum="1"/>
                    </h:inputText>                    
                </h:panelGroup>               
               

 
               

                <h:outputLabel for="grid" value="Gridline: " />
                <h:selectBooleanCheckbox
                    title="grid" id="grid"
                    value="#{GroupsPlotsBean.grid}" >
                </h:selectBooleanCheckbox>

               


                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{GroupsPlotsBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{GroupsPlotsBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="60" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{GroupsPlotsBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="60" maximum="10000"/>
                </h:inputText>

                
               
            </h:panelGrid>

             <p></p>
            


            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="signLevel" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
        </h:form>

    </div>
    
    <div id="intro">

            <f:subview id="inCA" rendered="#{!SessionDataBean.dataMiner}">
                <%@ include file="introCA/groupPlots.html" %>
            </f:subview>
            
            <f:subview id="inDS" rendered="#{SessionDataBean.dataMiner}">
                <%@ include file="introDS/groupPlots.html" %>
            </f:subview>
            
        </div>
    
    

    <h1><h:outputText value="#{GroupsPlotsBean.errorm}" style="color: red;"/></h1>
    <p></p>

    <div id="data">
        <h:graphicImage id="image"
                        alt=""
                        url="#{GroupsPlotsBean.chartLink}"
                        width="#{GroupsPlotsBean.pwidth}"
                        height="#{GroupsPlotsBean.pheight}"
                        rendered="#{GroupsPlotsBean.chartGenerated}">
        </h:graphicImage>

        <p></p>
        
        <h:outputLink value="#{GroupsPlotsBean.chartLink}" target="_blank" rendered="#{GroupsPlotsBean.chartGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>

            <p></p>
            
        <h:outputText rendered="#{GroupsPlotsBean.tableGenerated}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
        <h:outputText value="#{GroupsPlotsBean.tableRows}" escape="false" rendered="#{GroupsPlotsBean.tableGenerated}"/>
        <h:outputText rendered="#{GroupsPlotsBean.tableGenerated}" escape="false" value="</table>" />
        
        <p></p>    
        <h:graphicImage id="stats"
                        alt="StatsFile"
                        url="#{GroupsPlotsBean.statsLink}"
                        rendered="#{GroupsPlotsBean.statsGenerated}">
        </h:graphicImage>

        <h:graphicImage id="distPlot"
                        alt="distFile"
                        url="#{GroupsPlotsBean.distLink}"
                        rendered="#{GroupsPlotsBean.distGenerated}">
        </h:graphicImage>

        <h:graphicImage id="corPlot"
                        alt="correlationFile"
                        url="#{GroupsPlotsBean.corLink}"
                        rendered="#{GroupsPlotsBean.corGenerated}">
        </h:graphicImage>



        <%--
         <h:outputLink value="#{GroupsPlotsBean.chartLink}" rendered="#{GroupsPlotsBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>

    <div id="nutshell">
        
        <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="nutshell/groupPlots.html" %>
        </f:subview>
    </div>




    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
