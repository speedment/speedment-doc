---
permalink: stream_fundamentals.html
sidebar: mydoc_sidebar
title: Stream Fundamentals
keywords: Stream
toc: false
Tags: Stream
previous: introduction.html
next: getting_started.html
---

{% include prev_next.html %}

## What is a Stream?
Speedment is all about Java 8 {{site.data.javadoc.Stream}}s, that allows you to process data in a declarative way similar to SQL statements. So if you are not familiar with the concept of `Stream`s, I encourage you to read this chapter carefully. If you consider yourself a `Stream` expert, feel free to skip directly to the next chapter.

A Java 8 `Stream` is an `interface` with implementations that supports a functional style operation on streams of elements. The entire Java Collection framework was retrofitted with `Stream` support in Java 8.

Streams can be used to express a kind of "recipe" style of operations, allowing us to compose a number of function and only when the `Stream` is started, the functions are applied to the elements in the `Stream`. This means that `Streams` can be very efficient and general. A `Stream` recipe says *what to do* but generally *not how to do it* which is good from an abstraction point of view.

Consider the following simple example:

``` java
    Stream.of(                           // Creates a Stream with the given content
        "Zlatan", 
        "Tim", 
        "Bo",
        "George",
        "Adam",
        "Oscar"
    )
        .filter(n -> n.length() > 2)     // Retains only those Strings that are longer than 2 characters (i.e. "Bo" is dropped)
        .sorted()                        // Sorts the remaining Strings in natural order
        .collect(Collectors.toList());   // Collects the remaining sorted Strings in a List
```
First, we create a `Stream` using the statement `Stream.of()`. Note that nothing happens with the `Stream` at this point. We just have a stream that we can use to further build our "recipe" around. Now that we have a `Stream`, we add a `filter` that only lets through Strings that are longer than 2 characters. Again, the `Stream` is not started, we have just said that *when* the `Stream` starts, we want to filter the Strings. Next, we add a `sorted()` operation to our `Stream` recipe. This means that when the `Stream` is started, all Strings that passes the `filter` shall be sorted in natural order. Again, nothing is flowing through the `Stream`, we have just added yet an operation to the `Stream` recipe (the stream recipe can more formally be called a *stream pipeline*). The last operation we add to the `Stream` recipe is `collect`. 

This operation is different to all the previous operations in the way that it is a *terminal operation*. Whenever a *terminal operation* is applied to a `Stream`, the `Stream` cannot accept additional operations to its pipeline. It also means that the `Stream` is started.

It shall be noted that elements in a `Stream` are pulled by the *terminal operation* (i.e. the `collect` operation) and not pushed by the stream source. So, `Collect` will ask for the first element and that request will traverse up to the stream source that will provide the first element "Zlatan".
The `filter` operation will check if the length of "Zlatan" is greater than two (which it is) and will then propagate "Zlatan" to the `sorted` operation.
Because the `sorted` operation needs to see all strings before it can decide on its output order, it will ask the stream source for all its remaining elements which, via the filter, is sent down the stream. Once all stings are received by the `sorted` operator, it will sort the strings and then output its first element (i.e. "Adam") to the `collect` operation. The result of the entire stream statement will thus be:

``` text
"Adam", "George", "Oscar", "Tim", "Zlatan"
```

### Streams with Speedment
With Speedment, it is possible to use exactly the same semantics as for Java 8 streams. Instead of Strings as shown in the example above, we can use rows in database tables. This way, we can view database tables as pure Java 8 streams as shown hereunder:
``` java
    users.stream()                       // Creates a Stream with users from a database 
        .map(u -> u.getName())           // Extract the name (a String) from a user
        .filter(n -> n.length() > 2)     // Retains only those Strings that are longer than 2 characters (i.e. "Bo" is dropped)
        .sorted()                        // Sorts the remaining Strings in natural order
        .collect(Collectors.toList());   // Collects the remaining sorted Strings in a List
```
Because a Java 8 Stream is an interface, Speedment can select from a variety of different implementations of a Stream depending on the pipeline we are setting up and other factors.


## Intermediate Operations
An *intermediate operations* is an operation that allows further operations to be added to a `Stream`. For example, `filter` is an *intermediate operation* because we can add additional operations to a `Stream` pipeline after `filter` has been applied to the `Stream`.

