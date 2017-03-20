---
permalink: comparator.html
sidebar: mydoc_sidebar
title: Speedment Comparator
keywords: Comparator, Stream
toc: false
Tags: Stream, Comparator
previous: comparator.html
next: comparator.html
---

{% include prev_next.html %}

## What is a Comparator

A `Comparator` is... 


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


## Comparators

### Comparable Comparators
The following additional methods are available to a `ComparableField` that is
always associated to a `Comparable` field (e.g. Integer, String, Date, Time etc.).
Comparable fields can be tested for equality and can also be compared to other
 objects of the same type.
In the table below, the "Outcome" is a `Comparator<ENTITY>` that when compared with 
an object of type `ENTITY` will return TBW

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| comparator   | N/A       | the field is null                                      |



### Primitive Comparators
TBW

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| comparator   | N/A       | the field is null                                      |


{% include prev_next.html %}
