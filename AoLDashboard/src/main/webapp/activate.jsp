<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.beanlib.Authentication" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<title>Activate Your Account</title>
</head>

<body>
	<header>
		<h1>AoL Dashboard Workflow System</h1>
	</header>
	
	<%
	String email = request.getParameter("email");
	String acticode = request.getParameter("acticode");
	// update the corresponding entry
	login.updateLogin(acticode, email);

	out.print("<font color=\"#3c1a50\"><h1> Your account has been activated! </h1></font>");
	%>

	<form method="post" action="index.jsp">
		<div class="container">
			<label for="btn_sign_up_or_sign_in">Ready to Sign In? </label>
			<button type="submit" id="btn_sign_up_or_sign_in">Sign In Here</button>
		</div>
	</form>

</body>
</html>
