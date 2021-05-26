<%--
    Document   : help
    Created on : Sep 9, 2011, 1:23:20 PM
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

    <div align="left" style="padding-left:2cm; padding-right:2cm;">
    <h1>Calypso Workflows</h1>

    <h3>Identify outliers</h3>
    <ol>
        <li>Visit the Summary page, set Type to "ReadsPerSample" and press Draw Chart.
        The displayed histogram visualizes the number of reads obtained for each sample.
        Samples with a low number of reads should be excluded, e.g. by setting the
        "Include" field in the meta data file to "0".</li>
        <li>Select "Multivariate" in the main menu and use unsupervised multivariate
        techniques such as PCoA, PCA, Heatmap or Dendrogram to identify outliers.</li>
        <li>The total number of reads per sample influences the measured community
            composition and diversity. To identify if samples cluster by the total number of reads per sample,
            apply a unsupervised multivariate technique such as PCoA or PCA and color
        the samples by TotalReads. </li>
        
    </ol>
   

    <h3>Compare groups of samples</h3>
    To identify if groups of samples are different (e.g. microbial communities from lean mice
    vs. obese mice
    or surface ocean samples vs. deep water samples) follow the following steps:

    <h4>Assess if the groups are different on a global, whole community level</h4>
    <ol>
        <li>Select Multivariate in the main menu and apply unsupervised multivariate techniques
            such as PCA, PCoA, Network, DCA, NMDS or Dendrogram and assess if the samples of
            each group fall into distinct clusters.</li>
        <li>Test if sample groups have significantly different community composition
        using Anosim,  Adonis, RDA or CCA.</li>
        <li>Select the GroupPlots view and set the type to GlobalCommunityComp. The
    intra-group and inter-group sample distances are compared to assess if the community
    composition is different on a global, whole community level.</li>
        <li>Visualize differences between groups with the BubblePlot and BarChart plot.</li>
        <li>Select the Diversity view to assess if the groups differ in microbial
        community diversity. To test if the overall diversity is different, set
        "Level" to "OTU" and "Index" to "Shannon" and press "Draw Chart". To assess if the
        community richness is different, set "Level" to "OTU" and "Index" to "Richness" and press
        "Draw Chart"</li>
    </ol>

    <h4>Detect significantly differentially abundant taxa or OTUs</h4>
    <ol>
        
        <li>Select the Stats view and detect differently abundant bacterial taxa
            with a Wilcoxon rank test or Anova.</li>
        <li>Change to the GroupPlots view. Various plots are available to detect
        significantly differentially abundant taxa, in particular an AnovaPlot and
        RankTestPlot.</li>
        <li>Select the Regression view. Set Regress by to "Group". The Pearson correlation
        and Regression analysis reveal taxa that are differentially abundant between
        the selected groups.</li>
    </ol>
    

    <h3>Assess impact of environmental variables on community composition</h3>
    <ol>
        <li>Switch to the Multivariate page and set "Type" to either 
            PCA+, DCA+, or NMDS+. Press "Draw Chart". Depending on the selected type,
            a PCA, DCA or NMDS is computed and the environmental variables are overlayed.
            The generated plot allows identification of
            environmental variables influencing the community composition.</li>
        <li>Next, set "Type" to "PCoA" and select an
            environmental variable in the drop down menu "Color by" and press
            "Draw Chart". The samples
            are colored by the value of the selected environmental variable.
        </li>
        <li>Set "Type" to either RDA+ or CCA+. The displayed
        table lists a p-value for each environmental variable indicating
        if this variable significantly effects the community composition.</li>
        <li>Set "Type" to "Heatmap+", "Color" to "redgreen" and press "Draw Chart".
        The Pearson correlation between each environmental variable and each
        taxa/OTU is visualized as heatmap.
        </li>
        <li>Use the ANOVA test to identify if environmental variables impact the
            community composition. Select "Stats" in the main menu, set "Test" to "Anova+"
            and press "Do stats". Note that only categorical environmental variables
            are included; numerical environmental variables are excluded.
        </li>
        <li>Select Regression in the main menu. Regression analysis allows the 
            identification of complex associations between the community composition profiles
            and environmental variables. Both categorical and numerical environmental
            variables can be included. Set "Regress by" to "Taxa vs Envp" and
            press "Set Mode" followed by "Run Analysis". The displayed table of p-values
            indicates which taxa are significantly effected by each environmental variable.
            Next, select a specific taxon in the "Taxa" drop down menu and press "Run Analysis".
        </li>
         <li>To identify environmental variables effecting the community diversity,
             set "Regress by" to "Diversity vs Envp" and
            press "Set Mode". Next, set "Index" to either "Shannon" or
            "Richness" and press "Run Analysis".
        </li>
       <li>To identify environmental variables effecting the global community composition,
             set "Regress by" to "Distance vs Envp" and
            press "Set Mode". Next, set "Distance Method" to "Jaccard"
            and press "Run Analysis".
        </li>
        
    </ol>
 
    <h3>Analyze time series/longitudinal data</h3>
    <ol>
        <li>To run a time series analysis, the secondary group and pair field have to be
            specified in the meta data file for each sample. Secondary group will be used
            as sample time point.</li>
        <li>Select Regression in the main menu. Set "Regress by" to "Taxa Time Series" and
            press "Set Mode" followed by "Run Analysis". The displayed table of p-values
            indicates which taxa are significantly differentially abundant at the different
            time points (secondary group). Next, select a taxa of interest in the "Taxa" drop down menu
            and press "Run Analysis".</li>
        <li>Select the Multivariate view in the main menu. Set "Color by" to "Secondary Group" and run a
            PCoA, PCA, RDA, DCA, NMDS or CCA. Samples will be colored by their
        time point.</li>
        <li>Switch to the GroupPlots view. Set "Group by" to "Secondary Group" and press
            "Select Mode". Next, set "Type" to "AnovaPlot", "RankTestPlot" or "GlobCommunityComp"
            and press "Draw Chart".</li>
        <li>Select the Diversity view. Set "Group by" to "Secondary Group" and press
            "Draw Chart".</li>
    </ol>

    </div>

     <f:subview id="footer">
         <%@ include file="jspf/footer.jspf" %>
    </f:subview>
</f:view>
