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
The Hazelcast Bundles support storage of entities in distributed maps in a client/server architecture whereby the `HazelcastBundle` only needs to reside on the client side. No extra software is required on the server side which allows easy setup, migration and management of Hazelcast clusters.

{% include image.html file="hazelcast-architecture.png" alt="Hazelcast Architecture" caption="The Hazelcast client/server architecture" %}

Starting from the bottom of the picture, data in this example is stored in a traditional database in two tables named "film" and "actor".
Using the `HazelcastBundle` data from these tables can, via the application, easily be ingested into the Hazelcast server grid. in this example, the grid consist of two nodes "Hazelcast Server Node #0" and "Hazelcast Server Node #1". Node #0 and #1 each holds approximately 50% of the data from the database tables in two different distributed maps.
The application can query and manipulate data in the Hazelcast server grid without touching the database. 

Since the database is no longer involved in querying, application speed may be greatly improved in many cases.  

## Installing the Hazelcast Bundles
There are two Hazelcast bundles: 
- `HazelcastToolBundle` that is needed by the UI Tool to generate entity classes (generation)
- `HazelcastBundle`  that is needed at runtime by the Hazelcast client application (runtime)
 
### Installing the HazelcastToolBundle
In the `pom.xml` file, the `speedment-enterprise-maven-plugin` configuration needs to be updated so that the `HazelcastToolBundle` class is added and the `hazelcast-tool` dependency is added:
 
``` xml
<plugins>
    <plugin>
        <groupId>com.speedment.enterprise</groupId>
        <artifactId>speedment-enterprise-maven-plugin</artifactId>
        <version>${speedment.version}</version>

        <configuration>
            <components>
                <!-- Add the following component to this plugin -->
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

### Installing the HazelcastBundle
In the `pom.xml` file, the following dependencies needs to be added to make the `HazelcastBundle` present on the classpath:

```xml
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
The following Java data types are supported:
- byte, Byte
- short, Short
- int, Integer
- long, Long
- float, Float
- double, Double
- BigInteger
- BigDecimal
- Enum
- boolean, Boolean
- String
- Timestamp
- Time
- Date
- BLOB
- CLOB via String mapping
For each column, there are a number of [type mapping](maven.html#adding-a-type-mapper) possibilities that can be applied using the UI Tool. 

### Null Handling
Via the UI Tool, nullable columns can be configured to use getters returning either `null` or `Optional` objects. 

## Configuration
Speedment generates a complete class that can provide a Hazelcast `ClientConfiguration` containing all serialization factories and class definitions already pre-configured.
This class is named after the project name. For example, for a project named "Sakila", then the configuration class will be named `SakilaHazelcastConfigComponent`. 
This is how an exemplary generated class looks like:
```java
public class SakilaHazelcastConfigComponent extends GeneratedSakilaHazelcastConfigComponent {}
```
As can be seen, this class just inherits all it method from another generated class. This allows the possibility to override generated methods with custom code that is retained between re-generation of code.  

``` java
@GeneratedCode("Speedment")
public class GeneratedSakilaHazelcastConfigComponent implements HazelcastConfigComponent {
    
    protected GeneratedSakilaHazelcastConfigComponent() {}
    
    @Override
    public ClientConfig get() {
        final ClientConfig clientConfig = new ClientConfig();
        addPortableFactories(clientConfig);
        addClassDefinitions(clientConfig);
        return clientConfig;
    }
    
    protected void addPortableFactories(ClientConfig clientConfig) {
        clientConfig.getSerializationConfig()
            .addPortableFactory(1321754994, new SakilaSakilaPortableFactory())
        ;
    }
    
    protected void addClassDefinitions(ClientConfig clientConfig) {
        clientConfig.getSerializationConfig()
            .addClassDefinition(new ActorClassDefinition().apply(0))
            .addClassDefinition(new AddressClassDefinition().apply(0))
            .addClassDefinition(new CategoryClassDefinition().apply(0))
            .addClassDefinition(new CityClassDefinition().apply(0))
            .addClassDefinition(new CountryClassDefinition().apply(0))
            .addClassDefinition(new CustomerClassDefinition().apply(0))
            .addClassDefinition(new FilmClassDefinition().apply(0))
            .addClassDefinition(new FilmActorClassDefinition().apply(0))
            .addClassDefinition(new FilmCategoryClassDefinition().apply(0))
            .addClassDefinition(new FilmTextClassDefinition().apply(0))
            .addClassDefinition(new InventoryClassDefinition().apply(0))
            .addClassDefinition(new LanguageClassDefinition().apply(0))
            .addClassDefinition(new PaymentClassDefinition().apply(0))
            .addClassDefinition(new RentalClassDefinition().apply(0))
            .addClassDefinition(new StaffClassDefinition().apply(0))
            .addClassDefinition(new StoreClassDefinition().apply(0))
            .addClassDefinition(new ActorInfoClassDefinition().apply(0))
            .addClassDefinition(new CustomerListClassDefinition().apply(0))
            .addClassDefinition(new FilmListClassDefinition().apply(0))
            .addClassDefinition(new NicerButSlowerFilmListClassDefinition().apply(0))
            .addClassDefinition(new SalesByFilmCategoryClassDefinition().apply(0))
            .addClassDefinition(new SalesByStoreClassDefinition().apply(0))
            .addClassDefinition(new StaffListClassDefinition().apply(0))
        ;
    }
}
``` 

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