### Common Operations
The following *intermediate operations* can be accepted by a `Stream`:

| Operation         | Parameter          | Returns a `Stream` that:
| :------------     | :----------------- | :----------------------------------------------------- |
| `filter`          | `Predicate`        | contains only those elements that match the `Predicate`
| `map`             | `Function`         | contains the results of applying the given `Function` to the elements of this stream
| `distinct`        | -                  | contains the distinct (i.e. unique) elements in the stream as per the element's `equals()` method.
| `sorted`          | -                  | contains the elements in the stream in sorted order as per the element's `compareTo()` method
| `sorted`          | `Comparator`       | contains the elements in the stream in sorted order as per the given `Comparator`
| `limit`           | `long`             | contains the original elements in the stream but truncated to be no longer than the given `long` value
| `skip`            | `long`             | contains the original elements in the stream but after discarding the given `long` value of elements
| `flatMap`         | `Function`         | contains the elements of the `Stream`s in this stream obtained by applying the given `Function` to the stream elements of this stream
| `peek`            | `Consumer`         | contains the original elements in the stream but additionally accepting each element to the given `Consumer` (side effect)

### Stream Property Operations
There are also a number of *intermediate operations* that controls the properties of the `Stream` and has no effect on its actual content. These are:

| Operation         | Parameter          | Returns a `Stream` that:
| :------------     | :----------------- | :----------------------------------------------------- |
| `parallel`        | -                  | is parallel (not sequential)
| `sequential`      | -                  | is sequential (not parallel)
| `unordered`       | -                  | is unordered (data might appear in any order)
| `onClose`         | `Runnable`         | will run the provided `Runnable` when closed

### Map to Primitive Operations
There are also some *intermediate operations* that maps a `Stream` to one of the special primitive stream types; `IntStrem`, `LongStream` and `DoubleStream`:

| Operation         | Parameter          | Returns a `Stream` that:
| :------------     | :----------------- | :----------------------------------------------------- |
| `mapToInt`        | `ToIntFunction`    | is an `IntStream` containing `int` elements obtained by applying the given `ToIntFunction` to the elements of this stream
| `mapToLong`       | `ToLongFunction`   | is a `LongStream` containing `long` elements obtained by applying the given `ToLongFunction` to the elements of this stream
| `mapToDouble`     | `ToDoubleFunction` | is a `DoubleStream` containing `double` elements obtained by applying the given `ToDoubleFunction` to the elements of this stream
| `flatMapToInt`    | `Function`         | contains the `int` elements of the `IntStream`s in this stream obtained by applying the given `Function` to the stream elements of this stream
| `flatMapToLong`   | `Function`         | contains the `long` elements of the `LongStream`s in this stream obtained by applying the given `Function` to the stream elements of this stream
| `flatMapToDouble` | `Function`         | contains the `double` elements of the `DoubleStream`s in this stream obtained by applying the given `Function` to the stream elements of this stream

Primitive streams provides better performance in many cases but can only handle streams of: `int`, `long` and `double`.


### Primitive Operations
Primitive streams (like `IntStream` and `LongStream`) provide similar functionality as ordinary streams but usually the parameter count and types differ so that primitive streams can accept more optimized function variants.
Here is a table of some additional *intermediate operations* that primitive Streams can take:

| Operation         | Parameter          | Returns a `Stream` that:
| :------------     | :----------------- | :----------------------------------------------------- |
| `boxed`           | -                  | contains the boxed elements in the original stream (e.g. an `int` is boxed to an `Integer`)
| `asLongStream`    | -                  | contains the elements in the original stream converted to `long` elements
| `asDoubleStream`  | -                  | contains the elements in the original stream converted to `double` elements


### Java 9 Operations
Two new *intermediate operations* were introduced in Java 9. Because these methods were added to the Stream interface with default implementations, these methods can be used by any Stream written in either Java 8 or Java 9.

| Operation         | Parameter          | Returns a `Stream` that:
| :------------     | :----------------- | :----------------------------------------------------- |
| `takeWhile`       | `Predicate`        | contains the elements in the original stream until the the first one fails the Predicate test 
| `dropWhile`       | `Predicate`        | contains the elements in the original stream dropping all elements until the the first one fails the Predicate test then containing the rest of the elements

Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information. Here are some examples of streams with *intermediate operations*:

