package com.beanlib;

import java.awt.BasicStroke;
import java.awt.Color;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.util.Units;
import org.apache.poi.xwpf.usermodel.Document;
import org.apache.poi.xwpf.usermodel.ParagraphAlignment;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.ValueMarker;
import org.jfree.chart.renderer.category.StackedBarRenderer;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;

/* This class provides methods for generating various 
 * AoL required charts and reports
 */
public class ChartsAndReports {
		  // 3 groups of grades
		  final String[] Grades = {"Below Expectation", "Meet Expectation", "Above Expectation"};
		  // 10 graduate attributes
		  final String[] GA = {"GA1: Human Dignity", "GA2: Common Good", "GA3: Ethics", "GA4: Critical Thinking", 
				  "GA5: Discipline Knowledge", "GA6: Problem Solving", "GA7: Team Work", "GA8: Digital Literacy",
				  "GA9: Communication", "GA10: Use of Technologies"}; 
		  // 6 campuses
		  final String[] Campuses = {"ONL", "NSY", "MEL", "BNE", "STR", "BKT"};
		  
		  // benchmark line of 15%
		  final double benchmark = 0.15;
		  
		  // Generate multi-competency chart
		  public JFreeChart generateMCChart(String type, String param) {
			  String rangelabel = "";
			  String charttitle = "";
			  
			  // chart title depends on the type of chart
			  switch (type) {
			  	case "year":		charttitle = "Year Report (" + param + ")"; 
			  						break;
			  	case "iteration":	charttitle = "Iteration (" + param + ")";  
									break;
			  	case "course_id":	//map course_id to the chart title
			  						switch (param) {
			  							case "BBA": 		charttitle = "Bachelor of Business Administration";
			  												break;
			  							case "BCOM:Mktg": 	charttitle = "Bachelor of Commerce (Marketing)";
															break;
			  							case "BCOM:Finc": 	charttitle = "Bachelor of Commerce (Finance)";
			    	  										break;
			  							case "BCOM:Acct": 	charttitle = "Bachelor of Commerce (Accounting)";
															break;
			  							case "BCOM:Evmg": 	charttitle = "Bachelor of Commerce (Event Management)";
															break;
			  							case "BCOM:Hrmg": 	charttitle = "Bachelor of Commerce (Human Resources Management)";
			  												break;
			  							case "BCOM:Infm": 	charttitle = "Bachelor of Commerce (Informatics)";
															break;
			  							case "BCOM:Mngt": 	charttitle = "Bachelor of Commerce (Management)";
															break;
			  						}
			  						break;
			  	case "unit_id":		String desc = getUnitDesc(param);
			  						if (desc != null && desc != "") {
			  							charttitle = param + ":" + desc;
			  						} else {
			  							charttitle = "Unit does not exist";
			  						}
			  						break;
			  }

			  //prepare the dataset
			  String sqlquery = "select score from aoldata where " + type + "=\'" + param + "\' AND ga_id = ?";
			  final CategoryDataset dataset = generateMCDataset(sqlquery);
			  
			  //no data
			  if (!dataset.equals(new DefaultCategoryDataset())) {
				  //rangelabel = "No data available for this input!";

				  //create the chart   	     	  
				  final JFreeChart chart = ChartFactory.createStackedBarChart(
					  charttitle, // chart title
					  "Graduate Attributes", //domain (Y) axis label
					  rangelabel, //range (X) axis label
					  dataset, // dataset
					  PlotOrientation.HORIZONTAL, //orientation
					  true, // include legend
					  true, // tooltips
					  false // urls
					  );

				  // create the plot
				  createPlotChart(chart);

				  return chart; 
			  } else {
				  return null;
			  }

		  }	

