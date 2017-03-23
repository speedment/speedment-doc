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

## What is a Comparator?

A {{site.data.javadoc.Comparator}} of type `T` is something that takes two objects of type `T` and returns a negative integer, zero, or a positive integer if the first argument is less than, equal to, or greater than the second when its `compare` method is called. Let us take a closer look at an example where we have a `Comparator<String>` that we want to compare two strings using their natural order:
``` java
    Comparator<String> naturalOrder = (String first, String second) -> first.compareTo(second);
    Stream.of("Snail", "Ape", "Bird", "Ant", "Alligator")
        .sorted(naturalOrder)
        .forEachOrdered(System.out::println);
```
This will print out all animals in alphabetical order: Alligator, Ant, Ape, Bird and Snail because the `sorted` operator will sort the elements in the stream according to the provided `Comparator`.

In Speedment, the concept of a {{site.data.javadoc.Field}} is of central importance. Fields can be used to produce Comparators that are related to the field.

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `Hare` object:
``` java
    Comparator<Hare> nameOrder = Hare.NAME.comparator();
    hares.stream()
        .sorted(nameOrder)
        .forEachOrdered(System.out::println);
```
In this example, the {{site.data.javadoc.StringField}}'s method `User.NAME::comparator` returns a `Comparator<Hare>` that, when comparing two `Hare` objects, will return a negative value if the name of the first `Hare` is less than the name of the second `Hare`, zero if the name of the `Hare` objects are equal, a positive value if the name of the first `Hare` is greater than the name of the second `Hare`.

When run, the code above will produce the following output (given that there are three hares in the table with the name "Harry", "Henrietta" and "Henry"):
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare`
```
As can be seen, The current version of Speedment performs sorting in the JVM but future versions may use remote database sorting (see issue [#173][https://github.com/speedment/speedment/issues/173])

It would be possible to express the same semantics using `Comparator.comparing` and a method reference:
``` java
    hares.stream()
        .sorted(Comparator.comparing(Hare::getName))
        .forEachOrdered(System.out::println);
```
but Speedment would not be able to recognize and optimize vanilla comparators. Because of this, developers are highly encouraged to use the provided {{site.data.javadoc.Field}}s when obtaining comparators because these comparators, 
when used, can or will in the future be recognizable by the Speedment query optimizer. 

{% include important.html content= "
Do This: `sorted(Hare.NAME.comparator())` 
Don't do This: `sorted(Comparator.naturalOrder())`
" %}

{% include note.html content= "
Speedment Enterprise in-JVM-memory acceleration is making use of the Field comparators.
" %}

The rest of this chapter will be about how we can get comparators from different `Field` types and how these comparators can be used.


## Comparators

Comparators are only available from fields that represents comparable values like `int`, `Integer` and `String`. Fields like `Boolean` cannot be compared because they have no order defined.

The following methods are available to a `ComparableField` that is
always associated to a `Comparable` field (e.g. Integer, String, Date, Time etc.).
Comparable fields can be tested for equality and can also be compared to other objects of the same type.
In the table below, the "Outcome" is a stream where the elements are `sorted()` using a `Comparator<ENTITY>` and they will have the:

| Nulls | Method                                 |  Outcome                                               |
| :--:  | :------------------------------------- | :----------------------------------------------------- |
| No    | comparator()                           | natural order                                          |
| No    | comparator().reversed()                | reversed natural order                                 |
| Yes   | comparatorNullFieldsFirst()            | natural order with nulls first                         |
| Yes   | comparatorNullFieldsFirst().reversed() | reversed natural order will nulls last                 |
| Yes   | comparatorNullFieldsLast()             | natural order with nulls last                          |
| Yes   | comparatorNullFieldsLast().reversed()  | reversed natural order with nulls first                |

### comparator
TBW

### comparator reversed
TBW

### comparatorNullFieldsFirst
TBW

### comparatorNullFieldsFirst reversed
TBW

### comparatorNullFieldsLast
TBW

### comparatorNullFieldsLast reversed
TBW

## Primitive Comparators
For performance reasons, there are a number of primitive field types available in addition to the reference field type. By using a primitive field, unnecessary boxing and auto-boxing can be avoided. Primitive fields also generates primitive comparators like `IntFieldComparator` or `LongFieldComparator`

The following primitive types and their corresponding field types are supported by Speedment:

| Primitive Type | Primitive Field Type   | Comparators              |
| :------------- | :--------------------- | :----------------------- |
| `byte`         | `ByteField`            | `ByteFieldComparator`    |
| `short`        | `ShortField`           | `ShortFieldComparator`   |
| `int`          | `IntField`             | `IntFieldComparator`     |
| `long`         | `LongField`            | `LongFieldComparator`    |
| `float`        | `FloatField`           | `FloatFieldComparator`   |
| `double`       | `DoubleField`          | `DoubleFieldComparator`  |
| `char`         | `CharField`            | `CharFieldComparator`    |

This is something that is handled automatically by Speedment under the hood and does not require any additional coding. Our code will simply run faster width these specializations.

## Examples
TBW

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="comparator.html" %}