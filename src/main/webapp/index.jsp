    <%--
    Document   : error
    Created on : Oct 13, 2011, 8:13:49 PM
    Author     : lutzK
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="f" uri="http://java.sun.com/jsf/core"%>
<%@taglib prefix="h" uri="http://java.sun.com/jsf/html"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<f:view>
    <f:subview id="header">
        <jsp:include page="header.jsp"></jsp:include>
    </f:subview>

    


            <p>
                    
<f:subview id="indexCalypso" rendered="#{!SessionDataBean.dataMiner}">
        <jsp:include page="indexCalypso.jsp"></jsp:include>
    </f:subview>

<f:subview id="indexDM" rendered="#{SessionDataBean.dataMiner}">
        <jsp:include page="indexDataMiner.jsp"></jsp:include>
    </f:subview>
       
    <f:subview id="footer">
        <%@ include file="jspf/footer.jspf" %>
    </f:subview>
</f:view>