		  // return unit description from unit_id
		  private String getUnitDesc(String unit_id) {
			  String desc = "";
			  
			  try {
				  Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
				  PreparedStatement ps = conn.prepareStatement("select unit_desc from aoldata where unit_id = ?");
				  ps.setString(1, unit_id);
				  ResultSet rs = ps.executeQuery();
				  
				  if (rs.next()) {
					desc = rs.getString("unit_desc");  
				  }
				  
				  rs.close();
				  ps.close();
				  conn.close();

			  } catch (Exception e) {
				  e.printStackTrace();
			  }
			  
			  return desc;		  
		  }
		  
		  // generate multi-competency dataset from database using sqlquery
	      private CategoryDataset generateMCDataset(String sqlquery) {
	    	  
	    	  DefaultCategoryDataset result = new DefaultCategoryDataset();
	    	  
	    	  // 2-d array: 10 GAs and 3 groupings of scores (below, meet, above)
	    	  double[][] dataEntry = new double[10][3]; 
	    	  
	    	  // Initialise array
	    	  for (int i=0; i<10; i++)
	    		  for (int j=0; j<3; j++)
	    			  dataEntry[i][j] = 0.0;
	    	  
	    	  try {
	  			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
	  			PreparedStatement ps;
	      	    ResultSet rs;
	      	  
	  			// check each GA
	  			for (int i=0; i<10; i++) {
	  				ps=conn.prepareStatement(sqlquery); 
	  				ps.setInt(1, i+1);

	  				rs = ps.executeQuery();

	  				int score_all = 0;
	  				int score_below = 0;
	  				int score_meet = 0;
	  				int score_above = 0;
	  				
	  				// classify grades into 3 groupings
	  				while (rs.next()) {
	  					score_all += 1;
	  					switch (rs.getString("score")) {
	  						case "NN": score_below += 1;
	  								   break;
	  						case "PA":
	  						case "CR": score_meet += 1;
	  								   break;
	  						case "DI":
	  						case "HD": score_above += 1;
	  								   break;
	  	
	  					}  				
	  				}
	 				
	  				// calculate the percentage of each group
	  				dataEntry[i][0] = (double)score_below/score_all;
	  				dataEntry[i][1] = (double)score_meet/score_all;
	  				dataEntry[i][2] = (double)score_above/score_all;
	  				
	  				// Add data into the dataset
	  				if (dataEntry[i][0] > 0.0 || dataEntry[i][1] > 0.0 || dataEntry[i][2] > 0.0) {
	  					result.addValue(dataEntry[i][0], Grades[0], GA[i]+" (n="+score_all+")");
	  					result.addValue(dataEntry[i][1], Grades[1], GA[i]+" (n="+score_all+")");
	  					result.addValue(dataEntry[i][2], Grades[2], GA[i]+" (n="+score_all+")");		
	  				}
	  	  			rs.close();
	  	  			ps.close();
	  			}
	  			conn.close();	

	  		} catch(Exception e) {
	  				//Handle errors for Class.forName
	  				e.printStackTrace();
	  				return result;
	  		} 			

	  		return result;

	      } 
	 
		  // Generate single-competency chart, one for ga_id
		  public JFreeChart generateSCChart(int ga_id) {
			  //JFreeChart chart = null;
			  String charttitle = GA[ga_id-1]; 
			  String rangelabel = "";
			  //prepare the dataset for this particular competency
			  final CategoryDataset dataset = generateSCDataset(ga_id);
			  //no data
			  if (!dataset.equals(new DefaultCategoryDataset())) {
				  //rangelabel = "no data"; //range (X) axis label
				  //create the chart   	     	  
				  final JFreeChart chart = ChartFactory.createStackedBarChart(
					  charttitle, // chart title
					  charttitle, //domain (Y) axis label
					  rangelabel, //range (X) axis label
					  dataset, // dataset
					  PlotOrientation.HORIZONTAL, //orientation
					  true, // include legend
					  true, // tooltips
					  false // urls
					  );

				  	// create the plot
				  	createPlotChart(chart);
				  	return chart;
			  } else {
				  return null;
			  }
		  }	
		  
