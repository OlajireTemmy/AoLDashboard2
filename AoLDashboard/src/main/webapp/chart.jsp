<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page  import="java.io.*" %>
<%@ page  import="org.jfree.chart.*" %>
<%@ page  import="org.jfree.chart.entity.*" %>
<%@ page  import ="org.jfree.data.general.*"%>

<%@ page import = "com.beanlib.ChartsAndReports" %>
<jsp:useBean id="chart" class="com.beanlib.ChartsAndReports"></jsp:useBean>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

<%
 //check condition unauthorize user needs to log in first
 if(session.getAttribute("login")==null || session.getAttribute("login")==" ") {
   response.sendRedirect("index.jsp"); 
   return;
 }
 // chart types: competency, course, iteration, subject, year
 String ctype = request.getParameter("ctype");
 
%>
<title>Generate <%= ctype %> charts</title>
</head>
<body>
 <form method="post">
 
<%
switch (ctype) {
	case "year": 		out.print("<label for=\"year\">Choose a year:</label>");
						out.print("<select id=\"year\" name=\"year\">");
						out.print("<option value=\"2021\">2021</option>");
						out.print("<option value=\"2020\">2020</option>");
						out.print("<option value=\"2019\">2019</option>");
						out.print("</select> <br> <br>");
						break;
	case "course_id":	out.print("<label for=\"course_id\">Choose a course:</label>");
						out.print("<select id=\"course_id\" name=\"course_id\">");
						out.print("<option value=\"BBA\">Bachelor of Business Administration</option>");
						out.print("<option value=\"BCOM:Mktg\">Bachelor of Commerce (Marketing)</option>");
						out.print("<option value=\"BCOM:Finc\">Bachelor of Commerce (Finance)</option>");
						out.print("<option value=\"BCOM:Acct\">Bachelor of Commerce (Accounting)</option>");	
						out.print("<option value=\"BCOM:Evmg\">Bachelor of Commerce (Event Management)</option>");	
						out.print("<option value=\"BCOM:Hrmg\">Bachelor of Commerce (Human Resources Management)</option>");
						out.print("<option value=\"BCOM:Infm\">Bachelor of Commerce (Informatics)</option>");
						out.print("<option value=\"BCOM:Mngt\">Bachelor of Commerce (Management)</option>");
						out.print("</select> <br> <br>");
						break;
	case "iteration":	out.print("<label for=\"iteration\">Choose an iteration:</label>");
						out.print("<select id=\"iteration\" name=\"iteration\">");
						out.print("<option value=\"3\">3</option>");
						out.print("<option value=\"2\">2</option>");
						out.print("<option value=\"1\">1</option>");
						out.print("</select> <br> <br>");
						break;

	case "unit_id":		out.print("<label for=\"prefix\">Choose a subject:</label>");
						out.print("<select id=\"prefix\" name=\"prefix\">");
						out.print("<option value=\"ACCT\">ACCT</option>");
						out.print("<option value=\"BAFN\">BAFN</option>");
						out.print("<option value=\"BUSN\">BUSN</option>");
						out.print("<option value=\"EMGT\">EMGT</option>");
						out.print("<option value=\"ENTR\">ENTR</option>");
						out.print("<option value=\"HRMG\">HRMG</option>");
						out.print("<option value=\"ITEC\">ITEC</option>");
						out.print("<option value=\"MGMT\">MGMT</option>");
						out.print("<option value=\"MKTG\">MKTG</option>");
						out.print("<option value=\"STAT\">STAT</option>");
						out.print("</select><input type=\"text\" name=\"code\" /> <br> <br>");
						break;
	
	case "ga_id":		out.print("<label for=\"ga_id\">Choose a graduate attribute:</label>");
						out.print("<select id=\"ga_id\" name=\"ga_id\">");
						out.print("<option value=\"1\">GA1: Human Dignity</option>");
						out.print("<option value=\"2\">GA2: Common Good</option>");
						out.print("<option value=\"3\">GA3: Ethics</option>");
						out.print("<option value=\"4\">GA4: Critical Thinking</option>");
						out.print("<option value=\"5\">GA5: Discipline Knowledge</option>");
						out.print("<option value=\"6\">GA6: Problem Solving</option>");
						out.print("<option value=\"7\">GA7: Team Work</option>");
						out.print("<option value=\"8\">GA8: Digital Literacy</option>");
						out.print("<option value=\"9\">GA9: Communication</option>");
						out.print("<option value=\"10\">GA10: Use of Technologies</option>");
						out.print("</select> <br> <br>");
						break;
}

%> 

<button type="submit" id="btn_submit" name="btn_display" value = "Generate Chart">Generate Chart</button>

</form>
 
<%!  
 // generate the chart based on the input
 String generateChart(HttpServletRequest request, com.beanlib.ChartsAndReports aolchart, String ctype) throws Exception {  
	  String filename = "";
	  String param = "";
	  JFreeChart chart = null;
	  
	  switch (ctype) {
	  	case "year": 		param = request.getParameter("year");
	  						filename = param + "_yearchart.png";
	  						break;
	  	case "course_id":	param = request.getParameter("course_id");
					  		filename = param + "_coursechart.png";
		  					// replace ':' with '_' as ':' should not appear in a url
	 	  					filename = filename.replace(':', '_');
	  						break;
	  	case "iteration": 	param = request.getParameter("iteration");
		 					filename = param + "_iterchart.png";
							break;
	  	case "unit_id":		param = request.getParameter("prefix")+request.getParameter("code");
		 					filename = param + "_subjectchart.png";
							break;
	  	case "ga_id":		param = request.getParameter("ga_id");
		  					filename = param + "_compchart.png";
							break;
	  }
	  
	  final ChartRenderingInfo info = new ChartRenderingInfo(new StandardEntityCollection());
	  
	  File file = new File(getServletContext().getRealPath(".") + "/" + filename);
	  
	  // single competency chart
	  if (ctype.equals("ga_id")) {
		  chart = aolchart.generateSCChart(Integer.parseInt(param));
	  // multi-competency chart: year, course, iteration, subject	  
	  } else {
		  chart = aolchart.generateMCChart(ctype, param);
	  }
	  // save chart as a png image
	  if (chart != null) {    
      		ChartUtils.saveChartAsPNG(file, chart, 800, 600, info);
      } else {
    	  filename = "";      
      }
      
      return filename;      
  }

%>

<%
  // the "Display Chart" button is clicked
  if (request.getParameter("btn_display") != null) {
	 // Generate the chart 
	 String chartname = generateChart(request, chart, ctype); 
	 if (!chartname.equals("")) {
		 //save the chart to the database
		 chart.saveChart(chartname);
		 //show the chart
		 out.print("<img src=\"" + chartname + "\" WIDTH=\"800\" HEIGHT=\"600\" BORDER=\"0\"><br>");
 	 } else {
		 out.print("<h3><font color=\"#cc0000\">The type of chart does not exist!</font></h3>");
	 }
          
  }   
  

%>

 <a href="dashboard.jsp"><button type="submit" id="backtohome"> 
	<i class="fa fa-home"></i> Back to Home</button></a>
</body>
</html>