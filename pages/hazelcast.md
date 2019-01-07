---
permalink: hazelcast.html
sidebar: mydoc_sidebar
title: Hazelcast
keywords: Hazelcast
toc: false
Tags: Hazelcast
previous: hazelcast.html
next: hazelcast.html
---

{% include prev_next.html %}

## What is Hazelcast?
Hazelcast is an open-source In Memory Data Grid (IMDG) written i Java. In a Hazelcast grid, data is distributed amongst the nodes that participate in the cluster, allowing horizontal scaling of data storage and computation of data.

## The Hazelcast Bundles

{% include warning.html content = "
In the current release, Hazelcast support is experimental and it is not advised to use it in production systems. 
" %}

**Requires Speedment Enterprise 3.1.10 or later.**

Using the Hazelcast Bundles, Speedment can greatly simplify working with Hazelcast and can:
- Automatically generate a Java domain model from an existing database
- Automatically generate serialization support for Hazelcast
- Automatically generate configuration handling for Hazelcast
- Automatically generate Hazelcast indexing based on the underlying database indexing
- Provide automatic ingest of data from an existing database to the Hazelcast grid
- Provide access to the Hazelcast grid for additional languages such as
  -  C++
  -  node.js
  -  C#
  -  Go
  -  Python
  -  and many other languages
     

## Architecture
The Hazelcast Bundles support storage of entities in distributed maps in a client/server architecture where the Bundles reside on the client side. No extra software is required on the server side which allows easy setup, migration and management of Hazelcast clusters.

{% include image.html file="hazelcast-architecture.png" alt="Hazelcast Architecture" caption="The Hazelcast client/server architecture" %}

As

## Installing the Hazelcast Bundles
In the `pom.xml` file, the following dependencies needs to be added:

``` xml
</dependencies>

    <!-- other dependencies -->

    <dependency>
        <groupId>com.speedment.enterprise.hazelcast</groupId>
        <artifactId>hazelcast-runtime</artifactId>
        <version>${speedment.version}</version>
    </dependency>

    <dependency>
        <groupId>com.hazelcast</groupId>
        <artifactId>hazelcast-client</artifactId>
        <version>3.11</version>
    </dependency>
</dependencies>
```
 
In the `pom.xml` file, the `speedment-enterprise-maven-plugin` configuration needs to be updated so that the `HazelcastToolBundle` class is added and the `hazelcast-tool` dependency is added:
 
``` xml
<plugins>
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.version}</version>

        <configuration>
            <components>
                <!-- Add the following component to the plugin -->
                <component>com.speedment.enterprise.hazelcast.tool.HazelcastToolBundle</component>
            </components>
            <appName>${project.artifactId}</appName>
            <packageName>${project.groupId}</packageName>
        </configuration>

        <dependencies>
            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <version>${mysql.version}</version>
                <scope>runtime</scope>
            </dependency>
            
            <!-- The dependency below needs to be added -->            
            <dependency>
                <groupId>com.speedment.enterprise.hazelcast</groupId>
                <artifactId>hazelcast-tool</artifactId>
                <version>${speedment.version}</version>
            </dependency>

        </dependencies>
    </plugin>
</plugins>
``` 

In the application builder, the `HazelcastBundle` needs to be added to allow injection of the Hazelcast runtime components as shown in this example:

```
final Speedment hazelcastApp = new SakilaApplicationBuilder()
    .withPassword("sakila-password")
    .withBundle(HazelcastBundle.class)
    .withComponent(SakilaHazelcastConfigComponent.class)
    .build();
```
Note: The `SakilaHazelcastConfigComponent` is a generated configuration class and its meaning is explained [later](#configuration) in this chapter.


## Entities
Hazelcast compatible Data Entities are automatically generated from the database metadata. The generated entities implements Hazelcasts [`Portable`](https://docs.hazelcast.org/docs/latest/manual/html-single/index.html#implementing-portable-serialization) interface.  

### Serialization

### Primary Keys

### Supported Data Types


## Configuration


## Ingesting Data
TBW

{% include warning.html content = "
If  
" %}

## Query Data 

### Streams
TBW

### Hazelcast Map


### Other Languages
Data in the Hazelcast grid can also be queried using other languages. 


## Persistence
TBW

## Indexing
TBW

## Performance
TBW

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="hazelcast.html" %}
