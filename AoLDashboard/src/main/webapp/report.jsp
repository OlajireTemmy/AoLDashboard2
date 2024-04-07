<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*, com.beanlib.Configuration, com.beanlib.ChartsAndReports" %>
<jsp:useBean id="chart" class="com.beanlib.ChartsAndReports"></jsp:useBean>
<jsp:useBean id="conf" class="com.beanlib.Configuration"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<%
//check condition unauthorize user redirected to login page
if(session.getAttribute("login")==null || session.getAttribute("login")==" ") {
 response.sendRedirect("index.jsp"); 
 return;
}

%>

<title>Generate status and action plan reports</title>
<style>
input[type=checkbox] {
    transform: scale(1.5);
}
</style>
</head>
<body>

	<div class="container">
		<form method="post">
			<table class="table table-bordered table-striped">
				<thead> 	
					<tr>
						<th>In Status Report?</th>
						<th>Status Analysis</th>
						<th>AoL Chart</th>
						<th>Action Plan</th>
						<th>In Action Report?</th>
					</tr>
				</thead>
				<tbody>
				
					<%// retrieve all charts from the database
					  String sqlquery = "select * from chartsinreports";
					  Connection conn = DriverManager.getConnection(conf.getDbConnectionURL());
					  PreparedStatement ps=conn.prepareStatement(sqlquery, ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE); 
		    		  ResultSet rs = ps.executeQuery();

		    		  // display each chart, provide spaces for entering chart analyses, 
		    		  // and use checkboxes to select included charts
					  int row = 0;
					  while (rs.next()) {
						// placeholder if no analysis was given  
						String statusHolder = "Chart status analysis (at least 50 characters)";
						String actionHolder = "Chart action plan (at least 50 characters)";
						// display existing analysis if it exists
						String statusValue = "";
						String actionValue = "";
						
						if (rs.getString("status") != null && !rs.getString("status").equals(""))
							statusValue = rs.getString("status");
						if (rs.getString("action") != null && !rs.getString("action").equals(""))
							actionValue = rs.getString("action");
						
						out.print("<tr>");
						// value of each checkbox is set to the corresponding row number to record which row is checked
						out.print("<td class=\"clickable\" onclick=\"getElementById('checkbox1_" + row + "').click();\">" + 
									"<input type=\"checkbox\" name=\"instatus\" value = \"" + row + "\" id=\"checkbox1_" + row + "\" onclick=\"this.click()\"></td>");
						// write chart analysis if it exists
						if (statusValue.equals("")) {
							out.print("<td><textarea style=\"font-size: 10pt\" minlength=\"50\" maxlength=\"200\" name=\"status" +
								"\" placeholder=\"" + statusHolder + "\" rows=\"40\" cols=\"50\"></textarea></td>");
						} else {
							out.print("<td><textarea style=\"font-size: 10pt\" minlength=\"50\" maxlength=\"1000\" name=\"status\" rows=\"40\" cols=\"50\">" + statusValue + "</textarea></td>");
						}
						// load the chart
						out.print("<td><img src=\"" + rs.getString("chart") + "\" WIDTH=\"800\" HEIGHT=\"600\" BORDER=\"0\"></td>");
						// write chart action plan if it exists
						if (actionValue.equals("")) {
							out.print("<td><textarea style=\"font-size: 10pt\" minlength=\"50\" maxlength=\"200\" name=\"action" +
								"\" placeholder=\"" + actionHolder + "\" rows=\"40\" cols=\"50\"></textarea></td>");
						} else {
							out.print("<td><textarea style=\"font-size: 10pt\" minlength=\"50\" maxlength=\"1000\" name=\"action\" rows=\"40\" cols=\"50\">" + actionValue + "</textarea></td>");
						}
						// value of each checkbox is set to the corresponding row number to record which row is checked
						out.print("<td class=\"clickable\" onclick=\"getElementById('checkbox2_" + row + "').click();\">" +
									"<input type=\"checkbox\" name=\"inaction\" value = \"" + row + "\" id=\"checkbox2_" + row + "\" onclick=\"this.click()\"></td>");
						out.print("</tr>");

						row++;
					}

					rs.close();
					ps.close();
					conn.close();
					
				%>
				</tbody>
			</table>
			<button type="submit" id="btn_submit" name="btn_status" onclick="showProgress()"> Download Status Report </button>
			<i id="progress" class="fa fa-spinner fa-spin" style="display:none"></i> 
			<button type="submit" id="btn_submit" name="btn_action" onclick="showProgress()"> Download Action Plan Report </button>
			<i id="progress" class="fa fa-spinner fa-spin" style="display:none"></i> 
		</form>
	</div>
	
<%
//instatus[] contains the row numbers of charts to included in status report
String[] instatus = request.getParameterValues("instatus");
//status[] contains status analysis of each chart
String[] status = request.getParameterValues("status");
//inaction[] contains the row numbers of charts to included in action plan report
String[] inaction = request.getParameterValues("inaction");
//action[] contains action plan of each chart
String[] action = request.getParameterValues("action");

//the "Download Status Report" button is clicked
if (request.getParameter("btn_status") != null) {
	String reportType = chart.generateReport(request, instatus, status, null, action);
	response.sendRedirect(reportType + ".docx");
	
}

//the "Download Action Plan Report" button is clicked
if (request.getParameter("btn_action") != null) {
	String reportType = chart.generateReport(request, null, status, inaction, action);
	response.sendRedirect(reportType + ".docx");	
}

%>

<br><br>
<a href="dashboard.jsp"><button type="submit" id="backtohome"> 
	<i class="fa fa-home"></i> Back to Home</button></a>
</body>
</html>