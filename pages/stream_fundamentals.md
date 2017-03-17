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
Speedment is all about Java 8 {{site.data.javadoc.Stream}}s so if you are not familiar with the concept of `Stream`s, I encourage you to read this chapter carefully. If you consider yourself a `Stream` expert, feel free to skip directly to the next chapter.

A Java 8 `Stream` is an `interface` with implementations that supports a functional style operation on streams of elements. The entire Java Collection framework was retrofitted with `Stream` support in Java 8.

Streams can be used to express a kind of "recipe" style of operations, allowing us to compose a number of function and only when the `Stream` is started, the functions are applied to the elements in the `Stream`. This means that `Streams` can be very efficient and general. A `Stream` recipe says *what to do* but generally *not how to do it* which is good from an abstraction point of view.

Consider the following simple example:

``` java
    List<String> names = Arrays.asList("Zlatan", "Tim", "Bo", "George", "Adam", "Oscar");
    List<String> longNames = names.stream()
        .filter(n -> n.length() > 2)     // Retains only those Strings that are longer than 2 characters (i.e. "Bo" is dropped)
        .sorted()                        // Sorts the remaining Strings in natural order
        .collect(Collectors.toList());   // Collects the remaining sorted Strings in a List
```
First, we create an initial `List` called `names` with all the name candidates we have. The names are in no particular order and the `List` is only used as a source for a `Stream` in the example.

Then we create a `Stream` using the statement `names.stream()`. Note that nothing happens with the `Stream` at this point. We just have
a stream that we can use to further build our "recipe" around. Now that we have a `Stream`, we add a `filter` that only lets through Strings
that are longer than 2 characters. Again, the `Stream` is not started, we have just said that *when* the `Stream` starts, we want to filter
the Strings. Next, we add a `sorted()` operation to our `Stream` recipe. This means that when the `Stream` is started, all Strings that
passes the `filter` shall be sorted in natural order. Again, nothing is flowing through the `Stream`, we have just added yet an operation
to the `Stream` recipe (the stream recipe can more formally be called a *stream pipeline*). The last operation we add to the `Stream` recipe is `collect`. 
This operation is different to all the previous operations in the way that it is a *terminal operation*. 
Whenever a *terminal operation* is applied to a `Stream`, the `Stream` cannot accept additional operations to its pipeline. It also means that
the `Stream` is started.

It shall be noted that elements in a `Stream` are pulled by the *terminal operation* (i.e. the `collect` operation) and not pushed by the stream source.
So, `Collect` will ask for the first element and that request will traverse up to the stream source that will provide the first element "Zlatan".
The `fiter` operation will check if the length of "Zlatan" is greater than two (which it is) and will then propagate "Zlatan" to the `sorted` operation.
Because the `sorted` operation needs all strings before it can decide on its output order, it will ask the stream source for all its remaining elements
which, via the filter, is sent down the stream. Once all stings are received by the `sorted` operator, it will sort the strings and then output
its first element (i.e. "Adam") to the `collect` operation. The result of the entire stream statement will thus be:

``` shell
"Adam", "George", "Oscar", "Tim", "Zlatan"
```

Speedment provide the same semantics but for database tables, allowing us to view database tables as pure Java 8 streams. 
Because a Java 8 Stream is an interface, Speedment can select from a variety of different implementations of a Stream depending 
on the pipeline we are setting up and other factors.


### Intermediate Operations
An *intermediate operations* is an operation that allows further operations to be added to a `Stream`. For example, `filter` is an *intermediate operation* because we can add additional operations to a `Stream` pipeline after `filter` has been applied to the `Stream`.
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

There are also a number of *intermediate operations* that controls the properties of the `Stream` and has no effect on its actual content. These are:

| Operation         | Parameter          | Returns a `Stream` that:
| :------------     | :----------------- | :----------------------------------------------------- |
| `parallel`        | -                  | is parallel (not sequential)
| `sequential`      | -                  | is sequential (not parallel)
| `unordered`       | -                  | is unordered (data might appear in any order)
| `onClose`         | `Runnable`         | will run the provided `Runnable` when closed


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

Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information. Here are some examples of streams with *intermediate operations*:


