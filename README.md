# README

Java-based full-stack web application

## Required packages

```
fd-find ripgrep tomcat10 fzf fish mysql-server openjdk-11-jdk neovim git-delta maven tomcat10-admin
```

There may be a issue with default java version

```sh
sudo update-alternatives --config java
```

it should give `/usr/lib/jvm/java-11-openjdk-amd64/bin/java` as one of the options

Tomcat 10 <-> Java servlet (Java classes) <-> JDBC (Java Database Connectivity) <-> MySQL

## MySQL

Backend Database

### JDBC Java Database Connectivity

Essentially, JDBC is an API that translates Java code to run a variety of relational databases, such as MySQL, by providing methods and interfaces to execute SQL queries, manage connections, and process the results.

1. Load the JDBC Driver - a communication link between your Java code and the database server - translate Java calls into database-specific calls

	```mysql
	Class.forName("com.mysql.cj.jdbc.Driver");
	```

2. Establish a database connection - `DriverManager` class and `Connection connection`
	- JDBC driver communicates with the MySQL  server over network (TCP, IP)

	```mysql
	String url = "jdbc:mysql://localhost:3306/moviedbexample";
	String user = "username";
	String password = "password";
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
	- JDBC API abstracts the SQL interaction, providing methods that let user directly execute SQL statement from Java code
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

- add `mytestuser` and grant permissions

	```mysql
	CREATE USER 'mytestuser'@'localhost' IDENTIFIED BY 'My6$Password'; GRANT ALL PRIVILEGES ON *.* TO 'testuser'@'localhost' WITH GRANT OPTION;
	```

- ERROR 1044 (42000)
	- Did not grant permission! Check the above command!

- enable MySQL logs

	```mysql
	SET GLOBAL general_log = 'ON';
	```

- logs
	- `/var/log/mysql/error.log`
	- `/var/lib/mysql/$hostname.log`
	- `/var/lib/mysql/$hostname.log`
	- `/var/lib/mysql/`

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

- cannot login as `mytestuser` due to `ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (13)`

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

- SQL NULL to Java null

	- NULL means the field is empty, and it is not the same as 0 or “”
	- String getString(int columnIndex) retrieves the column value as a String and returns null if the SQL value is NULL.
	- int getInt​(int columnIndex) returns the column value; if the value is SQL NULL, the value returned is 0
	- In JDBC, you must explicitly ask if a field is null by using wasNull()

		```java
		String name = rs.getString(1); // Retrieves the value of the first column
		if (name == null) {
			// The value was SQL NULL
			System.out.println("The value is NULL");
		} else {
			System.out.println("Value: " + name);
		}
		```


## Tomcat 10

- Servlet: a small program that runs on a web server often accessing databases in response to client input
- **Servlet container** (aka web container): a part of a webserver that interacts with **Java Servlets** (Java classes that handle requests and generate response).
	- receive HTTP request
	- invoke the appropriated servlet `/movies` or `/customers`
		- Here servlet connect to MySQL with JDBC and generate response
	- send back the generated response

- rely on JRE to execute Java code for servlets and Java Server Pages (dynamic web pages using Java code embedded within HTML)
- **separate the frontend from the backend**: The web client (UI) is distinct from the backend (data and business logic).
- **Security**: You can use Tomcat to implement security features such as user authentication, encryption, and session management, ensuring that only authorized requests can interact with the database. Java classes (servlets or RESTful services) that can include **middle-ware logic** like authentication, authorization, validation, and request processing before interacting with the database.
- **Ease of Database Access**: Using Java libraries like **JDBC** and **JPA**, your servlets can access the MySQL database efficiently. Tomcat provides an environment to manage **connection pooling**, ensuring optimal database connectivity.
- **Connection pooling**: When a servlet needs a connection, it retrieves one from the pool instead of creating a new one. After using it, the connection is returned to the pool rather than being closed, allowing it to be reused. Tomcat provides built-in support for **connection pooling** using a library called **Apache Commons DBCP** (Database Connection Pooling).

### Example
JRE
1. A user navigates to `http://localhost:8080/movies` in their browser.
2. The browser sends an HTTP **GET request** to Tomcat.
3. Tomcat routes the request to a **servlet** that handles `/movies`.
4. The servlet:
    - Connects to **MySQL** to execute a query like `SELECT * FROM movies`.
    - Retrieves the data, processes it, and formats it as an **HTML** page (if using JSP) or **JSON** object (if building a RESTful API).
