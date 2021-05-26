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
            <h:panelGrid columns="18">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
             
                <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
                <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{CorrelationBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                </h:panelGroup>
                
                
                <h:outputLabel value="&nbsp; " escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="typeSelect" value="Type: " />
                    <h:selectOneMenu id="typeSelect" value="#{CorrelationBean.type}"  >
                        <f:selectItems value="#{CorrelationBean.types}" />
                    </h:selectOneMenu>
                </h:panelGroup>

                <h:outputLabel value="&nbsp; " escape="false"/>
             
                 

                 <h:panelGroup>
                      <h:outputLabel value="&nbsp;" escape="false"/>
                    <h:outputLabel for="figureFormat" value="Figure Format: " />
                    <h:selectOneMenu id="figureFormat" value="#{CorrelationBean.figureFormat}"  >
                        <f:selectItems value="#{SessionDataBean.figureFormats}" />
                    </h:selectOneMenu>
                    
                </h:panelGroup>
                
                <h:outputLabel value="&nbsp;" escape="false"/>
                    <h:commandButton id="submitMode" value="Select Mode" action="#{CorrelationBean.setSelectedMode}" />
                
            </h:panelGrid>
  <p></p>
               <h:panelGrid columns="23" rendered="#{ CorrelationBean.plot}">
              <h:outputLabel value="&nbsp; &nbsp; &nbsp;First value" escape="false"/>
               <h:panelGroup>
               <h:selectOneMenu id="firSelect" value="#{CorrelationBean.env}"  >
                    <f:selectItems value="#{SessionDataBean.colorBy}" />
               </h:selectOneMenu>
               </h:panelGroup>

            <h:outputLabel value="&nbsp; &nbsp; &nbsp;Second value" escape="false"/>
               <h:panelGroup>
               <h:selectOneMenu id="secSelect" value="#{CorrelationBean.envTaxa}"  >
                    <f:selectItems value="#{CorrelationBean.envAndTaxa}" />
               </h:selectOneMenu>
               </h:panelGroup>    
               
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;Third value (optional)" escape="false"/>
               <h:panelGroup>
               <h:selectOneMenu id="thiSelect" value="#{CorrelationBean.taxa}"  >
                        <f:selectItems value="#{CorrelationBean.opt}" />
                    </h:selectOneMenu>
               </h:panelGroup>
              </h:panelGrid>  
            <%-- second row of input fields --%>
            <p></p>
            <h:panelGrid columns="23" rendered="#{! (CorrelationBean.selectMode)}">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Filter (0-1000)" />
                    <h:inputText id="taxFilter" value="#{CorrelationBean.taxFilter}" required="true" size="3" >
                        <f:validateLongRange minimum="0" maximum="1000"/>
                    </h:inputText>
                   
                </h:panelGroup>

                <h:outputLabel value="&nbsp; " escape="false"/>
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{CorrelationBean.color}"  >
                    <f:selectItems value="#{CorrelationBean.colors}" />
                </h:selectOneMenu>
                
                

                <h:panelGroup rendered="#{(CorrelationBean.nodeXYopt)}">
                    <h:outputLabel for="nodeX" value="Number of Nodes " />
                    <h:inputText id="nodeX" value="#{CorrelationBean.nodeX}" required="true" size="1" >
                    <f:validateLongRange minimum="1" maximum="6"/>
                    </h:inputText>
                    <h:inputText id="nodeY" value="#{CorrelationBean.nodeY}" required="true" size="1" >
                    <f:validateLongRange minimum="1" maximum="6"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{CorrelationBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{CorrelationBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{CorrelationBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>
                 <h:outputText value="(mm)"/>
               
                 <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{CorrelationBean.getChart}" />
                 
            </h:panelGrid>
            

             <h:panelGrid columns="23" rendered="#{ CorrelationBean.networksopt}">
                 
                  <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                 
            <h:panelGroup rendered="#{(CorrelationBean.corindexopt)}">
                    <h:outputLabel for="distSelect" value="Correlation coefficient: " />
                    <h:selectOneMenu id="distSelect" value="#{CorrelationBean.corIndex}"  >
                        <f:selectItems value="#{CorrelationBean.corIndexS}" />
                    </h:selectOneMenu>
                    <h:outputLabel value="&nbsp;" escape="false"/>
                </h:panelGroup>
                 
                <h:panelGroup>
                    <h:outputLabel for="minSim" value="Edge Min Similarity " />
                    <h:inputText id="minSim" value="#{CorrelationBean.minSim}" required="true" size="4" >
                    <f:validateDoubleRange minimum="0" maximum="1"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp;" escape="false"/>
                </h:panelGroup>

                <h:panelGroup>
                    <h:outputLabel for="vSize" value="Vertex Size " />
                    <h:inputText id="vSize" value="#{CorrelationBean.vSize}" required="true" size="4" >
                    <f:validateLongRange minimum="1" maximum="100"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; " escape="false"/>
                </h:panelGroup>


                <h:outputLabel for="layout" value="Layout By Correlation: " />
                <h:selectBooleanCheckbox
                    title="layout" id="layout"
                    value="#{CorrelationBean.corLayout}" >
                </h:selectBooleanCheckbox>

                <h:outputLabel for="overlap" value="Avoid Overlapping Nodes: " />
                <h:selectBooleanCheckbox
                    title="overlap" id="overlap"
                    value="#{CorrelationBean.aoverlap}" >
                </h:selectBooleanCheckbox>
                <h:outputLabel value="&nbsp; " escape="false"/>
                

                  </h:panelGrid>
            
            

            
             <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
             <h:message for="minSim" showSummary="false" style="color: red;"/>
              <h:message for="vSize" showSummary="false" style="color: red;"/>
              <h:message for="nodeX" showSummary="false" style="color: red;"/>
              <h:message for="nodeY" showSummary="false" style="color: red;"/>


        </h:form>

    </div>

    <p></p>
    
    <div id="intro">

            <f:subview id="inCA" rendered="#{!SessionDataBean.dataMiner}">
                <%@ include file="introCA/correlation.html" %>
            </f:subview>
            
            <f:subview id="inDS" rendered="#{SessionDataBean.dataMiner}">
                <%@ include file="introDS/correlation.html" %>
            </f:subview>
            
        </div>
    
    
    <div id="data">

       

        <h:graphicImage id="image"
                        alt=""
                         width="#{CorrelationBean.pwidth}"
                        height="#{CorrelationBean.pheight}"
                        url="#{CorrelationBean.chartLink}"
                        rendered="#{CorrelationBean.filesGenerated}">
        </h:graphicImage>

        <p></p>
           <h:outputLink value="#{CorrelationBean.chartLink}" target="_blank" rendered="#{CorrelationBean.filesGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>
       
        
        <p></p>
        Note, if the figure is completely white increase the width and height.


        
        
        
        <h1><h:outputText value="#{CorrelationBean.errorm}" style="color: red;"/></h1>

        <%--
         <h:outputLink value="#{CorrelationBean.chartLink}" rendered="#{CorrelationBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>

        <div id="nutshell">
        
    <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
        <%@ include file="nutshell/correlation.html" %>
    </f:subview>
    </div>


    
    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
