---
permalink: stream_fundamentals.html
sidebar: mydoc_sidebar
title: Stream Fundamentals
keywords: Stream
Tags: Stream
---

## What is a Stream?
Speedment is all about `Stream`s so if you are not familiar with the concept of `Stream`s I encourage you to read this chapter carefully. If you consider yourself a `Stream` expert, feel free to skip to the next chapter.

A Java 8 {{site.data.javadoc.Stream}} is an `interface` with implementations that supports a functional style operation on streams of elements. The entire Java Collection framework was retrofitted with `Stream` support in Java 8.

Streams can be used to express a kind of "cook book" style of operations allowing us to compose a number of function and only when the `Stream` is terminated, the functions are applied. This means that `Streams` can be very efficient and general. A `Stream` pipeline says what to do but generally not how to do it which is good from an abstraction point of view.

Consider the following simple example:

``` java
    List<String> names = Arrays.asList("Zlatan", "Tim", "Bo", "George", "Adam", "Oscar");
    List<String> longNames = names.stream()
        .filter(n -> n.length() > 2)     // Retains only those Strings that are longer than 2 characters (i.e. "Bo" is dropped.
        .sorted()                        // Sorts the remaining Strings in natural order
        .collect(Collectors.toList());   // Collects the remaining sorted Strings in a List
```
First, we create an initial `List` called `names` with all the name candidates we have. The names are in no particular order.

Then we create a stream using the statement `names.stream()`. Note that nothing happens with the `Stream` at this point. We just have
a stream that we can use to further build our "recipe" around. Now that we have a `Stream` we add a `filter` that only lets through Strings
that are longer than 2 characters. Again, the `Stream` is not "started", we have just said that *when* the `Stream` starts, we want to filter
the Strings. Next, we add a `sorted()` operation to our `Stream` recipe. This means that when the `Stream` is started, all Strings that
passes the `filter` shall be sorted in natural order. Again, nothing is flowing through the `Stream`, we have just added an additional operation
to the `Stream` recipe (the recipe can more formally be called a *stream pipeline*). The last operation we add to the `Stream` recipe is `collect`. 
This operation is different to all the previous operations in the way that it is a *terminal operation*. 
Whenever a *terminal operation* is applied to a `Stream`, the `Stream` cannot accept additional operations to its pipeline. It also means that
the `Stream` is started.

It shall be noted that elements in a `Stream` are pulled by the *terminal operation* (i.e. the `collect` operation) and not pushed by the stream source.
So, `Collect` will ask for the first element and that request will traverse up to the stream source that will provide the first element "Zlatan".
The `fiter` operation will check if the length of "Zlatan" is greater than two (which it is) and will then propagate "Zlatan" to the `sorted` operation.
Because the `sorted` operation needs all strings before it can decide on its output order, it will ask the stream source for all its remaining elements
which, via the filter, is sent down the stream. Once all stings are received by the `sorted` operator it will sort the strings and then output
its first element (i.e. "Adam") to the `collect` operation. The result of the entire Stream statement will thus be:

``` shell
"Adam", "George", "Oscar", "Tim", "Zlatan"
```

Speedment will provide the same semantics but for database tables, allowing us to view database tables as Java 8 streams. 
Because a Java 8 Stream is an interface, Speedment can select from a variety of different implementations of a Stream depending 
on the pipeline we are setting up.


### Intermediate Operations
An *intermediate operations* is an operation that allows further operations to be added to a Stream. For example, `filter` is an *intermediate operation* because we can add additional operations to a `Stream` pipeline after `filter` has been applied to the `Stream`.
The following *intermediate operations* can be accepted by a `Stream`:

| Operation         | Returns a `Stream` that:
| :------------     | :----------------------------------------------------- |
| `sequential()`      | is sequential (not parallel)
| `parallel()`        | is parallel (not sequential)
| `unordered()`       | is unordered (data might appear in any order)
| `onClose()`         | will run the provided closeHandler when closed

Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information.


### Terminal Operations
A *terminal operations* starts the `Stream` and returns a result that depends on the `Stream` pipeline and content.
The following *terminal operations* can be accepted by a `Stream`:

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| comparator   | N/A       | the field is null                                      |

Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information.

### Other Operations
There are also a small number of of other operations that are neither a *intermediate operation* nor a *terminal operation* as shown in the table below:
| Operation         | Action
| :------------     | :----------------------------------------------------- |
| `isParallel()`      | Returns `true` if the Stream is parallel, else `false`
| `close`             | Closes the `Stream` and releases all its resources (if any)

Please revise the complete {{site.data.javadoc.Stream}} JavaDoc for more information.

## Examples

Here is an example of how a `StringField` can be used in conjuction with
a `User` object:

``` java
    Optional<User> johnSmith = users.stream()
        .filter(User.NAME.equal("John Smith")
        .findAny();
```
In this example, the `StringField`s method `User.NAME::equal` creates 
and returns a `Predicate<User>`that, when tested with a User, will 
return `true` if and only if that User has a name that is equal to "John Smith",
otherwise it will return `false`.

N.B. It would be possible to express the same semantics using a standard lambda:
``` java
    Optional<User> johnSmith = users.stream()
        .filter(u -> "John Smith".equals(u.getName())
        .findAny();
```
but Speedment would not be able to recognize and optimize vanilla lambdas. Instead,
developers are encouraged to use the provided Predicate Builders which, when used,
will always be recognizable by the Speedment query optimizer.


## Comparable Comparators
The following additional methods are available to a `ComparableField` that is
always associated to a `Comparable` field (e.g. Integer, String, Date, Time etc.).
Comparable fields can be tested for equality and can also be compared to other
 objects of the same type.
In the table below, the "Outcome" is a `Comparator<ENTITY>` that when compared with 
an object of type `ENTITY` will return TBW

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| comparator   | N/A       | the field is null                                      |



## Primitive Comparators
TBW