		  // generate single-competency dataset from database 
		  /* Sprint 3 is to complete this method
		   * Hints:
		   * 1. Retrieve all units that ensure this ga_id
		   * 2. Store a set of unique units using HashSet
		   *   	Set<String> unit_set = new HashSet<String>();    	    
		   *   	while (rs.next()) {
		   *   		unit_set.add(rs.getString("unit_id"));
		   *   	}
		   *   
		   * 3. Declare the 2-d dataEntry: the number of rows is 6 * unit_set.size() (max number of entries, 
		   *    each unit has 6 campuses) and the number of columns is 3 (below, meet, above)
		   * 4. Initialise the array to be 0.0 for each element
		   * 5. Declare a variable entry_loc_block (initialised to be 0 and increments by 6 
		   *    because each unit needs a block of 6 entries, one for each campus)
		   * 6. Declare an iterator to check each element in unit_set: Iterator<String> itr = unit_set.iterator()
		   * 7. For each unit while(itr.hasNext()):
		   * 	  - retrieve the unit_id: String unit_id = itr.next();
		   *      - retrieve the scores for each campus of this unit using a loop: for (int i=0; i<6; i++)
		   *      	* the query for each campus is: select score from aoldata where ga_id=? and unit_id=? and campus_id=?
		   *      	* execute the query
		   *          * aggregate the scores and save the data into dataEntry (dataEntry[i+entry_loc_block][0..2]) 
		   *            by referring to the generateMCDataset method after line ps.executeQuery();
		   *      - increment entry_loc_block: entry_loc_block += 6;
		   *      - close the resultset and then the prepareStatement
		   *
		   */
		  private CategoryDataset generateSCDataset(int ga_id) {
			  DefaultCategoryDataset result = new DefaultCategoryDataset();

			  return result;

		  } 
	 
	      // create the plot from the chart
	      private void createPlotChart(final JFreeChart chart) {
	  		  //prepare the plot from the chart
	      	  CategoryPlot plot = chart.getCategoryPlot();
	      	  
	      	  // Using percentage for X axis
	      	  NumberAxis numberaxis = (NumberAxis) plot.getRangeAxis();
	      	  numberaxis.setNumberFormatOverride(NumberFormat.getPercentInstance());
	      	  
	      	  final StackedBarRenderer renderer = (StackedBarRenderer) plot.getRenderer();
	      	  
	      	  //display percentages
	      	  renderer.setRenderAsPercentages(true);
	      	  
	      	  // set bar width
	      	  renderer.setMaximumBarWidth(0.1);
	      	  
	      	  //Set traffic light colors
	      	  plot.getRenderer().setSeriesPaint(0, Color.RED);
	          plot.getRenderer().setSeriesPaint(1, Color.YELLOW);
	          plot.getRenderer().setSeriesPaint(2, Color.GREEN);
	            
	          // draw the benchmark line 
	          ValueMarker vm = new ValueMarker(benchmark);
	          vm.setPaint(Color.BLACK);
	          vm.setStroke(new BasicStroke(2));
	          plot.addRangeMarker(vm);           
	  	  }
	      
