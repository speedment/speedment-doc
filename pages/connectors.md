---
permalink: connectors.html
sidebar: mydoc_sidebar
title: Connectors
keywords: Connector, Connectors, Oracle, SQL Server, DB2, AS400
toc: false
Tags: Connector, Connectors, Oracle, SQL Server, DB2, AS400
previous: hazelcast.html
next: author.html
---

{% include prev_next.html %}

## Open Source Connectors
Support for open-source database types can easily be obtained by adding an appropriate connector. Adding a connector is straight forward:

* Add a connector dependency in your pom file
* If run under the Java Module System (JPMS), add `require com.speedment.runtime.connector.xxxx;` to the applications `module-info.java` file.
* Mention the connector's `Bundle` in your `ApplicationBuilder` using `.withBundle()`

The Speedment plugin automatically installs all open-source bundles.

## MySQL
Speedment supports MySQL out-of-the-box. Please refer to the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your MySQL project.

Starting from version 3.0.11, the MySQL `FieldPredicatView` can be configured to use custom collations by modifying the following configuration parameters:

| Name                                             | Default value     |
| :----------------------------------------------- | :---------------- |
| db.mysql.collationName                           | utf8_general_ci   |
| db.mysql.binaryCollationName                     | utf8_bin          |

These values can be set to custom values using the application builder as depicted below:
```
     ApplicationBuilder app = new SakilaApplicationBuilder()
        .withPassword("sakila-password")
        .withParam("db.mysql.collationName", "utf8mb4_general_ci")
        .withParam("db.mysql.binaryCollationName", "utf8mb4_bin")
        .withBundle(MySqlBundle.class)
        .build();
```
The selected collations will be used for all MySQL tables.

Speedment officially supports the following MySQL JDBC version(s):

| Database | groupId   | artifactId           | version |
| :------- | :-------- | :------------------- | :------ |
| MySQL    | mysql     | mysql-connector-java | 8.0.18  |

### Java Module System (JPMS)
MySQL applications running under the Java Module System (JPMS) needs to `require com.speedment.runtime.connector.mysql;`

### Bundle Installation
Add the following line to you `ApplicationBuilder` to install the connector specific classes `.withBundle(MySqlBundle.class)`