Here is a list with examples for many of the  *intermediate operations*:

#### filter
``` java
    Stream.of("B", "A", "C" , "B")
        .filter(s -> s.equals("B")
```
returns a `Stream` with the elements "B" and "B".

#### map
``` java
    Stream.of("B", "A", "C" , "B")
        .map(s -> s.toLowerCase())
```
is a `Stream` with the elements "b", "a", "c" and "b".

#### distinct
``` java
    Stream.of("B", "A", "C" , "B")
        .distinct()
```
is a `Stream` with the elements "B", "A" and "C".

#### sorted
``` java
    Stream.of("B", "A", "C" , "B")
        .sorted()
```
returns a `Stream` with the elements "A", "B", "B" and "C".

``` java
    Stream.of("B", "A", "C" , "B")
        .sorted(Comparator.reverseOrder())
```
is a `Stream` with the elements "C", "B", "B" and "A".

#### limit
``` java
    Stream.of("B", "A", "C" , "B")
        .limit(2)
```
is a `Stream` with the elements "B" and "A".
#### skip
``` java
    Stream.of("B", "A", "C" , "B")
        .skip(1)
```
is a `Stream` with the elements "A", "C" and "A".

#### flatMap
``` java
    Stream.of(
        Stream.of("B", "A"),
        Stream.of("C", "B")
    )
    .flatMap(Function.identity())
```
returns a `Stream` with the elements "B", "A", "C" and "B". The two streams (that each contain two elements) are "flattened" to a single `Stream` with four elements.

#### peek
``` java
    Stream.of("B", "A", "C" , "B")
        .peek(System.out::print)
```
is a `Stream` with the elements "B", "A", "C" and "B" but, when consumed in its entirety, will print out the text "BACB".

#### parallel
``` java
    Stream.of("B", "A", "C" , "B")
        .parallel()
```
is a `Stream` with the elements "B", "A", "C" and "B" but, when consumed, elements in the `Stream` may be propagated through the pipeline using different `Thread`s.

#### sequential
``` java
    Stream.of("B", "A", "C" , "B")
        .parallel()
        .sequential()
```
is a `Stream` with the elements "B", "A", "C" and "B" that is not parallel.

#### unordered
``` java
    Stream.of("B", "A", "C" , "B")
        .unordered()
```
is a `Stream` with the given elements but in no particular order, so when consumed, elements might be encountered in any order, for example in the order "C", "B", "B", "A".

#### onClose
``` java
    Stream.of("B", "A", "C" , "B")
        .onClosed(() -> System.out.println("The Stream was closed")
```
is a `Stream` with the elements "B", "A", "C" and "B" but, when closed, will print out the text "The Stream was closed".

#### mapToInt
``` java
    Stream.of("B", "A", "C" , "B")
        .mapToInt(s -> s.hashCode())
```
is an `IntStream` with the `int` elements 66, 65, 67 and 66.

#### mapToLong
``` java
    Stream.of("B", "A", "C", "B")
        .mapToLong(s -> s.hashCode() * 1_000_000_000_000l)

```
is a `LongStream` with the `long` elements 66000000000000, 65000000000000, 67000000000000 and 66000000000000.

#### mapToDouble
``` java
    Stream.of("B", "A", "C", "B")
        .mapToDouble(s -> s.hashCode() / 10.0)

```
is a `DoubleStream` with the `double` elements 6.6, 6.5, 6.7 and 6.6.

#### flatMapToInt
``` java
    Stream.of(
        IntStream.of(1, 2),
        IntStream.of(3, 4)
    )
        .flatMapToInt(s -> s.map(i -> i + 1))
```
is an `IntStream` with the `int` elements 2, 3, 4 and 5.

#### flatMapToLong
``` java
    Stream.of(
        LongStream.of(1, 2),
        LongStream.of(3, 4)
    )
        .flatMapToLong(s -> s.map(i -> i + 1))
```
is a `LongStream` with the `long` elements 2, 3, 4 and 5.

