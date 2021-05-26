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
        <h:form rendered="#{!SessionDataBean.dataMiner}">
            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
                    <h:outputLabel for="levelSelect" value="Level" />
                    <h:selectOneMenu id="levelSelect" value="#{TaxaBean.level}"  >
                        <f:selectItems value="#{SessionDataBean.levels}" />
                    </h:selectOneMenu>
                </h:panelGroup>



                <h:outputLabel value="&nbsp;" escape="false"/>
                <h:commandButton id="submitMode" value="Select Mode" action="#{TaxaBean.setSelectedMode}" />

            </h:panelGrid>
        </h:form>

        <p></p>

        <h:form rendered="#{! (TaxaBean.selectMode)}">           

            <p></p>

            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup>



                    <h:outputLabel for="groupBy" value="Group by: " />
                    <h:selectOneMenu id="groupBy" value="#{TaxaBean.groupBy}"  >
                        <f:selectItems value="#{TaxaBean.groupByMode}" />
                    </h:selectOneMenu>




                    <h:outputLabel value="&nbsp; " escape="false"/>
                    <h:outputLabel for="typeSelect" value="Type: " />
                    <h:selectOneMenu id="typeSelect" value="#{TaxaBean.type}"  >
                        <f:selectItems value="#{TaxaBean.types}" />
                    </h:selectOneMenu>
                </h:panelGroup>



                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{TaxaBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>



                <h:outputLabel value="&nbsp; " escape="false"/>
                <h:outputLabel for="groupS" value="Secondary Group:" />
                <h:selectOneMenu id="groupS" value="#{TaxaBean.groupS}"  >
                    <f:selectItems value="#{TaxaBean.allGroupS}" />
                </h:selectOneMenu>


                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{TaxaBean.getChart}" />


            </h:panelGrid>


            <%-- second row of input fields --%>
            <p></p>
            <h:panelGrid columns="23">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>











                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{TaxaBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:panelGroup>
                    <h:outputLabel for="figureFormat" value="Figure Format: " />
                    <h:selectOneMenu id="figureFormat" value="#{TaxaBean.figureFormat}"  >
                        <f:selectItems value="#{SessionDataBean.figureFormats}" />
                    </h:selectOneMenu>                 
                </h:panelGroup>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{TaxaBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="60" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{TaxaBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="60" maximum="10000"/>
                </h:inputText>



            </h:panelGrid>

            <p></p>
            <p></p>
            <h:panelGrid columns="23">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup>
                    <h:outputLabel for="taxaSelect" value="Taxa: " rendered="#{!SessionDataBean.dataMiner}"/>
                    <h:outputLabel for="taxaSelect" value="Feature: " rendered="#{SessionDataBean.dataMiner}"/>
                    <h:selectOneMenu id="taxaSelect" value="#{TaxaBean.taxa}"  >
                        <f:selectItems value="#{TaxaBean.allTaxa}" />
                    </h:selectOneMenu>
                </h:panelGroup>

            </h:panelGrid>


            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="signLevel" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
        </h:form>

    </div>


    <div id="intro">

        <f:subview id="inCA" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="introCA/taxa.html" %>
        </f:subview>

        <f:subview id="inDS" rendered="#{SessionDataBean.dataMiner}">
            <%@ include file="introDS/taxa.html" %>
        </f:subview>

    </div>


    <h1><h:outputText value="#{TaxaBean.errorm}" style="color: red;"/></h1>
    <p></p>

    <div id="data">
        <h:graphicImage id="image"
                        alt=""
                        url="#{TaxaBean.chartLink}"
                        width="#{TaxaBean.pwidth}"
                        height="#{TaxaBean.pheight}"
                        rendered="#{TaxaBean.chartGenerated}">
        </h:graphicImage>

        <p></p>

        <h:outputLink value="#{TaxaBean.chartLink}" target="_blank" rendered="#{TaxaBean.chartGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>

        <p></p>

        <h:graphicImage id="stats"
                        alt="StatsFile"
                        url="#{TaxaBean.statsLink}"
                        rendered="#{TaxaBean.statsGenerated}">
        </h:graphicImage>

        <h:graphicImage id="distPlot"
                        alt="distFile"
                        url="#{TaxaBean.distLink}"
                        rendered="#{TaxaBean.distGenerated}">
        </h:graphicImage>

        <h:graphicImage id="corPlot"
                        alt="correlationFile"
                        url="#{TaxaBean.corLink}"
                        rendered="#{TaxaBean.corGenerated}">
        </h:graphicImage>



        <%--
         <h:outputLink value="#{TaxaBean.chartLink}" rendered="#{TaxaBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>

    <div id="nutshell">

        
    </div>




    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>

