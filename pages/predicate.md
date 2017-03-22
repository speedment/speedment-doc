---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
toc: false
Tags: Stream
previous: comparator.html
next: comparator.html
---

{% include prev_next.html %}

## What is a Predicate

A Java 8 {{site.data.javadoc.Predicate}} of type `T` is something that takes an object of type `T` and returns either `true` or `false` when its `test` method is called. Let us take a closer look at an example where we have a `Predicate<String>` that we want to return `true` if the `String` begins with an "A" and `false` otherwise:
``` java
    Predicate<String> startsWithA = (String s) -> s.startsWith("A");

    Stream.of("Snail", "Ape", "Bird", "Ant", "Alligator")
        .filter(startsWithA)
        .forEachOrdered(System.out::println);
```
This will print out all animals that starts with "A": Ape, Ant and Alligator.


Another thing of central importance in Speedment is the concept of a {{site.data.javadoc.Field}}. Fields can be used to produce Predicates that are related to the field.

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `Hare` object:

``` java
    Predicate<Hare> isOld = Hare.AGE.greaterThan(5);
    hares.stream()
        .filter(isOld)
        .forEachOrdered(System.out::println);
```
In this example, the {{site.data.javadoc.StringField}}'s 
method `User.NAME::greaterThan` creates and returns a `Predicate<Hare>` that, when 
tested with a `Hare`, will return `true` if and only if that `Hare` has an age that 
is grater than 5, otherwise it will return `false`. When run, the code above will produce the following SQL code:
``` sql
    SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` > 5)
```

It would be possible to express the same semantics using a standard anonymous lambda:
``` java
    Predicate<Hare> isOld = h -> h.getAge() > 5;
    hares.stream()
        .filter(isOld)
        .forEachOrdered(System.out::println);
