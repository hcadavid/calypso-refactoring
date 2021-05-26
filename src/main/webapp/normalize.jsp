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
            <h:panelGrid columns="17">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <h:panelGroup rendered="#{! SessionDataBean.dataMiner}">
                    <h:outputLabel for="levelSelect" value="Level" />
                    <h:selectOneMenu id="levelSelect" value="#{NormalizeBean.level}"  >
                        <f:selectItems value="#{SessionDataBean.levels}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                <h:outputLabel for="typeSelect" value="Transformation:" />
                <h:selectOneMenu id="typeSelect" value="#{NormalizeBean.normalization}"  >
                    <f:selectItems value="#{FileUploadBean.normMethods}" />
                </h:selectOneMenu>
               

                <h:outputLabel for="orderSelect" value="Order" />
                <h:selectOneMenu id="orderSelect" value="#{NormalizeBean.orderBy}"  >
                    <f:selectItems value="#{SessionDataBean.orderBy}" />
                </h:selectOneMenu>
                

<h:panelGroup rendered="#{!SessionDataBean.dataMiner}">
                <h:outputLabel for="tss" value="TSS " />
                <h:selectBooleanCheckbox
                    title="tss" id="tss"
                    value="#{NormalizeBean.tss}" >
                </h:selectBooleanCheckbox>
</h:panelGroup>
           
                 <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{NormalizeBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="50" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{NormalizeBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="100" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{NormalizeBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="250" maximum="10000"/>
                </h:inputText>
                <h:outputText value="(mm)"/>
                
                
                 <h:outputLabel value="&nbsp;" escape="false"/>
                
                
                
          

                
                <h:outputLabel value="&nbsp; &nbsp; " escape="false"/>
                <h:commandButton id="submit" value="Draw Chart" action="#{NormalizeBean.getChart}" />

            </h:panelGrid>


             <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
            
        </h:form>

    </div>
    <p></p>
    
    
    
    
    <div id="data">
        <h:graphicImage id="image"
                        alt="alternative"
                        width="#{NormalizeBean.pwidth}"
                        height="#{NormalizeBean.pheight}"
                        url="#{NormalizeBean.chartLink1}"
                        rendered="#{NormalizeBean.fileGenerated}">
        </h:graphicImage>

        <p></p>
        <h:outputLink value="#{NormalizeBean.chartLink1}" target="_blank" rendered="#{NormalizeBean.fileGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>

      
    </div>

    <p/>
    
    <h2>Data Normalization</h2>
    
 <div>
     <h3>Download normalized data:</h3>
     <h:outputLink value="#{NormalizeBean.metaLink}" target="_blank"
                      rendered="#{NormalizeBean.fileGenerated}">
            <f:verbatim>Download meta annotation file in csv format (Right mouse click "Save As").
            </f:verbatim>
        </h:outputLink>
            <p/>
            <h:outputLink value="#{NormalizeBean.countsNormLink}" target="_blank"
                      rendered="#{NormalizeBean.fileGenerated}">
            <f:verbatim>Download normalized data table in csv format (Right mouse click "Save As").
            </f:verbatim>
        </h:outputLink>
             <p/>
            <h:outputLink value="#{NormalizeBean.distLink}" target="_blank"
                      rendered="#{NormalizeBean.showDistLink}">
            <f:verbatim>Download distance matrix in csv format (Right mouse click "Save As").
            </f:verbatim>
        </h:outputLink>
            <p/>
            
            
             The downloaded files can be opened with Excel. Depending
                on your browser, you may need to change the suffix to .csv first.    
           
    </div>
    
    
    

    <h1><h:outputText value="#{NormalizeBean.errorm}" style="color: red;"/></h1>

    <p></p>

    

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
