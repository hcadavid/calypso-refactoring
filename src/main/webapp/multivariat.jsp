<%--
    Document   :     GroupsPlots
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
                
                <h:panelGroup rendered="#{! SessionDataBean.dataMiner}">
                <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{MultivariatBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

               
                
                
                <h:panelGroup>
                    <h:outputLabel for="typeSelect" value="Type: " />
                    <h:selectOneMenu id="typeSelect" value="#{MultivariatBean.type}"  >
                        <f:selectItems value="#{MultivariatBean.types}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                
                <h:panelGroup>
                    <h:outputLabel for="figureFormat" value="Figure Format: " />
                    <h:selectOneMenu id="figureFormat" value="#{MultivariatBean.figureFormat}"  >
                        <f:selectItems value="#{SessionDataBean.figureFormats}" />
                    </h:selectOneMenu>
                    
                </h:panelGroup>
                
                
                
                <h:outputLabel value="&nbsp;" escape="false"/>
                 <h:commandButton id="submitMode" value="Select Mode" action="#{MultivariatBean.setSelectedMode}" />
                
            </h:panelGrid>
        </h:form>
                
        <p></p>

        <h:form rendered="#{! (MultivariatBean.selectMode)}">           

            <p></p>
        <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                
                <h:outputLabel for="colorBy" value="Group/Color by: "/>
                
                <h:selectOneMenu id="colorBy" value="#{MultivariatBean.colorBy}"  >
                    <f:selectItems value="#{SessionDataBean.colorBy}" />
                </h:selectOneMenu>
               
                <h:panelGroup rendered="#{MultivariatBean.symbolopt}">
                <h:outputLabel for="symbolBy" value="Symbol by" />
                <h:selectOneMenu id="symbolBy" value="#{MultivariatBean.symbolBy}"  >
                    <f:selectItems value="#{SessionDataBean.colorBy}" />
                </h:selectOneMenu>
                 </h:panelGroup>
            
                <h:outputLabel value="&nbsp; " escape="false"/>

               


                <h:panelGroup rendered="#{MultivariatBean.componentsopt}">
                <h:outputLabel for="first" value="Components:" />
                <h:selectOneMenu id="first" value="#{MultivariatBean.firstC}"  >
                    <f:selectItems value="#{MultivariatBean.components}" />
                </h:selectOneMenu>
                <h:selectOneMenu id="second" value="#{MultivariatBean.secondC}"  >
                    <f:selectItems value="#{MultivariatBean.components}" />
                </h:selectOneMenu>
                 </h:panelGroup>

                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Filter (0-1000)" />
                    <h:inputText id="taxFilter" value="#{MultivariatBean.taxFilter}" required="true" size="3" >
                         <f:validateLongRange minimum="0" maximum="1000"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>
                
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{MultivariatBean.getChart}" />
         
                
                  </h:panelGrid>

        
         

            <%-- second row of input fields --%>
           
            <h:panelGrid columns="23">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                
                
              
                
                <h:panelGroup rendered="#{MultivariatBean.showLegendOpt}">
            <h:outputLabel for="legend" value="Show legend" />
                <h:selectBooleanCheckbox
                    title="legend" id="legend"
                    value="#{MultivariatBean.legend}" >
                </h:selectBooleanCheckbox>
                </h:panelGroup>
                
                <h:panelGroup rendered="#{MultivariatBean.colorOpt}">
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{MultivariatBean.color}"  >
                    <f:selectItems value="#{MultivariatBean.colors}" />
                </h:selectOneMenu>
                </h:panelGroup>
                
                <h:panelGroup rendered="#{MultivariatBean.loadingsopt}">
              <h:outputLabel for="loadings" value="Loadings: " />
             <h:selectBooleanCheckbox
                    title="loadings" id="loadings"
                    value="#{MultivariatBean.loadings}" >
                </h:selectBooleanCheckbox>
                </h:panelGroup>

              <h:panelGroup rendered="#{MultivariatBean.sampleIDopt}">
             <h:outputLabel for="label" value="Sample IDs: " />
             <h:selectBooleanCheckbox
                    title="label" id="label"
                    value="#{MultivariatBean.label}" >
                   </h:selectBooleanCheckbox>
              </h:panelGroup>
             

                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{MultivariatBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{MultivariatBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{MultivariatBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>
                    <h:outputText value="(mm)"/>

                
            </h:panelGrid>


             <h:panelGrid columns="23">
                 <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
               
                  <h:outputLabel for="groupS" value="Secondary Group:" />
                <h:selectOneMenu id="groupS" value="#{MultivariatBean.groupS}"  >
                    <f:selectItems value="#{MultivariatBean.allGroupS}" />
                </h:selectOneMenu>
                
                <h:outputLabel value="&nbsp;" escape="false"/>
                 
                 <h:panelGroup rendered="#{MultivariatBean.distopt}">
                    <h:outputLabel for="distSelect" value="Distance Metric: " />
                    <h:selectOneMenu id="distSelect" value="#{MultivariatBean.distMethod}"  >
                        <f:selectItems value="#{SessionDataBean.distmethods}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                            
                 <h:panelGroup rendered="#{MultivariatBean.networkopt}">
                    <h:outputLabel for="minSim" value="Edge Min Similarity " />
                    <h:inputText id="minSim" value="#{MultivariatBean.minSim}" required="true" size="4" >
                    <f:validateDoubleRange minimum="0" maximum="1"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

                <h:panelGroup rendered="#{MultivariatBean.networkopt}">
                    <h:outputLabel for="vSize" value="Vertex Size " />
                    <h:inputText id="vSize" value="#{MultivariatBean.vSize}" required="true" size="4" >
                    <f:validateLongRange minimum="1" maximum="40"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>
                 
                     
            <h:panelGroup rendered="#{MultivariatBean.hullopt}">
                <h:outputLabel for="hull" value="Hull: " />
                <h:selectOneMenu id="hull" value="#{MultivariatBean.hull}"  >
                    <f:selectItems value="#{MultivariatBean.hulls}" />
                </h:selectOneMenu>
                 </h:panelGroup>

                  </h:panelGrid>

        <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
            <h:message for="minSim" showSummary="false" style="color: red;"/>
            <h:message for="vSize" showSummary="false" style="color: red;"/>
        </h:form>

    </div>

    <p></p>
    <div id="data">



        <h3>Multivariate analysis.</h3>

           <h1><h:outputText value="#{MultivariatBean.errorm}" style="color: red;"/></h1>

        <p></p>
        
        <h:graphicImage id="image"
                        alt=""
                         width="#{MultivariatBean.pwidth}"
                        height="#{MultivariatBean.pheight}"
                        url="#{MultivariatBean.chartLink}"
                        rendered="#{MultivariatBean.filesGenerated}">
        </h:graphicImage>
        
        <p></p>
           <h:outputLink value="#{MultivariatBean.chartLink}" target="_blank" rendered="#{MultivariatBean.filesGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>
            <p/>
        <h:graphicImage id="ccat"
                        alt=""
                         width="900"
                        height="900"
                        url="#{MultivariatBean.ccaTableLink}"
                        rendered="#{MultivariatBean.showCCATable}">
        </h:graphicImage>

        

     

        <%--
         <h:outputLink value="#{MultivariatBean.chartLink}" rendered="#{MultivariatBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>


<div id="nutshell" >
        
    <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
        <%@ include file="nutshell/multivariat.html" %>
    </f:subview>
    </div>
    

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
