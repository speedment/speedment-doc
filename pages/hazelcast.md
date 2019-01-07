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
 
```xml
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
<dependencies>

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

``` java
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
As can be seen, the generated configuration class adds all the portable serialization factories and all class definitions that has been automatically generated 

## Ingesting Data
Ingesting data from a database into the Hazelcast server nodes is greatly simplified with the methods added via the Hazelcast bundles. The process involves creating a Speedment instance that is connected to the database and one Hazelcast client instance connected to the Hazelcast server cluster.
The following example shows a method that will invoke `IngestUtil::ingest` to ingest data from all tables in the the database into the Hazelcast server grid:

``` java
    public void ingestAll() {

        // Create a Speedment application connected to a SQL database
        final Speedment sqlApp = new SakilaApplicationBuilder()
            .withPassword("sakila-password")
            .build();

        // Create a Hazelcast client instance connected to a Hazelcast server grid
        final HazelcastInstance hazelcastClientInstance =
            HazelcastClient.newHazelcastClient(new SakilaHazelcastConfigComponent().get());

        // Ingest all tables from the database into the Hazelcast
        // server grid using the default IngestConfiguration:
        //
        // - Load all data (i.e. all rows) from the tables
        // - Use the default ForkJoin pool for parallel loading
        // - Perform loading outside any database transaction
        // - Do not clear the maps before loading
        CompletableFuture<Void> job = IngestUtil.ingest(hazelcastClientInstance, sqlApp);

        // Wait for the ingest job to complete
        job.join();

        // Close the Speedment SQL application
        sqlApp.close();

        // Print out att the distributed maps that now has been
        // created and populated with data
        hazelcastClientInstance.getDistributedObjects().stream()
            .forEach(System.out::println);

        // Close the Hazelcast client instance
        hazelcastClientInstance.shutdown();
    }
```
This might produce the following output showing all the `IMap` objects in which data was ingested:
``` text
IMap{name='sakila.sakila.nicer_but_slower_film_list'}
IMap{name='sakila.sakila.film'}
IMap{name='sakila.sakila.payment'}
IMap{name='sakila.sakila.film_list'}
IMap{name='sakila.sakila.sales_by_store'}
IMap{name='sakila.sakila.address'}
IMap{name='sakila.sakila.rental'}
IMap{name='sakila.sakila.staff'}
IMap{name='sakila.sakila.country'}
IMap{name='sakila.sakila.store'}
IMap{name='sakila.sakila.category'}
IMap{name='sakila.sakila.customer'}
IMap{name='sakila.sakila.staff_list'}
IMap{name='sakila.sakila.actor'}
IMap{name='sakila.sakila.inventory'}
IMap{name='sakila.sakila.film_text'}
IMap{name='sakila.sakila.customer_list'}
IMap{name='sakila.sakila.film_actor'}
IMap{name='sakila.sakila.language'}
IMap{name='sakila.sakila.film_category'}
IMap{name='sakila.sakila.actor_info'}
IMap{name='sakila.sakila.city'}
IMap{name='sakila.sakila.sales_by_film_category'}
```
The utility class `IngestUtil` contains a number of related methods that can be used to control the ingest process in more detail including:
- Selecting a custom `ExecutorService` used to ingest data
- Selecting a database transaction to use during data ingest
- Applying arbitrary `Stream` operators on the database source Stream (e.g. to limit or filter the database content)
- Clearing all data before start of data ingest
- Selecting a subset of database tables to use during ingest

See the JavaDoc for the classes `IngestUtil` and `IngestConfiguration` for a detailed description on these features. 

{% include tip.html content = "
Because the Hazelcast nodes must be able to operate independent on the Java data model, data is loaded from the database via the application to the Hazelcast nodes.
" %}

## Query Data 
Data can be queried using at least three different methods:
- Hazelcast IMap API
- Hazelcast Jet (distributed streams)
- Standard Java Streams 

### Hazelcast Map
Applications can use the Hazelcast `Map` and `IMap` interfaces directly and work with data this way. The name of a distributed map can be obtained using the `HazelcastMapUtil::mapName` method as shown hereunder:
``` java
String filmMapName = HazelcastMapUtil.mapName(FilmManager.IDENTIFIER); 
```
Read more on the Hazelcast `IMap` API [here](https://docs.hazelcast.org/docs/latest/javadoc/com/hazelcast/core/IMap.html)

### Hazelcast Jet
Read more on connecting Hazelcast Jet to Hazelcast `IMap` objects [here](https://docs.hazelcast.org/docs/jet/latest/manual/#connector-imdg)

### Streams
As for all Speedment applications, data in the Hazelcast grid can be queried using standard `java.util.stream.Stream` objects.
Here is an example where we are collecting a list of the film titles of the films with a rating of PG-13 that has a length greater than 75 minutes:
``` java
FilmManager films = hazelcastApp.getOrThrow(FilmManager.class);

List<String> list = films.stream()
    .filter(Film.RATING.equal("PG-13"))
    .filter(Film.LENGTH.greaterThan(75))
    .map(Film.TITLE)
    .sorted()
    .collect(Collectors.toList());
```
Read more about Speedment streams [here (examples)](https://speedment.github.io/speedment-doc/speedment_examples.html#top) and [here (fundamentals)](https://speedment.github.io/speedment-doc/stream_fundamentals.html#top)


### Other Languages
Because data is stored using `Portable` entity classes, data in the Hazelcast server nodes can also be queried using other languages. Read more [here](https://hazelcast.org/clients-languages/).

{% include tip.html content = "
Remember to check for `null` values explicitly in your predicates if you have Wrapper classes (e.g. Integer, Long, Double) that are nullable.
" %}
 
## Persistence
TBW

## Indexing
Upon generation, Speedment examines the database metadata and suggests indexing based on how the database is indexed. This provides a solid baseline for grid indexing.
In the following example, an index utility method was automatically generated when working with the Sakila database (the class has been shortened for brevity):
``` java
@GeneratedCode("Speedment")
public final class GeneratedSakilaIndexUtil {
    
    private GeneratedSakilaIndexUtil() {}
    
    public static void setupIndex(final HazelcastInstance h) {
        
        // Indexes for table actor
        // Index PRIMARY (unique) using column actor_id
        h.getMap("sakila.sakila.actor").addIndex("actor_id", true);
        // Index idx_actor_last_name  using column last_name
        h.getMap("sakila.sakila.actor").addIndex("last_name", true);
        
        // ... Rows hidden for brevity
        
        // Indexes for table film
        // Index PRIMARY (unique) using column film_id
        h.getMap("sakila.sakila.film").addIndex("film_id", true);
        // Index idx_film_rating  using column rating
        h.getMap("sakila.sakila.film").addIndex("rating", true);
        // Index idx_fk_language_id  using column language_id
        h.getMap("sakila.sakila.film").addIndex("language_id", true);
        // Index idx_fk_original_language_id  using column original_language_id
        h.getMap("sakila.sakila.film").addIndex("original_language_id", true);
        // Index idx_title  using column title
        h.getMap("sakila.sakila.film").addIndex("title", true);
        
        // ... Rows hidden for brevity
    }
}
```  
As can be seen, creating a `HazelcastInstance` and then just invoking the method `GeneratedSakilaIndexUtil::setupIndex` will create the same indexes in the Hazelcast grid that were present in the database.

## Performance
Thanks to the `Portable` entity classes, Hazelcast server nodes can benefit from indexing and partial deserialization when testing predicates. This greatly speedup querying in many cases. 

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="hazelcast.html" %}
