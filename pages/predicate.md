---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
Tags: Stream
---

## Predicate and Fields

A `Predicate` is... A `Field` is ...

## Examples

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `User` object:

``` java
    Optional<User> johnSmith = users.stream()
        .filter(User.NAME.equal("John Smith")
        .findAny();
```
In this example, the {{site.data.javadoc.StringField}}'s 
method `User.NAME::equal` creates and returns a `Predicate<User>` that, when 
tested with a User, will return `true` if and only if that User has a name that 
is equal to "John Smith", otherwise it will return `false`.

N.B. It would be possible to express the same semantics using a standard lambda:
``` java
    Optional<User> johnSmith = users.stream()
        .filter(u -> "John Smith".equals(u.getName())
        .findAny();
```
but Speedment would not be able to recognize and optimize vanilla lambdas. Instead,
developers are encouraged to use the provided {{site.data.javadoc.Field}}s which, 
when used, will always be recognizable by the Speedment query optimizer.


## Reference Field

The following methods are available to all {{site.data.javadoc.ReferenceField}}s
 (i.e. fields that are not primitive fields). In the table below, The "Outcome" is 
a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will 
return `true` if and only if:

| Method         | Param Type | Operation          | Outcome                                                |
| :------------- | :--------- | :----------------- | :----------------------------------------------------- |
| isNull         | N/A        | field == null      | the field is null                                      |
| isNotNull      | N/A        | field != null      | the field is not null                                  |

A {{site.data.javadoc.ReferenceField}} implements the interface trait 
{{site.data.javadoc.HasReferenceOperators}}.

## Comparable Field
The following additional methods are available to a {{site.data.javadoc.ReferenceField}}
that is always associated to a `Comparable` field (e.g. `Integer`, `String`, `Date`, `Time` etc.).
Comparable fields can be tested for equality and can also be compared to other 
objects of the same type.
In the table below, the "Outcome" is a `Predicate<ENTITY>` that when tested with an 
object of type `ENTITY` will return `true`if and only if:

| Method         | Param Type | Operation                  | Outcome                                                |
| :------------- | :--------- | :------------------------- | :----------------------------------------------------- |
| equal          | `V`          | Objects.equals(p, field)   | the field is equal to the parameter                    |
| notEqual       | `V`          | !Objects.equals(p, field)  | the field is not equal to the parameter                |
| lessThan       | `V`          | field < p                  | the field is less than the parameter                   |
| lessOrEqual    | `V`          | field <= p                 | the field is less or equal to the the parameter        |
| greaterThan    | `V`          | field > p                  | the field is greater than the parameter                |
| greaterOrEqual | `V`          | field >= p                 | the field is greater or equal to the parameter         |
| .........      | `Set<V>`     | More..         |


A {{site.data.javadoc.ComparableField}} implements the interface traits 
{{site.data.javadoc.HasReferenceOperators}} and {{site.data.javadoc.HasComparableOperators}}.

## String Field
The following additional methods (over Comparable) are available to a `PredicateBuilder` that is associated
to a `String` field.

| Method             | Param Type | Operation                  | Outcome                                                     |
| :----------------- | :--------- | :------------------------- | :---------------------------------------------------------- |
| equalIgnoreCase    | `String`     | String::equalsIgnoreCase   | the field is equal to the given parameter ignoring case     |
| notEqualIgnoreCase | `String`     | !String::equalsIgnoreCase  | the field is not equal to the given parameter ignoring case |

A {{site.data.javadoc.StringField}} implements the interface traits 
{{site.data.javadoc.HasReferenceOperators}}, {{site.data.javadoc.HasComparableOperators}}.
 and {{site.data.javadoc.HasReferenceOperators}}.

N.B. An informal notation of method references is made in the table above with "!" 
indicating the `Predicate::negate` method. I.e. it means that the Operation indicates a 
`Predicate` that will return the negated value.

## Primitive Field
For performance reasons, there are a number of primitive fields available too.
By using a primitive field, unnecessary boxing and auto-boxing cam be avoided.

### IntPrimitiveField
TBW

### LongPrimitiveField
TBW

### FloatPrimitiveField
TBW

### DoublePrimitiveField
TBW

