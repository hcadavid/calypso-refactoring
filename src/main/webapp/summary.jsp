<%--
    Document   : summary
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

                
                <h:outputLabel for="typeSelect" value="Type" />
                <h:selectOneMenu id="typeSelect" value="#{SummaryBean.type}"  >
                    <f:selectItems value="#{SummaryBean.types}" />
                </h:selectOneMenu>
                
                
                <h:outputLabel value="&nbsp;" escape="false"/>
                 <h:commandButton id="submitMode" value="Select Mode" action="#{SummaryBean.setSelectedMode}" />
                
                       </h:panelGrid>
        </h:form>
                
        <p></p>

        <h:form rendered="#{! (SummaryBean.selectMode)}">  
               <h:panelGrid columns="15">  
                   <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                   
                   <h:panelGroup rendered="#{SummaryBean.ranksopt}">
                   <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{SummaryBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>
                    </h:panelGroup>
           

                
                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{SummaryBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>


                 <h:outputLabel value="&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{SummaryBean.getChart}" />
            </h:panelGrid>
                <%-- second row of input fields --%>
                <p></p>
 <h:panelGrid columns="17">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:outputLabel for="loh" value="Log scale" />
                <h:selectBooleanCheckbox
                    title="log" id="log"
                    value="#{SummaryBean.logScale}" >
                </h:selectBooleanCheckbox>

                    
                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{SummaryBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{SummaryBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{SummaryBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>
                <h:outputText value="(mm)"/>


                <h:panelGrid columns="17">
                <h:outputLabel for="groupS" value="Secondary Group:" />
                <h:selectOneMenu id="groupS" value="#{SummaryBean.groupS}"  >
                    <f:selectItems value="#{SummaryBean.allGroupS}" />
                    </h:selectOneMenu>
                </h:panelGrid>

            </h:panelGrid>


                <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
        </h:form>

    </div>
    <p></p>
    <h3>This page provides a basic descriptive overview of the uploaded data.</h3>

    <p></p>
    <h1><h:outputText value="#{SummaryBean.errorm}" style="color: red;"/></h1>
    <div id="data">
        <h:graphicImage id="image"
                        alt="summary"
                        url="#{SummaryBean.chartLink}"
                        width="#{SummaryBean.pwidth}"
                        height="#{SummaryBean.pheight}"
                        
                        rendered="#{SummaryBean.fileGenerated}">
        </h:graphicImage>



    </div>

  <div id="nutshell">
         
    <f:subview id="nut">
        <%@ include file="nutshell/summary.html" %>
    </f:subview>
    </div>


    

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
