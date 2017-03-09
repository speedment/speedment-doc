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
and returns a `Predicate<User>` that, when tested with a User, will 
return `true` if and only if that User has a name that is equal to "John Smith",
otherwise it will return `false`.

N.B. It would be possible to express the same semantics using a standard lambda:
``` java
    Optional<User> johnSmith = users.stream()
        .filter(u -> "John Smith".equals(u.getName())
        .findAny();
```
but Speedment would not be able to recognize and optimize vanilla lambdas. Instead,
developers are encouraged to use the provided `Field`s which, when used,
will always be recognizable by the Speedment query optimizer.


## Reference Field

The following methods are available to all `ReferenceField`s (i.e. fields that
are not primitive fields). In the table below, The "Outcome" is 
a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will 
return `true`if and only if:

| Method         | Param Type | Operation          | Outcome                                                |
| :------------- | :--------- | :----------------- | :----------------------------------------------------- |
| isNull         | N/A        | field == null      | the field is null                                      |
| isNotNull      | N/A        | field != null      | the field is not null                                  |

A `ReferenceField` implements the interface trait `HasReferenceOperators<ENTITY>`.

## Comparable Field
The following additional methods are available to a `ComparableField` that is
always associated to a `Comparable` field (e.g. Integer, String, Date, Time etc.).
Comparable fields can be tested for equality and can also be compared to other 
objects of the same type.
In the table below, the "Outcome" is a `Predicate<ENTITY>` that when tested with an 
object of type `ENTITY` will return `true`if and only if:

| Method         | Param      | Operation                  | Outcome                                                |
|                | Type       |                            |                                                        |
| :------------- | :--------- | :------------------------- | :----------------------------------------------------- |
| equal          | V          | Objects.equals(p, field)   | the field is equal to the parameter                    |
| notEqual       | V          | !Objects.equals(p, field)  | the field is not equal to the parameter                |
| lessThan       | V          | field < p                  | the field is less than the parameter                   |
| lessOrEqual    | V          | field <= p                 | the field is less or equal to the the parameter        |
| greaterThan    | V          | field > p                  | the field is greater than the parameter                |
| greaterOrEqual | V          | field >= p                 | the field is greater or equal to the parameter         |
| .........      | Set<V>     | More..         |


A `ComparableField` implements the interface traits `HasReferenceOperators<ENTITY>` 
and `HasComparableOperators<ENTITY>`.

## String Field
The following additional methods (over Comparable) are available to a `PredicateBuilder` that is associated
to a `String` field.

| Method             | Param Type | Outcome                                                |
| :----------------  | :--------- | :----------------------------------------------------- |
| equalIgnoreCase    | V          | the field starts with the given parameter              |
| notEqualIgnoreCase | V          | the field is not null                                  |

A `StringField` implements the interface trait `HasReferenceOperators<ENTITY>`
and `HasComparableOperators<ENTITY>` and `HasStringOperators<ENTITY>`.

## Primitive Field
TBW