#### flatMapToDouble
``` java
    Stream.of(
        LongStream.of(1.0, 2.0),
        LongStream.of(3.0, 4.0)
    )
        .flatMapToDouble(s -> s.map(i -> i + 1))
```
is a `DoubleStream` with the `double` elements 2.0, 3.0, 4.0 and 5.0.

This completes the example list of *intermediate operations*.


### Terminal Operations
A *terminal operations* starts the `Stream` and returns a result that depends on the `Stream` pipeline and content. For example, 'collect' is a *terminal operation* because we cannot add additional operation to a `Stream` pipeline after `collect` has been called.
Here are some of the *terminal operations* that can be accepted by a `Stream`:


| Operation         | Parameter(s)         | Action
| :------------     | :------------------- | :----------------------------------------------------- |
| `forEach`         | `Consumer`           | Performs the given `Consumer` action for each element in the stream in any order
| `forEachOrdered`  | `Consumer`           | Performs the given `Consumer` action for each element in the stream in stream order
| `collect`         | `Collector`          | Returns a reduction of the elements in the stream. For example a `List`, `Set` or a `Map`
| `min`             | `Comparator`         | Returns the smallest element (as determined by the provided `Comparator`) in the stream (if any)
| `max`             | `Comparator`         | Returns the biggest element (as determined by the provided `Comparator`) in the stream (if any)
| `count`           | -                    | Returns the number of element in the stream
| `anyMatch`        | `Predicate`          | Returns whether at least one element in this stream match the provided `Predicate`
| `allMatch`        | `Predicate`          | Returns whether all elements in this stream match the provided `Predicate`
| `noneMatch`       | `Predicate`          | Returns whether no elements in this stream match the provided `Predicate`
| `findFirst`       | -                    | Returns the first element in this stream (if any)
| `findAny`         | -                    | Returns any element in this stream (if any)
| `toArray`         | -                    | Returns an array containing all the elements in this stream
| `toArray`         | `IntFunction`        | Returns an array containing all the elements in this stream whereby the array is created using the provided `IntFunction`


Here is a list of other *terminal operations* that are a bit more complicated:

| Operation         | Parameter(s)         | Action
| :------------     | :------------------- | :----------------------------------------------------- |
| `collect`         | `Supplier, BC, BC`   | Returns a reduction of the elements in the stream starting with an empty reduction (e.g. an empty `List`) obtained from the `Supplier` and then applying the first `BiFunction` (BF) for each element and at the end, combining using the second `BiConsumer`.
| `reduce`          | `T, BinaryOperation` | Using a first `T` and then subsequently applying a `BinaryOperation` for each element in the stream, returns the value of the last value (reduction)
| `reduce`          | `BinaryOperation`    | By subsequently applying a `BinaryOperation` for each element in the stream, returns the value of the last value (reduction)
| `reduce`          | `T, BO, CO`          | In parallel, using  first values `T` and then subsequently applying a `BinaryOperation` (BO) for each element in the stream, returns the value of the last values combined using the `CO`
| `iterator`        | -                    | Returns an `Iterator` of all the values in this string.
| `spliterator`     | -                    | Returns a `Spliterator` with all the values in this string.


### Other Operations
There are also a small number of other operations that are neither a *intermediate operation* nor a *terminal operation* as shown in the table below:

| Operation         | Action
| :------------     | :----------------------------------------------------- |
| `isParallel()`    | Returns `true` if the Stream is parallel, else `false`
| `close`           | Closes the `Stream` and releases all its resources (if any)

Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information.

Here is a list with examples for many of the  *intermediate operations*:

#### forEach
``` java
     Stream.of("B", "A", "C" , "B")
        .forEach(System.out::print);
```
might output "CBBA".

#### forEachOrdered
``` java
     Stream.of("B", "A", "C" , "B")
        .forEachOrdered(System.out::print);
```
outputs "BACB"