## PostgreSQL
Speedment supports PostgreSQL out-of-the-box. Please refer to the Speedment [Initializer](https://www.speedment.com/initializer/) to setup your PostgreSQL project.

Speedment officially supports the following PostgreSQL JDBC version(s):

| Database | groupId        | artifactId           | version |
| :------- | :------------- | :------------------- | :------ |
| PosgreSQL| org.postgresql | postgresql           | 42.2.8  |

### Java Module System (JPMS)
PostgreSQL applications running under the Java Module System (JPMS) needs to `require com.speedment.runtime.connector.postgres;`

### Bundle Installation
Add the following line to you `ApplicationBuilder` to install the connector specific classes `.withBundle(PostgresBundle.class)`

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
        .withParam("db.mysql.binaryCollationName", "utf8mb4_bin")
        .withBundle(MySqlBundle.class)
        .build();
```
The selected collations will be used for all MariaDB tables.

{% include important.html content= "
Some Linux distributions (notable Debian/Ubuntu) requires the utf8mb4 collations to be used as per instructions above.
" %}

Speedment officially supports the following MariaDB JDBC version(s):

| Database | groupId          | artifactId           | version |
| :------- | :--------------- | :------------------- | :------ |
| MariaDB  | org.mariadb.jdbc | mariadb-java-client  |  2.4.4  |

{% include important.html content= "
Pre 2.0.1 MariaDB JDBC drivers contain significant bugs. Users are highly encouraged to upgrade to 2.x.x drivers.
" %}

### Java Module System (JPMS)
MariaDB applications running under the Java Module System (JPMS) needs to `require com.speedment.runtime.connector.mariadb;`

### Bundle Installation
Add the following line to you `ApplicationBuilder` to install the connector specific classes `.withBundle(MariaDbBundle.class)`

## SQLite
Starting from Speedment version 3.1.10, SQLite is supported. SQLite is a lightweight database that can either be backed by a single file or run in-memory. Speedment supports both these, but the in-memory option is only usable once the `speedment.json`-file has been generated.

Speedment officially supports the following SQLite version(s):

| Database | groupId          | artifactId           | version |
| :------- | :--------------- | :------------------- | :------ |
| SQLite   | org.xerial       | sqlite-jdbc          | 3.28.0  |

### SQLite Metadata
When Speedment parses the metadata given by the JDBC-connector, a lot of information is given that is not necessary enforced by the database. This involves (but is not limited to) the type and size of certain columns. Speedment will do its best to use such information to decide which Java types to use when representing the entity in generated code. This can, however, mean that the generated entity does not perfectly match the bounds enforced in the database. When the table definition in the metadata and the actual bounds enforced by the database conflict, Speedment will prioritize the former.

For an example, if a column is specified as `INTEGER PRIMARY KEY` in the table definition, Speedment will interpret that as an `int` in java. SQLite will however use 64-bits to store the value since that column will be considered an alias for the `rowid`. You could therefore argue that Speedment should interpret the column as a `long`, but it does not since it prioritizes the SQL-definition above the internal implementation used by the database engine.

### Working with File-Based Databases
When SQLite is backed by a file, it is important to make sure that the file is not accessed by multiple threads at the same time. If you see the following error, this is likely the issue:

```
org.sqlite.SQLiteException: [SQLITE_LOCKED]  A table in the database is locked (database table is locked)
    at org.sqlite.core.DB.newSQLException(DB.java:909)
    at org.sqlite.core.DB.newSQLException(DB.java:921)
    at org.sqlite.core.DB.execute(DB.java:822)
    at org.sqlite.core.CoreStatement.exec(CoreStatement.java:75)
    at org.sqlite.jdbc3.JDBC3Statement.execute(JDBC3Statement.java:61)
    ...
```

To fix this, you need to do one of the following:
* Wrap your streams [in transactions](crud.html#transactions) using the `TransactionComponent`
* Use the `SingletonConnectionPoolComponent` as [described here](advanced_features.html#connection-pooling)

The two steps above can also be used together.

### Auto-Incrementing Columns
A table in SQLite always has a column named `rowid` that is used as the primary key. If a column in the table definition is set as `INTEGER PRIMARY KEY`, that column will be considered an alias for the `rowid`. This can be a bit confusing, and requires Speedment to make some decisions on how to interpret the database metadata. Speedment will create the `rowid` column and show it in entities only as long as there is no `INTEGER PRIMARY KEY` column present in the metadata. If a different primary key have been specified (for an example a `CHAR PRIMARY KEY`), that one will instead be considered a regular column with a `UNIQUE INDEX`.

There are two types of auto-increments in SQLite. A column specified as `AUTOINCREMENT` will work slightly different than the increment that is always present in the `rowid` column. For the intents and purposes in Speedment, these are equivalent and both are therefore considered auto-incrementing columns by Speedment.

### Default values
If the table definition has columns with default values specified, these has to be excluded when persisting and updating entities using Speedment. This can be done by defining a `FieldSet` object as explained [here](crud.html#selecting-fields-to-update).

### Java Module System (JPMS)
SQLite applications running under the Java Module System (JPMS) needs to `require com.speedment.runtime.connector.sqlite;`

### Bundle Installation
Add the following line to you `ApplicationBuilder` to install the connector specific classes `.withBundle(SqliteBundle.class)`

## Enterprise Connectors
Support for enterprise database types can easily be obtained by adding an appropriate connector. Adding a connector is straight forward:

* Add a connector dependency in your pom file
* Mention the connector's `Bundle` in the Speedment Enterprise plugin (in the `pom.xml` file)
* If run under the Java Module System (JPMS), add `require com.speedment.enterprise.connectors.oracle.xxxx;` to the applications `module-info.java` file.
* Mention the connector's `Bundle` in your `ApplicationBuilder` using `.withBundle()`

{% include important.html content= "
In order to use the connectors in this chapter, you need a commercial Speedment license or a trial license key. Download a free trial license using the Speedment [Initializer](https://www.speedment.com/initializer/).
" %}

## Oracle
This chapter shows how to add support for Oracle in Speedment. 

### Privileges
In order for the Speedment tool to read the schema metadata you need the following privileges:

| Privilege          | Create Example                           |
| :----------------- | :--------------------------------------- |
| CREATE SESSION     | GRANT CREATE SESSION TO SPEEDMENT_USER;
| SELECT             | GRANT SELECT ON t TO SPEEDMENT_USER; (*)
| ANALYZE            | GRANT ANALYZE ANY TO SPEEDMENT_USER;
| ANALYZE DICTIONARY | GRANT ANALYZE DICTIONARY TO SPEEDMENT_USER;

(*) Repeat for each and every table t being used.

When the application runs, only the CREATE SESSION and the SELECT privileges are needed (plus UPDATE/DELETE if those operations are being used within the Speedment application).

### Oracle POM
Always use the [Initializer](https://www.speedment.com/initializer/) to get a complete POM file template as the POM snipes hereunder just show portions of what is needed.

Here is how you configure the Speedment Enterprise plugin for use with an Oracle database:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <dependencies>
            <dependency>
                <dependency>
                    <groupId>com.oracle.ojdbc</groupId>
                    <artifactId>ojdbc8</artifactId>
                    <version>19.3.0.0</version>
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
You also have to depend on the Oracle connector and JDBC connector as a Runtime dependency for your application:
``` xml
    <dependencies>
        <dependency>
            <groupId>com.oracle.ojdbc</groupId>
            <artifactId>ojdbc8</artifactId>
            <version>19.3.0.0</version>
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

### Java Module System (JPMS)
Oracle applications running under the Java Module System (JPMS) needs to `require com.speedment.enterprise.connectors.oracle;`

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

### Dbms Application Info
The Oracle specific feature `DBMS_APPLICATION_INFO` is supported by Speedment. This feature allows client and module names to be visible in a number of locations such as Enterprise Manager performance graphs, ASH and AWR reports.
Here is an example of how it might look like in the Enterprise Manager:

{% include image.html file="01-top-activity-modules.jpg" url="https://www.speedment.com/" alt="Enterprise Manager: app info" caption="Enterprise Manager: app info" %}

Here is an example how to activate the feature:

``` java
SpeedmentApplicationBuilder builder = new SpeedmentApplicationBuilder()
       .withPassword("speedmentpw")
       .withBundle(OracleBundle.class)
       .withComponent(OracleConnectionDecorator.class)
       .withParam(OracleConnectionDecorator.CLIENT_INFO, "test-client")
       .withParam(OracleConnectionDecorator.MODULE_NAME, "test-module");
```
This will mark every connection to the database with these parameters. 

Read more about `DBMS_APPLICATION_INFO` [here](https://oracle-base.com/articles/8i/dbms_application_info)

## SQL Server
This chapter shows how to add support for Microsoft SQL Server in Speedment.

### SQL Server POM
Always use the [Initializer](https://www.speedment.com/initializer/) to get a complete POM file template as the POM snipes hereunder just show portions of what is needed.

This is how you configure the Speedment Enterprise plugin for use with a SQL Server database:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <dependencies>
            <dependency>
                <groupId>com.microsoft.sqlserver</groupId>
                <artifactId>mssql-jdbc</artifactId>
                <version>7.4.1.jre8</version>
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
            <version>7.4.1.jre8</version>
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

### Java Module System (JPMS)
Sql Server applications running under the Java Module System (JPMS) needs to `require com.speedment.enterprise.connectors.sqlserver;`

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

This is how you configure the Speedment Enterprise plugin for a DB2 database:
``` xml
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.enterprise.version}</version>
        <dependencies>
            <dependency>
                <groupId>com.ibm.db2</groupId>
                <artifactId>jcc</artifactId>
                <version>11.5.0.0</version>
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
            <artifactId>jcc</artifactId>
            <version>11.5.0.0</version>
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

### Java Module System (JPMS)
DB2 applications running under the Java Module System (JPMS) needs to `require com.speedment.enterprise.connectors.tbtwo;`

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

This is how you configure the Speedment Enterprise plugin for use with an AS400 database:
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
            <version>9.8</version>
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

### Java Module System (JPMS)
AS400 applications running under the Java Module System (JPMS) needs to `require com.speedment.enterprise.connectors.tbtwo;`

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

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
