---
permalink: connectors.html
sidebar: mydoc_sidebar
title: Connectors
keywords: Connector, Connectors, Oracle, SQL Server, DB2, AS400
toc: false
Tags: Connector, Connectors, Oracle, SQL Server, DB2, AS400
previous: connectors.html
next: connectors.html
---

{% include prev_next.html %}

## Connectors
Support for additional database types can easily be obtained by adding an appropriate connector. Adding a connector is straight forward:

* Add a connector dependency in your pom file
* Mention the connector's `Bundle` in the speedment enterprise plugin
* Mention the connector's `Bundle` in your `ApplicationBuilder `

{% include important.html content= "
In order to use the connectors in this chapter you need a commercial Speedment license or a trial license key. Download a free trial license using the Speedment [Initializer](https://www.speedment.com/initializer/).
" %}

## Oracle
Unfortunately, Oracle does not provide a JDBC driver that you can add as a dependency via your pom file. Instead, it has to be installed manually before you can use the Oracle connector. [Here](http://www.oracle.com/technetwork/topics/jdbc-faq-090281.html) is Oracle's official JDBC FAQ that provides information on how to install the Oracle JDBC driver.

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
You also have to depend on the Oracle connector as a runtime dependency for your application:
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
        .withUsername("your-dbms-username")
        .withPassword("your-dbms-password")
        .withParam("licenseKey",
            "(YOUR LICENSE CODE)"
        )
        .withBundle(OracleBundle.class)
        .build();
```
{% include tip.html content= "
The Oracle JDBC driver has many features (e.g. redundancy, pooling and other optimizations) that can be controlled using the connection URL. To activate these functions, use the method `ApplicationBuilder::withConnectionUrl` to specify a custom connection URL.
" %}

The JDBC driver version above is the one officially supported by Speedment. Other JDBC versions may also work.

## SQL Server
TBW

## DB2
TBW

## AS400
TBW

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="connectors.html" %}