<%--
    Document   : convert
    Created on : Sep 8, 2011, 9:21:20 AM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t" %>


<!DOCTYPE html>

<f:view>
    <f:subview id="header">
        <jsp:include page="header.jsp" />
    </f:subview>

    <h2>Convert files to Calypso format</h2>

    <h:form id="uploadForm" enctype="multipart/form-data">

        <h:panelGrid columns="15">
            <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
            <h:panelGroup>
                <h:outputLabel for="typeSelect" value="File Format: " />
                <h:selectOneMenu id="typeSelect" value="#{ConvertBean.format}"  >
                    <f:selectItems value="#{ConvertBean.formats}" />
                </h:selectOneMenu>
            </h:panelGroup>
            <h:outputLabel value="&nbsp; " escape="false"/>

            <h:outputLabel for="file" value="Select file: &nbsp; " escape="false"/>
            <t:inputFileUpload id="file" value="#{ConvertBean.file}" required="true" />
            <h:panelGroup />
            <h:commandButton value="Convert" action="#{ConvertBean.convert}" />
            <h:message for="file" style="color: red;" />
            <h:message for="uploadForm" infoStyle="color: green;" errorStyle="color: red;" />
        </h:panelGrid>

    </h:form>

    <p></p>
    <div id="data">

        <h3><h:outputText value="Download the converted file for #{ConvertBean.fileName}:" rendered="#{ConvertBean.converted}" style="color: green;"/></h3>

        <h:outputLink value="#{ConvertBean.convertedLink}" rendered="#{ConvertBean.converted}">
            <f:verbatim>Converted file
            </f:verbatim>
        </h:outputLink><p/>

        <h:outputText value="To download the file, click on \"Conveted file\"
                      with the right mouse button and choose \"Save linked file as\".
                      <br>Convert
                      and download your QIIME files. Next, open and update
                      the calypso annotatio file (e.g. using Excel). 
                      Finally, upload the converted
                      files to Calypso via the "
                      rendered="#{ConvertBean.converted}" escape="false"/>
        <h:outputLink value="faces/uploadFiles.jsp" rendered="#{ConvertBean.converted}">
            Upload Page
        </h:outputLink>

        <h1><h:outputText value="#{ConvertBean.errorm}" style="color: red;"/></h1>



        <%--
         <h:outputLink value="#{GroupsPlotsBean.chartLink}" rendered="#{GroupsPlotsBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>

    <div id="nutshell">
        <h2>In a nutshell</h2>
        <f:subview id="nut">
            <%@ include file="nutshell/convert.html" %>
        </f:subview>
    </div>


    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>
</f:view>