---
permalink: connectors.html
sidebar: mydoc_sidebar
title: Connectors
keywords: Connector, Connectors, Oracle, SQL Server, DB2, AS400
toc: false
Tags: Connector, Connectors, Oracle, SQL Server, DB2, AS400
previous: enterprise_plugins.html
next: author.html
---

{% include prev_next.html %}

## Open Source Connectors

## MySQL
Speedment supports MySQL out-of-the-box. Please refer to the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your MySQL project.

Starting from version 3.0.11, the MySQL `FieldPredicatView` can be configured to use custom collations by modifying the following configuration parameters:

| Name                         | Default value     | A |
| :--------------------------- | :---------------- | - |
| db.mysql.collationName       | utf8_general_ci   | . |
| db.mysql.binaryCollationName | utf8_bin          | . |

These values can be set to custom values using the application builder as depicted below:
```
     ApplicationBuilder app = new SakilaApplicationBuilder()
        .withPassword("sakila-password")
        .withParam("db.mysql.collationName", "utf8mb4_general_ci")
        .withParam("db.mysql.binaryCollationName", "utf8mb4_bin");
        .build();
```
The selected collations will be used for all MySQL tables.

## PostgreSQL
Speedment supports PostgreSQL out-of-the-box. Please refer to the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your PostgreSQL project.

## MariaDB
Speedment supports MariaDB out-of-the-box. Please refer to the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your MariaDB project.

Starting from version 3.0.11, the MariaDB `FieldPredicatView` can be configured to use custom collations by modifying the following configuration parameters:

| Name                         | Default value     |
| :--------------------------- | :---------------- |
| db.mysql.collationName       | utf8_general_ci   |
| db.mysql.binaryCollationName | utf8_bin          |

These values can be set to custom values using the application builder as depicted below:
```
     ApplicationBuilder app = new SakilaApplicationBuilder()
        .withPassword("sakila-password")
        .withParam("db.mysql.collationName", "utf8mb4_general_ci")
        .withParam("db.mysql.binaryCollationName", "utf8mb4_bin");
        .build();
```
The selected collations will be used for all MariaDB tables.


## Enterprise Connectors
Support for additional enterprise database types can easily be obtained by adding an appropriate connector. Adding a connector is straight forward:

* Add a connector dependency in your pom file
* Mention the connector's `Bundle` in the speedment enterprise plugin
* Mention the connector's `Bundle` in your `ApplicationBuilder `

