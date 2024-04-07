<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.beanlib.DataImport" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="di" class="com.beanlib.DataImport"></jsp:useBean>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<title>File Upload</title>
</head>

<body>
	<header>
		<h1>AoL Dashboard System</h1>
	</header>
	
	<%
	// check condition unauthorize user redirected to login page
	if (session.getAttribute("login") == null || session.getAttribute("login") == " ") {
		response.sendRedirect("index.jsp");
		return;
	}
	
	// Test if the file is successfully uploaded
	if (di.fileToDB(request)) {
		out.println("<font color=\"#3c1a50\"><h2>AoL data has successfully been imported!</h2></font>");
	}
	else {
		out.println("<font color=\"#cc0000\"><h2>AoL data import has failed!</h2></font>");
	}
	
	%>
	
	<a href="dashboard.jsp"><button type="submit" id="backtohome"> 
	<i class="fa fa-home"></i> Back to Home</button></a>
</body>
</html>


		   
