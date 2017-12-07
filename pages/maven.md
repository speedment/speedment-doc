---
permalink: maven.html
sidebar: mydoc_sidebar
title: Speedment Maven Plugin
keywords: Maven, Plugin, Tool, Generate, Reload, Clear
toc: false
Tags: Installation, Maven
previous: application_configuration.html
next: predicate.html
---

{% include prev_next.html %}

## Installation

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

Set the property `${speedment.version}` to the latest Speedment version released (currently {{ site.data.speedment.version }}). A list of all versions of the Speedment Maven Plugin can be found [here](https://search.maven.org/#search%7Cgav%7C1%7Cg%3A%22com.speedment%22%20AND%20a%3A%22speedment-maven-plugin%22).


The Speedment Maven Plugin automatically depends on relevant version of open-source JDBC database drivers. These dependencies can be overridden should we want to use another version. In the example below, we override the MySql JDBC version with a newer one:

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
                        <version>6.0.6</version>
                    </dependency>
                </dependencies> 
            </plugin>
        </plugins>
    </build>
```


## Installation Example

Here is an example of a complete POM file that is setup for a Speedment application that runs against a MySQL database:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.company</groupId>
    <artifactId>test-speedment</artifactId>
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

{% include tip.html content="
Always use the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your pom file.
" %}


## Maven Targets
The Speedment Mavan Plugin has four Maven targets that can be used to simplify and/or automate our build process. These Maven targets can be used to read the meta data (e.g. schemas, tables and columns) from the database. They are also used to generate code that we can use in our applications. Therefore, before we can use Speedment, we must run at least one of the Maven targets.

These are the four Maven targets in the Speedment Maven Plugin:

| Target                                 | Purpose                                                             | Tool |
| :------------------------------------- | :------------------------------------------------------------------ | :--- |
| [tool](maven.html#tool)                | Starts the graphical tool that connects to an existing database     | Yes  |
| [generate](maven.html#generate)        | Generates code                                                      | No   |
| [reload](maven.html#reload)            | Reloads meta data and merges changes with the existing config file  | No   |
| [clear](maven.html#clear)              | Removes all generated code                                          | No   |
| [clearTables](maven.html#clear-tables) | Removes all tables, columns, indexes etc from the config file       | No   |


### Tool
By using the `speedment:tool` target we can start the Speedment Graphical Tool that can be used to connect to the database and generate code. All settings are saved in a JSON configuration file. Click [here](tool.html) to read more about the graphical tool.

### Generate
By using the `speedment:generate` target we can generate code directly from the JSON configuration file without connecting to the database and without starting the Tool. 

### Reload
By using the `speedment:reload` target we can reload the metadata from the database and merges any changes with the existing JSON configuration file without starting the Tool.

### Clear
By using the `speedment:clear` target we can remove all the generated files from our project without starting the Tool. Files that are manually changed are protected by a cryptographic hash code and will not be removed.

### Clear Tables
By using the `speedment:clearTables` target we can remove all tables, columns, indexes and foreign keys from the configuration file. This is useful if you want clear you config file and then run Reload to obtain an exact copy of the database, regardless of the configuration file's previous state.

## Configuration
The Speedment Maven Plugin can be configured in many ways. A special debug mode can be set and new functionality can be added dynamically by adding {{site.data.javadoc.TypeMapper}}s, Components and {{site.data.javadoc.InjectBundle}}s.

### Enable Debug Mode
If we want to follow more closely what is going on in one or several of the Speedment Maven Plugin Maven  targets, we can enable *Debug Mode*. In this mode, information about what classes are being initiated are shown in the standard logger together with other data. This makes it easier to trouble-shoot problems and can provide valuable information in many cases.

Enable debug mode by adding a `<debug>true</debug>` element in the POM as described hereunder:

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
                <configuration>
                    <debug>true</debug>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

{% include tip.html content="
Debug mode can be used to track what TypeMappers and Components exist and how they interact with each other.
" %}

### Adding a Type Mapper
{{site.data.javadoc.TypeMapper}}s are used to map a database type to a Java type and vice versa. For example, a `Timestamp` field can  be mapped to the Java type `long` to save memory and reduce the number of objects that are created during execution. {{site.data.javadoc.TypeMapper}}s can be added to the Maven Targets dynamically and will then be available like any built-in {{site.data.javadoc.TypeMapper}}.

This example show a fictive German {{site.data.javadoc.TypeMapper}} that converts a `String` that is either "Ja" (Yes) or "Nein" (No) and maps that to a `boolean` that is either `true` ("Ja") or `false` ("Nein"):

``` xml
    <build>
        <plugin>
            <groupId>com.speedment</groupId>
            <artifactId>speedment-maven-plugin</artifactId>
            <version>${speedment.version}</version>
            <configuration>
                <typeMappers>
                    <typeMapper>
                        <databaseType>java.lang.String</databaseType>
                        <implementation>de.entwicklung.typemappers.JaNeinStringToBooleanTypeMapper</implementation>
                    </typeMapper>
                </typeMappers>
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
            <artifactId>typemappers</artifactId>
            <version>1.0.0</version>
        </dependency>
    </dependencies>
```

The {{site.data.javadoc.TypeMapper}} above also converts information in the other direction. For example, if a mapped property is `false` and is persisted in the database, the value in the database will read "Nein".

{% include tip.html content="
`TypeMapper`s that are added to the plugins must also be on the class path once our application run. If the `TypeMapper` comes from an external project, remember to depend on the artifact that contains the `TypeMapper` in your POM file as shown in the last part of the example above.
" %}

(Placeholder -> Link to text about creating your own TypeMapper)

### Adding a Component
A component can add or change Speedment functionality. Most functions within Speedment are handled by Components. Components are easily added to the plugins like this:

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
In the example above, someone has written a Component that will plug in its own code generation views so that the Java code generated by Speedment will be formatted in a custom way compared to the default code. Perhaps that person wanted to be able to control the order of methods in a class so that they are introduced in alphabetic order rather than in insertion order.

Read more in [this tutorial](https://github.com/speedment/speedment/wiki/Tutorial:-Writing-your-own-extensions) on how to create custom components.

### Adding a Bundle
An {{site.data.javadoc.InjectBundle}} simply represents a collection of Components that can be installed in one sweep using just one reference. Typically, custom database support are installed using an {{site.data.javadoc.InjectBundle}} because several Components are needed to support a new database type. In the example below a fictive H2 open-source database driver is added to the plugins:

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

{% include note.html content="
 For some components and bundles, the order in which they are added are significant. Some component have a specific function (called InjectKey) and only the last component added will be used.
" %}


### Setting Component Parameters
Some Componens can be configured directly using the POM file. This is done using a `<parameter>` tag as shown below:
``` xml
<plugin>
    <groupId>com.speedment</groupId>
    <artifactId>speedment-maven-plugin</artifactId>
    <version>${speedment.version}</version>
    <configuration>
        <parameters>
            <parameter>
                <name>someParameterName</name>
                <value>someParameterValue</value>
            </parameter>
        </parameters>
    </configuration>
</plugin>
```
Check the documentation for the individual Components to see what parameters can be set.


### Setting Other Plugin POM Parameters 
A number of Plugin parameters can be set in the POM file as shown in this table:

| Name           | Type     | Purpose                                            | Example     |
| :------------- | :------- | :------------------------------------------------- | :---------- |
| debug          | boolean  | Enables debug mode for the plugin                  | true        |
| dbmsHost       | String   | Sets the dbms host name                            | 192.168.0.4 |         
| dbmsPort       | int      | Sets the dbms port                                 | 3306        |
| dbmsUsername   | String   | Sets the dbms username                             | john.smith  |
| dbmsPassword   | String   | Sets the dbms password                             | W8kAk2H!Eh  | 
| configFile     | String   | Sets the location of the configuration file        | src/main/json/my_config.json |

Here is an example where we set a number of database parameters for the plugins.
``` xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
                <configuration>
                    <dbmsHost>92.168.0.4</dbmsHost>
                    <dbmsPort>3306</dbmsPort>
                    <dbmsUsername>john.smith</dbmsUsername>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

## Automated Maven Builds
Automated builds can save time and enables continues integration on our projects. We can instruct Maven to generate code for us automatically on each build by attaching our plugin to certain goals like this:

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
Now, all Speedment code will be generated automatically for us upon re-build.

If we want to perform an automatic reload (and merge potential changes in the database structure with our JSON configuration file) and then re-generate code we can do that like this:
``` xml
    <plugin>
        <groupId>com.speedment</groupId>
        <artifactId>speedment-maven-plugin</artifactId>
        <version>${speedment.version}</version>
        <dependencies>
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <version>5.1.40</version>
            </dependency>
        </dependencies>
        <configuration>
            <dbmsPassword>mySecretPassword</dbmsPassword>
        </configuration>
        <executions>
            <execution>
                <id>Merge database schema updates with the json config file</id>
                <phase>generate-sources</phase>
                <goals>
                    <goal>reload</goal>
                </goals>
            </execution>
            <execution>
                <id>Generate code</id>
                <phase>generate-sources</phase>
                <goals>
                    <goal>generate</goal>
                </goals>
            </execution>
        </executions>
    </plugin>
```
This way, each time we rebuilt, the code will always reflect the current database structure.

### Using target/generated-sources
If you have an automated build, you might not want the generated code to sit in the same folder as all your other code. A common convention for these situations are to generate the code into the `target/generated-sources/`-folder. Most IDEs scan this folder automatically so you will still have access to the in-IDE documentation, but you have a clear separation between generated and hand-written code.

To tell Speedment to generate all code into the `target/generated-sources/`-folder, open the Speedment tool and change the `Package Location` like this. Note that you might have to uncheck `Auto` when you switch from a default option to a custom one.

{% include image.html file="use_generated_sources.png" url="https://www.speedment.com/" alt="Generate Code into the generated-sources folder in the Speedment tool" caption="Change 'Package Location' to use 'target/generated-sources/'" %}

## Speedment Enterprise
Speedment Enterprise is configured the same way except that we have to use different group and artifact ids. Here is an example of a Speedment Enterprise plugin definition:

``` xml
<plugin>
    <groupId>com.speedment.enterprise</groupId>
    <artifactId>speedment-enterprise-maven-plugin</artifactId>
    <version>${speedment.enterprise.version}</version>
    <configuration>
        <parameters>
            <parameter>
                <name>licenseKey</name>
                <value>${speedment.licenseKey}</value>
            </parameter>
        </parameters>
    </configuration>
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
{speedment.enterprise.version} is different from {speedment.version}. Always use the recommended {speedment.enterprise.version}. Also note that a `${speedment.licenseKey}` is nescessary to use the plugin.
" %}

{% include tip.html content="
Always use the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your pom file and to request a free trial license.
" %}

The Speedment Enterprise Maven Plugin works the same way as the Speedment Maven Plugin but the plugins come with more Components and Bundles pre-installed.

# License Keys
Speedment Enterprise requires a valid License Key to be used. The key must be available for **both** the Speedment tool and the runtime for you to be able to build and run the application.

There are two ways to enter a license key. The easiest way is to specify it as a string to both the tool (as a Maven tag) and in the `ApplicationBuilder` in your application. Here is an example of that:

**pom.xml**
```xml
<plugin>
    <groupId>com.speedment.enterprise</groupId>
    <artifactId>speedment-enterprise-maven-plugin</artifactId>
    <version>${speedment.enterprise.version}</version>
    <configuration>
        <parameters>
            <parameter>
                <name>licenseKey</name>
                <value>${speedment.licenseKey}</value> <!-- License Key must be specified! -->
            </parameter>
        </parameters>
    </configuration>
</plugin>
```

**Main.java**
```java
public static void main(String... param) {
  DemoApplication app = new DemoApplicationBuilder()
    .withUsername("your-dbms-username")
    .withPassword("your-dbms-password")
    .withParam("licenseKey", "(YOUR LICENSE CODE)")
    .withBundle(VirtualColumnBundle.class)
    .withBundle(DataStoreBundle.class)
    .build();

  // You are ready to go!
  
  app.stop();
}
```

If you don't want to have your license in the code, a better way to supply it using a license file. It is a basic text-file with your license key(s) entered on separate lines. Lines that start with a `#`-character are considered comments and will not be parsed. You can enter multiple licenses into the file. Speedment will consider all of them to determine what products you have access to and for how long.

The location and name of the file can be supplied like this:

**pom.xml**
```xml
<plugin>
    <groupId>com.speedment.enterprise</groupId>
    <artifactId>speedment-enterprise-maven-plugin</artifactId>
    <version>${speedment.enterprise.version}</version>
    <configuration>
        <parameters>
            <parameter>
                <name>licensePath</name>
                <value>/opt/speedment/speedment.license</value> <!-- You need to create this file -->
            </parameter>
        </parameters>
    </configuration>
</plugin>
```

**Main.java**
```java
public static void main(String... param) {
  DemoApplication app = new DemoApplicationBuilder()
    .withParam("licensePath", "/opt/speedment/speedment.license") // Can be absolute or relative
    .build();
}
```

Another way is to create a file called `settings.properties` in the working directory of the application and enter the `licenseKey` and/or the `licensePath` like this:

**settings.properties**
```properties
licensePath = /opt/speedment/speedment.license
licenseKey = YOUR LICENSE KEY!!!
```

The default value for `licensePath` is `[User Home]/.speedment/.licenses`. If you create that folder and file and enter your license key into it, it will be loaded automatically.

## Command Line Parameters
When running the maven targets, we can set a number of command line parameters to configure the plugins. The following command line parameters are available:

| Name           | Type     | Purpose                                            | Example     |
| :------------- | :------- | :------------------------------------------------- | :---------- |
| debug          | boolean  | Enables debug mode for the plugin                  | true        |
| dbms.host      | String   | Sets the dbms host name                            | 192.168.0.4 |         
| dbms.port      | int      | Sets the dbms port                                 | 3306        |
| dbms.username  | String   | Sets the dbms username                             | john.smith  |
| dbms.password  | String   | Sets the dbms password                             | W8kAk2H!Eh  | 
| configLocation | String   | Sets the location of the configuration file        | src/main/json/my_config.json |
| components     | String[] | Adds one or several components or bundles to the plugin | com.company.MyComponent |

## Command Line Examples
Below, a number of command line examples are shown:

Start the tool with default parameters (from the POM)
``` shell
  mvn speedment:tool
```

Start the tool in debug mode
``` shell
  mvn speedment:tool -Ddebug=true
```

Generate code directly using the default config file (JSON):
``` shell
  mvn speedment:generate
```

Generate code directly using a custom configuration file (JSON):
``` shell
  mvn speedment:generate -DconfigLocation=src/main/json/my_config.json
```

Merge changes from the database with the current configuration file without asking for password:
``` shell
  mvn speedment:reload -DdbmsPassword=W8kAk2H!Eh
```

{% include tip.html content="
Make sure that coma-separated items do not contain any space characters after a coma, or your maven build will fail.
" %}


## The Configuration File
Speedment stores the configuration of the database metadata in a special JSON file that, by default, is located in the file `src/main/json/speedment.json`

The Tool's purpose is basically to maintain this file and to generate code. We can do manual changes to the file and the changes will immediately affect the plugins and how code is generate, once the plugin are started.

## Specifying a Configuration File
See [Command Line Parameters]({{page.permalink}}#command-line-parameters) for information on how to specify a custom configuration file.

## Resetting the Configuration File
If the configuration file is removed, the Tool will be reset and we can start all over with a clean sheet.

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="maven.html" %}