## Intermediate Operations Examples

Here is a list with examples for many of the  *intermediate operations*. In the examples below, lambdas are used but many times, the lambdas could be replaces by method references (e.g. the lambda `() -> new StringBuilder` can be replaced by a method reference `StringBuilder::new`). The source code for the examples with *intermediate operations* below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/stream_fundamentals/IntermediateOperations.java)

### filter
``` java
    Stream.of("B", "A", "C" , "B")
        .filter(s -> s.equals("B"))
```
returns a `Stream` with the elements "B" and "B" because only elements that are equal to "B" will pass the `filter` operation.

### map
``` java
    Stream.of("B", "A", "C" , "B")
        .map(s -> s.toLowerCase())
```
is a `Stream` with the elements "b", "a", "c" and "b" because each element will be mapped (converted) to its lower case representation.

### distinct
``` java
    Stream.of("B", "A", "C" , "B")
        .distinct()
```
is a `Stream` with the elements "B", "A" and "C" because only unique elements will pass the `distinct` operation.

### sorted
``` java
    Stream.of("B", "A", "C" , "B")
        .sorted()
```
returns a `Stream` with the elements "A", "B", "B" and "C" because the `sort` operation will sort all elements in the stream in natural order.

``` java
    Stream.of("B", "A", "C" , "B")
        .sorted(Comparator.reverseOrder())
```
is a `Stream` with the elements "C", "B", "B" and "A" because the `sort` operation will sort all elements in the stream according to the provided `Comparator` (in reversed natural order).

### limit
``` java
    Stream.of("B", "A", "C" , "B")
        .limit(2)
```
is a `Stream` with the elements "B" and "A" because after the two first elements the rest of the elements will be discarded.
### skip
``` java
    Stream.of("B", "A", "C" , "B")
        .skip(1)
```
is a `Stream` with the elements "A", "C" and "B" because the first element in the stream will be skipped.

### flatMap
``` java
    Stream.of(
        Stream.of("B", "A"),
        Stream.of("C", "B")
    )
        .flatMap(Function.identity())
        .forEachOrdered(System.out::println);
```
returns a `Stream` with the elements "B", "A", "C" and "B" because the two streams (that each contain two elements) are "flattened" to a single `Stream` with four elements.

``` java
    Stream.of(
        Arrays.asList("B", "A"),
        Arrays.asList("C", "B")
    )
        .flatMap(l -> l.stream())
```
returns a `Stream` with the elements "B", "A", "C" and "B" because the two lists (that each contain two elements) are "flattened" to a single `Stream` with four elements. The lists are converted to sub-streams using the `List::stream` mapper method.

### peek
``` java
    Stream.of("B", "A", "C" , "B")
        .peek(System.out::print)
```
is a `Stream` with the elements "B", "A", "C" and "B" but, when consumed in its entirety, will print out the text "BACB" as a side effect. Note that using side effects in stream are discouraged. Use this operation for debug only.

### parallel
``` java
    Stream.of("B", "A", "C" , "B")
        .parallel()
```
is a `Stream` with the elements "B", "A", "C" and "B" but, when consumed, elements in the `Stream` may be propagated through the pipeline using different `Thread`s. By default, parallel streams are executed on the default `ForkJoinPool`.

### sequential
``` java
    Stream.of("B", "A", "C" , "B")
        .parallel()
        .sequential()
```
is a `Stream` with the elements "B", "A", "C" and "B" that is not parallel.

### unordered
``` java
    Stream.of("B", "A", "C" , "B")
        .unordered()
```
is a `Stream` with the given elements but not necessary in any particular order. So when consumed, elements might be encountered in any order, for example in the order "C", "B", "B", "A". Note that `unordered` is just a relaxation of the stream requirements. Unordered streams can retain their original element order or elements can appear in any other order.

### onClose
``` java
    Stream.of("B", "A", "C", "B")
        .onClose( () -> System.out.println("The Stream was closed") );
```
is a `Stream` with the elements "B", "A", "C" and "B" but, when closed, will print out the text "The Stream was closed".

### mapToInt
``` java
    Stream.of("B", "A", "C" , "B")
        .mapToInt(s -> s.hashCode())
```
is an `IntStream` with the `int` elements 66, 65, 67 and 66. (A is 65, B is 66 and so on)

