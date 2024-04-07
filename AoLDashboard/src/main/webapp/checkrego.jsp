<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.beanlib.Authentication" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>
<jsp:useBean id="util" class="com.beanlib.AoLUtil"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<title>Approve/Decline Account Registration</title>
</head>

<body>
	<header>
		<h1>AoL Dashboard System</h1>
	</header>

	<%
	String email = request.getParameter("email");
	String decision = request.getParameter("decision");
	// if approver declines the request 
	if (decision.equals("no")) {
		// remove the corresponding entry from database
		login.removeLogin(email);
		
		// Extract the URL of the request
		String linkbase = request.getRequestURL().toString();
		String link = linkbase.substring(0, linkbase.indexOf("checkrego.jsp"));
		
		String[] requestor = {email};
		String subject = "AoLDashboard: Accout Activation Required";
		String htmlmsg = "Your request for account registration has been declined.<br>";
		// send out an email notification to requester
		util.sendEmail(requestor, subject, htmlmsg);
		
		out.print("<font color=\"#cc0000\"><h1> Request for Account Registration is declined! </h1></font>");
	}
	// if approver approves the request 
	else if (decision.equals("yes")) {
		// update the corresponding entry
		String acticode = login.updateLogin(null, email);
		// Extract the URL of the request
		String linkbase = request.getRequestURL().toString();
		String link = linkbase.substring(0, linkbase.indexOf("checkrego.jsp"));
		
		String[] requestor = {email};
		String subject = "AoLDashboard: Accout Activation Required";
		String htmlmsg = "Your request for account registration has been approved.<br>" + 
						 "Please <a href=\"" + link + "activate.jsp?email=" + email + "&acticode=" + acticode + "\"> Activate </a>.";
		// send out approval email notification to requester
		util.sendEmail(requestor, subject, htmlmsg);

		out.print("<font color=\"#3c1a50\"><h1> Request for Account Registration is approved! </h1></font>");
		out.print("<font color=\"#3c1a50\"><h2> Check your email and activate your account! </h2></font>");
	}
	%>

</body>
</html>
