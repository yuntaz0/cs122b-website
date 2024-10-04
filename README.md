# README

Java-based full-stack web application

## Required packages

```
fd-find ripgrep tomcat10 fzf fish mysql-server openjdk-11-jdk neovim git-delta maven
```

There may be a issue with default java version

```sh
sudo update-alternatives --config java
```

it should give `/usr/lib/jvm/java-11-openjdk-amd64/bin/java` as one of the options

Tomcat10 <-> Java servlets (Java classes) <-> JDBC (Java Database Connectivity) <-> MySQL

## MySQL

Backend Database

### JDBC Java Database Connectivity

Essentially, JDBC is an API that tanslates Java code to run a variety of relational databases, such as MySQL, by providing methods and interfaces to execute SQL queries, manage connections, and process the results.

1. Load the JDBC Driver - a commnication link between your Java code and the database server - translate Java calls into database-specific calls

	```mysql
	Class.forName("com.mysql.cj.jdbc.Driver");
	```

2. Establish a database connection - `DriverManager` class and `Connection connection`
	- JDBC driver communicates with the MySQL  server over network (TCP, IP)

	```mysql
	String url = "jdbc:mysql://localhost:3306/moviedbexample";
	String user = "myuser";
	String password = "mypassword";
	Connection connection = DriverManager.getConnection(url, user, password);
	```

3. Create a `Statement` - queries or `PreparedStatement` - parameterized queries and prevent SQL injection to send SQL queries to the database
	- close statement when done `stmt.close();` - consumes resources on both the **Java side** (within the JDBC driver) and the **database side** (potentially holding locks or other resources).

	```mysql
	String query = "SELECT * FROM movies WHERE year = ?"; 
	PreparedStatement stmt = connection.prepareStatement(query); 
	stmt.setInt(1, 2023); // Set the value for the parameter `?`
	```

4. Execute the SQL query
	- JDBC API absracts the SQL interaction, poviding methods that let user directly execute SQL statement from Java code
	- `executeQuery()`: for `SELECT` that return a `ResultSet`
	- `executeUpdate()`: for `INSERT`, `UPDATE`, `DELETE` that modify data, return the number of affected rows
	- `execute()`: for executing multiple statements - stored procedure (such as each `SELECT` returns one `ResultSet`) that could return multiple `ResultSet`. It returns a boolean indicating whether the first result is a `ResultSet` (T) or and update count (F).

		```mysql
		// Create a CallableStatement to call a stored procedure
		CallableStatement stmt = connection.prepareCall("{call getMultipleResults()}");
		
		// Execute the stored procedure
		boolean hasResults = stmt.execute(); // Returns true if the first result is a ResultSet
		
		// Process all results
		while (hasResults) {
		    ResultSet resultSet = stmt.getResultSet(); // Get the current ResultSet
		    while (resultSet.next()) { // Iterate through each row in the ResultSet
		        // Process each row (for example, print a value from the result set)
		        System.out.println("Column Value: " + resultSet.getString(1));
		    }
		    // Close the current ResultSet
		    resultSet.close();
		    
		    // Move to the next result (could be another ResultSet or an update count)
		    hasResults = stmt.getMoreResults(); // Returns true if there is another ResultSet
		}
		
		// Close the CallableStatement
		stmt.close();
		```
		
	```mysql
	ResultSet resultSet = stmt.executeQuery();
	```
	
5. Process the `ResultSet` - SQL returns data - a cursor that points to the rows returned by the query
	- iterate through the returned rows and retrieve data from each column
	- JDBC handles data conversion between Java and SQL types
	- close `ResultSet` when done `resultSet.close();` - database keeps the memory and resources associated with that `ResultSet` until it is closed.

	```mysql
	while (resultSet.next()) {
	    String title = resultSet.getString("title");
	    int year = resultSet.getInt("year");
	    System.out.println("Movie: " + title + ", Year: " + year);
	}
	```
	
6. Closing the `Connection` to prevent resource leaks and keeps the database server from getting overloaded
	- For connection pool, instead of closing, the connection is usually return to the pool - it is reused for the next client that needs a connection.

	```mysql
	Connection connection = null;
	Statement statement = null;
	ResultSet resultSet = null;
	
	try {
	    connection = dataSource.getConnection();
	    statement = connection.createStatement();
	    resultSet = statement.executeQuery("SELECT * FROM movies");
	
	    while (resultSet.next()) {
	        String title = resultSet.getString("title");
	        System.out.println("Movie: " + title);
	    }
	} catch (SQLException e) {
	    e.printStackTrace();
	} finally {
	    // Close ResultSet first
	    if (resultSet != null) {
	        try {
	            resultSet.close();
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	    }
	    
	    // Close Statement second
	    if (statement != null) {
	        try {
	            statement.close();
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	    }
	
	    // Close Connection last
	    if (connection != null) {
	        try {
	            connection.close();
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	    }
	}
	// Or use Apache Common DbUtils
	
	} finally {
		DbUtils.closeQuietly(rs);
		DbUtils.closeQuietly(ps);
		DbUtils.closeQuietly(conn);
	}
	```
		