	      // Save chartName to the table chartsinreports
	      /* Sprint 4 needs to complete this method
	       * Hints:
	       * 	1. first check whether the chart is is already saved in the table
	       * 	2. if not already save, insert a new record to the table
	       */
	      public void saveChart(String chartName) {
	    	  
	      }
	    
	                  
	      // generate current status or action plan report in word format
	      public String generateReport(HttpServletRequest request, 
	    		  String[] instatus, String[] status, String[] inaction, String[] action) 
	    				  throws IOException, SQLException, InvalidFormatException {
	    	  
	    	  // decide the report type
	    	  String reportType = "";
	    	  if (instatus != null)
	    		  reportType = "status_report";
	    	  else  if (inaction != null)
	    		  reportType = "action_report";
	    	  
	    	  // add status analysis and action plan of each chart to the database
	    	  saveAnalysis(instatus, status, inaction, action);
	    	  
	    	  // create word document
	    	  try (XWPFDocument doc = new XWPFDocument()) {

	              // create a paragraph
	              XWPFParagraph p = doc.createParagraph();
	              p.setAlignment(ParagraphAlignment.LEFT);

	              // create the report heading
	              XWPFRun r = p.createRun();
	              r.setBold(true);
	              r.setItalic(true);
	              r.setFontSize(22);
	      		  r.setFontFamily("New Roman");
	              // add text
	              r.setText("This is the "+ reportType);
	              // add break
	              r.addBreak();
	              
	              // add selected charts and analyses into the report
	              Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
	    		  PreparedStatement ps;
	    		  ResultSet rs;
	    		  
	    		  String sqlquery = "select * from chartsinreports where " + reportType + "=1";
	    		  ps=conn.prepareStatement(sqlquery); 
	    		  rs = ps.executeQuery();
	    		  // when the chart is to be included in the report
	    		  while (rs.next() && rs.getInt(reportType) == 1) {
	    			  String chartname = rs.getString("chart");
	    			  // add the chart 
	    			  if (chartname != null && chartname != "") {
	    				  String imgFile = request.getServletContext().getRealPath(".") + "/" + rs.getString("chart");
	        			  // add the file into the word document
	        			  try (FileInputStream fis = new FileInputStream(imgFile)) {
	        				  r.addPicture(fis,
	                                Document.PICTURE_TYPE_PNG,    // png file
	                                imgFile,
	                                Units.toEMU(400),
	                                Units.toEMU(300));            // 400x200 pixels
	        			  }
	        			  r.addBreak();
	    			  }
	    			  // add the chart analysis
	    			  r = p.createRun();
		              r.setBold(false);
		              r.setItalic(false);
		              r.setFontSize(12);
		      		  r.setFontFamily("New Roman");
	    			  r.setText(rs.getString(reportType.substring(0, reportType.indexOf('_'))));
		              // add break
		              r.addBreak();
	    		  }
	    		  
	    		  rs.close();
	    		  ps.close();
	    		  conn.close();
	              
	              // save everything to .docx file
	              final File f = new File(request.getServletContext().getRealPath(".") + "/" + reportType + ".docx");
	              try (FileOutputStream out = new FileOutputStream(f)) {
	                  doc.write(out);
	              }
	              
	          }
	    	  
	    	  return reportType;
    	  
	      }
	      
	      // save status analysis and action plan of each chart to table chartsinreports
	      // and also flag whether the chart is to be included in the status report and/or action plan report
	      /* Sprint 5 needs to complete this method
	       * instatus[] array stores the row numbers checkboxed to be included in status report
	       * status[] array stores the status analysis of each chart row by row
	       * inaction[] array stores the row numbers checkboxed to be included in action plan report
	       * action[] array stores the action plan of each chart row by row
	       * 
	       * Hints:
	       * 	1. set variables reportType and inType according to the report type
	       * 	2. Retrieve all records from table chartsinreports using 
	       * 		ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE to allow updates to records
	       * 	3. loop through all records with variable row pointing to the current row and
	       * 		variable i pointing to current instatus/inaction array index
	       * 		1. if the chart's status analysis is not empty, save it to the table
	       * 		2. if the chart's action plan is not empty, save it to the table
	       * 		3. clear the existing report inclusion flag
	       * 		4. if the current row appears in inType[], it means it is checkboxed for this type of report
	       * 			and the corresponding inlusion flag is set to 1
	       * 		5. update the row and increment variable row
	       * 
	       */
	      void saveAnalysis(String[] instatus, String[] status, String[] inaction, String action[]) {
	    	  try {
	    		 //decide the report type
		    	  String reportType = ""; //report type: "status_report" or "action_report"
		    	  String inType[] = null; //checkbox type: instatus or inaction
		    	  
		    	  // your code here
	    		  
	    	  } catch(Exception e) {
	    		  //Handle errors for Class.forName
	    		  e.printStackTrace();
	    	  } 			

	      }
}
