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
                <h:selectOneMenu id="levelSelect" value="#{PairwiseBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>
                
                
                <h:panelGroup>
                    <h:outputLabel for="typeSelect" value="Type: " />
                    <h:selectOneMenu id="typeSelect" value="#{PairwiseBean.type}"  >
                        <f:selectItems value="#{PairwiseBean.types}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                
                <h:outputLabel value="&nbsp;" escape="false"/>
                <h:commandButton id="submitMode" value="Select Mode" action="#{PairwiseBean.setSelectedMode}" />

            </h:panelGrid>
        </h:form>

        <p></p>

        <h:form rendered="#{! PairwiseBean.selectMode}">
            <h:panelGrid columns="20">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>



                <h:outputText  value="Secondary Group: " style="font-weight: bold; text-decoration: underline;" />
                <h:outputText  value="G1:" />

                <h:selectOneMenu id="first" value="#{PairwiseBean.firstT}"  >
                    <f:selectItems value="#{PairwiseBean.allGroupS}" />
                </h:selectOneMenu>

                <h:outputText value="G2:" />
                <h:selectOneMenu id="second" value="#{PairwiseBean.secondT}">
                    <f:selectItems value="#{PairwiseBean.allGroupS}" />
                </h:selectOneMenu>

             

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:outputLabel for="colorSelect" value="Color: " />
                <h:selectOneMenu id="colorSelect" value="#{PairwiseBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>
                
               
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{PairwiseBean.getChart}" />
            </h:panelGrid>


            <h:panelGrid columns="15">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{PairwiseBean.divopt}">
                    <h:outputLabel for="index" value="Index: " />
                    <h:selectOneMenu id="index" value="#{PairwiseBean.index}"  >
                        <f:selectItems value="#{PairwiseBean.indexTypes}" />
                    </h:selectOneMenu>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

                
                <h:panelGroup>
                    <h:outputLabel for="test" value="Test: " />
                    <h:selectOneMenu id="test" value="#{PairwiseBean.test}"  >
                        <f:selectItems value="#{PairwiseBean.allTests}" />
                    </h:selectOneMenu>
                    </h:panelGroup>
               

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Filter (0-1000)" />
                    <h:inputText id="taxFilter" value="#{PairwiseBean.taxFilter}" required="true" size="3" >
                        <f:validateLongRange minimum="0" maximum="1000"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

                <h:outputLabel for="label" value="Sample IDs: " />
                <h:selectBooleanCheckbox
                    title="label" id="label"
                    value="#{PairwiseBean.label}" >
                </h:selectBooleanCheckbox>

                


                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>


                


            </h:panelGrid>


            <h:panelGrid columns="15">
           
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
           
                <h:panelGroup rendered="#{PairwiseBean.taxasopt}">
                    <h:outputLabel for="taxaSelect" value="Taxa: " rendered="#{!SessionDataBean.dataMiner}"/>
                    <h:outputLabel for="taxaSelect" value="Feature: " rendered="#{SessionDataBean.dataMiner}"/>
                    <h:selectOneMenu id="taxaSelect" value="#{PairwiseBean.taxa}"  >
                        <f:selectItems value="#{PairwiseBean.allTaxa}" />
                    </h:selectOneMenu>
                </h:panelGroup>

                 <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{PairwiseBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{PairwiseBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{PairwiseBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>
            </h:panelGrid>

            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>



        </h:form>

    </div>
    <h2>Paired comparison of samples.</h2>
    <p></p>
   

    <div id="data">
        <center>

            <h:outputText rendered="#{PairwiseBean.tableGenerated}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
            <h:outputText value="#{PairwiseBean.tableRows}" escape="false" rendered="#{PairwiseBean.tableGenerated}"/>
            <h:outputText rendered="#{PairwiseBean.tableGenerated}" escape="false" value="</table>" />
            <h:outputText value="Click on table header to sort table (Javascript has to be activated)." escape="false" rendered="#{PairwiseBean.tableGenerated}"/>

        </center>
        <p></p>
        <h:graphicImage id="imagePhist"
                        alt="p-value distribution"

                        height ="500"
                        url="#{PairwiseBean.chartLink}"
                        rendered="#{PairwiseBean.phistGenerated}">
        </h:graphicImage>


        <h:graphicImage id="image"
                        alt=""
                          width="#{PairwiseBean.pwidth}"
                        height="#{PairwiseBean.pheight}"
                        url="#{PairwiseBean.chartLink}"
                        rendered="#{PairwiseBean.filesGenerated}">
        </h:graphicImage>

        <p></p>

        <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
        <h:outputText value="If the figure is empty, the selected taxa/OTU is not present in both secondary groups. Select a different taxa/OTU." rendered="#{PairwiseBean.showP}" style="text-decoration : underline;"/>
        </h:panelGroup>
        <h:panelGroup rendered="#{SessionDataBean.dataMiner}">
        <h:outputText value="If the figure is empty, the selected feature is not present in both secondary groups. Select a different feature." rendered="#{PairwiseBean.showP}" style="text-decoration : underline;"/>
        </h:panelGroup>
        <p></p>
        

        <h3><h:outputText value="#{PairwiseBean.p}" rendered="#{PairwiseBean.showP}"/></h3>



        <h1><h:outputText value="#{PairwiseBean.errorm}" style="color: red;"/></h1>

        <%--
         <h:outputLink value="#{PairwiseBean.chartLink}" rendered="#{PairwiseBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>

<div id="nutshell">
         
    <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
        <%@ include file="nutshell/paired.html" %>
    </f:subview>
    </div>

    

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
