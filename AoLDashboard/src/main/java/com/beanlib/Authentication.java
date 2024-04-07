package com.beanlib;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.apache.commons.lang3.RandomStringUtils;
//jBCrypt is a Java™ implementation of OpenBSD's Blowfish password hashing code, 
//as described in "A Future-Adaptable Password Scheme" by Niels Provos and David Mazières.
//http://www.mindrot.org/projects/jBCrypt/
import org.mindrot.jbcrypt.BCrypt;

/* This Bean class contains methods for registering a new user, 
 * validating user login, updating and removing login, changing password, 
 * and returning user info
 */
public class Authentication {
	// Attributes
	String firstname;
	String lastname;
	String email;
	String password;
	String passwordNew;
	String confirmPassword;
	
	// public accessors
	public String getFirstname() { return firstname;}
	public String getLastname() { return lastname;}
	public String getEmail() { return email;}
	public String getPassword() {return password;}
	public String getPasswordNew() {return passwordNew;}
	
	public void setFirstname (String first) { firstname = first;}
	public void setLastname (String last) { lastname = last;}
	public void setEmail (String em) { email = em; }
	public void setPassword (String pass) {	password = pass;}
	public void setPasswordNew (String passnew) {passwordNew = passnew;}
	
	
	public String getConfirmPassword() {
		return confirmPassword;
	}
	public void setConfirmPassword(String confirmPassword) {
		this.confirmPassword = confirmPassword;
	}
	// validate user log in 
	public int validateLogin() {
		int loginCode = -1; // -1: login failed, 0: account not activated, 1: login succeeded 
		
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps=conn.prepareStatement("select * from login where email=?"); 
			// provide parameter values
			ps.setString(1, email);
			// execute sql query
			ResultSet rs = ps.executeQuery();
			
			if (rs.next()) {
				// database stores encrypted password
				String hashedpw = rs.getString("password");
				
				// password matches and account activated
				if (BCrypt.checkpw(password, hashedpw) && rs.getInt("activated") == 1) {
					loginCode = 1;	
				} else if (BCrypt.checkpw(password, hashedpw)) {
					loginCode = 0;	
				} 
			}
			
			// close resultset, statement and connection
			rs.close();
			ps.close();
			conn.close();
						
		 } catch(Exception e) {
	         //Handle errors for Class.forName
	         e.printStackTrace();
		 }
		