### mapToLong
``` java
    Stream.of("B", "A", "C", "B")
        .mapToLong(s -> s.hashCode() * 1_000_000_000_000l)
```
is a `LongStream` with the `long` elements 66000000000000, 65000000000000, 67000000000000 and 66000000000000.

### mapToDouble
``` java
    Stream.of("B", "A", "C", "B")
        .mapToDouble(s -> s.hashCode() / 10.0)
```
is a `DoubleStream` with the `double` elements 6.6, 6.5, 6.7 and 6.6.

### flatMapToInt
``` java
    Stream.of(
        IntStream.of(1, 2),
        IntStream.of(3, 4)
    )
        .flatMapToInt(s -> s.map(i -> i + 1))
```
is an `IntStream` with the `int` elements 2, 3, 4 and 5 because the two `IntStream`s where flattened to one stream whereby 1 was added to each element.

### flatMapToLong
``` java
    Stream.of(
        LongStream.of(1, 2),
        LongStream.of(3, 4)
    )
        .flatMapToLong(s -> s.map(i -> i + 1))
```
is a `LongStream` with the `long` elements 2, 3, 4 and 5 because the two `LongStream`s where flattened to one stream whereby 1 was added to each element.

### flatMapToDouble
``` java
    Stream.of(
        LongStream.of(1.0, 2.0),
        LongStream.of(3.0, 4.0)
    )
        .flatMapToDouble(s -> s.map(i -> i + 1))
```
is a `DoubleStream` with the `double` elements 2.0, 3.0, 4.0 and 5.0 because the two `DoubleStream`s where flattened to one stream whereby 1 was added to each element.


### boxed
``` java
    IntStream.of(1, 2, 3, 4)
        .boxed()
```
is a `Stream` with the `Integer` elements 1, 2, 3 and 4 because the original `int` elements were boxed to their corresponding `Integer` elements.

### asLongStream
``` java 
     IntStream.of(1, 2, 3, 4)
        .asLongStream()
 ```
is a `LongStream` with the `long` elements 1, 2, 3 and 4 because the original `int` elements were converted to `long` elements.

### asDoubleStream
``` java
    IntStream.of(1, 2, 3, 4)
        .asDoubleStream()
```
is a `DoubleStream` with the `double` elements 1.0, 2.0, 3.0 and 4.0 because the original `int` elements were converted to `double` elements.

### takeWhile (Java 9 only)
``` java
    Stream.of("B", "A", "C", "B")
        .takeWhile(s -> "B".compareTo(s) >= 0)
```
is a `Stream` with the elements "B" and "A" because when "C" in encountered in the stream, that element and all following are dropped.

### dropWhile (Java 9 only)
``` java
    Stream.of("B", "A", "C", "B")
        .dropWhile(s -> "B".compareTo(s) >= 0)
```
is a `Stream` with the elements "C" and "B" because elements are dropped from the stream but when "C" in encountered, subsequent elements are not dropped.


This completes the example list of *intermediate operation* examples.


## Terminal Operations
A *terminal operations* starts the `Stream` and returns a result that depends on the `Stream` pipeline and content. For example, `collect` is a *terminal operation* because we cannot add additional operation to a `Stream` pipeline after `collect` has been called.

### Common Operations
Here are some of the *terminal operations* that can be accepted by a `Stream`:

| Operation         | Parameter(s)         | Action
| :------------     | :------------------- | :----------------------------------------------------- |
| `forEach`         | `Consumer`           | Performs the given `Consumer` action for each element in the stream in any order
| `forEachOrdered`  | `Consumer`           | Performs the given `Consumer` action for each element in the stream in stream order
| `collect`         | `Collector`          | Returns a reduction of the elements in the stream. For example a `List`, `Set` or a `Map`
| `min`             | `Comparator`         | Returns the smallest element (as determined by the provided `Comparator`) in the stream (if any)
| `max`             | `Comparator`         | Returns the biggest element (as determined by the provided `Comparator`) in the stream (if any)
| `count`           | -                    | Returns the number of elements in the stream
| `anyMatch`        | `Predicate`          | Returns whether at least one element in this stream matches the provided `Predicate`
| `allMatch`        | `Predicate`          | Returns whether all elements in this stream match the provided `Predicate`
| `noneMatch`       | `Predicate`          | Returns whether no elements in this stream match the provided `Predicate`
| `findFirst`       | -                    | Returns the first element in this stream (if any)
| `findAny`         | -                    | Returns any element in this stream (if any)
| `toArray`         | -                    | Returns an array containing all the elements in this stream
| `toArray`         | `IntFunction`        | Returns an array containing all the elements in this stream whereby the array is created using the provided `IntFunction`.

