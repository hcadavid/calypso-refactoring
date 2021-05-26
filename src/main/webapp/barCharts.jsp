<%-- 
    Document   : barCharts
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
        <h:form>
            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{! SessionDataBean.dataMiner}">
                    <h:outputLabel for="levelSelect" value="Level" />
                    <h:selectOneMenu id="levelSelect" value="#{BarChartsBean.level}"  >
                        <f:selectItems value="#{SessionDataBean.levels}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                <h:outputLabel for="typeSelect" value="Type" />
                <h:selectOneMenu id="typeSelect" value="#{BarChartsBean.type}"  >
                    <f:selectItems value="#{BarChartsBean.types}" />
                </h:selectOneMenu>
               

                <h:outputLabel for="orderSelect" value="Order" />
                <h:selectOneMenu id="orderSelect" value="#{BarChartsBean.orderBy}"  >
                    <f:selectItems value="#{SessionDataBean.orderBy}" />
                </h:selectOneMenu>
                

                <h:outputLabel value="&nbsp;" escape="false"/>
                <h:commandButton id="submitMode" value="Select Mode" action="#{BarChartsBean.setSelectedMode}" />


            </h:panelGrid>

            <%-- second row of input fields --%>

            <p></p>

            <h:panelGrid columns="17">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>



                <h:outputLabel for="legend" value="Show legend " />
                <h:selectBooleanCheckbox
                    title="legend" id="legend"
                    value="#{BarChartsBean.legend}" >
                </h:selectBooleanCheckbox>
                
                <h:outputLabel value="&nbsp;" escape="false"/>

                <h:panelGroup rendered="#{BarChartsBean.showColor}">
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{BarChartsBean.color}"  >
                    <f:selectItems value="#{BarChartsBean.colors}" />
                </h:selectOneMenu>
                </h:panelGroup>
                
                 <h:panelGroup rendered="#{BarChartsBean.filter}">
                    <h:outputLabel for="taxFilter" value="Filter (0-10000)" />
                    <h:inputText id="taxFilter" value="#{BarChartsBean.taxFilter}" required="true"
                                 size="5">
                        <f:validateLongRange minimum="0" maximum="10000"/>
                    </h:inputText>
                </h:panelGroup>
                
                 <h:outputLabel value="&nbsp;" escape="false"/>
                
                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{BarChartsBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{BarChartsBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{BarChartsBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>
                <h:outputText value="(mm)"/>
                
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{BarChartsBean.getChart}" />

            </h:panelGrid>

            <h:panelGrid columns="17" rendered="#{BarChartsBean.notTable}">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup>
                    <h:outputLabel for="figureFormat" value="Figure Format: " />
                    <h:selectOneMenu id="figureFormat" value="#{BarChartsBean.figureFormat}"  >
                        <f:selectItems value="#{SessionDataBean.figureFormats}" />
                    </h:selectOneMenu>                 
                </h:panelGroup>

                <h:outputLabel for="groupS" value="Secondary Group:" />
                <h:selectOneMenu id="groupS" value="#{BarChartsBean.groupS}"  >
                    <f:selectItems value="#{BarChartsBean.allGroupS}" />
                </h:selectOneMenu>

                <h:outputLabel for="signLevel" value="Significance Level (Anova, primary group):" />
                <h:inputText id="signLevel" value="#{BarChartsBean.signLevel}" required="true" size="6" >
                    <f:validateDoubleRange minimum="0" maximum="1"/>
                </h:inputText>
            </h:panelGrid> 

            <h:panelGrid columns="17" rendered="#{BarChartsBean.heatmap}">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>


                <h:outputLabel for="reOrder" value="ReOrder Samples: " />
                <h:selectBooleanCheckbox
                    title="reOrder" id="reOrder"
                    value="#{BarChartsBean.reOrder}" >
                </h:selectBooleanCheckbox>

                <h:outputLabel for="scale" value="Scale data: " />
                <h:selectBooleanCheckbox
                    title="scale" id="scale"
                    value="#{BarChartsBean.scale}" >
                </h:selectBooleanCheckbox>

                
                <h:outputLabel for="trim" value="&nbsp;&nbsp;Remove outliers, trim values by:" escape="false" />
                <h:inputText id="trim" value="#{BarChartsBean.trim}" required="true" size="8" >
                    <f:validateDoubleRange minimum="0" maximum="10000000000000"/>
                </h:inputText>
                
                <h:outputLabel for="center" value="&nbsp;Color center:" escape="false"/>
                <h:inputText id="center" value="#{BarChartsBean.cc}" required="true" size="8" >
                    <f:validateDoubleRange minimum="0" maximum="10000000000000"/>
                </h:inputText>

            </h:panelGrid>

            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
            <h:message for="signLevel" showSummary="false" style="color: red;"/>
            <h:message for="trim" showSummary="false" style="color: red;"/>
        </h:form>

    </div>
    <p></p>
    
    <div id="intro">

            <f:subview id="inCA" rendered="#{!SessionDataBean.dataMiner}">
                <%@ include file="introCA/barCharts.html" %>
            </f:subview>
            
            <f:subview id="inDS" rendered="#{SessionDataBean.dataMiner}">
                <%@ include file="introDS/barCharts.html" %>
            </f:subview>
            
        </div>
    
    
    <div id="data">
        <h:graphicImage id="image"
                        alt="alternative"
                        width="#{BarChartsBean.pwidth}"
                        height="#{BarChartsBean.pheight}"
                        url="#{BarChartsBean.chartLink}"
                        rendered="#{BarChartsBean.fileGenerated}">
        </h:graphicImage>

        <p></p>
        <h:outputLink value="#{BarChartsBean.chartLink}" target="_blank" rendered="#{BarChartsBean.fileGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>

        <h:outputText rendered="#{BarChartsBean.tableGenerated}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
      
        <h:outputText value="#{BarChartsBean.tableRowsNorm}" escape="false" rendered="#{BarChartsBean.tableGenerated}"/>
        <h:outputText rendered="#{BarChartsBean.tableGenerated}" escape="false" value="</table>" />
    </div>

    <p></p>
    <div>
        <h:outputLink value="getTable.jsp" rendered="#{false}">
            <f:verbatim>Download (normalized) data table in csv format. 
            </f:verbatim>
        </h:outputLink>
          
    </div>
  
    
  
    
    <div>
        <h:outputLink value="#{BarChartsBean.countsNormLink}" target="_blank"
                      rendered="#{BarChartsBean.showTableLink}">
            <f:verbatim>Download (normalized) data table in csv format (Right mouse click "Save As"). The downloaded file can be opened with Excel. Depending
                on your browser, you may need to change the suffix to .csv first.    
            </f:verbatim>
        </h:outputLink>
           
    </div>
    
    

    <h1><h:outputText value="#{BarChartsBean.errorm}" style="color: red;"/></h1>

    <p></p>

    <div id="nutshell">
        
        <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="nutshell/barCharts.html" %>
        </f:subview>
    </div>

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