5. Tomcat returns the response to the browser, which displays the list of movies to the user.

### Common Issues

- check if tomcat 10 is running
	- from AWS instance
	- `curl localhost:8080`
- firewall
	- `sudo ufw allow from any to any port 8080 proto tcp`
- setup tomcat manager
	- `sudoedit /etc/tomcat10/tomcat-users.xml`
```xml
<role rolename="manager-gui"/>  
<user username="admin" password="mypassword" roles="manager-gui"/>
```
- inbound rule:
	- custom TCP port 8080 and your IP address
- `tomcat10-admin` is required for management
- Tomcat 10 can be managed at `/usr/share/tomcat10`, which is not the idea way
	- use when `systemctl` is not available
	- multiple files will be missing, need to manually set up environment
- soft link all missing files before `sudo /usr/share/tomcat10/bin/startup.sh`
	- `webapp` is missing
		- `sudo ln -s /var/lib/tomcat10/webapps /usr/share/tomcat10/`
	- `log` is missing
		- `sudo ln -s /var/lib/tomcat10/logs /usr/share/tomcat10/`
	- `conf` is missing 
		- `sudo ln -s /etc/tomcat10 /usr/share/tomcat10/conf`
	- `manager` is missing from default `webapp`
		- `sudo ln -s /usr/share/tomcat10-admin/host-manager/ /var/lib/tomcat10/webapps/`
		- `sudo ln -s /usr/share/tomcat10-admin/manager /var/lib/tomcat10/webapps/`

```
🧭 /usr/share/tomcat10  
ll  
total 20K  
drwxr-xr-x. 1 root root  360 Oct 10 10:55 bin/  
lrwxrwxrwx. 1 root root   13 Oct 10 12:51 conf -> /etc/tomcat10/  
-rw-r--r--. 1 root root 1017 Dec  3  2023 default.template  
drwxr-xr-x. 1 root root  202 Oct 10 10:55 etc/  
drwxr-xr-x. 1 root root  842 Oct 10 10:55 lib/  
-rw-r--r--. 1 root root  150 Dec  3  2023 logrotate.template  
lrwxrwxrwx. 1 root root   22 Oct 10 12:49 logs -> /var/lib/tomcat10/logs/  
lrwxrwxrwx. 1 root root   25 Oct 10 12:51 webapps -> /var/lib/tomcat10/webapps/  
drwxr-x---. 1 root root   16 Oct 10 12:25 work/

🧭 /var/lib/tomcat10/webapps  
ll  
total 8.0K  
lrwxrwxrwx. 1 root root 39 Oct 10 12:44 host-manager -> /usr/share/tomcat10-admin/host-manager//  
lrwxrwxrwx. 1 root root 33 Oct 10 12:44 manager -> /usr/share/tomcat10-admin/manager/  
drwxr-xr-x. 1 root root 36 Oct 10 10:55 ROOT/
```

- If Firefox auto set it to `https`, website port 8080 does not work. Use `http` instead.
- cannot shutdown due to `SEVERE: No shutdown port configured. Shut down server through OS signal. Server not shut down.`
	- change `server.xml` in `sudoedit /etc/tomcat10/server.xml` so it have `<Server port="8005" shutdown="SHUTDOWN">`. the default value is `-1`

- `WARNING: java.io.tmpdir directory does not exist`
- `sudoedit /usr/share/tomcat10/bin/setenv.sh`
```sh
export CATALINA_TMPDIR=/tmp
export JAVA_OPTS="$JAVA_OPTS -Djava.io.tmpdir=/tmp"
```
## Maven