### Less Common Operations

Here is a list of other *terminal operations* that are a bit less commonly used by at least some programmers:

| Operation         | Parameter(s)         | Action
| :------------     | :------------------- | :----------------------------------------------------- |
| `collect`         | `Supplier, BiCOnsumer, BiConsumer`   | Returns a reduction of the elements in the stream starting with an empty reduction (e.g. an empty `List`) obtained from the `Supplier` and then applying the first `BiConsumer` for each element and at the end, combining using the second `BiConsumer`.
| `reduce`          | `T, BinaryOperation` | Using a first `T` and then subsequently applying a `BinaryOperation` for each element in the stream, returns the value of the last value (reduction)
| `reduce`          | `BinaryOperation`    | By subsequently applying a `BinaryOperation` for each element in the stream, returns the value of the last value (reduction)
| `reduce`          | `T, BiFunction, BinaryOperator`          | In parallel, using  first values `T` and then subsequently applying a `BiFunctionn` for each element in the stream, returns the value of the last values combined using the combining `BinaryOperator`
| `iterator`        | -                    | Returns an `Iterator` of all the values in this stream.
| `spliterator`     | -                    | Returns a `Spliterator` with all the values in this stream.


### Primitive Stream Operations

Primitive streams (like `IntStream` and `LongStream`) provide similar functionality as ordinary streams but usually the parameter count and types differ so that primitive streams can accept more optimized function variants.
Here is a list of additional *terminal operations* that are available for primitive Streams:

| Operation         | Parameter(s)         | Action
| :------------     | :------------------- | :----------------------------------------------------- |
| `sum`             | -                    | Returns a reduction of the elements which is the sum of all elements in the stream.
| `average`         | -                    | Returns a reduction of the elements which is the average of all elements in the stream (if any).
| `summaryStatistics`| -                    | Returns a reduction of the elements which is a summary of a number of statistic measurements (min, max, sum, average and count)


Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information.

## Terminal Operations Examples

Here is a list with examples for many of the *terminal operations*. The source code for the examples below with *terminal operations* can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/stream_fundamentals/TerminalOperations.java)

### forEach
``` java
     Stream.of("B", "A", "C" , "B")
        .forEach(System.out::print);
```
might output "CBBA". However, it has to be said that most stream implementation actually *would* output "BACB" but there is no guarantee of a particular order using `forEach`.

### forEachOrdered
``` java
     Stream.of("B", "A", "C" , "B")
        .forEachOrdered(System.out::print);
```
outputs "BACB" (*always* as opposed to `forEach`)

### collect
``` java
     Stream.of("B", "A", "C" , "B")
        .collect(Collectors.toList());
```
Returns a `List<String>` equal to ["B", "A", "C", "B"]

``` java
     Stream.of("B", "A", "C" , "B")
        .collect(Collectors.toSet());
```
Returns a `Set<String>` equal to ["A", "B", "C"]

``` java
    Stream.of("I", "am", "a", "stream")
        .collect(Collectors.toMap(
            s -> s.toLowerCase(), // Key extractor
            s -> s.length())      // Value extractor
        )
```
Returns a `Map<String, Integer>` equal to {a=1, stream=6, i=1, am=2}. Thus, the `Map` contains a mapping from a word (key) to how many characters that word has (value).


### min
``` java
     Stream.of("B", "A", "C" , "B")
        .min(String::compareTo);
```
returns `Optional[A]` because "A" is the smallest element in the stream.

``` java
    Stream.<String>empty()
        .min(String::compareTo);
```
returns `Optional.empty` because there is no min value because the stream is empty.

### max
``` java
     Stream.of("B", "A", "C" , "B")
        .max(String::compareTo);
```
returns `Optional[C]` because "C" is the largest element in the stream.

