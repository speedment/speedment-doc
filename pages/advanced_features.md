---
permalink: advanced_features.html
sidebar: mydoc_sidebar
title: Advanced Features
keywords: Parallel, Iterator, Spliterator
toc: false
Tags: Parallel, Iterator, Spliterator
previous: integration.html
next: datastore.html
---

{% include prev_next.html %}

## Advanced Features

This chapter covers features and properties that are more advanced and that might not be needed or used by the average Speedment user. 

## Automatic Closing
Speedment Streams are closed automatically as apposed to ordinary `Collection` streams such as `List::stream`. This was an API decision taken early because otherwise the application logic would be cluttered with numerous try/catch/finally statements defying the purpose of having a fluent and simple API. It is important that streams are properly closed because as long as they are open, they will hold a database connection and other resources.

If Speedment did not have automatically closed streams, then a Speedment application would look something like this:
``` java
   try (Stream<Film> stream = films.stream()) {
      long count = stream
          .filter(Film.RATING.equal("PG-13"))
          .count();
   }
```
instead of this:
``` java
    long count = films.stream()
        .filter(Film.RATING.equal("PG-13"))
        .count();
   }
```
{% include note.html content= "
If a Speedment stream throws an `Exception`, then it will still perform a proper automatic close. Closing a Speedment stream explicitly after is has already been automatically closed is a no-op and it is guaranteed that the stream only calls its close handlers once.
" %}


## Iterator and Spliterator
Calls to either `Stream::iterator` or `Spliteraor::spliterator` will produce an object where the automatic closing property can not be ensured (Partly because neither `Iterator` nor `Spliterator` have a close method).

Because of this, the `Stream::iterator` and `Stream:spliterator` functions are disabled in Speedment streams by default and they will throw an `UnsupportedOperationException` whenever they are invoked. If you are willing to assume the responsibility of always closing the underlying stream, then you can enable the `Stream::iterator` and `Stream:spliterator` methods via your `ApplicationBuilder`:
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword(password)
        .withAllowStreamIteratorAndSpliterator()
        .build();
```
If you elect to enable these methods using the `withAllowStreamIteratorAndSpliterator()` method, then it is imperative that you always close your underlying streams or you will deplete your database connection pool. Here is an example of how to make sure an `Iterator` from a Speedment stream is used properly:
``` java
    try (Stream<Film> filmStream = films.stream()) {
        Iterator<Film> filmIterator = filmStream.iterator();
        filmIterator.forEachRemaining(System.out::println);
    };
```
The `spliterator()` method can be handled much the same way. 

### Stream.concat()
The static method `Stream::concat` relies on merging two Spliterators from two underlying streams and thus it cannot be used unless the `withAllowStreamIteratorAndSpliterator()` has been called. Because of this, Speedment provides another support method `StreamComposition::concatAndAutoClose` that allows concatenation without using Spliterators and thus there is no need to call the `withAllowStreamIteratorAndSpliterator()` method just for the sake of being able to concatenate streams.


## Parallelism
Speedment supports database parallelism out-of-the-box using the `Stream:parallel` method. This can improve your database performance significantly in many cases.

Here is an example of how parallel streams can be used:
``` java
    inventories.stream()
        .parallel()
        .forEach(this::expensiveOperation);

    private void expensiveOperation(Inventory inventory) {
        try {
            Thread.sleep(100);
            System.out.format("%34s %s%n", Thread.currentThread().getName(), inventory);
        } catch (InterruptedException ie) {
            throw new RuntimeException(ie);
        }
    }
```
As can be seen above, we have simulated an `extensiveOperaion` by inserting an artificial delay of 100 ms for each element in the stream. The code above will produce the following output:
``` text
ForkJoinPool.commonPool-worker-1 InventoryImpl { inventoryId = 1, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
                            main InventoryImpl { inventoryId = 1025, filmId = 229, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-2 InventoryImpl { inventoryId = 3073, filmId = 676, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-1 InventoryImpl { inventoryId = 2, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
                            main InventoryImpl { inventoryId = 1026, filmId = 229, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-2 InventoryImpl { inventoryId = 3074, filmId = 676, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-1 InventoryImpl { inventoryId = 3, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
                            main InventoryImpl { inventoryId = 1027, filmId = 230, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-2 InventoryImpl { inventoryId = 3075, filmId = 676, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
...
```
Read more about Parallel Database Streams with Speedment in this [blog post](http://minborgsjavapot.blogspot.com/2016/10/work-with-parallel-database-streams.html)

## Parallel Strategy
In the [previous chapter](#parallelism) we learned about parallelism. Because the number of rows that a stream is processing is unknown in the beginning, Speedment will apply a certain strategy of how to divide the stream elements over the available threads. By default, Speedment is using Java 8's default parallel strategy `Spliterators::spliteratorUnknownSize` whereby an arithmetic progression in split sizes 1024, 2048, 3072, 4096, etc. elements will be laid out over the available threads.

When the number of elements are relatively low, the default strategy will not work (for example if there are less than 1024 elements, then only one thread will be used). This is why Speedment supports different parallel strategies. You can set your own parallel strategy like this:
``` java
    Manager<Inventory> inventoriesWithStategy = app
        .configure(InventoryManager.class)
        .withParallelStrategy(ParallelStrategy.computeIntensityHigh())
        .build();
        
    inventoriesWithStategy.stream()
        .parallel()
        .forEach(this::expensiveOperation);
```

This will produce the following output:
``` text
ForkJoinPool.commonPool-worker-2 InventoryImpl { inventoryId = 4, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
                            main InventoryImpl { inventoryId = 2, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-3 InventoryImpl { inventoryId = 3, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-4 InventoryImpl { inventoryId = 7, filmId = 1, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-1 InventoryImpl { inventoryId = 1, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-7 InventoryImpl { inventoryId = 9, filmId = 2, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-5 InventoryImpl { inventoryId = 5, filmId = 1, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-6 InventoryImpl { inventoryId = 11, filmId = 2, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-4 InventoryImpl { inventoryId = 8, filmId = 1, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-3 InventoryImpl { inventoryId = 13, filmId = 3, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-5 InventoryImpl { inventoryId = 6, filmId = 1, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool.commonPool-worker-7 InventoryImpl { inventoryId = 10, filmId = 2, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
...
```
As can be seen, more threads are being used with the selected parallel strategy `ParallelStrategy.computeIntensityHigh()` compared to the case in the previous clause where the default strategy was used.

The following static methods are available in the `ParallelStrategy` interface:

| Strategy                      | Elements per thread             | Description                |
| :---------------------------- | :------------------------------ | :------------------------- |
| `computeIntensityDefault()`   | 1024, 2048, 3072, 4096, ...     | Default Java 8 strategy that favors relatively large sets (in the ten thousands or more) with low computational overhead
| `computeIntensityMedium()`    | 16, 32, 64, ..., up to 16384    | A Parallel Strategy that favors relatively small to medium sets with medium computational overhead
| `computeIntensityHigh()`      | 1, 1, 2, 2, 4, 4, ..., up to 256| A Parallel Strategy that favors relatively small to medium sets with high computational overhead
| `computeIntensityExtreme()`   | 1 always                        | A Parallel Strategy that favors small sets with extremely high computational overhead. The set will be split up in solitary elements that are executed separately in their own thread

It is relatively easy to implement a custom parallel strategy. Read more about that, Parallel Database Streams and Parallel strategies with Speedment in this [blog post](http://minborgsjavapot.blogspot.com/2016/10/work-with-parallel-database-streams.html)

## Parallel Thread Pools
By default, parallel streams are executed by the Common ForkJoin pool. If you want to execute parallel streams using another thread pool then do like this:
``` java
        // Create a custom ForkJoinPool with only three threads
        ForkJoinPool forkJoinPool = new ForkJoinPool(3);

        forkJoinPool.submit(() -> {
            inventories.stream()
                .parallel()
                .forEach(this::expensiveOperation);
        });

        try {
            forkJoinPool.shutdown();
            forkJoinPool.awaitTermination(1, TimeUnit.HOURS);
        } catch (InterruptedException ie) {
            ie.printStackTrace();
        }
```
This will produce the following output:
``` text
ForkJoinPool-1-worker-2 InventoryImpl { inventoryId = 1, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-1 InventoryImpl { inventoryId = 1025, filmId = 229, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-3 InventoryImpl { inventoryId = 3073, filmId = 676, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-2 InventoryImpl { inventoryId = 2, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-1 InventoryImpl { inventoryId = 1026, filmId = 229, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-3 InventoryImpl { inventoryId = 3074, filmId = 676, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-2 InventoryImpl { inventoryId = 3, filmId = 1, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-1 InventoryImpl { inventoryId = 1027, filmId = 230, storeId = 1, lastUpdate = 2006-02-15 05:09:17.0 }
ForkJoinPool-1-worker-3 InventoryImpl { inventoryId = 3075, filmId = 676, storeId = 2, lastUpdate = 2006-02-15 05:09:17.0 }
```
As can be seem, the parallel stream was executed by the thread pool we just created. 

Read more about parallel streams in custom thread pools in this [blog post](http://minborgsjavapot.blogspot.com/2016/11/work-with-parallel-database-streams.html)


## Connection Pooling
The task of obtaining a database connection is a relatively expensive operation. Because of this, many tools are using a connection pool whereby it is possible to re-use connections previously obtained from the database.

Speedment is no exception and has its own connection pool that is enabled by default. If you are running Speedment under a Java EE server with its own connection pool then these pools will work simultaneously so that Speedment will allocate a connector from the Java EE pool and then it will pool this connection internally in its own pool. Once the connection is aged out, it will be returned to the Java EE pool. If the Java EE pool retains connection longer than Speedment, then the connection might be re-used again, otherwise a new connection is allocated.

The default Speedment `ConnectionPoolComponent` will hold up to 32 connections per database and each connection is retained for 30 seconds before they are discarded. These parameters can be set at configuration time using the `ApplicationBuilder::param` method:
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword(password)
        .withLogging(LogType.CONNECTION)
        .withParam("connectionpool.maxAge", "8000")
        .withParam("connectionpool.maxRetainSize", "10")
        .build();
```
This will build an application with a `ConnectionPoolComponent` that will pool at most 10 database connections and where each connection will be held in the pool for no more than 8 seconds (= 8,000 ms).

{% include tip.html content= "
You can enable logging of `ConnectionPoolComponent` events by calling `.withLogging(LogType.CONNECTION)` in your `ApplicationBuilder`. This is useful when using a Java EE server and allow you to see where and by whom your connections are allocated.
" %}

It is possible to inspect the current settings and state of the `ConnectionPoolComponent` at runtime like this:
``` java
    ConnectionPoolComponent connectionPool = app.getOrThrow(ConnectionPoolComponent.class);

    System.out.format("poolSize:%d, leaseSize:%d, maxAge:%d, maxRetainSize:%d%n",
        connectionPool.poolSize(),
        connectionPool.leaseSize(),
        connectionPool.getMaxAge(),
        connectionPool.getMaxRetainSize()
    );
```

## Custom Stream Sources
If you want to work with data from another data source than originally selected, you could easily plug in your own `StreamSupplierComponent` and replace the standard one that reads from the original data source (e.g. the database).

There may be many different types of sources including CSV, JSON, Binary and Excel files. There might also be other sources like remote web services or algorithms that computes data deterministically.

The following example shows an example when films are read from a CSV file rather than the database. The other tables will be read from the database as before.

```
public class FilmCsvStreamSupplierComponent implements StreamSupplierComponent {

    private static final TableIdentifier<Film> FILM_TABLE_IDENTIFIER = TableIdentifier.of("sakila", "sakila", "film");

    private StreamSupplierComponent previous;

    /**
     * Retrieves the previous StreamSupplierComponent under this one. This 
     * is used to delegate streams other than Film streams.
     * 
     * @param injector 
     */
    @ExecuteBefore(State.STARTED)
    void findPrevious(Injector injector) {
        final List<StreamSupplierComponent> components = injector.stream(StreamSupplierComponent.class)
            .collect(toList());

        int myIndex = -1;
        for (int i = 0; i < components.size(); i++) {
            if (components.get(i) == this) {
                myIndex = i;
                break;
            }
        }
        if (myIndex == -1 || myIndex == components.size() - 1) {
            throw new IllegalStateException("There was no previous StreamSupplierComponent");
        }
        previous = components.get(myIndex + 1);
    }

    @Override
    @SuppressWarnings("unchecked")
    public <ENTITY> Stream<ENTITY> stream(TableIdentifier<ENTITY> tableIdentifier, ParallelStrategy strategy) {
        if (FILM_TABLE_IDENTIFIER.equals(tableIdentifier)) {
            // Read Film entities from a csv file
            return (Stream<ENTITY>) streamFilmCsv();
        } else {
            // Delegate all other streams to the previous StreamSupplierComponent
            return previous.stream(tableIdentifier, strategy);
        }
    }

    private Stream<Film> streamFilmCsv() {
        try {
            return Files.lines(Paths.get("film.csv"))
                .skip(1)                  // The first row contains headers so it should be skipped
                .map(this::stringToFilm); // Convert a line to a Film entity
        } catch (IOException ioe) {
            throw new SpeedmentException("Error reading from file", ioe);
        }

    }

    private static final String CSV_SEPARATOR = ";";

    private Film stringToFilm(String s) {
        final String[] arr = s.split(CSV_SEPARATOR);

        return new FilmImpl()
            .setFilmId(Integer.parseInt(arr[0]))
            .setTitle(unquote(arr[1]))
            .setDescription(unquote(arr[2]))
            .setReleaseYear(Date.valueOf(unquote(arr[3]) + "-01-01"))
            .setLanguageId(Short.parseShort(arr[4]))
            .setOriginalLanguageId(Short.parseShort(arr[5]))
            .setRentalDuration(Short.parseShort(arr[6]))
            .setRentalRate(new BigDecimal(unquote(arr[7])))
            .setLength(Integer.parseInt(arr[8]))
            .setReplacementCost(new BigDecimal(unquote(arr[9])))
            .setRating(unquote(arr[10]))
            .setSpecialFeatures(unquote(arr[11]))
            .setLastUpdate(Timestamp.valueOf(unquote(arr[12])));
    }

    private String unquote(String s) {
        return s.trim().substring(1, s.length() - 1);
    }

}
```
The CSV specific code above is used because it can be easily understood. There are a number of third party libraries available for reading various file formats.


This is how the content of the "film.csv" file could look like:
``` text 
"film_id";"title";"description";"release_year";"language_id";"original_language_id";"rental_duration";"rental_rate";"length";"replacement_cost";"rating";"special_features";"last_update"
1;"ACADEMY DINOSAUR";"A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies";"2006";1;0;6;0.99;86;20.99;"PG";"Deleted Scenes,Behind the Scenes";"2006-02-15 05:03:42"
2;"ACE GOLDFINGER";"A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China";"2006";1;0;3;4.99;48;12.99;"G";"Trailers,Deleted Scenes";"2006-02-15 05:03:42"
3;"ADAPTATION HOLES";"A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory";"2006";1;0;7;2.99;50;18.99;"NC-17";"Trailers,Deleted Scenes";"2006-02-15 05:03:42"
...
```
{% include warning.html content = "
Providing a custom `StreamSupplierComponent` means that you are assuming the responsibility of ensuring referential integrity. If the `StreamSupplierComponent` are using components that are from different transaction states, then these component views might violate referential integrity. This must now be handled by your application.
" %}


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="advanced_features.html" %}
