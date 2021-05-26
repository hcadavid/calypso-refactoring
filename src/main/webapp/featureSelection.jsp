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
        <h:form>
            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
                    <h:outputLabel for="levelSelect" value="Level" />
                    <h:selectOneMenu id="levelSelect" value="#{FeatureSelectionBean.level}"  >
                        <f:selectItems value="#{SessionDataBean.levels}" />
                    </h:selectOneMenu>
                </h:panelGroup>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:outputLabel for="method" value="Method: " />
                <h:selectOneMenu id="method" value="#{FeatureSelectionBean.method}"  >
                    <f:selectItems value="#{FeatureSelectionBean.methods}" />
                </h:selectOneMenu>



                <h:outputLabel value="&nbsp;" escape="false"/>
                <h:commandButton id="submitMode" value="Select Mode" action="#{FeatureSelectionBean.setSelectedMode}" />

            </h:panelGrid>

        </h:form>

        <p></p>


        <h:form rendered="#{! (FeatureSelectionBean.selectMode)}">

            <p></p>


            <h:panelGrid columns="15">

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>


                <h:panelGroup rendered="#{FeatureSelectionBean.iSGroupByopt()}">
                    <h:outputLabel for="groupBy" value="Group by: " />
                    <h:selectOneMenu id="groupBy" value="#{FeatureSelectionBean.groupBy}"  >
                        <f:selectItems value="#{FeatureSelectionBean.groupNames}" />
                    </h:selectOneMenu>

                </h:panelGroup>


                <h:outputLabel value="&nbsp; &nbsp;" escape="false"/>




                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="taxFilter" value="Filter (0-10000)" />
                    <h:inputText id="taxFilter" value="#{FeatureSelectionBean.taxFilter}" required="true" size="3" >
                        <f:validateLongRange minimum="0" maximum="10000"/>
                    </h:inputText>
                </h:panelGroup>







                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup rendered="#{FeatureSelectionBean.directionOpt}">
                    <h:outputLabel for="direction" value="Direction: " />
                    <h:selectOneMenu id="direction" value="#{FeatureSelectionBean.direction}"  >
                        <f:selectItems value="#{FeatureSelectionBean.directions}" />
                    </h:selectOneMenu>
                </h:panelGroup>




                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Run Analysis" action="#{FeatureSelectionBean.run}" />

            </h:panelGrid>

            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
        </h:form>

    </div>

    <p></p>
    <div id="data">




        <p></p> <h3>Feature Selection</h3>

        <h1><h:outputText value="#{FeatureSelectionBean.errorm}" style="color: red;"/></h1>
        <p/>

        
        <center>


        Identify relevant features associated with an explanatory variable or confounding factor.
        Feature selection methods are based on the premise that data frequently contains 
        many features that are either redundant or irrelevant, and can thus be removed 
        without incurring much loss of information. Feature selection algorithms identify 
        new feature subsets that best predict an outcome of interest (in this case a factor 
        defined in the meta annotation file).
        
        <p/>


            <p></p>



            <p></p><p></p>




            <p/>

            <h:graphicImage id="figure"
                            alt=""
                            width="800"
                            height="1000"
                            url="#{FeatureSelectionBean.figureLink}"
                            rendered="#{FeatureSelectionBean.figuresGenerated}">
            </h:graphicImage>

        </center>
    </div>





    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