``` java
    Stream.<String>empty()
        .max(String::compareTo);
```
returns `Optional.empty` because there is no max value because the stream is empty.

### count
``` java
     Stream.of("B", "A", "C" , "B")
        .count();
```
returns 4 because there are four elements in the stream.

``` java
    Stream.empty()
        .count();
```
returns 0 because there are no elements in an empty stream.

### anyMatch
``` java
    Stream.of("B", "A", "C", "B")
        .anyMatch("A"::equals);
```
returns `true` because there is an "A" element in the stream.
``` java
    Stream.of("B", "A", "C", "B")
        .anyMatch("Z"::equals);
```
returns `false` because there are no "Z" elements in the stream.

### noneMatch
``` java
    Stream.of("B", "A", "C", "B")
        .noneMatch("A"::equals);
```
returns `false` because there is an "A" element in the stream.
``` java
    Stream.of("B", "A", "C", "B")
        .noneMatch("Z"::equals);
```
returns `true` because there are no "Z" elements in the stream.

### findFirst
``` java
    Stream.of("B", "A", "C", "B")
        .findFirst();
```
returns `Optional[B]` because "B" is the first element in the stream.

``` java
    Stream.<String>empty()
        .findFirst();
```
returns `Optional.empty` because the stream is empty.

### findAny
``` java
    Stream.of("B", "A", "C", "B")
        .findAny();
```
might return `Optional[C]` or any other element in the stream.

``` java
    Stream.<String>empty()
        .findFirst();
```
returns `Optional.empty` because the stream is empty.

### toArray
``` java
    Stream.of("B", "A", "C", "B")
        .toArray();
```
Returns an array containing [B, A, C, B] the array being created automatically by the `toArray` operator.
``` java
    Stream.of("B", "A", "C", "B")
        .toArray(String[]::new)
```
Returns an array containing [B, A, C, B] that will be created by the provided constructor, for example using the equivalent to `new String[4]`.

### collect with 3 Parameters
``` java
            Stream.of("B", "A", "C", "B")
                                .collect(
                    () -> new StringBuilder(),
                    (sb0, sb1) -> sb0.append(sb1),
                    (sb0, sb1) -> sb0.append(sb1)
                )
```
Returns a `StringBuilder` containing "BACB" that will be created by the provided supplier and then built up by the append lambdas.


### reduce
``` java
    Stream.of(1, 2, 3, 4)
        .reduce((a, b) -> a + b)
```
Returns the value of `Optional[10]` because 10 is the sum of all `Integer` elements in the stream. If the stream is empty, `Optional.empty()` is returned.

``` java
    Stream.of(1, 2, 3, 4)
        .reduce(100, (a, b) -> a + b)
```
Returns the value of 110 because we start with 100 and the add all the `Integer` elements in the stream. If the stream is empty, 100 is returned.
``` java
    Stream.of(1, 2, 3, 4)
        .parallel()
        .reduce(
            0, 
            (a, b) -> a + b,
            (a, b) -> a + b
        )
```
Returns the value of 10 because we start with 0 and the add all the `Integer` elements in the stream. The stream can be executed i parallel whereby the last lambda will be used to combine results from each thread. If the stream is empty, 0 is returned.


### iterator
``` java
    Iterator<String> iterator
        = Stream.of("B", "A", "C", "B")
            .iterator();
```
Creates a new `Iterator` over all the elements in the Stream.

### spliterator
``` java
    Spliterator<String> spliterator
        = Stream.of("B", "A", "C", "B")
            .spliterator();
```
Creates a new `Spliterator` over all the elements in the Stream.

### sum
``` java
    IntStream.of(1, 2, 3, 4)
        .sum()
```
Returns 10 because 10 is the sum of all elements in the stream.

### average
``` java
    IntStream.of(1, 2, 3, 4)
        .average()
```
Returns `OptionalDouble[2.5]` because 2.5 is the average of all elements in the stream. If the stream is empty, `OptionalDouble.empty()` is returned.

### summaryStatistics
``` java
    IntStream.of(1, 2, 3, 4)
        .summaryStatistics()
```
Returns `IntSummaryStatistics{count=4, sum=10, min=1, average=2.500000, max=4}`. If the stream is empty, `IntSummaryStatistics{count=0, sum=0, min=2147483647, average=0.000000, max=-2147483648}` is returned (N.B. max is initially set to Integer.MIN_VALUE which is -2147483648).