### Common Issue

- login as root user via sudo

	```sh
	sudo mysql
	```

- add mytestuser and grant permissions

	```mysql
	CREATE USER 'mytestuser'@'localhost' IDENTIFIED BY '123123'; GRANT ALL PRIVILEGES ON *.* TO 'testuser'@'localhost' WITH GRANT OPTION;
	```

- Cannot login as testuser

	```sh
	mysql -h 127.0.0.1 -P 3306 -u <user> -p <database>
	```

- enable mysql logs

	```mysql
	SET GLOBAL general_log = 'ON';
	```

- logs
	- /var/log/mysql/error.log
	- /var/lib/mysql/$hostname.log
	- /var/lib/mysql/$hostname.log
	- /var/lib/mysql/

- login as root user: `sudo -u root -p` can be replaced with `sudo mysql`

- cannot login as root user due to `ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)`

	```sh
	sudo service mysql --full-restart
	```

- run a script on a specific database

	```sh
	mysql database_name < script.sql
	```

- run a command on a specific database

	```sh
	mysql moviedb -e "cmd"
	```

	```sh
	mysql -e "USE database; cmd"
	```

- cannot login as mytestuser due to `ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (13)`
	
	```sh
	mysql -h 127.0.0.1 -P 3306 -u <user> -p <database>
	```

- launch website from CLI

	```sh
	mvn clean package
	```

	- then move war file to `/usr/share/tomcat10/webapps/` (sometimes sudo this)
	- you can have multiple war files for multiple urls
	- tomcat10 seems to create a folder for each one
	- the name of the folder should be appended to the url to access page from browser

## Tomcat10

- Servlet: a small program that runs on a web server often accessing databases in response to client input
- **Servlet container** (aka web container): a part of a webserver that interacts with **Java Servlets** (Java classes that handle requests and generate response).
	- receive HTTP request
	- invoke the appropriated servlet `/movies` or `/customers`
		- Here servlet connect to mysql with JDBC and generate response
	- send back the generated response

- rely on JRE to execute Java code for servlets and Java Server Pages (dynamic web pages using Java code embedded within HTML)
- **separate the frontend from the backend**: The web client (UI) is distinct from the backend (data and business logic).
- **Security**: You can use Tomcat to implement security features such as user authentication, encryption, and session management, ensuring that only authorized requests can interact with the database. Java classes (servlets or RESTful services) that can include **middleware logic** like authentication, authorization, validation, and request processing before interacting with the database.
- **Ease of Database Access**: Using Java libraries like **JDBC** and **JPA**, your servlets can access the MySQL database efficiently. Tomcat provides an environment to manage **connection pooling**, ensuring optimal database connectivity.
- **Connection pooling**: When a servlet needs a connection, it retrieves one from the pool instead of creating a new one. After using it, the connection is returned to the pool rather than being closed, allowing it to be reused. Tomcat provides built-in support for **connection pooling** using a library called **Apache Commons DBCP** (Database Connection Pooling).

### Example

1. A user navigates to `http://localhost:8080/movies` in their browser.
2. The browser sends an HTTP **GET request** to Tomcat.
3. Tomcat routes the request to a **Servlet** that handles `/movies`.
4. The servlet:
    - Connects to **MySQL** to execute a query like `SELECT * FROM movies`.
    - Retrieves the data, processes it, and formats it as an **HTML** page (if using JSP) or **JSON** object (if building a RESTful API).
5. Tomcat returns the response to the browser, which displays the list of movies to the user.

### Common Issues

- `tomcat10-admin` is required for management
- tomcat10 is at `/usr/share/tomcat10`
- if log directory is missing at the begin

	```sh
	sudo mkdir -p /usr/share/tomcat10/logs/
	```

- `server.xml` and `web.xml` are missing: cp from `/etc/tomcat10` and `chmod o+r` them for intellij to copy
- If Firefox auto set it to https, website port 8080 does not work. Use http instead.
- cannot shutdown due to `SEVERE: No shutdown port configured. Shut down server through OS signal. Server not shut down.`
	- change `server.xml` in `/usr/share/tomcat10/conf/` so it have `<Server port="8005" shutdown="SHUTDOWN">`. the default value is `-1`

## Development

- **War**: packaging `mvn package` WAR file will be generated in the target directory
- Tomcat Deployment:
	1. Deploy WAR file to webapps/. Tomcat will automatically unpack and deploy the application when it starts
	2. run `sudo /usr/share/tomcat10/bin/startup.sh` to start
	3. run `/usr/share/tomcat10/bin/shutdown.sh` to stop

## Structure

```
my-web-app/
 ├── src/
 │    ├── main/
 │    │    ├── java/
 │    │    │    └── com/example/  (Java classes)
 │    │    ├── resources/
 │    │    │    └── application.properties  (Config files)
 │    │    └── webapp/
 │    │         ├── WEB-INF/
 │    │         │     └── web.xml  (Servlet configurations)
 │    │         ├── index.jsp  (JSP pages)
 │    │         └── static/  (CSS, JS)
 │    └── test/  (Unit tests)
 ├── pom.xml  (Maven build file)

```
