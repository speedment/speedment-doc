---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
Tags: Stream
---

## Predicate and Fields

A `Predicate` is... A Field is ...

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


## Object Predicates

The following methods are available to all `Field`s. In the table below, The "Outcome" is 
a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will 
return `true`if and only if:

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| isNull       | N/A       | the field is null                                      |
| isNotNull    | N/A       | the field is not null                                  |

A `Field` implement the interface `HasReferenceOperators<ENTITY>`.

## Comparable Predicates
The following additional methods are available to a `ComparableField` that is
always associated to a `Comparable` field (e.g. Integer, String, Date, Time etc.).
Comparable fields can be tested for equality and can also be compared to other
 objects of the same type.
In the table below, the "Outcome" is a `Predicate<ENTITY>` that when tested with an object of
 type `ENTITY` will return `true`if and only if:

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| isNull       | N/A       | the field is null                                      |
| isNotNull    | N/A       | the fiels is not null                                  |


Predicate Builders for Comparable fields implement the interfaces 
`HasReferenceOperators<ENTITY>`and `HasComparableOperators<ENTITY>`.

## String Predicates
The following additional methods (over Comparable) are available to a `PredicateBuilder` that is associated
to a `String` field.

| Method       | Parameter | Outcome                                                |
| :----------  | :-------- | :----------------------------------------------------- |
| isNull       | N/A       | the field is null                                      |
| isNotNull    | N/A       | the fiels is not null                                  |

Predicate Builders for Comparable fields implement the interfaces 
`HasReferenceOperators<ENTITY>`and `HasComparableOperators<ENTITY>` and 
`HasStringOperators<ENTITY>`.

## Primitive Fields
TBW

