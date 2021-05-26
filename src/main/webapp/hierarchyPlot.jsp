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
        <h:form   id="selectHierarchy" rendered="#{SessionDataBean.visibilityMode}">

            <h:panelGrid columns="3">
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>

                <%--       </h:panelGroup>--%>
                <h:selectOneMenu id="visualizationMode" value="#{HierarchyBean.visualization}"  >
                    <f:selectItems value="#{HierarchyBean.visualizationMode}" />
                </h:selectOneMenu>
                <h:commandButton id="selectMode" value="Select Mode" action="#{HierarchyBean.setSelectedMode}" />
            </h:panelGrid>
              <h:panelGrid columns="3">          
                <h:outputLabel value="&nbsp; &nbsp; &nbsp; " escape="false"/>
                <h:outputLabel for="taxFilter" value="Filter (0-1000)" />
                <h:inputText id="taxFilter" value="#{HierarchyBean.taxFilter}" required="true" size="3">
                    <f:validateLongRange minimum="0" maximum="1000"/>
                </h:inputText>
               </h:panelGrid>
            
            <h:panelGrid columns="15" rendered="#{ HierarchyBean.networks2opt}">

                <h:outputLabel value="&nbsp; &nbsp;&nbsp;" escape="false" rendered="#{ HierarchyBean.notkronaopt}"/>
                <h:inputHidden id="jsonFileName" value="#{HierarchyBean.jsonFileNameURL}"  rendered="#{ HierarchyBean.notkronaopt}"/>  
                
               
                <h:outputLabel for="sampleplots" value=" Sampleplots" rendered="#{ HierarchyBean.notkronaopt}" />
                <h:selectBooleanCheckbox  rendered="#{ HierarchyBean.notkronaopt}"
                    title="sampleplots" id="sampleplots"
                    value="#{HierarchyBean.sampleplots}" >
                </h:selectBooleanCheckbox>
                     
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="groupBy" value="Group by " />
                <h:selectOneMenu id="groupBy" value="#{HierarchyBean.groupBy}"  >
                    <f:selectItems value="#{HierarchyBean.groupByMode}" />
                </h:selectOneMenu>

                
              
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"  rendered="#{ HierarchyBean.notkronaopt}"/>
                <h:outputLabel for="edgesWidth" value="Edges width"  rendered="#{ HierarchyBean.notkronaopt}"/>
                <h:selectOneMenu id="edgesWidth" value="#{HierarchyBean.edgesWidth}"  rendered="#{ HierarchyBean.notkronaopt}" >
                    <f:selectItems value="#{HierarchyBean.edgesWidths}" />
                </h:selectOneMenu>

               
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false" rendered="#{ HierarchyBean.notkronaopt}"/>

                <h:outputLabel for="height" value="Height"  rendered="#{ HierarchyBean.notkronaopt}"/>
                <h:inputText id="height" value="#{HierarchyBean.height}" required="true" size="4" rendered="#{ HierarchyBean.notkronaopt}">
                    <f:validateLongRange minimum="60" maximum="10000"/>
                </h:inputText>
                <h:message for="selectHierarchy" infoStyle="color: green;" errorStyle="color: red;"  rendered="#{ HierarchyBean.notkronaopt}"/>
                <h:commandButton id="submitMode2" value="Draw" action="#{HierarchyBean.run}" />
            </h:panelGrid>

            
            <h:panelGrid columns="10" rendered="#{HierarchyBean.networksopt}">
                
                <h:inputHidden id="jsonFileName2" value="#{HierarchyBean.jsonFileNameURL}" />
                <h:outputLabel value="&nbsp; &nbsp;&nbsp; " escape="false"/>

                
                <h:outputLabel for="levelSelect" value="Level" />
                <h:selectOneMenu id="levelSelect" value="#{HierarchyBean.level}"  >
                    <f:selectItems value="#{SessionDataBean.levels}" />
                </h:selectOneMenu>

                <h:outputLabel value="&nbsp;" escape="false"/>             
                <h:panelGroup >
                    <h:outputLabel for="distSelect" value="Correlation Index: " />
                    <h:selectOneMenu id="distSelect" value="#{HierarchyBean.corIndex}"  >
                        <f:selectItems value="#{HierarchyBean.corIndexS}" />
                    </h:selectOneMenu>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>
                <h:panelGroup>
                    <h:outputLabel for="minSim" value="Edge Min Similarity " />
                    <h:inputText id="minSim" value="#{HierarchyBean.minSim}" required="true" size="4" >
                    <f:validateDoubleRange minimum="0" maximum="1"/>
                    </h:inputText>
                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>

                <h:panelGroup>
                    <h:outputLabel for="vSize" value="Node Size " />
                <h:selectOneMenu id="vSize" value="#{HierarchyBean.vSize}"  >
                    <f:selectItems value="#{HierarchyBean.edgesWidths}" />
                </h:selectOneMenu>

                    <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                </h:panelGroup>
                 
                <h:outputLabel value="Color nodes by" escape="false"/>
                <h:selectOneMenu id="levelSelect2" value="#{HierarchyBean.colorNodesBy}"  >
                    <f:selectItems value="#{HierarchyBean.levels}" />
                </h:selectOneMenu>
            </h:panelGrid>
            <h:panelGrid columns="13" rendered="#{ HierarchyBean.networksopt}">
                
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                <h:outputLabel for="width" value="Width" />
                <h:inputText id="width" value="#{HierarchyBean.width}" required="true" size="4" >
                    <f:validateLongRange minimum="100" maximum="10000"/>
                </h:inputText>
                <h:outputLabel for="height" value="Height" />
                <h:inputText id="height2" value="#{HierarchyBean.height}" required="true" size="4" >
                    <f:validateLongRange minimum="100" maximum="10000"/>
                </h:inputText>
                <h:outputLabel value="&nbsp; &nbsp; " escape="false"/>
                <h:outputLabel value="Background" escape="false"/>
                <h:selectOneMenu id="background" value="#{HierarchyBean.background}"  >
                    <f:selectItems value="#{HierarchyBean.backgroundcolors}" />
                </h:selectOneMenu>    
                <h:outputLabel value="&nbsp; &nbsp; " escape="false"/>
                <h:outputLabel for="overlap" value="Avoid Overlapping Nodes: " />
                <h:selectBooleanCheckbox
                    title="overlap" id="overlap"
                    value="#{HierarchyBean.aoverlap}" >
                </h:selectBooleanCheckbox>
                <h:outputLabel value="&nbsp; &nbsp; &nbsp;" escape="false"/>
                 <h:commandButton id="submitMode" value="Draw" action="#{HierarchyBean.run}" />

                  </h:panelGrid>
            

        </h:form>
        <p></p>
    </div>
    <h1><h:outputText value="#{HierarchyBean.errorm}" style="color: red;"/></h1>
    <h3>Interactive hierarchical view of identified taxa. </h3>
    <h:panelGroup rendered="#{! HierarchyBean.notkronaopt}">
    <h:outputLink value="#{HierarchyBean.kronaFileLink}" target="_blank" rendered="#{!HierarchyBean.firstDraw}">Click here to open Krona in new window.</h:outputLink>
    </h:panelGroup>
    <p></p>

    <table>

        <tr><td>
                <div id="tree"></div>   
            </td><td>
                <div id="distribution"></div>
            </td></tr></table>
    <h:panelGroup rendered="#{ HierarchyBean.notkronaopt}" id="download" layout="block">
 
       <h:panelGrid columns="2" rendered="#{!HierarchyBean.networksopt}">
        <h:commandButton id="DownloadSVG" value="DownloadSVG" onclick="DownloadSVG" rendered="#{! HierarchyBean.firstDraw}"/>
        <h:commandButton id="DownloadPNG" value="DownloadPNG" onclick="DownloadPNG"  rendered="#{! HierarchyBean.firstDraw}"/>
        </h:panelGrid>
       <h:panelGrid columns="1" rendered="#{HierarchyBean.networksopt}">
        <h:commandButton id="DownloadSVG2" value="DownloadSVG" onclick="DownloadSVG" rendered="#{! HierarchyBean.firstDraw}"/>
        </h:panelGrid>
        <p>
        <centre>Download currently not supported by Safari. Hierarchy is not supported by MS Explorer.</centre>
    </h:panelGroup>
    <div id="pngdataurl"></div>
    <div id="svgdataurl"></div>

    <canvas id="canvas" width="1400" height="100" style="display:none"></canvas>
    <div>
   <script src="http://d3js.org/d3.v3.js" charset="utf-8"></script> 
        <script>
            
            var svg;
            var margin = {top: 20, right: 50, bottom: 20, left: 50},
            width = 1400 - margin.right - margin.left,
            height = document.forms[1].elements[8].value * 5 - margin.top - margin.bottom;
            var canvas = document.getElementById('canvas'); //finds Original Canvas
            
