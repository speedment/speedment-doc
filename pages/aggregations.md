---
permalink: aggregations.html
sidebar: mydoc_sidebar
title: Aggregations
keywords: Aggregations, Aggregate
toc: false
Tags: Aggregations, Aggregate
previous: datastore.html
next: sharding.html
---

{% include prev_next.html %}

## What are Aggregations?
TBW

## Aggregating

**Requires Speedment Enterprise 1.2.0 or later.** 
A common use case in analytical applications is to aggregate many results into a few composite values. 
This can be done very efficiently using the specialized collectors built into 
Speedment Enterprise by leveraging the standard Java Streams API.

Since the Aggregator is designed to perform all steps of the aggregation off-heap, aggregations 
of large data sets can be performed with minimal heap memory footprint. 

In the following examples we will aggregate data entities of the type `Person`, defined by the following fields.

``` java
    private static class Person {
        private final int age;
        private final short height;
        private final short weight;        
        private final String gender;
        private final double salary;
        ...
    }
```

To represent results of aggregations we will be using a data class called `AgeSalary` which 
associates a certain age with an average salary.

``` java
    private static class AgeSalary {
         private int age;
         private double avgSalary;
         ...
    }
```

#### Aggregation to Explicitly Typed Results

To compute the average salary for each age, we will first create an `Aggregator<Person, ?, AgeSalary>` as follows.

``` java
    Aggregator<Person, ?, AgeSalary> aggregator = Aggregator.builder(AgeSalary::new)
        .on(Person::age).key(AgeSalary::setAge)
        .on(Person::salary).average(AgeSalary::setAvgSalary)
        .build();
```

The first line calls the defines the `Aggregator` to use and determines the constructor
for result objects as `AgeSalary::new`. The second line declares the key for the aggregation;
first in terms of how to find the key value in an incoming `Person` instance and then
how to set the key value in our result object. The third line is similar, but instead of
a key it defines an average value to be computed from the salaries of `Person` instances.

An `Aggregator` can produce a collector that can be used in any standard Java stream. 
Thus, having a `Stream<Person> persons` we can compute the aggregation of average salaries as follows.

``` java
    Aggregation<AgeSalary> aggregation = persons().collect(aggregator.createCollector());
```

The `Aggregation` holds the state of the aggregation data and allows repeated streaming over 
the data. 

``` java
    aggregation.streamAndClose()
        .forEach(System.out::println);
```

Since the `Aggregation` may hold data that is stored off-heap, it may benefit from 
explicit closing rather than just being garbage collected. Closing the `Aggregation` can 
be done by calling the `close()` method, possibly by taking advantage of the `AutoCloseable` 
trait, or as in the example above by using `streamAndClose()` which returns a stream that 
will close the `Aggregation` after stream termination.

In summary, the aggregation can be condensed as follows. 

``` java
    persons().collect(Aggregator.builderOfType(Person.class, AgeSalary::new)
        .on(Person::age).key(AgeSalary::setAge)
        .on(Person::salary).average(AgeSalary::setAvgSalary)
        .build()
        .createCollector()
    ).streamAndClose()
        .forEach(System.out::println);
```

#### Aggregation to Generic Tuples

Sometimes designing an explicit result data class is overly verbose without adding much
clarity. In such cases, Speedment `MutableTuples` can be used to create result data on the fly.

``` java
    persons().collect(
        Aggregator.builder(MutableTuples.constructor(Integer.class, Double.class))
            .on(Person::age).key(MutableTuple2::set0)
            .on(Person::salary).average(MutableTuple2::set1)
            .build()
            .createCollector()
    ).streamAndClose()
        .forEach(System.out::println);
```

#### Derived Keys and Values

The functions supplied to the aggregator for finding and setting keys and result field values are general functions,
meaning that they do not necessarily need to be simple getters and setters as in the above examples. Using the Speedment 
predefined utilities for composing functions from basic building blocks, the example above can easily be extended to
aggregate on decades instead of specific years. The key is then not the age, but age divided by 10 and that can
be expressed as follows.

``` java
    Aggregator.builder(MutableTuples.constructor(Integer.class, Double.class))
        .on(divide(Person::age, 10).asInt()).key(MutableTuple2::set0)
        .on(Person::salary).average(MutableTuple2::set1)
        .build()
```

where the method `divide` is statically imported from the Speedment utility class `Expressions`. Clearly, one can
use any kind of function here, but using the Speedment utility functions allows the Speedment runtime to optimize
the stream operations and is therefore potentially significantly more efficient.

As a second example, consider the following code aggregating the BMI per gender of persons in a data set.

``` java
    Aggregator<Person, ?, Result> aggregator = Aggregator.builder(Result::new)
        .on(Person::getGender)
        .key(Result::setGender)
        .on(shortToDouble(Person::getWeight)
            .divide(Expressions.pow(
                Expressions.divide(Person::getHeight, 100),
                2)))
        .average(Result::setBMI)
        .build();
```

Here, the `Result` class is defined to have setter methods for BMI and gender, `Result::setBMI` and `Result::setGender`.

#### Aggregating DataStore Data

The actual aggregation computations are performed in off-heap memory, meaning that garbage collection is not affected 
and that the size of the aggregated data is not bounded by the size of the heap. 

In the above examples, incoming data to aggregate is heap objects, meaning that no matter how the stream supplying the
data creates it, all the incoming data objects will need to be garbage collected at some point. To address this,
Speedment supports aggregating off-heap data in place in a DataStore, minimizing the need for heap materialization and 
the implied garbage collection load. This is achieved automatically if the Speedment aggregator is used to collect
a stream from a DataStore.


## Performance
The Aggregator will store intermediate results off-heap and can operate without creating any intermediate result objects during aggregation. If an Aggregator is used in conjunction with a Stream form a [DataStore](datastore.html#top) component, then the Aggregator could provide additional performance benefits such as only extracting needed column values without actually materializing the entities in the stream.

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="aggregations.html" %}
