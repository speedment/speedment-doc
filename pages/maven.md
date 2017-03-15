---
permalink: maven.html
sidebar: mydoc_sidebar
title: Speedment Maven Plugin
keywords: Maven, Plugin, Tool, Generate, Reload, Clear
toc: false
Tags: Installation
---

## Maven Targets

The Speedment Mavan Plugin has four Maven targets that can be used to simplify and/or automate our build process. These Maven targets 
can be used to read the meta data (e.g. schemas, tables and columns) from the database. They are also used to generate code that we can use in 
our applications. Therefore, before we can use Speedment, we must run at least one of the Maven targets.

### Installation

To install the Speedment Maven Plugin, we just add it as a plugin in our pom.xml file as described hereunder:

``` xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
            </plugin>
        </plugins>
    </build>
```

Once the file has been saved, the new Maven targets are immediately available to our project.


Set the property ${speedment.version} to the latest Speedment version released (currently {{ site.data.speedment.version }}). A list 
of all versions of the Speedment Maven Plugin can be found 
[here](https://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.speedment%22%20AND%20a%3A%22speedment-maven-plugin%22).


The Speedment Maven Plugin automatically depends on relevant version of open-source JDBC database drivers. These dependencies can be overridden 
should we want to use another version. In the example below, we override the MySql JDBC version with an older one:

``` xml
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
                        <version>5.1.38</version>
                    </dependency>
                </dependencies> 
            </plugin>
        </plugins>
    </build>
```


### Installation Example

Here is an example of a complete POM file that is setup for a Speedment application that runs against a MySQL database:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.comapny</groupId>
    <artifactId>test_speedment</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <speedment.version>{{ site.data.speedment.version }}</speedment.version>
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
            <version>5.1.40</version>
        </dependency>
    </dependencies>
</project>
```


## Maven Targets
There are four Maven targets in the Speedment Maven Plugin:

| Target   | Purpose                                                         | Tool |
| :------- | :-------------------------------------------------------------- | :--- |
| tool     | Starts the graphical tool that connects to an existing database | Yes  |
| generate | Generates code                                                  | No   |
| reload   | Reloads meta data and merges changes with the existing config file  | No   |
| clear    | Removes all generated code                                      | No   |


### Tool
By using the `speedment:tool` target we can start the Speedment Graphical Tool that can be used to connect to
 the database and generate code. All settings are saved in a JSON configuration file. Click [here] () to read 
more about the graphical tool.

### Generate
By using the `speedment:generate` target we can generate code directly from the JSON configuration file 
without connecting to the database and without starting the Tool. 

### Reload
By using the `speedment:reload` target we can reload the metadata from the database and merges any changes 
with the existing JSON configuration file without starting the Tool.

### Clear
By using the `speedment:clear` target we cab remove all the generated files from our project without starting 
the Tool. Files that are manually changed are protected by a cryptographic hash code and will not be removed.


## Configuration

The Speedment Maven Plugin can be configured in many ways. A special debug mode can be set and new
 functionality can be added dynamically by adding {{site.data.javadoc.TypeMapper}}s,
 Components and {{site.data.javadoc.InjectBundle}}s.

### Enable Debug Mode
If we want to follow more closely what is going on in the Speedment Maven Plugin, we can enable *Debug Mode*. In this mode, information about 
what classes are being initiated are shown in the standard logger together with other data. This makes it easier to trouble shoot 
problems and can provide valuable information in many cases.

Enable debug mode by adding a `<configuration><debug>true</debug></configuration>` element in the POM as described here:

``` xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
            </plugin>
            <configuration>
                <debug>true</debug>
            <configuration>
        </plugins>
    </build>
```

{% include tip.html content="
Once Debug Mode is enabled, much more information will be printed out on the console when the plugin runs.
" %}


### Adding a Type Mapper
{{site.data.javadoc.TypeMapper}}s are used to map a database type to a Java type. For example, a `Timestamp` field can
 be mapped to the Java type `long` to save memory and reduce the number of objects that are created during execution.
{{site.data.javadoc.TypeMapper}}s can be added to the Maven Targets dynamically and will then be available like
 any built-in {{site.data.javadoc.TypeMapper}}.

``` xml
    <build>
        <plugin>
            <groupId>com.speedment</groupId>
            <artifactId>speedment-maven-plugin</artifactId>
            <version>${speedment.version}</version>
            <dependencies>
                <dependency>
                    <groupId>de.entwicklung</groupId>
                    <artifactId>typemapers</artifactId>
                    <version>1.0.0</version>
                </dependency>
            </dependencies> 
            <configuration>
                <components>
                    <component>de.entwicklung.typemapper.JaNeinStringToBooleanTypeMapper</component>
                </components>
            </configuration>
        </plugin>
    <build>
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
            <version>5.1.40</version>
        </dependency>
        <dependency>
            <groupId>de.entwicklung</groupId>
            <artifactId>typemapers</artifactId>
            <version>1.0.0</version>
        </dependency>
    </dependencies>
```

This example show a fictive German {{site.data.javadoc.TypeMapper}} that converts a `String` that is either 
"Ja" (Yes) or "Nein" (No) and maps that to a `boolean` that is either `true` ("Ja") or `false` ("Nein"). 

{% include tip.html content=
"`TypeMapper`s that are added to the plugins must also be on the class path once our application run.
 Remember to depend on the artifact that contains the `TypeMapper` in your POM file as shown in the last
 part of the example above."
 %}

### Adding a Component
A component can add or change functionality of Speedment. Most functions within Speedment are handled by Components.
Components are easily added to the plugins like this:

``` xml
<plugin>
    <groupId>com.speedment</groupId>
    <artifactId>speedment-maven-plugin</artifactId>
    <version>${speedment.version}</version>
    <dependencies>
        <dependency>
            <groupId>com.company</groupId>
            <artifactId>component</artifactId>
            <version>1.0.0</version>
            </dependency>
    </dependencies> 
    <configuration>
        <components>
            <component>com.company.component.MyCodeFormattingComponent</component>
        </components>
    </configuration>
</plugin>
```
In the example above, someone has written a Component that will plug in 
its own code generation views so that the Java code generated by Speedment will be formatted in
a custom way compared to the default code.


### Adding a Bundle
An {{site.data.javadoc.InjectBundle}} simply represents a collection of Components that can 
be installed in one sweep with just one reference. Typically, custom database support are
installed using an {{site.data.javadoc.InjectBundle}} because several Components
need to be installed to support a new database type.
In the example below a fictive H2 open-source database driver is added to the plugins:

``` xml
<plugin>
    <groupId>com.speedment</groupId>
    <artifactId>speedment-maven-plugin</artifactId>
    <version>${speedment.version}</version>
    <!-- Add Oracle to the list of dependencies -->       
    <dependencies>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>1.4.194</version>
            <scope>runtime</scope>
        </dependency>
    </dependencies>
    <!-- Make sure the H2 Bundle is loaded when the maven plugin is started -->
    <configuration>
        <components>
            <component>com.speedment.connector.h2.H2Bundle</component>
        </components>
    </configuration>
</plugin>
```


## Speedment Enterprise
Speedment Enterprise is configured the same way except that we have to use different group and artifact ids.
Here is an example of a Speedment Enterprise plugin definition:

``` xml
<plugin>
    <groupId>com.speedment.enterprise</groupId>
    <artifactId>speedment-enterprise-maven-plugin</artifactId>
    <version>${speedment.enterprise.version}</version>
    <executions>
        <execution>
            <id>Generate code for Oracle</id>
            <goals>
                <goal>generate</goal>
            </goals>
        </execution>
    </executions>        
</plugin>
```
{% include note.html content="
{speedment.enterprise.version} is different from {speedment.version}. Always use the recommended version
of {speedment.enterprise.version}
" %}

The Speedment Enterprise Maven Plugin works the same way as the Speedment Maven Plugin but
the plugins come with more Components and Bundles pre-installed.


## Automated Maven Builds
We can instruct Maven to generate code for us automatically on each build by attaching our
plugin to certain goals like this:

``` xml
<plugin>
    <groupId>com.speedment</groupId>
    <artifactId>speedment-maven-plugin</artifactId>
    <version>${speedment.version}</version>
    <executions>
        <execution>
            <id>Generate code automatically</id>
            <goals>
                <goal>generate</goal>
            </goals>
        </execution>
    </executions>        
</plugin>
```
Now, all code will be generated automatically for us upon re-build.



## Command Line Parameters
When running the maven targets, we can set a number of command line parameters to
configure the plugins. The following command line parameters are available:

| Name           | Type     | Purpose                                            | Example     |
| :------------- | :------- | :------------------------------------------------- | :---------- |
| debug          | boolean  | Enables debug mode for the plugin                  | true        |
| dbms.host      | String   | Sets the dbms host name                            | 192.168.0.4 |         
| dbms.port      | int      | Sets the dbms port                                 | 3306        |
| dbms.username  | String   | Sets the dbms username                             | john.smith  |
| dbms.password  | String   | Sets the dbms password                             | W8kAk2H!Eh  | 
| configLocation | String   | Sets the location of the configuration file        | src/main/json/my_config.json |
| components     | String[] | Adds one or several Components to the plugin       | com.company.MyComponent |
| typeMappers    | String[] | Adds one or several {{site.data.javadoc.TypeMapper}}s to the plugin      | com.so.MyTypeMapper, com.so.MyOtherTypeMapper |


## Command Line Examples
Below, a number of command line examples are shown:

Start the tool with default parameters (from the POM):
`mvn speedment tool`

Start the tool in debug mode:
`mvn speedment tool -Ddebug=true`

Generate code directly using the default config file (JSON)
`mvh speedment generate`

Generate code directly using a custom configuration file (JSON)
`mvh speedment generate -DconfigLocation=src/main/json/my_config.json`



## The Configuration File
Speedment stores the configuration of the database metadata in a special JSON file that, by default, is 
located in the file src/main/json/speedment.json

The Tool's purpose is basically to edit this file. We can do manual changes to the file and 
the changes will immediately affect the plugins and how the generate code once the plugins are
restarted.

## Specifying a Configuration File
See [Command Line Parameters]{maven.html#command_line_parameters) for information on how to specify a
custom configuration file.

## Resetting the Configuration File
If the configuration file is removed, the Tool will be reset and we can start all over with a clean sheet.
