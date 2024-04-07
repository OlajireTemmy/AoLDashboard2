<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %> 
<%@ page import="com.beanlib.Authentication" %> 
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>

<!DOCTYPE html>
<html lang="en">
<head> 
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<title>Import AoL Data from File</title>
</head> 

<body>
	<%
	// If the user has not logged in yet, the unauthorised user needs to log in first
	if (session.getAttribute("login") == null || session.getAttribute("login") == " ") {
		response.sendRedirect("index.jsp");
		return;
	}
	%>
	
	<header>
		<h1>AoL Dashboard System</h1>
		<h2>Select a CSV file to import</h2>
	</header>
	
	<form action="upload.jsp" method="post" enctype="multipart/form-data">
		<div class="container"> 
			<input type="file" name="file" class="import_file" />
			<br><br>
			<button type="submit" name="btn_import" id="btn_submit">Import</button>
			<br><br>
			
			<button type="submit" formaction="dashboard.jsp" id="backtohome">
				<i class="fa fa-home"></i> Back to Home</button>
		</div>
	</form>
</body>
</html>
