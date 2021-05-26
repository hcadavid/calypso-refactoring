<%-- 
    Document   : uploadFiles
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
    <h:form rendered="#{!SessionDataBean.dataMiner}">
        <h2>Welcome to Calypso Version <h:outputText value="#{SessionDataBean.version}"/></h2>
        <dsP>
            Calypso is an easy to use online platform for mining,
            visualizing and comparing multiple 16S rDNA samples. The software is free for
            academic use.
            Start by uploading a data and meta data file.<br>
            <rbfl>You can rapidly explore Calypso using example files:</rbfl><br>
                <h:commandButton value="Start Demo Project" action="#{FileUploadBean.uploadExample}" />
                <h:message for="exam" style="color: red;" />
                <h:message for="exampleUploadForm" infoStyle="color: green;" errorStyle="color: red;" />
            <br>Simply press "Start Demo Project"
            and start exploring Calypso by selecting one of the views in the main menu. For example,
            press "Start Demo Project", next select SamplePlots
            or GroupPlots in the main menu.
            The meta information, data file and UniFrac distance matrix 
            for the demo project can be downloaded from here:
            <a href="resources/ExampleCounts.csv">Example Data File
            </a>, <a href="resources/ExampleAnnotation.csv">Example Meta Data</a>,
            <a href="resources/exampleDistanceMatrix.txt">Example Distance Matrix</a>
            (Right mouse click -> "Save as").
            You can use <a href="http://qiime.org/" target="_blank">QIIME</a> or 
            <a href="http://www.mothur.org" target="_blank">mothur</a> to preprocess your data, for quality control, demultiplexing,
            clustering into OTUs, and taxonomic assignment.
            
        </dsp>
    </h:form>

    <h:form rendered="#{SessionDataBean.dataMiner}">
        <h2>Welcome to DataSmart Version <h:outputText value="#{SessionDataBean.version}"/></h2>

        <dsP>

            DataSmart is an easy to use online platform for mining,
            visualizing and comparing complex and multidimensional data. 
            The software is free for
            academic use.
            Start by uploading a data and metadata file.<br>
            <rbfl>You can rapidly explore DataSmart using example files:</rbfl><br>
                <h:commandButton value="Start Demo Project" action="#{FileUploadBean.uploadExample}" />
                <h:message for="exam" style="color: red;" />
                <h:message for="exampleUploadForm" infoStyle="color: green;" errorStyle="color: red;" />
            <br>Simply press "Start Demo Project"
            and start exploring DataSmart by selecting one of the views in the main menu. For example,
            press "Start Demo Project", next select SamplePlots
            or GroupPlots in the main menu.
            The metadata and data files of the demo project can be downloaded from here:
            <a href="resources/ExampleDataMinerData.csv">Example Data File
            </a>, <a href="resources/ExampleDataMinerMeta.csv">Example Meta data</a>
            (Right mouse click -> "Save as").

        </dsp>
    </h:form>        
    <p/>
    <h:form>
        <h:commandLink value="Get help" action="help"></h:commandLink> or follow our 
        <h:commandLink value="tutorial." action="tutorial"></h:commandLink></p>
        <bbfl>
            Recommended browsers: Firefox, Mozilla, and Safari. Internet Explorer can be used, but 
            some pages are not well rendered, embedded SVG figures are not supported and 
            interactive hierarchical trees are not functional.
        </bbfl>
        <rbfl>You need to configure your browser to allow cookies and activate
            java script!!!</rbfl><br/>

</h:form>
<p></p>
<script>
    function setVisibility() {
        var value = document.forms[3].elements[2].value;
        console.log(value);
        if (value == "calypso3") {
            document.getElementById("countsUploadForm:delimiterC").style.visibility = 'visible';
        } else {
            document.getElementById("countsUploadForm:delimiterC").style.visibility = 'hidden';

        }
    }
</script>


<h:panelGrid columns="2">
    <h:outputLabel value="Annotation File:" style="font-weight:bold;"></h:outputLabel>
    <h:outputText escape="false" value="#{SessionDataBean.annotFileName}" style="font-weight:bold;"/>
    <h:outputLabel value="Data File:" style="font-weight:bold;"></h:outputLabel>
    <h:outputText escape="false" value="#{SessionDataBean.countsFileName}" style="font-weight:bold;"/>
    <h:outputLabel value="Hierarchy File:" style="font-weight:bold;" rendered="#{!SessionDataBean.dataMiner}"/>
    <h:outputText escape="false" value="#{SessionDataBean.taxFileType}" style="font-weight:bold;" rendered="#{!SessionDataBean.dataMiner}"/>
<h:outputLabel value="Distance File:" style="font-weight:bold;" rendered="#{!SessionDataBean.dataMiner}"/>
    <h:outputText escape="false" value="#{SessionDataBean.distFileName}" style="font-weight:bold;" rendered="#{!SessionDataBean.dataMiner}"/>


</h:panelGrid>
<p></p>


  