{% include important.html content= "
In order to use the connectors in this chapter, you need a commercial Speedment license or a trial license key. Download a free trial license using the Speedment [Initializer](https://www.speedment.com/initializer/).
" %}

## Oracle
This chapter shows how to add support for Oracle in Speedment. Unfortunately, Oracle does not provide a JDBC driver that you can download via a dependency in your pom file. Instead, it has to be installed manually before you can use the Oracle connector. [Here](http://www.oracle.com/technetwork/topics/jdbc-faq-090281.html) is Oracle's official JDBC FAQ that provides information on how to install the Oracle JDBC driver.

### Oracle POM
Always use the [Initializer](https://www.speedment.com/initializer/) to get a complete POM file template as the POM snipes hereunder just show portions of what is needed.

Here is how you configure the speedment enterprise plugin:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <dependencies>
            <dependency>
                <dependency>
                    <groupId>com.oracle</groupId>
                    <artifactId>ojdbc7</artifactId>
                    <version>12.1.0.1.0</version>
                    <scope>runtime</scope>
                </dependency>
            </dependency>
        </dependencies> 
        <configuration>
            <components>
                 <component>com.speedment.enterprise.connectors.oracle.OracleBundle</component>
            </components>
            <parameters>
                <parameter>
                    <name>licenseKey</name>
                    <value>(YOUR LICENSE CODE)</value>
                </parameter>
            </parameters>
        </configuration>
    </plugin>
```
You also have to depend on the Oracle connector and JDBC connector as a runtime dependency for your application:
``` xml
    <dependencies>
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
            <artifactId>runtime</artifactId>
            <version>${speedment.enterprise.version}</version>
            <type>pom</type>
        </dependency>
    </dependencies>
```



### Oracle Application
When you build the application, the `OracleBundle` needs to be added to the runtime like this:
``` java
    YourApplication app = new YourApplicationBuilder()
        .withPassword("your-dbms-password")
        .withParam("licenseKey", "(YOUR LICENSE CODE)")
        .withBundle(OracleBundle.class)
        .build();
```
{% include tip.html content= "
The Oracle JDBC driver has many features (e.g. redundancy, pooling and other optimizations) that can be controlled using the connection URL. To activate these functions, use the method `ApplicationBuilder::withConnectionUrl` to specify a custom connection URL.
" %}

{% include note.html content= "
The JDBC driver version above is the one officially supported by Speedment. Other JDBC versions may also work.
" %}

## SQL Server
This chapter shows how to add support for Microsoft SQL Server in Speedment.

### SQL Server POM
Always use the [Initializer](https://www.speedment.com/initializer/) to get a complete POM file template as the POM snipes hereunder just show portions of what is needed.

Here is how you configure the speedment enterprise plugin:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <dependencies>
            <dependency>
                <groupId>com.microsoft.sqlserver</groupId>
                <artifactId>mssql-jdbc</artifactId>
                <version>6.1.0.jre8</version>
                <scope>runtime</scope>
            </dependency>
        </dependencies>
        <configuration>
            <components>
                <component>com.speedment.enterprise.connectors.sqlserver.SqlServerBundle</component>
            </components>
            <parameters>
                <parameter>
                    <name>licenseKey</name>
                    <value>(YOUR LICENSE CODE)</value>
                </parameter>
            </parameters>
        </configuration>
    </plugin>
```
You also have to depend on the Sql Server connector and JDBC connector as a runtime dependency for your application:
``` xml
    <dependencies>
        <dependency>
            <groupId>com.microsoft.sqlserver</groupId>
            <artifactId>mssql-jdbc</artifactId>
            <version>6.1.0.jre8</version>
            <scope>runtime</scope>
        </dependency>
            <dependency>
            <groupId>com.speedment.enterprise.connectors</groupId>
            <artifactId>sqlserver-connector</artifactId>
            <version>${speedment.enterprise.version}</version>
        </dependency>
        <dependency>
            <groupId>com.speedment.enterprise</groupId>
            <artifactId>runtime</artifactId>
            <version>${speedment.enterprise.version}</version>
            <type>pom</type>
        </dependency>
    </dependencies>
```



### SQL Server Application
When you build the application, the `SqlServerBundle` needs to be added to the runtime like this:
``` java
    YourApplication app = new YourApplicationBuilder()
        .withPassword("your-dbms-password")
        .withParam("licenseKey", "(YOUR LICENSE CODE)")
        .withBundle(SqlServerBundle.class)
        .build();
```
{% include tip.html content= "
The SQL Server JDBC driver has many features (e.g. redundancy, pooling and other optimizations) that can be controlled using the connection URL. To activate these functions, use the method `ApplicationBuilder::withConnectionUrl` to specify a custom connection URL.
" %}

{% include note.html content= "
The JDBC driver version above is the one officially supported by Speedment. Other JDBC versions may also work.
" %}

## DB2
This chapter shows how to add support for IBM DB2 in Speedment. Unfortunately, IBM does not provide a JDBC driver that you can download via a dependency in your pom file. Instead, it has to be installed manually before you can use the DB2 connector. [Here](http://www-01.ibm.com/support/docview.wss?uid=swg21363866) is IBM's official JDBC download page.

### DB2 POM
Always use the [Initializer](https://www.speedment.com/initializer/) to get a complete POM file template as the POM snipes hereunder just show portions of what is needed.

Here is how you configure the speedment enterprise plugin:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <dependencies>
            <dependency>
                <groupId>com.ibm.db2</groupId>
                <artifactId>db2jcc4</artifactId>
                <version>4.21.29</version>
                <scope>runtime</scope>
            </dependency>
        </dependencies>
        <configuration>
            <components>
                <component>com.speedment.enterprise.connectors.db2.Db2Bundle</component>
            </components>
            <parameters>
                <parameter>
                    <name>licenseKey</name>
                    <value>(YOUR LICENSE CODE)</value>
                </parameter>
            </parameters>
        </configuration>
    </plugin>
```
You also have to depend on the DB2 connector and JDBC connector as a runtime dependency for your application:
``` xml
    <dependencies>
        <dependency>
            <groupId>com.ibm.db2</groupId>
            <artifactId>db2jcc4</artifactId>
            <version>4.21.29</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            groupId>com.speedment.enterprise.connectors</groupId>
            <artifactId>db2-connector</artifactId>
            <version>${speedment.enterprise.version}</version>
        </dependency>
        <dependency>
            <groupId>com.speedment.enterprise</groupId>
            <artifactId>runtime</artifactId>
            <version>${speedment.enterprise.version}</version>
            <type>pom</type>
        </dependency>
    </dependencies>
```



### DB2 Application
When you build the application, the `Db2Bundle` needs to be added to the runtime like this:
``` java
    YourApplication app = new YourApplicationBuilder()
        .withPassword("your-dbms-password")
        .withParam("licenseKey", "(YOUR LICENSE CODE)")
        .withBundle(Db2Bundle.class)
        .build();
```
{% include tip.html content= "
The DB2 JDBC driver has many features (e.g. redundancy, pooling and other optimizations) that can be controlled using the connection URL. To activate these functions, use the method `ApplicationBuilder::withConnectionUrl` to specify a custom connection URL.
" %}

{% include note.html content= "
The JDBC driver version above is the one officially supported by Speedment. Other JDBC versions may also work.
" %}

## AS400
This chapter shows how to add support for IBM AS400 in Speedment.

### AS400 POM
Always use the [Initializer](https://www.speedment.com/initializer/) to get a complete POM file template as the POM snipes hereunder just show portions of what is needed.

Here is how you configure the speedment enterprise plugin:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <configuration>
            <components>
                <component>com.speedment.enterprise.connectors.db2.Db2Bundle</component>
            </components>
            <parameters>
                <parameter>
                    <name>licenseKey</name>
                    <value>(YOUR LICENSE CODE)</value>
                </parameter>
            </parameters>
        </configuration>
    </plugin>
```
You also have to depend on the AS400 connector and JDBC connector as a runtime dependency for your application:
``` xml
    <dependencies>
        <dependency>
            <groupId>net.sf.jt400</groupId>
            <artifactId>jt400-full</artifactId>
            <version>6.0</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            groupId>com.speedment.enterprise.connectors</groupId>
            <artifactId>db2-connector</artifactId>
            <version>${speedment.enterprise.version}</version>
        </dependency>
        <dependency>
            <groupId>com.speedment.enterprise</groupId>
            <artifactId>runtime</artifactId>
            <version>${speedment.enterprise.version}</version>
            <type>pom</type>
        </dependency>
    </dependencies>
```


### AS400 Application
When you build the application, the `Db2Bundle` needs to be added to the runtime like this:
``` java
    YourApplication app = new YourApplicationBuilder()
        .withPassword("your-dbms-password")
        .withParam("licenseKey", "(YOUR LICENSE CODE)")
        .withBundle(Db2Bundle.class)
        .build();
```
The `Db2Bundle` supports both DB2 and AS400.

{% include tip.html content= "
The AS400 JDBC driver has some features that can be controlled using the connection URL. To activate these functions, use the method `ApplicationBuilder::withConnectionUrl` to specify a custom connection URL.
" %}

{% include note.html content= "
The JDBC driver version above is the one officially supported by Speedment. Other JDBC versions may also work.
" %}


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="connectors.html" %}
