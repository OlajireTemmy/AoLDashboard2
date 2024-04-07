<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.beanlib.Authentication" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
<title>Please log on to the AoL Dashboard System</title>
</head>
<body>

<h1> AoL Dashboard System </h1> 
    <form method="post">  
        <div class="container">   
            <label>Email : </label>   
            <input type="text" placeholder="Enter Username" name="email" required>  
            <label>Password : </label>   
            <input type="password" placeholder="Enter Password" name="password" required>  
            <button type="submit" name="btn_login">Login</button> 
        </div>   
    </form>    
    
    <form method="post" action="register.jsp">  
        <div class="container">   
            <label>No account? </label>   
            <button type="submit" class="signupbtn"> Sign Up Here</button>   
        </div>   
    </form>     
     

<%
// already logged in, redirect to the dashboard home
if (session.getAttribute("login")!=null) {
	response.sendRedirect("dashboard.jsp");
}
%> 
<!-- pass user input to login Bean class -->
<jsp:setProperty name="login" property="email" param="email"/>
<jsp:setProperty name="login" property="password" param="password"/>

<% 
  // get user input from the form
  String email = request.getParameter("email");
  String password = request.getParameter("password");
  // if login button is clicked
  if(request.getParameter("btn_login") != null) {
	 // successful login 
	 if (login.validateLogin() == 1) {
	   // set session information 
	   session.setAttribute("login", email);
	   // redirect to the dashboard home
	   response.sendRedirect("dashboard.jsp");
 	  // If the user's account has not activated
	 } else if (login.validateLogin() == 0) {
			out.println("<font color=\"#cc0000\"><h2>Account not activated. " +
								"Please refer to the account activation email!</h2></font>");
  	 } else {
		out.println("<font color=\"#cc0000\"><h2>Invalid password or username (email). " + 
								"Please log in again!</h2></font>");
	 }
   }
%>
</body>
</html>