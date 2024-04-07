<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page errorPage="error.jsp" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Log out from the system</title>
</head>

<body>
	<%
	session.invalidate(); //destroy session
	response.sendRedirect("index.jsp");
	%>
</body>
</html>
