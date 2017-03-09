---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
Tags: Stream
---

## Predicate and Predicate Builders

A `Predicate` is... A Predicate Builder is ...

## Examples

Here is an example of how a Predicate Builder can be used in conjuction with
a `User` object:

``` java
    Optional<User> johnSmith = users.stream()
        .filter(User.NAME.equal("John Smith")
        .findAny();
```
In this example, the Predicate Builder's method `User.NAME::equal` creates 
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


## Object Predicates

The following methods are available to all `PredicateBuilder`s.

| Method       | Parameter | Returns a Predicate that when tested returns true when |
| :----------  | :-------- | :----------------------------------------------------- |
| isNull       | N/A       | the field is null                                      |
| isNotNull    | N/A       | the fiels is not null                                  |


## Comparable Predicates
The following methods are available to a `PredicateBuilder` that is associated
to a `Comparable` field (e.g. Integer, String, Date, Time etc.)


## String Predicates
The following methods are available to a `PredicateBuilder` that is associated
to a `String` field.