## Other Operations
There are also a small number of other operations that are neither a *intermediate operation* nor a *terminal operation* as shown in the table below:

| Operation         | Action
| :------------     | :----------------------------------------------------- |
| `isParallel`      | Returns `true` if the Stream is parallel, else `false`
| `close`           | Closes the `Stream` and releases all its resources (if any)


Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information.

## Other Operations Examples

Here is a list with example of other operations. The source code for the examples below with other operations can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/stream_fundamentals/OtherOperations.java)

### isParallel
``` java
    Stream.of("B", "A", "C", "B")
        .parallel()
        .isParallel()
```
Returns `true` because the Stream is parallel.
``` java
    Stream.of("B", "A", "C", "B")
        .sequential()
        .isParallel()
```
Returns `false` because the Stream is *not* parallel.
### close
``` java
    Stream<String> stream = Stream.of("B", "A", "C", "B");
    stream.forEachOrdered(System.out::println);
    stream.close();
```
Prints all elements in the stream and then closes the stream. Some streams (e.g. streams from files) need to be closed to release their resources. Use the try-with-resource patterns if the stream must be closed:
``` java
    try (Stream<String> s = Stream.of("B", "A", "C", "B")) {
        s.forEachOrdered(System.out::println);
    }
```

## Examples

In the examples below we are working with entities of type `User`. The `User` class looks like this:

``` java 
    static class User {

        private static final List<String> CARS = Arrays.asList("Toyota", "Volvo", "Tesla", "Fiat", "Ford");

        private final int id;

        public User(int id) {
            this.id = id;
        }

        public int getId() {
            return id;
        }

        public String getName() {
            return "Name" + id;
        }

        public String getPassword() {
            return "PW" + (id ^ 0x7F93A27F);
        }

        public String getFavoriteCar() {
            return CARS.get(id % CARS.size());
        }

        public int getBornYear() {
            return 1950 + id % 50;
        }

        @Override
        public String toString() {
            return String.format(
                "{id=%d, name=%s, password=%s, favoriteCar=%s, bornYear=%d}",
                getId(),
                getName(),
                getPassword(),
                getFavoriteCar(),
                getBornYear()
            );
        }

        @Override
        public boolean equals(Object obj) {
            if (!(obj instanceof User)) {
                return false;
            }
            User that = (User) obj;
            return this.id == that.id;
        }

        @Override
        public int hashCode() {
            return id;
        }

    }

```
As can be seen, users are really not real users but instead they are synthetically generated from the user id. Because the id defines all other fields, we use a "trick" and whereby we only need to use the id field in the `equals` and `hashCode` methods.

The first users will thus be:

| id  | User                                                                         |
| :-- | :--------------------------------------------------------------------------- |
| 0   | {id=0, name=Name0, password=PW346289151, favoriteCar=Toyota, bornYear=1950}  |
| 1   | {id=1, name=Name1, password=PW1420030975, favoriteCar=Volvo, bornYear=1951}  |
| 2   | {id=2, name=Name2, password=PW883160063, favoriteCar=Tesla, bornYear=1952}   |
| 3   | {id=3, name=Name3, password=PW1956901887, favoriteCar=Fiat, bornYear=1953}   |
| 4   | {id=4, name=Name4, password=PW77853695, favoriteCar=Ford, bornYear=1954}     |
| 5   | {id=5, name=Name5, password=PW1151595519, favoriteCar=Toyota, bornYear=1955} |
| ... | ...                                                                          |

There is also a `UserManager` that provides a static stream method that will return a `Stream<User>` that contains 1000 elements (with user ids in the range 0 to 999). The `UserManager` class is shown hereunder:
``` java
    static class UserManager {
        static Stream<User> stream() {
            return IntStream.range(0, 1000)
                .mapToObj(User::new);
        }
    }
```
Note how the stream method creates an `IntStream` with elements from 0 to 999 and then maps each `int` element to a `User` object using the `User` constructor that takes an `int` as an argument.


### Count the Number of Ford Likers
In this example, we want to count the number of users that like Ford. Here is one way of doing it:
``` java
    long count = UserManager.stream()
        .filter(u -> "Ford".equals(u.getFavoriteCar()))
        .count();

        System.out.format("There are %d users that supports Ford %n", count);
```
The code above will produce:
``` text
There are 200 users that supports Ford 
```

