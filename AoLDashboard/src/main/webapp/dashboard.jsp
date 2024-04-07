<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.beanlib.Authentication" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">

<title>The AoL Dashboard</title>

</head>
<body>

<%
 String user = "";
 //not logged in yet, unauthorize user needs to log in first
 if(session.getAttribute("login")==null || session.getAttribute("login")==" ") {
   response.sendRedirect("index.jsp"); 
   return;
 }
 // return user info based on login account
 user = login.getUser(session.getAttribute("login").toString());
%>

<header>
	<h1>Welcome, <%= user %>, to the AoL Dashboard</h1>
</header>

<ul>
	<li class="li_main_menu">
		<a href="import.jsp">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">file_upload</i>
		<br>Import AoL Data</a>
	</li>
	<li class="li_main_menu">
		<a href="chart.jsp?ctype=course_id">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">assignment</i>
		<br>View Course Charts</a>
	</li> 
 	<li class="li_main_menu">
		<a href="chart.jsp?ctype=year">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">assignment</i>
		<br>View Year Charts</a>
	</li>
	<li class="li_main_menu">
		<a href="chart.jsp?ctype=unit_id">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">assignment</i>
		<br>View Unit Charts</a>
	</li> 
 	<li class="li_main_menu">
		<a href="chart.jsp?ctype=ga_id">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">assignment</i>
		<br>View Competency Charts</a>
	</li> 
	<li class="li_main_menu">
		<a href="chart.jsp?ctype=iteration">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">assignment</i>
		<br>View Iteration Charts</a>
	</li> 
	<li class="li_main_menu">
		<a href="report.jsp">
		<i class="material-icons main-menu-img" style="font-size:120px;color:#3c1a50">file_download</i>
		<br>Generate Reports</a>
	</li>
</ul>
	
<br><br>

<footer>
	<nav><ul>
		<li><a href="password.jsp"><button class="btn_sub_menu"><i class="fa fa-lock"></i> Change Password</button></a></li>
		<li><a href="logout.jsp"><button class="btn_sub_menu"><i class="fa fa-sign-out"></i> Logout</button></a></li>
	</ul></nav>
</footer>

</body>
</html>