#### collect
``` java
     Stream.of("B", "A", "C" , "B")
        .collect(Colectors.toList());
```
Returns a `List<String>` equal to `["B", "A", "C", "B"]`

``` java
     Stream.of("B", "A", "C" , "B")
        .collect(Colectors.toSet());
```
Returns a `Set<String>` equal to `["A", "B", "C"]`

``` java
    Stream.of("I", "am", "a", "stream")
        .collect(Collectors.toMap(
            s -> s.toLowerCase(), // Key extractor
            s -> s.length())      // Value extractor
        )
```
Returns a `Map<String, Integer>` equal to `{a=1, stream=6, i=1, am=2}`


#### min
``` java
     Stream.of("B", "A", "C" , "B")
        .min(String::compareTo);
```
returns `Optional[A]`

``` java
    Stream.<String>empty()
        .min(String::compareTo);
```
returns `Optional.empty`

#### max
``` java
     Stream.of("B", "A", "C" , "B")
        .max(String::compareTo);
```
returns `Optional[C]`

``` java
    Stream.<String>empty()
        .max(String::compareTo);
```
returns `Optional.empty`

#### count
``` java
     Stream.of("B", "A", "C" , "B")
        .count();
```
returns 4

``` java
    Stream.empty()
        .count();
```
returns 0

#### anyMatch
``` java
    Stream.of("B", "A", "C", "B")
        .anyMatch("A"::equals);
```
returns `true`
``` java
    Stream.of("B", "A", "C", "B")
        .anyMatch("Z"::equals);
```
returns `false`

#### noneMatch
``` java
    Stream.of("B", "A", "C", "B")
        .noneMatch("A"::equals);
```
returns `false`
``` java
    Stream.of("B", "A", "C", "B")
        .noneMatch("Z"::equals);
```
returns `true`

#### findFirst
``` java
    Stream.of("B", "A", "C", "B")
        .findFirst();
```
returns "B"

#### findAny
``` java
    Stream.of("B", "A", "C", "B")
        .findFirst();
```
might return "C"

#### toArray
``` java
    Stream.of("B", "A", "C", "B")
        .toArray();
```
Returns an array containing [B, A, C, B]
``` java
    Stream.of("B", "A", "C", "B")
        .toArray(String[]::new)
```
Returns an array containing [B, A, C, B] that was created by the provided constructor `new String[4]`

## Examples

``` java
    Stream.of("Bert", "Alice", "Charlie", "Assian", "Adam")
       .filter(s -> {
            String required = "A";
            boolean result = s.startsWith(required);
            System.out.format("filter : %s startsWith(\"%s\") is %s (%s) %n", s, required, result, result ? "retained" : "dropped");
            return result;
        })
        .sorted((s1, s2) -> {
            int result = s1.compareTo(s2);
            System.out.format("sort   : compare(%s, %s) is %d (%s)%n", s1, s2, result, result < 0 ? "not swapped" : "swapped");
            return result;
        })
        .map(s -> {
            String result = s.toLowerCase();
            System.out.format("map    : %s -> %s %n", s, result);
            return result;
        })
        .forEach(s
            -> System.out.println("forEach: " + s)
        );
```
will print:
``` text
filter : Bert startsWith("A") is false (dropped) 
filter : Alice startsWith("A") is true (retained) 
filter : Charlie startsWith("A") is false (dropped) 
filter : Assian startsWith("A") is true (retained) 
filter : Adam startsWith("A") is true (retained) 
sort   : compare(Assian, Alice) is 7 (swapped)
sort   : compare(Adam, Assian) is -15 (not swapped)
sort   : compare(Adam, Assian) is -15 (not swapped)
sort   : compare(Adam, Alice) is -8 (not swapped)
map    : Adam -> adam 
forEach: adam
map    : Alice -> alice 
forEach: alice
map    : Assian -> assian 
forEach: assian
```
So, in the end, the stream delivered the elements "adam", "alice" and "assian" as expected. Note how `sort` needs to retrieve all the element via the `filter' stage before it can emit result to the next stage.

{% include prev_next.html %}