- starting project
	- `mvn archetype:generate`: generate new project based on an archetype
	- `-DgroupId=edu.uci.ics`: group ID for the project, typically represents the organization or company creating the project. It follows a reverse domain name convention
	- `-DartifactId=fablix-webapp`: the name of the project and the final build artifact
	- `-DarchetypeArtifactId=maven-archetype-webapp`: archetype template to use for generating the project; `maven-archetype-webapp` is a Maven archetype that provides the basic structure for a web application project.
	- `-DarchetypeArtifactId=maven-archetype-webapp`: run the command in non-interactive mode

```sh
mvn archetype:generate -DgroupId=edu.uci.ics -DartifactId=fablix-webapp -DarchetypeArtifactId=maven-archetype-webapp -DinteractiveMode=false
```
	
- `pom.xml`: Project Object Model file, which serves as the main configuration file for a Maven project. It defines the project's structure, dependency, build configuration, and other essential settings that Maven uses to manage the project.
	- Manage dependencies: declare the external libraries and frameworks. Maven automatically download these from a central repository and include them in the project.
	- Define project's metadata
		- `groupId`: one per org
		- `artifactId`: one per project
		- `version`
	- Configure build settings
		- customize the build process, like `warSourceDirectory` is set to `WebContent`
	- Define Project Modules: manage multi module project with one `pom.xml`
	- Manage the project life cycle: Maven has a defined project life cycle; how each stage of the life cycle is handled
		- compile
		- test
		- package
		- install
		- deploy
	- Plugin: Maven supports various plugin that extend its functionality. These plugins are also defined in `pom.xml` and executed as part of the build life cycle
		- `maven-compiler-plugin`: compiles Java source code
		- `maven-war-plugin`: packages that project as a WAR for web applications
		- `maven-surefire-plugin`: runs unit tests

- `src/main`
	- `src/main/java`: all java source code (classes, servlets, etc.). Maven compiles this code into `.class` files during the build process
	- `src/main/resource`: all non-Java resource, such as configuration files or other assets that the Java code may need. These files are automatically added to the class path during runtime
	- `src/main/webapp`: `WebContent` in the project. This is for web-related resources like HTML, JSP, CSS, JavaScript, and images. This folder is packaged into your WAR file and is where web resources are served from.
	- Follow package structure if needed, but not required. Package deceleration
		- `edu.uci.ics`
		- `src/main/java/edu/uci/ics`
		- `package edu.uci.ics`

- `mvn clean install`: clean the project, force Maven to download any missing dependencies and attempt to build the project again
- `mvn clean package`: rebuild the WAR package
- **War**: packaging `mvn package` WAR file will be generated in the target directory
- Tomcat Deployment:
	1. Deploy WAR file to `webapps/`. Tomcat will automatically unpack and deploy the application when it starts
	2. run `sudo /usr/share/tomcat10/bin/startup.sh` to start
	3. run `sudo /usr/share/tomcat10/bin/shutdown.sh` to stop

## Jakarta

- The **Jakarta Servlet API** enables Java servlets to process **HTTP requests** from clients (browsers) and return dynamic responses (like HTML, JSON).
- `HttpServletRequest` and `HttpServletResponse` provide access to the details of the request and allow you to build the response.
- **Servlets** use this API to interact with **backend data (e.g., databases)** and return processed content to the client.

## Structure

```
my-web-app/
├── pom.xml  
├── src
│   ├── test/  (Unit tests)
│   └── main  
│       ├── java  
│       │   └── com/example/  (Java classes) 
│       └── resources/  
│           └── application.properties  (Config files)
├── target  
│   ├── classes
│   ├── fablix-webapp/
│   ├── fablix-webapp.war  
└── WebContent  
   ├── index.jsp  
   └── WEB-INF  
       └── web.xml
```
