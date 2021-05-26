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
                    <h:selectOneMenu id="levelSelect" value="#{FactorAnalysisBean.level}"  >
                        <f:selectItems value="#{SessionDataBean.levels}" />
                    </h:selectOneMenu>
                </h:panelGroup>
                
                 <h:outputLabel for="factors" value="Number of factors" />
                <h:inputText id="factors" value="#{FactorAnalysisBean.factors}" required="true" size="4" >
                    <f:validateLongRange minimum="0" maximum="1000"/>
                </h:inputText>
                
                
                <h:panelGroup>
                    <h:outputLabel for="algorithm" value="Algorithm: " />
                    <h:selectOneMenu id="algorithm" value="#{FactorAnalysisBean.algorithm}"  >
                        <f:selectItems value="#{FactorAnalysisBean.algorithms}" />
                    </h:selectOneMenu>
                </h:panelGroup>
           
                 <h:outputLabel for="resolution" value="Resolution" />
                <h:inputText id="resolution" value="#{FactorAnalysisBean.resolution}" required="true" size="4" >
                    <f:validateLongRange minimum="50" maximum="1000"/>
                </h:inputText>

                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{FactorAnalysisBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="100" maximum="10000"/>
                </h:inputText>


                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height" value="#{FactorAnalysisBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="250" maximum="10000"/>
                </h:inputText>
                <h:outputText value="(mm)"/>
                
                
                 <h:outputLabel value="&nbsp;" escape="false"/>
                
                
                
          

                
                <h:outputLabel value="&nbsp; &nbsp; " escape="false"/>
                <h:commandButton id="submit" value="Run" action="#{FactorAnalysisBean.getChart}" />

            </h:panelGrid>


            <h:message for="factors" showSummary="false" style="color: red;"/>
             <h:message for="resolution" showSummary="false" style="color: red;"/>
            <h:message for="width" showSummary="false" style="color: red;"/>
            <h:message for="height" showSummary="false" style="color: red;"/>
            
        </h:form>

    </div>
    <p></p>
    
    
    <h2>Factor Analysis</h2>
    
     <p></p>
    
    <div id="data">
        <h:graphicImage id="image"
                        alt="alternative"
                        width="#{FactorAnalysisBean.pwidth}"
                        height="#{FactorAnalysisBean.pheight}"
                        url="#{FactorAnalysisBean.chartLink1}"
                        rendered="#{FactorAnalysisBean.fileGenerated}">
        </h:graphicImage>

        <p></p>
        <h:outputLink value="#{FactorAnalysisBean.chartLink1}" target="_blank" rendered="#{FactorAnalysisBean.fileGenerated}">
            <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>
            
            
            <h:graphicImage id="image2"
                        alt="alternative"
                        width="#{FactorAnalysisBean.pwidth}"
                        height="#{FactorAnalysisBean.pheight}"
                        url="#{FactorAnalysisBean.chartLink2}"
                        rendered="#{FactorAnalysisBean.fileGenerated}">
        </h:graphicImage>
            
              <p/>
            
            <h:outputLink value="#{FactorAnalysisBean.chartLink2}" target="_blank" rendered="#{FactorAnalysisBean.fileGenerated}">     
                <f:verbatim>Download figure.
            </f:verbatim>
        </h:outputLink>

      
    </div>

    <p/>
    
 <div>
     <h3>Download reduced data:</h3>
     <h:outputLink value="#{FactorAnalysisBean.metaLink}" target="_blank"
                      rendered="#{FactorAnalysisBean.fileGenerated}">
            <f:verbatim>Download meta annotation file in csv format (Right mouse click "Save As").
            </f:verbatim>
        </h:outputLink>
            <p/>
            <h:outputLink value="#{FactorAnalysisBean.factorLink1}" target="_blank"
                      rendered="#{FactorAnalysisBean.fileGenerated}">
            <f:verbatim>Download factor matrix in csv format (Right mouse click "Save As").
            </f:verbatim>
        </h:outputLink>
             <p/>
            
            <h:outputLink value="#{FactorAnalysisBean.factorLink2}" target="_blank"
                      rendered="#{FactorAnalysisBean.fileGenerated}">
            <f:verbatim>Download coefficient matrix in csv format (Right mouse click "Save As").
            </f:verbatim>
        </h:outputLink>
             <p/>
             The downloaded files can be opened with Excel. Depending
                on your browser, you may need to change the suffix to .csv first.    
           
    </div>
    
    
    

    <h1><h:outputText value="#{FactorAnalysisBean.errorm}" style="color: red;"/></h1>

    <p></p>

    

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
