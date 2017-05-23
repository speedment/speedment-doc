---
permalink: advanced_features.html
sidebar: mydoc_sidebar
title: Advanced Features
keywords: Parallel, Iterator, Spliterator
toc: false
Tags: Parallel, Iterator, Spliterator
previous: advanced_features.html
next: advanced_features.html
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
Calls to either `Stream::iterator` or `Spliteraor::spliterator` will produce an object where the automatically closing property can not be ensured (Because neither `Iterator` nor `Spliterator` have a close method)

Because of this, the `Stream::iterator` and `Stream:spliterator` functions are disabled in Speedment streams by default and will throw an `UnsupportedOperationException` whenever they are called. If you are willing to assume the responsibility of always closing the underlying stream, then you can enable the `Stream::iterator` and `Stream:spliterator` like this:
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword(password)
        .withAllowStreamIteratorAndSpliterator()
        .build();
```
If you elect to enable these methods using the `withAllowStreamIteratorAndSpliterator()` method, it is imperative that you always close your underlying streams or you will deplete your database connection pool. Here is an example of how to make sure an `Iterator` from a Speedment stream is used properly:
``` java
    try (Stream<Film> filmStream = films.stream()) {
        filmStream.onClose(() -> System.out.println("Close : iteratorWitchClose"));
        Iterator<Film> filmIterator = filmStream.iterator();
        filmIterator.forEachRemaining(System.out::println);
    };
```
The `spliterator()` method can be handled the same way. The method `Stream::concat` relies on merging two streams' Spliterators and thus it cannot be used unless the `withAllowStreamIteratorAndSpliterator()` has been called. There is another method `StreamComposition::concatAndAutoClose` that allows concatenation without using Spliterators and thus there is no need to call the `withAllowStreamIteratorAndSpliterator()` method.


## Parallelism


## Parallel Strategy


## Connection Pooling
The task of obtaining a database connection is a relatively expensive operation. Because of this, many tools are using a connection pool whereby it is possible to re-use connections previously obtained from the database.

Speedment has its own connection pool that is enabled by default. If you are running Speedment under a Java EE server with its own connection pool then these pools will work simultaneously so that Speedment will allocate a connector from the Java EE pool and then it will pool this connection internally in its own pool. Once the connection is aged out, it will be returned to the Java EE pool. If the Java EE pool retains connection longer than Speedment, then the connection might be re-used again, otherwise a new connection is allocated.
The default Speedment `ConnectionPoolComponent` can hold up to 32 connections per database and each connection is retained for 30 seconds before they are discarded. These parameters can be set at configuration time using the `ApplicationBuilder::param` method:
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword(password)
        .withLogging(LogType.CONNECTION)
        .withParam("connectionpool.maxAge", "8000")
        .withParam("connectionpool.maxRetainSize", "10")
        .build();
```
This will build an application with a `ConnectionPoolComponent` that will use at most 10 database connections and where each connection will be held in the pool for no more than 8 seconds (= 8,000 ms).

It is possible to read the current settings and state of the `ConnectionPoolComponent` at runtime like this:
``` java
    ConnectionPoolComponent connectionPool = app.getOrThrow(ConnectionPoolComponent.class);

    System.out.format("poolSize:%d, leaseSize:%d, maxAge:%d, maxRetainSize:%d%n",
        connectionPool.poolSize(),
        connectionPool.leaseSize(),
        connectionPool.getMaxAge(),
        connectionPool.getMaxRetainSize()
    );
```


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="advanced_features.html" %}