<h:form id="annotUploadForm" enctype="multipart/form-data">
    <h:panelGrid columns="7">
        <h:outputLabel for="annot" value="1) Select meta data file" />
        
        <h:inputFile id="annotIF" value="#{FileUploadBean.annotationFile}" 
                     rendered="#{FileUploadBean.HInputFile}"/>
        
        <t:inputFileUpload id="annot" value="#{FileUploadBean.annotationFileUF}" 
                           required="true" rendered="#{!FileUploadBean.HInputFile}"/>
        
        <h:selectOneMenu id="delimiter" value="#{FileUploadBean.delimiter}"  >
            <f:selectItems value="#{FileUploadBean.delimiters}" />
        </h:selectOneMenu> 

        <h:commandButton value="Upload"  action="#{FileUploadBean.uploadAnnot}"/>
       
        
          <h:message for="annot" showSummary="false" style="color: red;"/>
          <h:message for="annotIF" showSummary="false" style="color: red;"/>
        
        <h:message for="annotUploadForm" infoStyle="color: green;" errorStyle="color: red;" />
    </h:panelGrid>

    <h:panelGrid columns="7">
        <h:message for="annot" style="color: red;" />
    </h:panelGrid>

    <h:inputHidden id="warning"/>
    <h:message for="warning" infoStyle="color: green;" errorStyle="color: red;" />

</h:form>

<h:form id="annotUploadErrors" enctype="multipart/form-data">
    <h:message for="annotUploadErrors" infoStyle="color: green;" errorStyle="color: red;" />
</h:form>

<h:form id="countsUploadForm" enctype="multipart/form-data" >

       <h:panelGrid columns="6">
        <h:outputLabel for="norm" value="2) Upload data: Transformation: " escape="false"/>        
        <h:selectOneMenu id="norm" value="#{FileUploadBean.normalization}" >
            <f:selectItems value="#{FileUploadBean.normMethods}" />
        </h:selectOneMenu> 

        
        <h:panelGroup rendered="#{!SessionDataBean.dataMiner}">

            <h:outputLabel for="tss" value="&nbsp; &nbsp; Total sum normalization (TSS): " escape="false"/>
            <h:selectBooleanCheckbox
                title="tss" id="tss"
                value="#{FileUploadBean.relative}" >
            </h:selectBooleanCheckbox>

            <h:outputLabel for="taxFilter" value="&nbsp; &nbsp; Filter rare taxa (0-100)" escape="false" />
            <h:inputText id="taxFilter" value="#{FileUploadBean.taxFilter}" required="true" size="3" >
                <f:validateDoubleRange minimum="0" maximum="100"/>
            </h:inputText>
            <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
        </h:panelGroup>

    </h:panelGrid>
    
    
        <h:panelGrid columns="8" rendered="#{false}">
        <h:panelGroup>
            <h:outputLabel for="meanFilter" value="&nbsp; &nbsp; Filter by mean, min mean (0-1000000)" escape="false"/>
            <h:inputText id="meanFilter" value="#{FileUploadBean.meanFilter}" required="true" size="6" >
                <f:validateDoubleRange minimum="0" maximum="1000000"/>
            </h:inputText>
            <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
        </h:panelGroup>


        <h:message for="meanFilter" showSummary="false" style="color: red;"/>

    </h:panelGrid>
    
    <h:panelGrid columns="6" rendered="#{!SessionDataBean.dataMiner}">
        <h:outputLabel for="formatSelect" value="&nbsp; &nbsp; File Format: " escape="false"/>
        <h:selectOneMenu id="formatSelect" value="#{FileUploadBean.format}" onchange="setVisibility()"  >
            <f:selectItems value="#{FileUploadBean.formats}" />
        </h:selectOneMenu>

        <h:outputLabel for="filtertaxs" value="&nbsp; &nbsp; Filter Taxa: " escape="false"/>        
        <h:selectOneMenu id="filtertaxa" value="#{FileUploadBean.filtertaxa}" >
            <f:selectItems value="#{FileUploadBean.filtertaxas}" />
        </h:selectOneMenu> 
    </h:panelGrid>
    
    <h:panelGrid columns="8">
        <h:outputLabel for="counts" value="&nbsp; &nbsp; Select data file &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;" escape="false"/>
        
        <h:inputFile id="countsIF" value="#{FileUploadBean.countsFile}" 
                     required="true" rendered="#{FileUploadBean.HInputFile}"/>

        
        <t:inputFileUpload id="counts" value="#{FileUploadBean.countsFileUF}" 
                           required="true" rendered="#{!FileUploadBean.HInputFile}"/>
        
        
        <h:selectOneMenu id="delimiterC" value="#{FileUploadBean.delimiter}" style="visibility:visible;" >
            <f:selectItems value="#{FileUploadBean.delimiters}" />
        </h:selectOneMenu> 

        <h:commandButton value="Upload" action="#{FileUploadBean.uploadCounts}" />
        <h:message for="countsUploadForm" infoStyle="color: green;" errorStyle="color: red;" />
        
    </h:panelGrid>

    <h:panelGrid columns="8">
        <h:message for="counts" style="color: red;" />   
        <h:message for="countsIF" style="color: red;" />   
    </h:panelGrid>

    


 


    <h:panelGrid columns="8">
        <h:message for="taxFilter" style="color: red;" />
        <h:message for="taxFilter" showSummary="false" style="color: red;"/>

    </h:panelGrid>

    <h:panelGrid columns="8">
        <h:message for="taxonomyFile" style="color: red;" />
        <h:message for="taxonomyFile" showSummary="false" style="color: red;"/>

    </h:panelGrid>



