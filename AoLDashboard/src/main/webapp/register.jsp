<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.beanlib.Authentication" %>
<%@ page errorPage="error.jsp" %>
<jsp:useBean id="login" class="com.beanlib.Authentication"></jsp:useBean>
<jsp:useBean id="conf" class="com.beanlib.Configuration"></jsp:useBean>
<jsp:useBean id="util" class="com.beanlib.AoLUtil"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<title>Please Sign Up Here</title>
<script>
    function showProgress() {
        document.getElementById('progress').style.display = 'inline-block';
    }
</script>  
</head>
<body>

<h1> AoL Dashboard System Sign Up </h1> 
    <form method="post" >  
        <div class="container">   
            <label>First name : </label>   
            <input type="text" placeholder="Enter first name" name="firstname" required>
            <label>Last name : </label>   
            <input type="text" placeholder="Enter last name" name="lastname" required>   
            <label>Email : </label>   
            <input type="text" placeholder="Enter email" name="email" required> 
            <label>Password : </label>   
            <input type="password" placeholder="Enter Password" name="password" required>  
           	
           	<button type="submit" name="btn_register" id="btn_submit" onclick="showProgress()">Register</button>
			<i id="progress" class="fa fa-spinner fa-spin" style="display:none"></i>
        </div>   
    </form>  
    
    <form method="post" action="index.jsp">
		<div class="container">
			<label for="btn_sign_up_or_sign_in">Ready to Sign In? </label>
			<button type="submit" id="btn_sign_up_or_sign_in">Sign In Here</button>
		</div>
	</form>    
  
<%
// already logged in
if (session.getAttribute("login")!=null) {
	response.sendRedirect("dashboard.jsp");
}
%>
<!-- pass all user input to login Bean class -->
<jsp:setProperty name="login" property="*" />

<% 
  //if register button is clicked
  if(request.getParameter("btn_register") != null) {
	 // register successful 
	 if (login.registerLogin() == 1) {
		// send email notification to approver
		String firstname = request.getParameter("firstname");
		String lastname = request.getParameter("lastname");
		String email = request.getParameter("email");	
		String approvEmail = conf.getApprovEmail();
		
		String[] approver = {approvEmail};
				
		String linkbase = request.getRequestURL().toString();
		String link = linkbase.substring(0, linkbase.indexOf("register.jsp"));
		String subject = "AoLDashboard: Accout Registration Approval Required";
		String htmlmsg = firstname + " " + lastname + " requested creating account: " + email + ".<br>"
						+ " Please <a href=\"" + link + "checkrego.jsp?email=" + email + "&decision=yes\"> Approve </a> or " 
						+ "<a href=\"" + link + "checkrego.jsp?email=" + email + "&decision=no\"> Decline </a>";

		util.sendEmail(approver, subject, htmlmsg);
	 
		 
		out.println("<font color=\"#3c1a50\"><h2>Registration is successful, pending approval!</h2></font>");
	 // If the username has already registered
	 } else if (login.registerLogin() == 0) {
	 	 	out.println("<font color=\"#cc0000\"><h2>This account was already registered. " + 
	 						" Please <a href = \"index.jsp\"> log in <a>!</h2></font>");
	 // If the registeration is unccessful
	 } else {
	  		out.println("<font color=\"#cc0000\"><h2>Register is unsuccessful. Please try it again!</h2></font>");
 	 }
   }
%>

</body>
</html>