### Calculate Average Age
In this example, we want to calculate the average age of the users that like Tesla. Here is a solution assuming that the current year is 2017:
``` java
    OptionalDouble avg = UserManager.stream()
        .filter(u -> "Tesla".equals(u.getFavoriteCar()))
        .mapToInt(u -> 2017 - u.getBornYear()) // Calculates the age
        .average();

    if (avg.isPresent()) {
        System.out.format("The average age of Tesla likers are %d years %n", avg.getAsDouble());
    } else {
        System.out.format("There are no Tesla lovers");
    }
```
The code above will produce:
``` text
The average age of Tesla likers are 42.500000 years
```

### Find the Youngest Volvo Digger
Here we want to locate the youngest Volvo digger. The solution below sorts all users in bornYear order and then picks the first one. Is there another solution without sort?
``` java
Comparator<User> comparator = Comparator.comparing(User::getBornYear).reversed();
        
    Optional<User> youngest = UserManager.stream()
        .filter(u -> "Volvo".equals(u.getFavoriteCar()))
        .sorted(comparator)
        .findFirst();

    youngest.ifPresent(u
        -> System.out.println("Found the youngest Volvo digger which is :" + u.toString())
    );
```
This will produce the following output:
``` text
Found the youngest Volvo digger which is :{id=46, name=Name46, password=PW782496767, favoriteCar=Volvo, bornYear=1996}
```

### Collect a Stream in a List
In this example, we want to collect all users that love Fiat in a List. This can be done like this:
``` java
        List<User> fiatLovers = UserManager.stream()
            .filter(u -> "Fiat".equals(u.getFavoriteCar()))
            .collect(Collectors.toList());

        System.out.format("There are %d fiat lovers %n", fiatLovers.size());
```
The code above will produce:
``` text
There are 200 fiat lovers
```

### Element Flow
In the example below, the flow of elements and the different operations in the stream's pipeline are examined. We create a `Stream` with five names and then `filter` out only those having a name that starts with the letter "A". After that, we `sort` the remaining names and then we `map` the names to lower case. Finally, we print out the elements that have passed through the entire pipeline. In each operation we have inserted print statements so that we may observe what each operation is actually doing in the `Stream`:
``` java
    Stream.of("Bert", "Alice", "Charlie", "Assian", "Adam")
        .filter(s -> {
            String required = "A";
            boolean result = s.startsWith(required);
            System.out.format("filter        : \"%s\".startsWith(\"%s\") is %s (%s) %n", s, required, result, result ? "retained" : "dropped");
            return result;
        })
        .sorted((s1, s2) -> {
            int result = s1.compareTo(s2);
            System.out.format("sort          : compare(%s, %s) is %d (%s)%n", s1, s2, result, result < 0 ? "not swapped" : "swapped");
            return result;
        })
        .map(s -> {
            String result = s.toLowerCase();
            System.out.format("map           : %s -> %s %n", s, result);
            return result;
        })
        .forEachOrdered(s
            -> System.out.println("forEachOrdered: " + s)
        );
```
This will print:
``` text
filter        : "Bert".startsWith("A") is false (dropped) 
filter        : "Alice".startsWith("A") is true (retained) 
filter        : "Charlie".startsWith("A") is false (dropped) 
filter        : "Assian".startsWith("A") is true (retained) 
filter        : "Adam".startsWith("A") is true (retained) 
sort          : compare(Assian, Alice) is 7 (swapped)
sort          : compare(Adam, Assian) is -15 (not swapped)
sort          : compare(Adam, Assian) is -15 (not swapped)
sort          : compare(Adam, Alice) is -8 (not swapped)
map           : Adam -> adam 
forEachOrdered: adam
map           : Alice -> alice 
forEachOrdered: alice
map           : Assian -> assian 
forEachOrdered: assian
```
So, in the end, the stream delivered the elements "adam", "alice" and "assian" as expected. Note how `sort` needs to retrieve all the element via the `filter` stage before it can emit result to the next stage. On the contrary, the last steps are executed in pipeline order because both `map` and `forEachOrdered` can process a stream element one at a time.

{% include prev_next.html %}

