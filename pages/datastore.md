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

The DataStore module is a Speedment Enterprise feature that pulls in database content from a database to an in-JVM memory data store. Data can then be used in analytics applications. Because data is stored off heap, the Java garbage collector is unaffected by data that is held by the DataStore module.

The DataStore module can hold terabytes of data and will significantly reduce stream latency. The Stream API remains exactly the same as for SQL Streams.


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
This will load a new version of the database in the background and when completed, new streams will use the new data. Old ongoing streams will continue to use the old version of the DataStore content. Once all old streams are completed, the old version of the DataStore content will be released.


### Loading/Reloading with a Particular ExecutorService
By default, DataStore will load and structure data from the database using the common `ForkJoinPool`. Sometimes loading can take minutes and then it might be desirable to perform loading using a custom executor with perhaps a limited number of threads so that the application can continue to serve requests while loading in the background.
You can provide any executor to the `load()` and `reload()` methods like this:
``` java
    ExecutorService myExecutorService = Executors.newFixedThreadPool(3);
    DataStoreComponent dsc = app.getOrThrow(DataStoreComponent.class);
    dsc.load(myExecutorService);
    ...
    // Later on
    dsc.reload(myExecutorService);
```

### Obtaining Statistics
You can obtain statistics on how tables, columns and memory segments are used by invoking the DataStoreComponent::getStatistics method. Here is an example of how to print out DataStore statistics.
``` java
    app.get(DataStoreComponent.class)
        .map(DataStoreComponent::getStatistics)
        .map(StatisticsUtil::prettyPrint)
        .ifPresent(s -> s.forEachOrdered(System.out::println));
```

This will produce an output that starts like this:

|   Table  |  Column    | Off_Heap [B]| Rows | Nulls | Cardinality | Type  |         Class              | Distinct  |
| :------- | :--------- | ----------: | ---: | ----: | :---------- | :---- | :------------------------- | :-------- |
|   actor  |    -       |        6307 |  200 |     - |          -  | Table | SingleSegmentEntityStore   |      -    |
|   actor  | actor_id   |         400 |    - |     0 |          -  | Column| IndexedIntFieldCache       | true      |     
|   actor  | first_name |         400 |    - |     0 |          -  | Column| IndexedStringFieldCache    | false     |
|   actor  | last_name  |         400 |    - |     0 |          -  | Column| IndexedStringFieldCache    | false     |
|   actor  | last_update|         400 |    - |     0 |          -  | Column| IndexedComparableFieldCache| false     |
| address  |       -    |       66286 |  603 |     - |          -  | Table | SingleSegmentEntityStore   |      -    |
| address  | address    |        2412 |    - |     0 |          -  | Column| IndexedStringFieldCache    | false     |
| address  | address2   |        2404 |    - |     4 |          -  | Column| IndexedStringFieldCache    | false     |
| address  | address_id |        2412 |    - |     0 |          -  | Column| IndexedIntFieldCache       | true      |

...


### Showing The Load/Reload Progress
The load and organize process can be viewed in the log by enabling `APPLICATION_BUILDER` logging as shown hereunder:
``` java
    SakilaApplicationBuilder builder = new SakilaApplicationBuilder()        
        .withPassword(password)
        .withLogging(LogType.APPLICATION_BUILDER)
        .withBundel(DataStoreBundle.class);
        .build();
```
When the DataStore is loaded, information on the loading progress will be shown in the logs:
``` text
2017-05-16T01:46:16.901Z DEBUG [pool-1-thread-3] (#APPLICATION_BUILDER) - db0.sakila.category : Loading from database completed (took 136.76 ms).
2017-05-16T01:46:16.939Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -    db0.sakila.actor : Loading from database completed (took 195.63 ms).
2017-05-16T01:46:16.948Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -    db0.sakila.actor : Building entity cache with 200 rows completed (took 7.98 ms). Density is 31 bytes/entity
2017-05-16T01:46:16.948Z DEBUG [pool-1-thread-3] (#APPLICATION_BUILDER) - db0.sakila.category : Building entity cache with 16 rows completed (took 46.12 ms). Density is 20 bytes/entity
2017-05-16T01:46:16.985Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -  db0.sakila.country : Loading from database completed (took 36.65 ms).
2017-05-16T01:46:16.995Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -  db0.sakila.country : Building entity cache with 109 rows completed (took 8.78 ms). Density is 24 bytes/entity
2017-05-16T01:46:17.007Z DEBUG [pool-1-thread-2] (#APPLICATION_BUILDER) -  db0.sakila.address : Loading from database completed (took 252.67 ms).
...
2017-05-16T01:46:18.732Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -  rental.rental_date : Loading column store
2017-05-16T01:46:18.743Z DEBUG [pool-1-thread-3] (#APPLICATION_BUILDER) - rental.inventory_id : Building column cache with 16,044 rows completed (took 53.60 ms). Density is 4 bytes/entity
2017-05-16T01:46:18.743Z DEBUG [pool-1-thread-3] (#APPLICATION_BUILDER) -    rental.rental_id : Loading column store
2017-05-16T01:46:18.745Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -  rental.rental_date : Building column store
2017-05-16T01:46:18.748Z DEBUG [pool-1-thread-2] (#APPLICATION_BUILDER) -  rental.return_date : Building column cache with 16,044 rows completed (took 97.70 ms). Density is 4 bytes/entity
2017-05-16T01:46:18.750Z DEBUG [pool-1-thread-3] (#APPLICATION_BUILDER) -    rental.rental_id : Building column store
2017-05-16T01:46:18.756Z DEBUG [pool-1-thread-3] (#APPLICATION_BUILDER) -    rental.rental_id : Building column cache with 16,044 rows completed (took 12.33 ms). Density is 4 bytes/entity
2017-05-16T01:46:18.781Z DEBUG [pool-1-thread-1] (#APPLICATION_BUILDER) -  rental.rental_date : Building column cache with 16,044 rows completed (took 47.96 ms). Density is 4 bytes/entity
Finished reloading in 2.05 s.
```

## Performance
The DataStore module will sort each table and each column upon load/re-load. This means that you can benefit from low latency regardless on which column you use in stream filters, sorters, etc.
When the DataStore module is being used, Stream latency will be orders of magnitudes better.

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="datastore.html" %}