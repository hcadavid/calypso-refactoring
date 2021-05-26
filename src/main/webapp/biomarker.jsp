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
                <h:selectOneMenu id="levelSelect" value="#{BiomarkerBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                </h:panelGroup>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:outputLabel for="test" value="Test: " />
                <h:selectOneMenu id="test" value="#{BiomarkerBean.test}"  >
                    <f:selectItems value="#{BiomarkerBean.tests}" />
                </h:selectOneMenu>



                <h:outputLabel value="&nbsp;" escape="false"/>
                <h:commandButton id="submitMode" value="Select Mode" action="#{BiomarkerBean.setSelectedMode}" />

            </h:panelGrid>

        </h:form>

        <p></p>


        <h:form rendered="#{! (BiomarkerBean.selectMode)}">

            <p></p>


            <h:panelGrid columns="15">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>


                <h:panelGroup rendered="#{BiomarkerBean.iSGroupByopt()}">
                    <h:outputLabel for="groupBy" value="Group by: " />
                    <h:selectOneMenu id="groupBy" value="#{BiomarkerBean.groupBy}"  >
                        <f:selectItems value="#{BiomarkerBean.groupNames}" />
                    </h:selectOneMenu>

                </h:panelGroup>


                <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>


                

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Filter (0-10000)" />
                    <h:inputText id="taxFilter" value="#{BiomarkerBean.taxFilter}" required="true" size="3" >
                        <f:validateLongRange minimum="0" maximum="10000"/>
                    </h:inputText>

                     <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                    <h:panelGroup >
                        <h:outputLabel for="inverse" value="Invert OR,Delta and FoldChange" />
                        <h:selectBooleanCheckbox
                            title="inverse" id="inverse"
                            value="#{BiomarkerBean.inverseOR}">
                        </h:selectBooleanCheckbox>
                    </h:panelGroup>




                </h:panelGroup>


                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Run Analysis" action="#{BiomarkerBean.getBiomarker}" />

            </h:panelGrid>

            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
        </h:form>

    </div>

    <p></p>
    <div id="data">


        <%--
         <h:outputLink value="#{BiomarkerBean.chartLink}" rendered="#{BiomarkerBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

        <p></p> <h3>Biomarker Discovery.</h3>Compare two groups, calculate
        p-values, Area Under the ROC Curve (AUC) and Odds-ratios (OR). 
        <p/>
        Set
        test to "LogisticRegression" to adjust p-values, AUC and OR for 
        covariates (all covariates defined in meta annotation file).
        <p/>
        Biomarker discovery can only be applied to data sets with exactly two groups.
        <p/>
        
        <h1><h:outputText value="#{BiomarkerBean.errorm}" style="color: red;"/></h1>
        <p/>

        <center>

            <h:outputText rendered="#{BiomarkerBean.filesGenerated}" escape="false" value="<table border=\"1\" cellpadding=\"2\" cellspacing=\"0\" rules=\"all\" style=\"border:solid 2px\" class=\"sortable\">" />
            <h:outputText value="#{BiomarkerBean.table}" escape="false" rendered="#{BiomarkerBean.filesGenerated}"/>
            <h:outputText rendered="#{BiomarkerBean.filesGenerated}" escape="false" value="</table>" />

            <h:outputText value="Click on table header to sort table (Javascript has to be activated)." escape="false" rendered="#{BiomarkerBean.filesGenerated}"/>



            <p></p>

            <h:outputLink value="#{BiomarkerBean.resultsFileLink}" rendered="#{BiomarkerBean.filesGenerated}">
                <f:verbatim>Download table in comma separated format</f:verbatim>
            </h:outputLink>

            <p></p><p></p>


            <h:graphicImage id="imageOR"
                            alt=""
                            width="800"
                            height="800"
                            url="#{BiomarkerBean.orLink}"
                            rendered="#{BiomarkerBean.figuresGenerated}">
            </h:graphicImage>
            
                <p/>

            <h:graphicImage id="imageHist"
                            alt=""
                            width="800"
                            height="400"
                            url="#{BiomarkerBean.histLink}"
                            rendered="#{BiomarkerBean.figuresGenerated}">
            </h:graphicImage>

        </center>
    </div>


    <div id="nutshell" >
        
        <f:subview id="nut" rendered="#{!SessionDataBean.dataMiner}">
            <%@ include file="nutshell/biomarker.html" %>
        </f:subview>
    </div>


    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