</h:form>

<h:panelGrid columns="6" rendered="#{!SessionDataBean.dataMiner}">
    <h:form id="taxUploadForm2" enctype="multipart/form-data" >
        <h:panelGrid columns="5">
            <h:outputLabel for="taxSelection" value="3) Optional: Select reference taxonomy database &nbsp; &nbsp; " escape="false"/>
            <h:selectOneMenu id="taxSelection" value="#{FileUploadBean.taxSelection}"  >
                <f:selectItems value="#{FileUploadBean.taxSelections}" />
            </h:selectOneMenu>
            <h:outputLabel value="&nbsp;" escape="false"/>
            <h:commandButton id="selectTax" value="Update taxonomy" action="#{FileUploadBean.setSelectionMode}" />     
            <h:message for="taxonomyFile" style="color: red;" />
        </h:panelGrid>

    </h:form>  

    <h:form id="taxUploadForm" rendered="#{! (FileUploadBean.taxMode)}" enctype="multipart/form-data">
        <h:panelGrid columns="3">
            <h:outputLabel for="taxFile" value="&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Select taxonomy file &nbsp;" escape="false"/>
    
            
            <h:inputFile id="taxFileIF" value="#{FileUploadBean.taxFile}"
                         rendered="#{FileUploadBean.HInputFile}"/>
            
             <t:inputFileUpload id="taxFile" value="#{FileUploadBean.taxFileUF}" 
                           required="true" rendered="#{!FileUploadBean.HInputFile}"/>
            
            
            <h:commandButton value="Upload" action="#{FileUploadBean.uploadTaxonomy}" />
        </h:panelGrid>       

    </h:form> 
    <h:message for="taxUploadForm2" infoStyle="color: green;" errorStyle="color: red;" />
</h:panelGrid>






<h:form id="distUploadForm" enctype="multipart/form-data" >

    <h:panelGrid columns="8" rendered="#{!SessionDataBean.dataMiner}">
       <h:outputLabel for="ud" value="4) Optional: Upload distance matrix (e.g. unifrac distance) " escape="false"/>        
    
       
        <h:inputFile id="udIF" value="#{FileUploadBean.distFile}" required="true"
                     rendered="#{FileUploadBean.HInputFile}"/>
        
        <t:inputFileUpload id="ud" value="#{FileUploadBean.distFileUF}" 
                           required="true" rendered="#{!FileUploadBean.HInputFile}"/>
        
        <h:selectOneMenu id="delimiterD" value="#{FileUploadBean.distDelimiter}" style="visibility:visible;" >
            <f:selectItems value="#{FileUploadBean.delimiters}" />
        </h:selectOneMenu> 

        <h:commandButton value="Upload" action="#{FileUploadBean.uploadDist}" />
        <h:message for="distUploadForm" infoStyle="color: green;" errorStyle="color: red;" />
        
    </h:panelGrid>

    <h:panelGrid columns="8">
        <h:message for="ud" style="color: red;" />   
        <h:message for="udIF" style="color: red;" />   
    </h:panelGrid>


</h:form>



<h:panelGrid columns="8">
    <h:message for="taxonomyFile" style="color: red;" />
    <h:message for="taxFilter" showSummary="false" style="color: red;"/>

</h:panelGrid>
<h:form id="countsUploadErrors" enctype="multipart/form-data">
    <h:panelGrid columns="7">
        <h:message for="countsUploadErrors" infoStyle="color: green;" errorStyle="color: red;" />
    </h:panelGrid>
</h:form>

<h:form id="taxUploadErrors" enctype="multipart/form-data">
    <h:panelGrid columns="7">
        <h:message for="taxUploadErrors" infoStyle="color: green;" errorStyle="color: red;" />
    </h:panelGrid>
</h:form>

<h:form id="distUploadErrors" enctype="multipart/form-data">
    <h:panelGrid columns="7">
        <h:message for="distUploadErrors" infoStyle="color: green;" errorStyle="color: red;" />
    </h:panelGrid>
</h:form>






<p></p>
<h:form id="terminate" enctype="multipart/form-data">
    <h:panelGrid columns="6">
        <h:outputLabel for="term" value="Start over again: " />
        <h:commandButton id="term" value="Terminate session" action="#{SessionDataBean.terminateSession}" />
    </h:panelGrid>
</h:form>

<p>

    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>
</f:view>
