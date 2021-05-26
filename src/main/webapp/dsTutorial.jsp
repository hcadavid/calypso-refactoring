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
    <h1>Tutorial</h1>

    <h3>Explore DataSmart using provided example meta data and data files.</h3>
    <ol>
        <li>Go to the <a href="faces/uploadFiles.jsp">Data Upload Page</a>
        <li>Press button "Start Demo Project"</li>
        <li>Continue with C)</li>
    </ol>
        


    <h3>E) View community composition of each sample</h3>
    Go to the <a href="faces/barCharts.jsp">SamplePlots Page</a>
     <f:subview id="barCharts">
        <%@ include file="nutshell/barCharts.html" %>
    </f:subview>

     <h3>F) View differences between groups</h3>
     Go to the <a href="faces/groupPlots.jsp">GroupPlots Page</a>

     <f:subview id="groupPlots">
        <%@ include file="nutshell/groupPlots.html" %>
    </f:subview>
     For the demo project, the following tables are obtained for rank genus.
     The tables show that the intra-group Pearson correlation is higher than the
     inter-group Pearson correlation of the community composition profiles.
     Also the intra-group distances are less than the inter-group
     distances of the community composition profiles (by default the community
     composition profiles are compared by the jaccard distance). These differences
     are significant (p = 0, Wilcoxon test that the intra-group distances are less
     than the inter-group distances).<br>
     <img src="resources/figures/global-comparison-pearson.png" width="400" height="400" alt="global-comparison-pearson"/>
     <img src="resources/figures/global-comparison-dist.png" width="400" height="400" alt="global-comparison-dist"/>
     <img src="resources/figures/global-comparison-p.png" width="400" height="400" alt="global-comparison-p"/>


     <h3>G) Statistical comparison</h3>
     Go to the <a href="faces/statsSTD.jsp">Stats Page</a>

      <f:subview id="stats">
        <%@ include file="nutshell/stats.html" %>
    </f:subview>
     For the demo project, the following p-value distribution is obtained for level OTU.
     The overrepresentation of low p-values indicates that the observed low p-values are
     relevant and not poorly obtained by chance and that the compared groups are
     significantly different.
     <img src="resources/figures/phist-otu.png" width="1000" height="500" alt="P-value histogram"/>


     <h3>H) Multivariate Analysis</h3>
     Go to the <a href="faces/multivariat.jsp">Multivariate Page</a>

          <f:subview id="multivariat">
        <%@ include file="nutshell/multivariat.html" %>
    </f:subview>

     <h3>I) Compare community diversity</h3>
     Go to the <a href="faces/diversity.jsp">Diversity Page</a>.

     <f:subview id="diversity">
        <%@ include file="nutshell/diversity.html" %>
    </f:subview>


     <h3>J) Paired Analysis</h3>
     Go to the <a href="faces/pairwise.jsp">Paired Page</a>.

     <f:subview id="paired">
        <%@ include file="nutshell/paired.html" %>
    </f:subview>


     <h3>K) Network</h3>

     Go to the <a href="faces/correlation.jsp">Network Page</a>
     <f:subview id="cor">
        <%@ include file="nutshell/correlation.html" %>
    </f:subview>

     <h3>L) Regression</h3>

     Go to the <a href="faces/regression.jsp">Regression Page</a>
     <f:subview id="regression">
        <%@ include file="nutshell/regression.html" %>
    </f:subview>


    </div>

     <f:subview id="footer">
         <%@ include file="jspf/footer.jspf" %>
    </f:subview>
</f:view>
