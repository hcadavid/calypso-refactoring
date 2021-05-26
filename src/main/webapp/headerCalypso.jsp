<%-- 
    Document   : header
    Created on : Sep 8, 2011, 10:13:35 AM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="f" uri="http://java.sun.com/jsf/core"%>
<%@taglib prefix="h" uri="http://java.sun.com/jsf/html"%>


<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" type="text/css" href="css/calypso.css">
        <title>Calypso WEB</title>
        <script src="sorttable.js" type="text/javascript"></script>
        <!--       <script src="js/d3.v3.js" type="text/javascript"></script>  -->
    </head>

    <body>
        
        
        
        <div id="logoText">
          Calypso
        </div>


        <div id="main">

            <div id="white"></div>


            <div id="menu" class="menu">



                <h:form >
                    <table width="100%" border="0">
                        <tr><td>
                                <table><tr>
                                        <td>&nbsp;|</td>
                                        <td><h:commandLink value="Home" action="index"></h:commandLink>&nbsp;|</td>

                                        <td><h:commandLink value="Sum" action="summary"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="Raref" action="rar"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="Sample" action="barCharts"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="Group" action="groupPlots"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="TA" action="taxa"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="Stats" action="statsSTD"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="Multiv" action="multivariat"></h:commandLink>&nbsp;|</td>                            
                                        <td><h:commandLink value="Div" action="diversity"></h:commandLink>&nbsp;|</td>
                                        
                                        <td><h:commandLink value="Network" action="correlation"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="Hierarchy" action="hierarchyPlot" rendered="#{SessionDataBean.visibilityMode}"></h:commandLink>&nbsp;|</td> 
                                        
                                        <td><h:commandLink value="Regression" action="regression"></h:commandLink>&nbsp;|</td>                            
                                   
                                         <td><h:commandLink value="BM" action="biomarker"></h:commandLink>&nbsp;|</td>
                                        <td><h:commandLink value="FS" action="featureSelection"></h:commandLink>&nbsp;|</td>
                                            
                                        <td><h:commandLink value="Paired" action="pairwise"></h:commandLink>&nbsp;|</td>
                                                <td><h:commandLink value="Norm" action="normalize"></h:commandLink>&nbsp;&nbsp;</td>
                                                                                
                                         </tr></table></td><td>
                                    <table width="100%"><tr>
                                           <td> <a target="_blank" href="http://cgenome.net:8080/html/wiki/index.php/Calypso">Help</a> &nbsp;</td>
                                            
                                        </tr></table></td>
                            </tr>
                        </table>

                </h:form>

                
            </div>

            <div id="content">