//            canvas.width = 1300;
            canvas.height = height+50;
            var i = 0,
            //   duration = 750,
            duration =0,
            
            root;
            var edge = document.forms[1].elements[7].value;
            
            var colors = ["darkred","darkblue","darkgrey","orange","salmon","black","gold","darkgreen","blue","red","lightblue","pink","#CCFF00FF","#6600FFFF","#0066FFFF","#00FFCCFF","yellow","aquamarine4","green","grey","lightgoldenrod1","orangered","lightsalmon2","tan2"];
            var colorsRanks = ["#000000","#08088A","#2E2EFE","#8181F7","#A9A9F5","#CEF6F5","#A9F5E1","#58FA82","#01DF74"];
            var samplePlot = document.forms[1].elements[5].checked;
            var rank = document.forms[1].elements[1].value;
            var samples;
            var nodeDistance = 140;
            var textSize = 14;
            var branchHeight = height;
            var scaleNode = 1;
            var abundances = [];
            var shiftKey;
            
            var url = document.forms[1].elements[4].value;
            if(url.substr(url.length - 4) == "json"){
                 if(document.forms[1].elements[1].value == "graph" || document.forms[1].elements[1].value == "graph+"){
                    width =  document.forms[1].elements[10].value*127/25.4;
                    height = document.forms[1].elements[11].value*127/25.4;

                    var newdiv = d3.select("#tree").append("div")
                    .attr("style","position:relative;top:4px;")
                    .style("font-size", "14px")
                    .style("font-family","sans-serif").append("p");
                    newdiv
                    .append("text")
                    .text(function(d) {
                        return "  Node text size"
                    }) 
                    newdiv.append("input")
                   // .attr("style","position:relative;top:4px;")
                    .attr("type","range")
                    .attr("id","textsize")
                    .attr("min",10)
                    .attr("max",25)
                    .attr("value",textSize)
                    .attr("step","1");
                    newdiv
                    .append("text")
                    .text(function(d) {
                        return "  "
                    })                   
                    svg = d3.select("body").select("#tree")
                    .attr("tabindex", 1)
                    .on("keydown.brush", keydown)
                    .on("keyup.brush", keyup)
                    .each(function() { this.focus(); })
                    .append("svg")
                    .attr("width", width)
                    .attr("height", height);        

                    if(document.forms[1].elements[12].value == "white"){
                        svg.style("background-color", "white")
                    }else if(document.forms[1].elements[12].value == "black"){
                 //        svg.style("background-color", "#000000") 
                         svg.append("rect")
                         .attr("x",0)
                         .attr("y",0)
                         .attr("width",width)
                         .attr("height",height)
                         .style("fill","#000000");
                    }

                    var link = svg.append("g")
                    .attr("class", "link")
                    .selectAll("line");

                    var brush = svg.append("g")
                    .datum(function() { return {selected: false, previouslySelected: false}; })
                    .attr("class", "brush");

                    var node ;
                    //= svg.append("g")
                    //.attr("class", "node")
                    // .selectAll("circle");
                    d3.json(document.forms[1].elements[4].value, function(error, graph) {
                        graph.links.forEach(function(d) {
                            d.source = graph.nodes[d.source];
                            d.target = graph.nodes[d.target];  
                        });

                        link = link.data(graph.links).enter().append("line")
                        .attr("x1", function(d) { return d.source.x; })
                        .attr("y1", function(d) { return d.source.y; })
                        .attr("x2", function(d) { return d.target.x; })
                        .attr("y2", function(d) { return d.target.y; })
                        .style("stroke",function(d) {  if(d.corr > 0){return "green"}else{return "blue"}} )
                        .style("stroke-width", 1);
                        node = svg.selectAll("g.node").data(graph.nodes).enter().append("g").attr("class", "node")
                        node.attr("transform", function(d) { return "translate(" + (d.x) + "," + (d.y) + ")"; });
                        node
                        .append("circle")
                        .style("fill",function(d) {  if(d.color=="red"){return document.forms[1].elements[12].value}else{return d.color} })
                        .style("stroke",function(d) {  if(d.color=="red"){return d.color }else{return "none"}})
                        .style("stroke-width",function(d) {  if(d.color=="red"){return 5}else{return 0}})
                        .attr("r", function(d) {  
                            var rad;
                            if(d.size == "leg"){
                                rad = 7;
                            }else{
                                if(document.forms[1].elements[8].value == "rel"){
                                    rad = 7*Math.sqrt( d.size/ Math.PI ); 
                                }else{
                                    if(d.color=="red"){
                                        rad = 4;
                                    }else{
                                        rad=5;
                                }
                            }
                            }
                            return rad; })
                        .attr("cx", 0)
                        .attr("cy", 0);
                        
                        if(document.forms[1].elements[12].value == "white"){
                            node.append("text")
                            .attr("dx", 6)
                            .attr("dy", 5)
                            .style("font-family",function(d) { return "sans-serif"})
                            .style("font-size",function(d) { if(d.size == "leg"){return "16px"}else{return textSize+"px"} })
                            .style("font-weight", function(d) {  if(d.color=="red"){ return "italic" }else{return "normal"} })
                            .style("fill", function(d) {  if(d.color=="red"){return "darkred" }else{return "black"} })
                            .style("stroke-width", 0)
                            .text(function(d) { return d.label });
                        }else{
                            node.append("text")
                            .attr("dx",6 )
                            .attr("dy", 5)
                            .style("font-family",function(d) { return "sans-serif"})
                            .style("font-size",function(d) { if(d.size == "leg"){return "16px"}else{return textSize+"px"} })
                            .style("font-style", function(d) {  if(d.color=="red"){ return "italic" }else{return "normal"} })
                            .style("font-weight", function(d) {  if(d.color=="red"){ return "bold" }else{return "normal"} })
                            .style("fill", function(d) {  if(d.color=="red"){return "white" }else{return "white"} })
                            .style("stroke-width", 0)
                            .text(function(d) { return d.label });
                        }
                
                        node
                        .call(d3.behavior.drag()
                        .origin(function(d) { return d; })
                        .on("drag", function(d) {
                            if(d.size != "leg"){
                            d.x = d3.event.x, d.y = d3.event.y;
                           // d3.select(this).attr("cx", d.x).attr("cy", d.y).console.log(this);
                            node.attr("transform", function(d) { return "translate(" + (d.x) + "," + (d.y) + ")"; });
                            link.filter(function(l) { return l.source === d; }).attr("x1", (d.x)).attr("y1", (d.y));
                            link.filter(function(l) { return l.target === d; }).attr("x2", (d.x)).attr("y2", (d.y));
                            }}));
             
                         });                          

                      
                  d3.select("input[id=textsize]").on("change", function() {
                        textSize = this.value;
                        updateNode();
                    });                    
                                     d3.select("#download")
                .on("click", function() {
                        downloadfunction();
//                                                    var serializer = new XMLSerializer();
//                        var xmlString = serializer.serializeToString(d3.select('svg').node());
//                        //                 var imgData = 'data:image/svg+xml;base64,' + btoa(xmlString);
//                        var uri = new XMLSerializer().serializeToString(// serialise
//                        d3.select('svg').node()),
//                        win;
//                        var cssstyle = ".node line{fill: none;stroke: black;shape-rendering: crispEdges;}";
//                        uri = 'data:image/svg+xml;charset=utf-8,' + window.encodeURIComponent( uri); // to data URI
//                        win = window.open(uri, '_blank'); // open new window

                });
                }else if(document.forms[1].elements[1].value == "dendrogram"){
                
                    var tree  = d3.layout.tree()
                    .size([height, width]);

                    var newdiv = d3.select("#tree").append("div")
                    .attr("style","position:relative;top:4px;")
                    .style("font-size", "14px")
                    .style("font-family","sans-serif");
                
                    var ndis = 140;
//                    if( document.forms[1].elements[1].value.toLowerCase() == "superkingdom" || 
//                        document.forms[1].elements[1].value.toLowerCase() == "domain"){
//                        ndis = 700;
//                    }else if(document.forms[1].elements[1].value.toLowerCase() == "phylum"){
//                        
//                        ndis = 500;  
//                        
//                    }else if(document.forms[1].elements[1].value.toLowerCase() == "class"){
//                        ndis = 350;  
//                        
//                    }else if(document.forms[1].elements[1].value.toLowerCase() == "order"){
//                        ndis = 250;  
//                        
//                    }else if(document.forms[1].elements[1].value.toLowerCase() == "genus"){
//                        ndis = 170;  
//                        
//                    }else{
//                        console.log(document.forms[1].elements[1].value.toLowerCase());
//                    }

                    
                    newdiv
                    .append("text")
                    .text(function(d) {
                        return "  Node distance"
                    }) 
                    .append("input")
                    .attr("style","position:relative;top:4px;")
                    .attr("id","nodedistance")
                    .attr("type","range")
                    .attr("min","50")
                    .attr("max",ndis)
                    .attr("value","140")
                    .attr("step","10");
                
                    newdiv
                    .append("text")
                    .text(function(d) {
                        return "  Node text size"
                    }) 
                    .append("input")
                    .attr("style","position:relative;top:4px;")
                    .attr("id","textsize")
                    .attr("type","range")
                    .attr("min","8")
                    .attr("max","18")
                    .attr("value","14")
                    .attr("step","2");
                
                    if(samplePlot){
                        newdiv
                        .append("text")
                        .text(function(d) {
                            return "  Sample plot "
                        }) 
                        .append("input")
                        .attr("style","position:relative;top:4px;")
                        .attr("id","samplePlot")
                        .attr("type","range")
                        .attr("min","0.8")
                        .attr("max","1.35")
                        .attr("value","1.0")
                        .attr("step","0.05");
                    }
                    var diagonal = d3.svg.diagonal()
                    .projection(function(d) { return [d.y, d.x]; });
                    d3.json(document.forms[1].elements[4].value, function(error, flare) {
                        root = flare;
                       
                     //   console.log(flare);
                        samples = root.relAbundance;
                        root = root.children[0];
                    
                    svg = d3.select("#tree").append("svg")
                    //svg = d3.select("body").select("p").append("svg")
                    .attr("width", width + margin.right + margin.left)
                    .attr("height", height + margin.top + margin.bottom)
                    .style("background-color", "white")
                    .append("g")
                    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
                    if(samplePlot){
                    var legend = svg.append("g").attr("class", "legend");
                    var padding = 15;                   
                    legend.selectAll("rect").data(samples).enter().append("rect")
                    .attr("x", padding) 
                    .attr("y", function(d, e) {
                        return e * 20 + padding;
                    })
                    .attr("width", 10)
                    .attr("height", 10)
                    .attr("fill", function(d, i) {
                        return colors[i];
                    })
                    .style("stroke", "black")
                    .style("stroke-width", 0.5);

                    legend.selectAll("text").data(samples).enter().append("text")
                    .text(function(d) {
                        return d;
                    })
                    .attr("x", padding + 15)
                    .attr("y", function(d, e) {
                        return e * 20 + padding + 10;
                    });
                    }
                        root.x0 = branchHeight / 2;
                        root.y0 = 0;
                        function collapse(d) {
                            if (d.children) {
                                d._children = d.children;
                                d._children.forEach(collapse); 
                                d.children = null;
                            }
                        }
 
                        //root.children.forEach(collapse);
                        update(root);
                    });

                    
                    d3.select("input[id=nodedistance]").on("change", function() {
                        nodeDistance = this.value;
                        update(root)
                    });
                    d3.select("input[id=samplePlot]").on("change", function() {
                        scaleNode = this.value;
                        update(root);
                    });            
                    d3.select("input[id=textsize]").on("change", function() {
                        textSize = this.value;
                        updateNode();
                    });
                    d3.select(self.frameElement).style("height", "800px");
                }else if(document.forms[1].elements[1].value == "radial"){
                    var diameter = document.forms[1].elements[8].value*5;
                    //aqua, black, blue, fuchsia, gray, green, lime, maroon, navy, olive, orange, purple, red, silver, teal, white, and yellow.
                    // colors = d3.scale.category20c();
                    var tree = d3.layout.tree()
                    .size([360, diameter /2 - 150])
                    .separation(function(a, b) {
                        return (a.parent == b.parent ? 1 : 2) / a.depth;
                    });
                    canvas.width = diameter ;
                    canvas.height = diameter ;
                    var diagonal = d3.svg.diagonal.radial()
                    .projection(function(d) {
                        return [d.y, d.x / 180 * Math.PI];
                    });
                    var height2 = 200;
                    var padding = 10;
                    var newdiv = d3.select("#tree").append("div")
                    .attr("style","position:relative;top:4px;")
                    .style("font-size", "14px")
                    .style("font-family","sans-serif");
                    
               
                
                    newdiv
                    .append("text")
                    .text(function(d) {
                        return "  Node text size"
                    }) 
                    .append("input")
                    .attr("style","position:relative;top:4px;")
                    .attr("id","textsize")
                    .attr("type","range")
                    .attr("min","8")
                    .attr("max","18")
                    .attr("value","14")
                    .attr("step","2");
                
                    var svg = d3.select("#tree").append("svg")
                    .attr("width", diameter)
                    .attr("height", diameter)
                    .style("background-color", "white")
                    .append("g")
                    .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")")
                    ;
            

                    var svg2 ;
                    if(samplePlot){ 
                        svg2 = d3.select("body").select("#distribution").append("svg").attr("width", 300).attr("height", diameter);
                    
                        svg2.style("fill","none")
                        .style("stroke","black")
                        .style("font", "12px sans-serif")
                        .style("shape-rendering","crispEdges")
                        .style("background-color", "white");
                        svg2.style("fill","none")
                        .style("stroke","black");
                    }else{
                        svg2 = d3.select("body").select("#distribution").append("svg").attr("width", 300).attr("height", diameter);
                    
                        svg2.style("fill","none")
                        .style("stroke","black")
                        .style("font", "12px sans-serif")
                        .style("shape-rendering","crispEdges");
                    }
                    d3.json(document.forms[1].elements[4].value, function(error, root) {
                        samples = root.relAbundance;
                        root = root.children[0];
               
                        var nodes = tree.nodes(root),
                        links = tree.links(nodes);
                        var dats = root.relAbundance;
                        var yScale = d3.scale.linear()
                        .domain([0, d3.max(dats)])
                        .range([height2 - padding, padding]);
                        var yAxis = d3.svg.axis().scale(yScale).orient("right")
                        .ticks(4).tickSize(4);
                        if(samplePlot){
                        
                            var rootchild = root.children[0];
                            var datschild = rootchild.relAbundance;
                            var gpaint = svg2.append("g")
                            .attr("transform", "translate(" + 0 + "," + (diameter/2-50) + ")")
                    
                            gpaint
                            .selectAll("rect")
                            .data(datschild)
                            .enter()
                            .append("rect")
                            .attr("class", "bar")
                            .attr("x", function(d, i) {
                                return (padding + 30 + (i * 13));
                            })
                            .attr("y", function(d) {
                                return yScale(d);
                            })//function(d){return d;})
                            .attr("width", 10)
                            .attr("height", function(d) {
                                return (height2 - padding - yScale(d));
                            })      
                            .attr("fill", function(d, i) {
                                return colors[i];
                            })

                            .style("stroke", "black")
                            .style("stroke-width", 1)
                            .style("font", "9px sans-serif");

                            gpaint.append("g").attr("class", "axis").attr("transform", "translate(10,0)").call(yAxis);
                            var namefield = svg2.append("g").attr("class", "namefield").append("text");
                            namefield
                            .attr("dy", ".31em")
                            .text(function(d) {
                                return rootchild.name
                            })    
                            .attr("y", diameter/2-50)
                            .attr("x", padding + 30 + (samples.length + 1) * 13)
                            .style("stroke","none")
                            .style("fill","black")
                            .style("font", "12px sans-serif")
                            .style("font-weight","bold")
                            .style("fill-opacity", "1");

                            var legend = gpaint.append("g").attr("class", "legend");

                        
                        
                            legend.selectAll("rect").data(samples).enter().append("rect")
                            .attr("x", padding + 30 + (samples.length + 1) * 13)
                            .attr("y", function(d, e) {
                                return e * 20 + padding+12;
                            })
                            .attr("width", 10)
                            .attr("height", 10)
                            .attr("fill", function(d, i) {
                                return colors[i];
                            })
                            .style("stroke", "black")
                            .style("stroke-width", 0.5);
                            legend.selectAll("text").data(samples).enter().append("text")
                            //   .text(function(d) {
                            //       return Math.round(d*100)/100;
                            //   })
                            .text(function(d) {
                                return d;
                            })
                            .style("stroke","none")
                            .style("fill","black")
                            .style("font", "12px sans-serif")
                            .style("fill-opacity", "1")
                            .attr("x", padding + 30 + (samples.length + 1) * 13 + 15)
                            .attr("y", function(d, e) {
                                return e * 20 + padding + 10+12;
                            });
                            gpaint.append("text")
                            .text(function(d) {
                                return "relative abundance ";
                            })    
                            .attr("y", 50)
                            .attr("x", 50)
                            .style("stroke","none")
                            .style("fill","black")
                            .style("font", "10px sans-serif")
                            .style("font-weight","bold")
                            .style("fill-opacity", "1")                        
                            .attr("transform", function(d) {
                                return "rotate(" + (270) + ")translate(" +40 + ",-"+100+")";
                            });
                            gpaint.append("text")
                            .text(function(d) {
                                return "relative abundance [%]";
                            })    
                            .attr("y", 50)
                            .attr("x", 50)
                            .style("stroke","none")
                            .style("fill","black")
                            .style("font", "10px sans-serif")
                            .style("font-weight","bold")
                            .style("fill-opacity", "1")                        
                            .attr("transform", function(d) {
                                return "rotate(270,40,80)translate(-85,-3)";
                            });
                        }   
 
                        if(edge == 'fixed'){
                            var link = svg.selectAll(".link")
                            .data(links)
                            .enter().append("path")
                            .attr("class", "link")
                            .attr("d", diagonal)
                            .style("fill", "none")
                            .style("stroke", "#ccc")
                            .style("stroke-width", 5);
                        }else{
                            var threshold = 0.5
                            var link = svg.selectAll(".link")
                            .data(links)
                            .enter().append("path")
                            .attr("class", "link")
                            .attr("d", diagonal)
                            .style("fill", "none")
                            .style("stroke", "#ccc")
                            .style("stroke-width", function(d) {
                                   if((d.target.size / 2) < threshold){
                                        return threshold
                                   }else{
                                return d.target.size / 2;
                                    }
                            });                  
                        }
                        var node = svg.selectAll(".node")
                        .data(nodes)
                        .enter().append("g")
                        .attr("class", "node")
                        .attr("transform", function(d) {
                            return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")";
                        });
                        node.append("circle")
                        .attr("r", 4.5)
                        .style("fill", function(d) {
                        
                            return colorsRanks[d.depth];
                        })
                        .style("stroke","black")
                        .style("stroke-width",0.5)
                        .on("click", function(d) {
                            if(d.name != "Root"){
                                showInfo(d);
                            }
                        });
                    
                        node.append("text")
                        .attr("dy", ".31em")
                        .attr("text-anchor", function(d) {
                            return d.x < 180 ? "start" : "end";
                        })
                        .attr("transform", function(d) {
                            return d.x < 180 ? "rotate(-25)translate(8)" : "rotate(205)translate(-8)";
                        })
                        .text(function(d) {
                            return d.name;
                        });
                        d3.select("input[id=nodedistance]").on("change", function() {
                            nodeDistance = this.value;
                        });     
                        d3.select("input[id=textsize]").on("change", function() {
                            textSize = this.value;
                            updateNode();
                        });
                        d3.select("#download")
                        .on("click", function() {
                            downloadfunction();
//                            var serializer = new XMLSerializer();
//                            var xmlString = serializer.serializeToString(d3.select("#tree").select('svg').node());
//                            //console.log(btoa(xmlString));
//                            //                 var imgData = 'data:image/svg+xml;base64,' + btoa(xmlString);
//                            var uri = new XMLSerializer().serializeToString(// serialise
//                            d3.select('svg').node()),
//                            win;
//                            var cssstyle = ".node line{fill: none;stroke: black;shape-rendering: crispEdges;}";
//                            uri = 'data:image/svg+xml;charset=utf-8,' + window.encodeURIComponent( uri); // to data URI
//                            win = window.open(uri, '_blank'); // open new window


                            //   console.log(imgData)
                        });
                    });
                    function showInfo(d) {
                        var dataset = d.relAbundance;
                        var yScale = d3.scale.linear()
                        .domain([0, d3.max(dataset)])
                        .range([height2 - padding, padding]);
                    
                        var yAxis = d3.svg.axis().scale(yScale).orient("right")
                        .ticks(3).tickSize(4);
                    
                        svg2.select("g.namefield").selectAll("text")
                        .attr("dy", ".31em")
                        .text(function(e) {
                            return d.name
                        })    
                        .attr("y", diameter/2-50)
                        .attr("x", padding + 30 + (dataset.length + 1) * 13)
                        .style("stroke","none")
                        .style("fill","black")
                        .style("font", "12px sans-serif")
                        .style("font-weight","bold")
                        .style("fill-opacity", "1");
                    
                        var rect = svg2.selectAll(".bar").data(dataset);
                        rect
                        .style("stroke", "black")
                        .style("stroke-width", 0.5)
                        .attr("x", function(d, i) {
                            return (padding + 30 + (i * 13));
                        })
                        .attr("y", function(d) {
                            return yScale(d);
                        })//function(d){return d;})
                        .attr("width", 10)
                        .attr("height", function(d) {
                            return (height2 - padding - yScale(d));
                        })
                        .attr("fill", function(e, i) {
                            return colors[i];
                        });
                        svg2.select("g.axis").call(yAxis);
                    }
      
                    d3.select(self.frameElement).style("height", diameter - 150 + "px");
                }else if(document.forms[1].elements[1].value == "sunburst"){
                    var width = 960,
                    height = 700,
                    radius = Math.min(width, height) / 2;

                    var x = d3.scale.linear()
                    .range([0, 2 * Math.PI]);

                    var y = d3.scale.sqrt()
                    .range([0, radius]);

                    var color = d3.scale.category20c();

                    var svg = d3.select("body").select("p").append("svg")
                    .attr("width", width)
                    .attr("height", height)
                    .append("g")
                    .attr("transform", "translate(" + width / 2 + "," + (height / 2 + 10) + ")");

                    var partition = d3.layout.partition()
                    .value(function(d) { return d.size; });

                    var arc = d3.svg.arc()
                    .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
                    .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
                    .innerRadius(function(d) { return Math.max(0, y(d.y)); })
                    .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

                    d3.json(document.forms[1].elements[4].value, function(error, root) {
                        var g = svg.selectAll("g").data(partition.nodes(root)).enter().append("g");
                        //  var path = svg.selectAll("path")
                        //  .data(partition.nodes(root))
                        //  .enter().append("path")
                        var path = g.append("path")
                        .attr("d", arc)
                        .style("fill", function(d) { return color((d.children ? d : d.parent).name); })
                        .on("click", click);
                    
                        var text = g.append("text")
                        .attr("transform", function(d) { return "rotate("+(d.x+d.dx /2 - Math.PI/2)/ Math.PI *180 +")";})
                        .attr("x", function(d){return Math.sqrt(d.y);})
                        .text(function(d) { return d.name; }); 
                    
                        function click(d) {
                            path.transition()
                            .duration(750)
                            .attrTween("d", arcTween(d));
                        }
                    });

                    d3.select(self.frameElement).style("height", height + "px");


  
                }else{
                    alert("type not defined "+document.forms[1].elements[1].value);
                }
 
            }
            // Interpolate the scales!
            function arcTween(d) {
                var xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
                yd = d3.interpolate(y.domain(), [d.y, 1]),
                yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
                return function(d, i) {
                    return i
                        ? function(t) { return arc(d); }
                    : function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); return arc(d); };
                };
            }

            function updateNode(){
                var nodeUpdate = svg.selectAll("g.node").select("text")
                .style("font-size", textSize+"px");
            }

            function downloadfunction()
            {
                var html = d3.select("svg")
                    .attr("version", 1.1)
                    .attr("xmlns", "http://www.w3.org/2000/svg")
                    .node().parentNode.html;
                var serializer = new XMLSerializer();
                var xmlString = serializer.serializeToString(d3.select('svg').node());
               

                var imgsrc = 'data:image/svg+xml;charset=utf-8;base64,'+ btoa(xmlString);

                if(d3.event.target.value == "DownloadPNG"){

              

                    var canvas = document.querySelector("canvas"),
                    context = canvas.getContext("2d");


                    var image = new Image;
                    image.src = imgsrc;
                    image.onload = function() {
                    context.drawImage(image, 0, 0);

                    var canvasdata = canvas.toDataURL("image/png");
                //    console.log(canvasdata);
	  var pngimg = '<img src="'+canvasdata+'">'; 

	  var a = document.createElement("a");
	  a.download = "sample.png";
	  a.href = canvasdata;
          document.body.appendChild(a);
	  a.click();
    };
  }else{
      var img = '<img src="'+imgsrc+'">';   
      	  var a = document.createElement("a");
	  a.download = "sample.svg";
	  a.href = imgsrc;
          document.body.appendChild(a);
	  a.click();
  }
            }
            function update(source) {
                var nodes = tree.nodes(root).reverse(),
                links = tree.links(nodes);
                // Normalize for fixed-depth.
                //         nodes.forEach(function(d) {
                //             d.y = d.depth * 180;
                //         });
                var counter = 0;

               
                var nodeHeight = 15;
                
                var maxPerLevel = new Object();
                nodes.forEach(function(d) {
                    if(rank.toLowerCase() == "species" || rank.toLowerCase() == "otu"){
                        // d.y = d.depth * 140;//180;
                        d.y = d.depth * nodeDistance;
                    }else{
                        d.y = d.depth * nodeDistance ;//180;                       
                    }
                    //var max = d3.max(d.relAbundance);
                    var abundanceNumber = d.relAbundance.map(Number);
                    var curVal = d3.max(abundanceNumber);
                    
                    if (maxPerLevel.hasOwnProperty(d.depth)) {
                        var storedMax = maxPerLevel[d.depth];
                        if(curVal > parseFloat(storedMax)){
                            maxPerLevel[d.depth] = curVal;
                        }
                    }else{
                            maxPerLevel[d.depth] = curVal;   
                        
                    }
                    //    maxPerLevel[d.depth] = d3.max([max, storedMax]);

                })              
                //links between the nodes
                if(edge == 'fixed'){
                    //  links = tree.links(nodes)  ;                   
                }else{

                    var links2 = [];
                    var linkspos = {};
                    links.forEach(function(d) {
                        counter++;
                        var c = d.source.children;
                        if (typeof (c) != 'undefined') {
                            if (c.length > 1) {
                                var s = new Object;
                                var t = new Object;
                                if (linkspos.hasOwnProperty(d.source.name)) {
                                    var newpos = linkspos[d.source.name] + (d.target.size / 2 + 1) / 2;
                                    s.x = newpos;
                                    s.x0 = newpos;
                                    linkspos[d.source.name] = newpos + (d.target.size / 2 + 1) / 2 - 1;
                                } else {
                                    var newpos = d.source.x - (d.source.size / 2 + 1) / 2 + (d.target.size / 2 + 1) / 2;
                                    s.x = newpos;
                                    s.x0 = newpos;
                                    linkspos[d.source.name] = newpos + (d.target.size / 2 + 1) / 2 - 1;

                                }
                                t.x = d.target.x;
                                t.x0 = d.target.x;
                                s.y = d.source.y;
                                t.y = d.target.y;
                                s.y0 = d.source.y;
                                t.y0 = d.target.y;
                                if(edge == 'fixed'){
                                    t.size = 5;                     
                                }else{
                                    t.size = d.target.size;
                                }
                                t.depth = d.target.depth;
                                s.depth = d.source.depth;
                                t.id = counter;

                                s.name = d.source.name;
                                t.name = d.target.name;


                                links2.push({source: s, target: t});

                            } else {

                                var s = new Object;
                                var t = new Object;
                                s.x = d.source.x;
                                t.x = d.target.x;
                                s.x0 = d.source.x;
                                t.x0 = d.target.x;
                                s.y = d.source.y;
                                t.y = d.target.y;
                                s.y0 = d.source.y;
                                t.y0 = d.target.y;
                                t.size = d.target.size;
                                s.name = d.source.name;
                                t.name = d.target.name;
                                // t.id = d.target.id;
                                t.id = counter;
                                links2.push({source: s, target: t});
                            }
                        }
                    });                            
                    links = links2;
                }


            
                //define scales for each depth
                var yScales = new Object();
                // var yAxiss = new Object();
                var maxValues = [];
                for (var k in maxPerLevel) {
                    if (maxPerLevel.hasOwnProperty(k)) {
                        var yScale = d3.scale.linear()
                        .domain([0, maxPerLevel[k]])
                        .range([nodeHeight, 0]);
                        //         yAxiss[k] = yAxis;
                        yScales[k] = yScale;
                    }
                }

                // Update the nodes
                var node = svg.selectAll("g.node")
                .data(nodes, function(d) {
                    return d.id || (d.id = ++i);
                });
                    
                // Enter any new nodes at the parent's previous position.
                var nodeEnter = node.enter().append("g")
                .attr("class", "node")
                .attr("transform", function(d) {
                    return "translate(" + source.y0 + "," + source.x0 + ")";
                })
                .on("click", click);
                //Add depth specific area (for depth-dependent levels
                nodeEnter.append("g")
                .attr("class", function(d) {
                    return "depth" + d.depth;
                });
                   
              
                //var xstart = 0;  //dependent on sample.depth
                if(samplePlot){ 
                    nodeEnter.append("text")  
                    .attr("x", function(d) {
                        
                        if(d.name == "Root"){
                            return ( 4 * samples.length) ;
                        }else{
                            return d.children || d._children ? (20 + 4 * samples.length) : (20 + 4 * samples.length);   //(-10+ (15 + 10 * samples.length))
                        }
                    })
                    .text(function(d) {
                        return d.name;
                    })
                    .style("font", textSize+"px sans-serif")
                    .style("fill-opacity", 1e-6);
                }else{
                    nodeEnter.append("text")
                    .attr("x", function(d) {
                              
                        return d.children || d._children ? -4 : 4;
                          
                      
                        //   return d.children || d._children ? d+2 : d;
                    })         
                    .attr("dy", ".35em")
                    .attr("text-anchor", function(d) {
                        return d.children || d._children ? "end" : "start";
                    })
                    .style("font", textSize+"px sans-serif")
                    .text(function(d) {
                        return d.name;
                    });
                    nodeEnter.append("circle")
                    .attr("r",2.5)
                    .style("fill", function(d) {return d.children || d._children ? "blue": "lightblue"})
                    .style("stroke", "black")
                    .style("stroke-width",0.5);
                    
                  
                }
                // Transition nodes to their new position.
                var nodeUpdate = node.transition()
                .duration(duration)
                .attr("transform", function(d) {
                    return "translate(" + d.y + "," + d.x + ")";
                });

                nodeUpdate.select("text")
                .style("fill-opacity", 1)
                .style("font", textSize+"px sans-serif");
                // Transition exiting nodes to the parent's new position.
                var nodeExit = node.exit().transition()
                .duration(duration)
                .attr("transform", function(d) {
                    return "translate(" + source.y + "," + source.x + ")";
                })
                .remove();

                nodeExit.select("circle")
                .attr("r", 1e-6);

                nodeExit.select("text")
                .style("fill-opacity", 1e-6);
                if(samplePlot){
                                                 

                    //Barcharts with relative distribution of taxon  
                    var sample = nodeEnter.append("g").attr("class","sample");
                    //   var nodescaled = nodeEnter.selectAll("g").selectAll("rect").data(function(d) {
                    var nodescaled = sample.selectAll("rect").data(function(d) {
                        var scaledRelAbundance = [];
                        if(d.name !="Root"){
                            for (var i = 0; i < d.relAbundance.length; i++) {
                                scaledRelAbundance.push(yScales[d.depth](d.relAbundance[i]));
                                abundances.push(yScales[d.depth](d.relAbundance[i]));
                            }
                        }
                        //abundances.push(scaledRelAbundance);
                        return scaledRelAbundance;
                    }
                );

                    nodescaled.enter().append("rect")
                    .attr("height", function(d) {
                        return nodeHeight - d;
                    })
                    .attr("x", function(d, i) {
                        return ((i - 0) * 4);//
                    })
                    .attr("y", function(d) {
                        return d - nodeHeight;
                    })
                    .attr("width", 4)
                    .attr("fill", function(d, i) {
                        return colors[i];
                    })
                    .style("stroke", "black");
                    //scale  
                    nodescaled.enter().append("line")
                    .attr("x1",samples.length * 4 + 2 +1)
                    .attr("x2",samples.length * 4 + 2+ 1)
                    .attr("y1", function(d) {
                        return nodeHeight*(-1);
                    })
                    .attr("y2", function(d) {
                        return 0;
                    })          
                    .attr("stroke-width", 1)
                    .attr("stroke", "grey");
                
                    nodescaled.enter().append("line")
                    .attr("x1",samples.length * 4 + 2 )
                    .attr("x2",samples.length * 4 + 2+4)
                    .attr("y1", function(d) {
                        return 0;
                    })
                    .attr("y2", function(d) {
                        return 0;
                    })          
                    .attr("stroke-width", 1)
                    .attr("stroke", "black");
            
                    nodescaled.enter().append("line")
                    .attr("x1",samples.length * 4 + 2 )
                    .attr("x2",samples.length * 4 + 2+4)
                    .attr("y1", function(d) {
                        return nodeHeight*(-1);
                    })
                    .attr("y2", function(d) {
                        return nodeHeight*(-1);
                    })          
                    .attr("stroke-width", 1)
                    .attr("stroke", "black");
         
                    nodescaled.enter().append("line")
                    .attr("x1",samples.length * 4 + 2 )
                    .attr("x2",samples.length * 4 + 2+4)
                    .attr("y1", nodeHeight/2*(-1))
                    .attr("y2", nodeHeight/2*(-1))   
                    .attr("stroke-width", 1)
                    .attr("stroke", "black");
            
   
                    //scale text
                    //                    nodeEnter.append("text")
                    //                    .attr("x",samples.length * 4 + 7 )
                    //                    .attr("y", nodeHeight/2-nodeHeight+2)                    
                    //                    .text(function(d) {
                    //                        return Math.round(maxPerLevel[d.depth] / 2)
                    //                    })   
                    //                    .style("visibility", function(d) {
                    //                        if(d.name == "Root"){
                    //                            return "hidden"; 
                    //                        }
                    //                    })
                    //                    .style("font", "10px sans-serif"); 
            
                    sample.append("text")
                    .attr("x",samples.length * 4 + 7 )
                    .attr("y", -nodeHeight+2)                    
                    .text(function(d) {
                        if(d.name !="Root"){
                            return Math.round(maxPerLevel[d.depth])
                        }
                    })
                    .style("font", "10px sans-serif");
              
                    sample.append("text")
                    .attr("x",samples.length * 4 + 7 )
                    .attr("y",2)                    
                    .text(function(d) {
                        
                        if(d.name !="Root"){
                            return "0"
                        }
                    })  
                    .style("font", "10px sans-serif");
              

                }
                
                var nodesUpdate = svg.selectAll("g.node").selectAll("g.sample").attr("transform", function(d) {
                    return "scale(" + scaleNode + "," + scaleNode+ ")";
                });
                // Update the links
                var link = svg.selectAll("path.link")
                .data(links, function(d) {
                    return d.target.id;
                })
                ;
                //   .data(links);

                // Enter any new links at the parent's previous position.
                link.enter().insert("path", "g")
                .attr("class", "link")
                //for total stroke width todo

                .attr("d", function(d) {
                    var o = {x: source.x0, y: source.y0};
                    return diagonal({source: o, target: o});
                })
                .style("fill", "none")
                .style("stroke", "#ccc");

                // Transition links to their new position.
                if(edge == 'fixed'){
                    link.transition()
                    .duration(duration)
                    .style("stroke-width",5)
                    .attr("d", diagonal);                   
                }else{
                    link.transition()
                    .duration(duration)
                    .style("stroke-width", function(d) {
                        return (d.target.size / 2 + 1);
                    })
                    .attr("d", diagonal);
                }
                // Transition exiting nodes to the parent's new position.
                link.exit().transition()
                .duration(duration)
                .attr("d", function(d) {
                    var o = {x: source.x, y: source.y};
                    return diagonal({source: o, target: o});
                })
                .remove();

                // Stash the old positions for transition.
                nodes.forEach(function(d) {
                    d.x0 = d.x;
                    d.y0 = d.y;
                });
  
            
 
d3.select("#download").on("click", function(){
downloadfunction();

}); 

//                d3.select("#download")
//                .on("click", function() {
//                    var serializer = new XMLSerializer();
//                    var xmlString = serializer.serializeToString(d3.select('svg').node());
//                                  var imgData = 'data:image/svg+xml;base64,' + btoa(xmlString);
//                    var uri = new XMLSerializer().serializeToString(// serialise
//                    d3.select('svg').node()),
//                    win;
//                    var cssstyle = ".node line{fill: none;stroke: black;shape-rendering: crispEdges;}";
//                    uri = 'data:image/svg+xml;charset=utf-8,' + window.encodeURIComponent( uri); // to data URI
//                    win = window.open(uri, '_blank'); // open new window
//
//
//                       console.log(imgData)
//                });
            }


            //          function getYaxis(d) {
            //             return call(yAxiss(d.depth));
            //       }
            // Toggle children on click.
            function click(d) {
                if (d.children) {
                    d._children = d.children;
                    d.children = null;
                } else {
                    d.children = d._children;
                    d._children = null;
                }
                update(d);
            }


            function nudge(dx, dy) {
                node.filter(function(d) { return d.selected; })
                .attr("cx", function(d) { return d.x += dx; })
                .attr("cy", function(d) { return meanfilterd.y += dy; })

                link.filter(function(d) { return d.source.selected; })
                .attr("x1", function(d) { return d.source.x; })
                .attr("y1", function(d) { return d.source.y; });

                link.filter(function(d) { return d.target.selected; })
                .attr("x2", function(d) { return d.target.x; })
                .attr("y2", function(d) { return d.target.y; });

                d3.event.preventDefault();
            }

            function keydown() {
                if (!d3.event.metaKey) switch (d3.event.keyCode) {
                    case 38: nudge( 0, -1); break; // UP
                    case 40: nudge( 0, +1); break; // DOWN
                    case 37: nudge(-1,  0); break; // LEFT
                    case 39: nudge(+1,  0); break; // RIGHT
                }
                shiftKey = d3.event.shiftKey || d3.event.metaKey;
            }

            function keyup() {
                shiftKey = d3.event.shiftKey || d3.event.metaKey;
            }
        </script></div>







    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>

</f:view>