		return loginCode;
		
	}
	// register a new user
	/* Sprint 1 needs to complete this method
	 * 
	 * Hints:
	 * 1. call InitDB() to create database and tables 
	 * 2. search the entered email address from the login table, if it exists, regcode = 0
	 * 3. if it does not exist, insert the account information (firstname, lastname, email, password) into login table, and regcode = 1
	 * 4. before that, you need to encrypt the password using the following code and store hashedpw into the table.
	 * 		String hashedpw = BCrypt.hashpw(password, BCrypt.gensalt(12));
	 */
	public int registerLogin() {
		int regcode = -1; //-1: error, 0: email exists, 1: successful
		// create database and tables
		//Connection conn = InitDB();
		boolean exist = false;
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps=conn.prepareStatement("select * from login where email=?"); 
			// provide parameter values
			ps.setString(1, email);
			// execute sql query
			ResultSet rs = ps.executeQuery();
			
			if (rs.next()) {
				exist = true;
				regcode = 0;
			}
			
			// close resultset, statement and connection
			rs.close();
			ps.close();
			conn.close();
						
		 } catch(Exception e) {
	         //Handle errors for Class.forName
	         e.printStackTrace();
		 }
		if(!exist) {
			regcode = 1;
			insertUser();
		}
		return regcode;
	}

	public int insertUser() {
		int record = 0;
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps = conn
					.prepareStatement("INSERT INTO aoldb.LOGIN (firstname, lastname, email, password) VALUES (?, ?, ?, ?)");
			// provide parameter values
			ps.setString(1, firstname);
			ps.setString(2, lastname);
			ps.setString(3, email);
			String hashedpw = BCrypt.hashpw(password, BCrypt.gensalt(12));
			ps.setString(4, hashedpw);
			// execute sql query
			record = ps.executeUpdate();

			ps.close();
			conn.close();

		} catch (Exception e) {
			// Handle errors for Class.forName
			e.printStackTrace();
		}

		return record;
	}
	

	
	
	// Create database and tables
	// return a connection to database for further use
	private Connection InitDB() {
		Connection conn = null;
		
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			//establish connection to mysql server
			conn = DriverManager.getConnection(Configuration.connectionURL);
			//create aoldb database
			String createdb = "CREATE DATABASE IF NOT EXISTS aoldb";
			PreparedStatement ps = conn.prepareStatement(createdb);
			ps.execute();
			//create login table			
			String createtable = "CREATE TABLE IF NOT EXISTS aoldb.login ("
				+ "firstname varchar(10) NOT NULL,"
				+ "lastname varchar(12) NOT NULL,"
				+ "email varchar(40) NOT NULL UNIQUE,"
				+ "password varchar(200) NOT NULL, "
				+ "activated INT NULL, "
				+ "acticode varchar(10) NULL, "
				+ "PRIMARY KEY (email)) ENGINE=InnoDB DEFAULT CHARSET=utf8";
			
			ps = conn.prepareStatement(createtable);
			ps.execute();
			
			//create chartsinreports table			
			createtable = "CREATE TABLE IF NOT EXISTS aoldb.chartsinreports ("
				+ "chart varchar(50) NOT NULL UNIQUE,"
				+ "status varchar(500) NULL,"
				+ "action varchar(500) NULL,"
				+ "status_report INT NULL,"
				+ "action_report INT NULL,"
				+ "PRIMARY KEY (chart)) ENGINE=InnoDB DEFAULT CHARSET=utf8";
			
			
			
			ps = conn.prepareStatement(createtable);
			ps.execute();
			
			//create chartsinreports table			
			createtable = "CREATE TABLE IF NOT EXISTS aoldb.aoldata ("
				+ "course_id varchar(10) NOT NULL UNIQUE,"
				+ "unit_id varchar(10) NOT NULL,"
				+ "unit_desc varchar(100) NOT NULL,"
				+ "assesment_id INT NOT NULL,"
				+ "student_id varchar(10) NOT NULL,"
				+ "campus_id varchar(20) NOT NULL,"
				+ "criteria INT NOT NULL,"
				+ "ga_id INT NOT NULL,"
				+ "score varchar(2) NOT NULL,"
				+ "category varchar(30) NOT NULL,"
				+ "weight INT NOT NULL,"
				+ "learning_starge varchar(5) NOT NULL,"
				+ "aspect INT NOT NULL,"
				+ "iteration INT NOT NULL,"
				+ "year INT NOT NULL,"
				+ "semester INT NOT NULL,"
				+ "aol_flag INT NOT NULL"
				+ "PRIMARY KEY (course_id,unit_id,assesment_id,student_id,campus_id,criteria,ga_id,iteration,year,semester)) ENGINE=InnoDB DEFAULT CHARSET=utf8";
			
			
			
			ps = conn.prepareStatement(createtable);
			ps.execute();
			
			ps.close();
		 } catch(Exception e) {
	         //Handle errors 
	         e.printStackTrace();
		 }
		
		return conn;
	}
	
	// remove the account from the database
	public void removeLogin(String email) {
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps=conn.prepareStatement("delete from login where email = ?"); 
			// provide parameter values
			ps.setString(1, email);
			// execute sql query
			ps.executeUpdate();

			// statement and connection
			ps.close();
			conn.close();
						
		 } catch(Exception e) {
	         //Handle errors for Class.forName
	         e.printStackTrace();
		 }
	}
	
	// update the account with the specified email
	/* Sprint 1 needs to complete this method
	 * if activation code acticode is null, it is called by the approver to generate the code 
	 * and save the code into the login table. if activation code acticode is not null, it is called
	 * by the user to activate the account.
	 * Hints: 
	 * 1. if (acticode == null), use the following code to generate 10-digit activation code
	 * 		acticode = RandomStringUtils.randomAlphanumeric(10);
	 * 2. save the code into login table using update statement
	 * 3. if (acticode != null), set activated =1 using update statement
	 */
	public String updateLogin(String acticode, String email) {
		if(acticode == null) {
			acticode = RandomStringUtils.randomAlphanumeric(10);
			updateUser(acticode, email, 0);
		}else {
			updateUser(acticode, email, 1);
		}
		
		return acticode;
	}
	
	public int updateUser(String acticode, String email, Integer activated) {
		int record = 0;
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps = conn
					.prepareStatement("UPDATE aoldb.LOGIN SET acticode = ?, activated = ? where email = ?");
			// provide parameter values
			ps.setString(1, acticode);
			ps.setInt(2, activated);
			ps.setString(3, email);
			
			record = ps.executeUpdate();

			ps.close();
			conn.close();

		} catch (Exception e) {
			// Handle errors for Class.forName
			e.printStackTrace();
		}

		return record;
	}
	
	public int updatePassword(String password, String email) {
		int record = 0;
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps = conn
					.prepareStatement("UPDATE aoldb.LOGIN SET password = ? where email = ?");
			// provide parameter values
			ps.setString(1, BCrypt.hashpw(password, BCrypt.gensalt(12)));
			ps.setString(2, email);
			
			
			record = ps.executeUpdate();

			ps.close();
			conn.close();

		} catch (Exception e) {
			// Handle errors for Class.forName
			e.printStackTrace();
		}

		return record;
	}
		
	// change user password
	/* Sprint 2 needs to complete this method
	 * Hints:
	 * 1. using email to retrieve the account record. you can either use update statement or select statement with 
	 * 	  options ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE so that you can modify the record
	 * 2. if record does not exist, changeCode = 0 (email not found)
	 * 3. if record is found, check whether password is correct using BCrypt.checkpw(password, rs.getString("password"))
	 * 4. if password is correct, encrypt the new password, update the old password with the new password, and set changeCode = 1
	 * 5. if password is incorrect, set changeCode = 0 (wrong password)
	 */
	public int changePassword() {
		int changeCode = -1; //1: successful, 0: incorrect email or password, -1: error
		
		User user = this.getUserInfo(this.email);
		if(user != null) {
			boolean checkedPassword = BCrypt.checkpw(this.getPassword(), user.getPassword());
			if(checkedPassword) {
				updatePassword(this.getPasswordNew(), this.email);
				changeCode = 1;
			}
		}else {
			changeCode = 0;
		}
		return changeCode;
	}
	
	// return user info
	public String getUser(String email) {
		String user = "";
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps=conn.prepareStatement("select * from login where email = ?"); 
			// provide parameter values
			ps.setString(1, email);
			// execute sql query
			ResultSet rs = ps.executeQuery();
			
			// both email and password match
			if (rs.next()) {
			    user = rs.getString("firstname") + " " + rs.getString("lastname");	
			}
			
			// close resultset, statement and connection
			rs.close();
			ps.close();
			conn.close();
						
		 } catch(Exception e) {
	         //Handle errors for Class.forName
	         e.printStackTrace();
		 }
		
		return user;
	}

	
	// return user info
	public User getUserInfo(String email) {
		User user = null;
		try {
			// load and register JDBC driver for MySQL
			Class.forName("com.mysql.cj.jdbc.Driver");
			// establish a connection to the database
			Connection conn = DriverManager.getConnection(Configuration.dbConnectionURL);
			// prepare a SQl statement
			PreparedStatement ps=conn.prepareStatement("select * from login where email = ?"); 
			// provide parameter values
			ps.setString(1, email);
			// execute sql query
			ResultSet rs = ps.executeQuery();
			user = new User();
			// both email and password match
			if (rs.next()) {
				user.setFirstName(rs.getString("firstname")); 
				user.setLastName(rs.getString("lastname")); 
				user.setEmail(rs.getString("email")); 
				user.setPassword(rs.getString("password")); 
				
			}
			
			// close resultset, statement and connection
			rs.close();
			ps.close();
			conn.close();
						
		 } catch(Exception e) {
	         //Handle errors for Class.forName
	         e.printStackTrace();
		 }
		
		return user;
	}
	

}
