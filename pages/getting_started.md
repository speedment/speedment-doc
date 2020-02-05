---
permalink: getting_started.html
sidebar: mydoc_sidebar
title: Getting Started
keywords: Speedment, Start, Quick Start
toc: false
Tags: Getting Started, Start, Setup
previous: stream_fundamentals.html
next: tutorials.html
---

{% include prev_next.html %}


## Speedment Requirements 
Before proceeding with the installation, please make sure that you have the following installed: 

* Apache Maven version 3.5.0 or later 
* Java version 8.0.40 or later (e.g. Java 11)

## Installation with Maven
Speedment is installed using [Apache Maven](https://maven.apache.org/) by including the Speedment dependencies in your pom.xml-file. You need to setup both the `speedment-maven-plugin` (for code generation) and the `speedment-runtime` (used by the application at runtime).

If starting a project from scratch, the Initializer can help you automatically generate a custom project pom-file. There are two different versions of the Initializer depending on which version of Speedment you intend to use: 
* [Speedment Open Source Initializer](https://speedment.com/oss-download) is used to generate a pom-file for a Speedment OSS project.
* [Speedment Initializer](https://speedment.com/download) is used to generate a pom-file for any Speedment Stream/HyperStream project, including trials and free-licenses. 

If you prefer to manually configure your pom.xml, see the [Maven guide](maven.html#top) for more detailed information about configuring the correct dependencies. 

## Starting the Tool
Speedment uses JSON configuration files to generate Java code from your database. The JSON files will be created using the Speedment Tool. You can choose to start the Tool from your IDE* or run it from the command line.

#### With the Command Line
Locate the directory of your pom.xml-file and run the following:

`mvn speedment:tool`

#### With Your IDE
Launch the project as a Maven project in your IDE. A number of Maven goals associated with Speedment will be available. Use `speedment:tool` to connect to your database and generate a Java representation of the domain model.

{% include image.html file="mvn-goals.png" alt="Speedment Maven Goals" caption="Speedment Maven Goals as shown in IntelliJ" %}

{% include note.html content = "
If you wish to use an existing JSON file, use `speedment:generate` instead.
" %}

The following process is divided in three steps:
  1. Select a preferred license type (only applies to Enterprise projects)
  1. Connect to the database
  2. Configure the project and generate a Java Domain Model from the database

### Step 1. Select a license type (For Enterprise projects only)
When the tool launches for the first time you need to license your software. The graphical interface will leave you with three options: 

* Use an existing license key for Stream or HyperStream
* Request a 30-day HyperStream trial 
* Start a Free license which will provide access to all features of HyperStream for databases under 500 MB 

### Step 2. Connect to the database
Next, simply fill out the database credentials and hit Connect. 

{% include note.html content = "
For security reasons, Speedment __never stores__ the database password in generated classes or configuration files.
" %}

{% include image.html file="tool_connect_screenshot.png" url="https://www.speedment.com/" alt="The Speedment Tool - Connecting to the Database" caption="The Speedment Tool - Connecting to the Database" %}

### Step 3. Configure the project and generate code
Speedment now analyses the underlying data sources’ metadata and automatically creates code which directly reflects the structure (i.e. the “domain model”) of the data sources. Once finished, the database structure is visualized as a tree in the appearing window. To generate the object-oriented Java representation, press "Generate".

{% include image.html file="tool-screenshot.png" url="https://www.speedment.com/" alt="The Speedment Tool - Configuration and Code Generation" caption="The Speedment Tool - Configuration and Code Generation" %}

## Hello World
Once the files are generated, you are ready to write your first Java Stream query. 

Here is a an application that will count the number of films that is rated "PG-13" from an example database named "Sakila".
``` java
     // Configure and start Speedment
     Speedment app = new SakilaApplicationBuilder()
        .withBundle(MySqlBundle.class)
        .withPassword("sakila-password")
        .build();

    // Get the FilmManager (that handles the 'film' table)
    FilmManager films = app.getOrThrow(FilmManager.class);

    // Here is the actual logic
    long count = films.stream()
        .filter(Film.RATING.equal("PG-13"))
        .count();

    // Print out the count
    System.out.format("There are %d films(s) with a PG-13 rating %n", count);    
```

This will produce the following output:
``` text
There are 223 films(s) with a PG-13 rating 
```

and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT COUNT(*)
FROM (
    SELECT
       `film_id`,`title`,`description`,`release_year`,
       `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
       `length`,`replacement_cost`,`rating`,`special_features`,
       `last_update` 
    FROM `sakila`.`film` 
    WHERE (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin)
) AS A, values:[PG-13]
```

## Speedment POM Example

Here is an example of a pom.xml file setup for Speedment OSS and MySQL that has been used for the examples in this manual.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.speedment</groupId>
    <artifactId>documentation-examples</artifactId>
    <version>3.0.21</version>
    <packaging>jar</packaging>
    
    <name>Speedment - Documentation - Examples</name>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <speedment.version>3.2.6</speedment.version>
    </properties>    
    
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
                
                <dependencies>
                     <dependency>
                         <groupId>mysql</groupId>
                         <artifactId>mysql-connector-java</artifactId>
                         <version>8.0.18</version>
                         <scope>runtime</scope>
                     </dependency>
                 </dependencies>
                
            </plugin> 
        </plugins>
    </build>
    
    <dependencies>
        <dependency>
            <groupId>com.speedment</groupId>
            <artifactId>runtime</artifactId>
            <version>${speedment.version}</version>
            <type>pom</type>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.18</version>
            <scope>runtime</scope>
        </dependency>
    </dependencies>
    
</project>
```

{% include tip.html content = "
Always use the [Speedment Open Source Initializer](https://speedment.com/oss-download) to get the most recent pom template for your project.
" %}

## Speedment Enterprise POM Example

Here is an example of a pom.xml file setup for [Speedment Enterprise](datastore#top), in-memory acceleration (DataStore) and Oracle.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  
  <modelVersion>4.0.0</modelVersion>
  
  <groupId>com.example</groupId>
  <artifactId>demo</artifactId>
  <version>1.0.0-SNAPSHOT</version>
  <packaging>jar</packaging>
  
  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
    <speedment.enterprise.version>3.2.7</speedment.enterprise.version>
  </properties>
  
  <dependencies>
    <dependency>
      <groupId>com.speedment.enterprise</groupId>
      <artifactId>runtime</artifactId>
      <version>${speedment.enterprise.version}</version>
      <type>pom</type>
    </dependency>
    <dependency>
      <groupId>com.speedment.enterprise</groupId>
      <artifactId>virtualcolumn-runtime</artifactId>
      <version>${speedment.enterprise.version}</version>
    </dependency>
    <dependency>
      <groupId>com.speedment.enterprise</groupId>
      <artifactId>datastore-runtime</artifactId>
      <version>${speedment.enterprise.version}</version>
    </dependency>
    <dependency>
      <groupId>com.speedment.enterprise.connectors</groupId>
      <artifactId>oracle-connector</artifactId>
      <version>${speedment.enterprise.version}</version>
    </dependency>
    <dependency>
      <groupId>com.oracle</groupId>
      <artifactId>ojdbc8</artifactId>
      <version>19.3.0.0</version>
      <scope>runtime</scope>
    </dependency>
  </dependencies>
  
  <build>
    <plugins>
      <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        
        <configuration>
          <components>
            <component>com.speedment.enterprise.virtualcolumn.tool.VirtualColumnToolBundle</component>
            <component>com.speedment.enterprise.datastore.tool.DataStoreToolBundle</component>
            <component>com.speedment.enterprise.connectors.oracle.OracleBundle</component>
          </components>
          
          <parameters>
            <parameter>
              <name>licenseKey</name>
              <value>(YOUR LICENSE CODE)</value>
            </parameter>
          </parameters>
        </configuration>
        
        <dependencies>
          <dependency>
            <groupId>com.oracle</groupId>
            <artifactId>ojdbc8</artifactId>
            <version>19.3.0.0</version>
            <scope>runtime</scope>
          </dependency>
        </dependencies>
      </plugin>
    </plugins>
  </build>
  
  <repositories>
    <repository>
      <id>speedment-enterprise</id>
      <name>Speedment Enterprise Repositories</name>
      <url>http://repo.speedment.com/nexus/content/repositories/releases/</url>
    </repository>
  </repositories>
  
  <pluginRepositories>
    <pluginRepository>
      <id>speedment-enterprise</id>
      <name>Speedment Enterprise Repositories</name>
      <url>http://repo.speedment.com/nexus/content/repositories/releases/</url>
    </pluginRepository>
  </pluginRepositories>
</project> 
```
{% include tip.html content = "
Always use the [Initializer](https://speedment.com/initializer) to get the most recent pom-template for your project.
"%}

{% include prev_next.html %}

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
