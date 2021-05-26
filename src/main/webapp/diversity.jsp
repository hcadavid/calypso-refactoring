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
                <h:selectOneMenu id="levelSelect" value="#{DiversityBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>

                <h:outputLabel for="colorSelect" value="Color" />
                <h:selectOneMenu id="colorSelect" value="#{DiversityBean.color}"  >
                    <f:selectItems value="#{SessionDataBean.colors}" />
                </h:selectOneMenu>

                <h:outputLabel for="colorBy" value="Group by: " />
                <h:selectOneMenu id="colorBy" value="#{DiversityBean.colorBy}"  >
                    <f:selectItems value="#{SessionDataBean.colorBy}" />
                </h:selectOneMenu>

            </h:panelGrid>

            <h:panelGrid columns="15" rendered="#{DiversityBean.pairwise}">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="groupA" value="A) Group " />
                <h:selectOneMenu id="groupA" value="#{DiversityBean.groupA}"  >
                    <f:selectItems value="#{SessionDataBean.groups}" />
                </h:selectOneMenu>

                <h:outputLabel for="groupSA" value="Secondary Group " />
                <h:selectOneMenu id="groupSA" value="#{DiversityBean.groupSA}"  >
                    <f:selectItems value="#{SessionDataBean.groupSs}" />
                </h:selectOneMenu>

                <h:outputLabel for="groupB" value="B) Group " />
                <h:selectOneMenu id="groupB" value="#{DiversityBean.groupB}"  >
                    <f:selectItems value="#{SessionDataBean.groups}" />
                </h:selectOneMenu>


                <h:outputLabel for="groupSB" value="Secondary Group " />
                <h:selectOneMenu id="groupSB" value="#{DiversityBean.groupSB}"  >
                    <f:selectItems value="#{SessionDataBean.groupSs}" />
                </h:selectOneMenu>


            </h:panelGrid>



            <h:panelGrid columns="15">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup>
                    <h:outputLabel for="figureFormat" value="Figure Format: " />
                    <h:selectOneMenu id="figureFormat" value="#{DiversityBean.figureFormat}"  >
                        <f:selectItems value="#{SessionDataBean.figureFormats}" />
                    </h:selectOneMenu>                 
                </h:panelGroup>

                <h:outputLabel for="orderSelect" value="Order" />
                <h:selectOneMenu id="orderSelect" value="#{DiversityBean.orderBy}"  >
                    <f:selectItems value="#{SessionDataBean.orderBy}" />
                </h:selectOneMenu>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:panelGroup>
                    <h:outputLabel for="typeSelect" value="Type: " />
                    <h:selectOneMenu id="typeSelect" value="#{DiversityBean.type}"  >
                        <f:selectItems value="#{DiversityBean.types}" />
                    </h:selectOneMenu>
                </h:panelGroup>

                <h:panelGroup>
                    <h:outputLabel for="indexSelect" value="Index: " />
                    <h:selectOneMenu id="indexSelect" value="#{DiversityBean.index}"  >
                        <f:selectItems value="#{DiversityBean.indexTypes}" />
                    </h:selectOneMenu>
                </h:panelGroup>


                


                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{DiversityBean.getChart}" />
            </h:panelGrid>


            <%-- second row of input fields --%>

            <h:panelGrid columns="23">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:outputLabel for="groupS" value="Included secondary group:" />
                <h:selectOneMenu id="groupS" value="#{DiversityBean.groupS}"  >
                    <f:selectItems value="#{DiversityBean.allGroupS}" />
                </h:selectOneMenu>

                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
              

                <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{DiversityBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{DiversityBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{DiversityBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="20" maximum="10000"/>
                </h:inputText>

            </h:panelGrid>


            <h:message for="taxFilter" showSummary="false" style="color: red;"/>
            <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
        </h:form>

    </div>

    <p></p>
    <div id="data">
        <h3>Compare the diversity of different groups of samples, e.g. microbial communities
            of obese vs. lean mice.</h3>
        Note: Uploaded data will directly be used and is not transformed or normalized by TSS (even if selected on upload page).

        <p></p>

        <h:graphicImage id="image"
                        alt=""
                        width="#{DiversityBean.pwidth}"
                        height="#{DiversityBean.pheight}"
                        url="#{DiversityBean.chartLink}"
                        rendered="#{DiversityBean.filesGenerated}">
        </h:graphicImage>
        
        <p></p>
           <h:outputLink value="#{DiversityBean.chartLink}" target="_blank" rendered="#{DiversityBean.filesGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>

        <p></p>

        <h3><h:outputText value="P=#{DiversityBean.p} (anova)" rendered="#{DiversityBean.showP}"/></h3>

        <h1><h:outputText value="#{DiversityBean.errorm}" style="color: red;"/></h1>

        <%--
         <h:outputLink value="#{DiversityBean.chartLink}" rendered="#{DiversityBean.filesGenerated}">
             <f:verbatim>Download chart in PDF</f:verbatim>
         </h:outputLink>
        --%>

    </div>

    <div id="nutshell">
        
        <f:subview id="nut">
            <%@ include file="nutshell/diversity.html" %>
        </f:subview>
    </div>


    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf"%>
    </f:subview>

</f:view>
