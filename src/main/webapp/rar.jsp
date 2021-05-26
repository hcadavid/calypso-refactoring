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
                <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{RarefactionBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>

                
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{RarefactionBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                 <h:outputLabel for="colorBy" value="Color by: " />
                <h:selectOneMenu id="colorBy" value="#{RarefactionBean.colorBy}"  >
                    <f:selectItems value="#{SessionDataBean.colorBy}" />
                </h:selectOneMenu>
            
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{RarefactionBean.getChart}" />
            </h:panelGrid>


            <%-- second row of input fields --%>
            <p></p>
            <h:panelGrid columns="23">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{RarefactionBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{RarefactionBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{RarefactionBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>
                <h:outputText value="(mm)"/>
                
            </h:panelGrid>
            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
        </h:form>

    </div>
<div align="center" style="padding-left:2cm; padding-right:2cm;">
    <p></p>
<h3>Rarefaction analysis to assess how well underlying communities are represented by sampled reads.</h3>

</div>
    <div id="data">

        <h:graphicImage id="image"
                        alt=""
                        width="#{RarefactionBean.pwidth}"
                        height="#{RarefactionBean.pheight}"
                        url="#{RarefactionBean.chartLink}"
                        rendered="#{RarefactionBean.filesGenerated}">
        </h:graphicImage>

        <p></p>



        <h1><h:outputText value="#{RarefactionBean.errorm}" style="color: red;"/></h1>

        <%--
         <h:outputLink value="#{RarefactionBean.chartLink}" rendered="#{RarefactionBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>


 <div id="nutshell">
        
    <f:subview id="nut">
        <%@ include file="nutshell/rar.html" %>
    </f:subview>
    </div>
    

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
