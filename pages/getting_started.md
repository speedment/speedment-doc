---
permalink: getting_started.html
sidebar: mydoc_sidebar
title: Getting Started
keywords: Speedment, Start, Quick Start
toc: false
Tags: Getting Started, Start, Setup
previous: introduction.html
next: overview.html
---

{% include prev_next.html %}

## Installation
Speedment is installed in your pom.xml file. We recommend that you use the on-line [Speedment Initializer](https://www.speedment.com/initializer/) to setup your pom file. You need to setup both the `speedment-maven-plugin` (for code generation) and the `speedment-runtime` (used by the application at runtime).

Here is an example of a pom.xml file setup for Speedment and MySQL that has been used for the examples in this manual.
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.speedment</groupId>
    <artifactId>documentation-examples</artifactId>
    <version>3.0.9</version>
    <packaging>jar</packaging>
    <name>Speedment - Documentation - Examples</name>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <speedment.version>3.0.9</speedment.version>
        <db.groupId>mysql</db.groupId>
        <db.artifactId>mysql-connector-java</db.artifactId>
        <db.version>5.1.42</db.version>
    </properties>    
    
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
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
            <version>5.1.42</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>com.speedment</groupId>
            <artifactId>runtime</artifactId>
            <version>${speedment.version}</version>
            <type>pom</type>
        </dependency>
        <dependency>
            <groupId>${db.groupId}</groupId>
            <artifactId>${db.artifactId}</artifactId>
            <version>${db.version}</version>
        </dependency>
    </dependencies>
    
</project>
```
{% include tip.html content = "
Always use the Initializer to get the most recent pom template for your project.
" %}


### Speedment
Speedment Open Source (or just Speedment for short) contains stream handling, code generation, runtime and connectors to MySQL, MariaDB and PostgreSQL.

### Speedment Enterprise
Speedment Enterprise contains additional features that are useful in enterprise environments, for example an in-memory DataStore accelerator and support for commercial databases like Oracle, Sql Server, DB2 and AS400.
In order to activate Speedment Enterprise, you need a license that can either be purchased or downloaded for free (trial) from [www.speedment.com](https::/www.speedment.com). Again, we encourage you to use the on-line [Speedment Initializer}(https://www.speedment.com/initializer/) to setup your pom file.

Here is an example of a pom.xml file setup for Speedment Enterprise, in-memory acceleration (DataStore) and Oracle.
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
    <speedment.enterprise.version>1.1.6</speedment.enterprise.version>
  </properties>
  
  <dependencies>
    <dependency>
      <groupId>com.speedment.enterprise</groupId>
      <artifactId>virtualcolumn-runtime</artifactId>
      <version>${speedment.enterprise.version}</version>
    </dependency>
    <dependency>
      <groupId>com.oracle</groupId>
      <artifactId>ojdbc7</artifactId>
      <version>12.1.0.1.0</version>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>com.speedment.enterprise.connectors</groupId>
      <artifactId>oracle-connector</artifactId>
      <version>${speedment.enterprise.version}</version>
    </dependency>
    <dependency>
      <groupId>com.speedment.enterprise</groupId>
      <artifactId>datastore-runtime</artifactId>
      <version>${speedment.enterprise.version}</version>
    </dependency>
    <dependency>
      <groupId>com.speedment.enterprise</groupId>
      <artifactId>runtime</artifactId>
      <version>${speedment.enterprise.version}</version>
      <type>pom</type>
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
            <component>com.speedment.enterprise.connectors.oracle.OracleBundle</component>
            <component>com.speedment.enterprise.datastore.tool.DataStoreToolBundle</component>
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
            <artifactId>ojdbc7</artifactId>
            <version>12.1.0.1.0</version>
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
The Initializer also supports Speedment Enterprise. Always use the Initializer to get the most recent pom template for your project.
" %}


## Starting the Tool
The code generation and configuration tool is started using the Maven target `speedment::tool`. Once run, you can elect to use the tool to graphically maintain your project or you can use any text editor and modify the `speedment.json` file that holds the configuration model for your project.

The process is divided in two steps:
  1 Connecting to the Database
  2 Configuration of the Project and Code Generation

### Step 1, Connecting to the Database
{% include image.html file="tool_connect_screenshot.png" url="https://www.speedment.com/" alt="The Speedment Tool - Connecting to the Database" caption="The Speedment Tool - Connecting to the Database" %}

### Step 2, Configuration of the Project and Code Generation
{% include image.html file="tool_screenshot.png" url="https://www.speedment.com/" alt="The Speedment Tool - Configuration and Code Generation" caption="The Speedment Tool - Configuration and Code Generation" %}

## Hello World
Once your project has been setup properly and you have run the Maven target `speedment::tool`, you can start writing Speedment applications.

Here is a small example that will count the number of films that is rated "PG-13" from an example database named "Sakila".
``` java
     // Configure and start Speedment
     ApplicationBuilder app = new SakilaApplicationBuilder()
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
SELECT
    COUNT(*)
FROM (
    SELECT
       `film_id`,`title`,`description`,`release_year`,
       `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
       `length`,`replacement_cost`,`rating`,`special_features`,
       `last_update` 
    FROM
       `sakila`.`film` 
    WHERE 
       (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin)
) AS A, values:[PG-13]
```

{% include prev_next.html %}


## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="getting-started.html" %}
