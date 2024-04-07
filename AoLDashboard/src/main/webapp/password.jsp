<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.beanlib.Authentication" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">

<title>Change your password</title>
</head>

<body>
	<header>
		<h1>AoL Dashboard System</h1>
		<h2>Change Your Password</h2>
	</header>

	<form method="post">
		<div class="container">
			<label for="email">Email:</label>
			<input type="text" placeholder="Enter Email Address" name="email" id="email" required>
			<label for="oldpassword">Old Password:</label>
			<input type="password" placeholder="Enter old password" name="password" id="oldpassword" required>
			<label for="newpassword">New Password:</label>
			<input type="password" placeholder="Enter new password" name="passwordNew" id="newpassword" required>
			<label for="newagain">Confirm New Password:</label>
			<input type="password" placeholder="Enter new password again" name="passwordAgain" id="newagain" required>
			<button type="submit" name="btn_change" id="btn_submit">Change</button>
		</div>
	</form>

	<form method="post" action="dashboard.jsp">
		<div class="container">
			<button type="submit" id="backtohome"><i class="fa fa-home"></i> Back to Home</button>
		</div>
	</form>


	<%
	// If the user has not logged in yet, the unauthorised user needs to log in first
	if (session.getAttribute("login") == null || session.getAttribute("login") == " ") {
		response.sendRedirect("index.jsp");
		return;
	}
	%>
	
	<!-- pass user input to login Bean class -->
	<jsp:setProperty name="login" property="email" param="email" />
	<jsp:setProperty name="login" property="password" param="password" />
	<jsp:setProperty name="login" property="passwordNew" param="passwordNew" />
		<jsp:setProperty name="login" property="confirmPassword" param="passwordAgain" />

	<%
	// if change button is clicked
	/* Sprint 2 needs to complete this part
	 * Hints:
	 * 	1. retrieve new password and retyped new password from the form
	 *  2. if they don't match, display an error message, otherwise call login.changePassword() method
	 *  3. if it returns 1, destroy the session, display a success message, and provide a link to index.jsp for sign in again
	 *  4. if it return 0, display an error message
	 *  5. if it return -1, display an error message
	 */
	if (request.getParameter("btn_change") != null) {
		if(!login.getPasswordNew().equals(login.getConfirmPassword())){
			out.println("<font color=\"red\"><h2>New Password does not match with Confirm New Password.</h2></font>");
		}
		else{
			int changePassword = login.changePassword();
			if(changePassword == 1){
				
				 session.invalidate();
				 //response.sendRedirect("index.jsp"); 
				 out.println("<font color=\"blue\"><h2>Password changed successfully. Please <a href='index.jsp'>login</a> again</h2></font>");
					 
				
			}else if(changePassword == -1){
				out.println("<font color=\"red\"><h2>Incorrect Email or Password</h2></font>");
			}else{
				out.println("<font color=\"red\"><h2>User does not exist</h2></font>");
			}
		}
	}
	
	%>

</body>
</html>