```
but Speedment would not be able to recognize and optimize vanilla lambdas and will therefore produce the following SQL code:
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare`
```
Because of this, developers are encouraged to use the provided {{site.data.javadoc.Field}}s when obtaining predicates because these predicates, 
when used, will always be recognizable by the Speedment query optimizer. 

{% include important.html content="
Do This: `hares.stream().filter(Hare.AGE.greaterThan(5))` 
Don't do This: `hares.stream().filter(h -> h.getAge() > 5)`
" %}

The rest of this chapter will be about how we can get predicates from different `Field` types.

## Reference Predicates

The following methods are available to all {{site.data.javadoc.ReferenceField}}s (i.e. fields that are not primitive fields). In the table below, The "Outcome" is a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will return `true` if and only if:

| Method         | Param Type | Operation          | Outcome                                                |
| :------------- | :--------- | :----------------- | :----------------------------------------------------- |
| isNull         | N/A        | field == null      | the field is null                                      |
| isNotNull      | N/A        | field != null      | the field is not null                                  |

A {{site.data.javadoc.ReferenceField}} implements the interface trait 
{{site.data.javadoc.HasReferenceOperators}}.

## Comparable Predicates
The following additional methods are available to a {{site.data.javadoc.ReferenceField}} that is always associated to a `Comparable` field (e.g. `Integer`, `String`, `Date`, `Time` etc.). Comparable fields can be tested for equality and can also be compared to other objects of the same type. In the table below, the "Outcome" is a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will return `true`if and only if:

| Method         | Param Type | Operation                  | Outcome                                                |
| :------------- | :--------- | :------------------------- | :----------------------------------------------------- |
| equal          | `V`          | Objects.equals(p, field)   | the field is equal to the parameter                    |
| notEqual       | `V`          | !Objects.equals(p, field)  | the field is not equal to the parameter                |
| lessThan       | `V`          | field < p                  | the field is less than the parameter                   |
| lessOrEqual    | `V`          | field <= p                 | the field is less or equal to the the parameter        |
| greaterThan    | `V`          | field > p                  | the field is greater than the parameter                |
| greaterOrEqual | `V`          | field >= p                 | the field is greater or equal to the parameter         |
| between        | `V`,`V`      | field >= s && field < e  | the field is between s (inclusive) and e (exclusive) |
| between        | `V`,`V`, `Inclusion`| field >? s && field <? e  | the field is between s and e inclusion according to the Inclusion parameter (`START_INCLUSIVE_END_INCLUSIVE`, `START_INCLUSIVE_END_EXCLUSIVE`, `START_EXCLUSIVE_END_INCLUSIVE` and `START_EXCLUSIVE_END_EXCLUSIVE`)|
| notBetween     | `V`,`V`      | field < s && field >= e  | the field is not between p1 (exclusive) and p2 (inclusive) |
| notBetween     | `V`,`V`, `Inclusion`| field <? s && field >? e  | the field is not between s and e inclusion according to the Inclusion parameter (`START_INCLUSIVE_END_INCLUSIVE`, `START_INCLUSIVE_END_EXCLUSIVE`, `START_EXCLUSIVE_END_INCLUSIVE` and `START_EXCLUSIVE_END_EXCLUSIVE`)|
| in             | `V[]`        |  array p contains field    | the array parameter contains the field
| in             | `Set<V>`     |  p.contains(field)         | the `Set<V>` contains the field
| notIn          | `V[]`        |  array p does not contain field    | the array parameter does not contain the field
| notIn          | `Set<V>`     |  !p.contains(field)        | the `Set<V>` does not contain the field

{% include note.html content = "
Fields that are `null` will never fulfill any of the predicates.
" %}

A {{site.data.javadoc.ComparableField}} implements the interface traits {{site.data.javadoc.HasReferenceOperators}} and {{site.data.javadoc.HasComparableOperators}}.

## String Predicates
The following additional methods (over {{site.data.javadoc.ReferenceField}}) are available to a {{site.data.javadoc.StringField}}:

| Method                  | Param Type   | Operation                  | Outcome                                                         |
| :---------------------- | :----------- | :------------------------- | :-------------------------------------------------------------- |
| equalIgnoreCase         | `String`     | String::equalsIgnoreCase   | the field is equal to the given parameter ignoring case         |
| notEqualIgnoreCase      | `String`     | !String::equalsIgnoreCase  | the field is not equal to the given parameter ignoring case     |
| startsWith              | `String`     | String::startsWith         | the field starts with the given parameter                       |
| notStartsWith           | `String`     | !String::startsWith        | the field does not start with the given parameter               |
| startsWithIgnoreCase    | `String`     | String::startsWith ic      | the field starts with the given parameter ignoring case         |
| notStartsWithIgnoreCase | `String`     | !String::startsWith ic     | the field does not start with the given parameter ignoring case |
| endsWith                | `String`     | String::endsWith           | the field ends with the given parameter                         |
| notEndsWith             | `String`     | !String::endsWith          | the field does not end with the given parameter                 |
| endsWithIgnoreCase      | `String`     | String::endsWith ic        | the field ends with the given parameter                         |
| notEndsWithIgnoreCase   | `String`     | !String::endsWith ic       | the field does not end with the given parameter                 |
| contains                | `String`     | String::contains           | the field contains the given parameter                          |
| notContains             | `String`     | !String::contains          | the field does not contain the given parameter                  |
| isEmpty                 | `String`     | String::isEmpty            | the field is empty (i.e. field.length() == 0)                   |
| isNotEmpty              | `String`     | !String::isEmpty           | the field is not empty (i.e. field.length() !=0)                |

{% include note.html content = "
Fields that are `null` will never fulfill any of the predicates.
" %}

A {{site.data.javadoc.StringField}} implements the interface traits {{site.data.javadoc.HasReferenceOperators}}, {{site.data.javadoc.HasComparableOperators}} and {{site.data.javadoc.HasStringOperators}}.

{% include note.html content = "
An informal notation of method references is made in the table above with \"!\" indicating the `Predicate::negate` method. I.e. it means that the Operation indicates a `Predicate` that will return the negated value. The notation \"ic\" means that the method reference shall be applied ignore case
" %}

## Primitive Predicates
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

## Examples
TBW

{% include prev_next.html %}
