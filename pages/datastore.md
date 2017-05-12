---
permalink: datastore.html
sidebar: mydoc_sidebar
title: Data Store
keywords: Data Store, In, Memory, Acceleration
toc: false
Tags: Data Store
previous: datastore.html
next: datastore.html
---

{% include prev_next.html %}

## What is DataStore?

The DataStore module is a Speedment Enterprise feature that pulls in database content from a database to an in-JVM memory data store. Because data is stored off heap, the Java garbage collector is unaffected by data that is held by the DataStore module.

The DataStore modu;e can hold terabytes of data and will significantly reduce stream latency. The Stream API remains exactly the same as for SQL Streams.


## Enabling DataStore
In order to use DataStore you need a commercial Speedment license or a trial license key. Download a free trial license using the Speedment [Initializer](https://www.speedment.com/initializer/).
The DataStore module needs to be referenced both in your pom.xml file and in you application.

### POM File
Use the [Initializer](https://www.speedment.com/initializer/) to get a POM file template. To use DataStore, add it as a dependency to the speedment-enterprise-maven-plugin and mention it as a component:
``` xml
            <plugin>
                <groupId>com.speedment.enterprise</groupId>
                <artifactId>speedment-enterprise-maven-plugin</artifactId>
                <version>${speedment.enterprise.version}</version>
                <dependencies>
                    <dependency>
                        <groupId>com.speedment.enterprise</groupId>
                        <artifactId>datastore-tool</artifactId>
                        <version>${speedment.enterprise.version}</version>
                    </dependency>
                </dependencies> 
                <configuration>
                    <components>
                        <component>com.speedment.enterprise.datastore.tool.DataStoreToolBundle</component>
                    </components>
                </configuration>
            </plugin>
```
You also have to depend on DataStore as a runtime dependency to your application:
``` xml
    <dependencies>
        <dependency>
            <groupId>com.speedment.enterprise</groupId>
            <artifactId>datastore-runtime</artifactId>
            <version>${speedment.enterprise.version}</version>
        </dependency>
    </dependencies>
```



### Application
When you build the application, the DataStoreBundle needs to be added to the runtime like this:
``` java
        SakilaApplicationBuilder builder = new SakilaApplicationBuilder()
            .withLogging(LogType.STREAM)
            .withPassword(password)
            .withBundel(DataStoreBundle.class);
```
## Using DataStore

### Load from the Database
Before DataStore can be used, it has to load all database content into the JVM. This is how it is done:
``` java
        // Load the in-JVM-memory content into the DataStore from the database
        app.get(DataStoreComponent.class)
            .ifPresent(DataStoreComponent::load);
```
After the DataStore module has been added and loaded, all stream queries will be made towards RAM instead of the remote database. No other change in the application is needed.

### Synchronizing with the Database
If you want to update the DataStore to the latest state of the underlying database, do like this:
``` java
        // Refresh the in-JVM-memory content from the database
        app.get(DataStoreComponent.class)
            .ifPresent(DataStoreComponent::reload);
```
This will load a new version of the database in the background and then completed, new streams will use the new data. Old ongoing streams will continue to use the old version of the DataStore content. Once all old streams are completed, the old version of the DataStore content will be released.

### Obtaining Statistics
TBW


## Performance
The DataStore module will sort each table and each column upon load/re-load. This means that you can benefit from low latency regardless
Stream latency will be orders of magnitudes better. TBW

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="datastore.html" %}