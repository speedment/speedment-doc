---
permalink: comparator.html
sidebar: mydoc_sidebar
title: Speedment Comparator
keywords: Comparator, Stream
toc: false
Tags: Stream, Comparator
previous: predicate.html
next: join.html
---

{% include prev_next.html %}

## What is a Comparator?

A {{site.data.javadoc.Comparator}} of type `T` is something that takes two objects of type `T` and returns a negative integer, zero, or a positive integer if the first argument is less than, equal to, or greater than the second when its `compare` method is called. Let us take a closer look at an example where a `Comparator<String>` is used to compare two Strings using their natural order:
``` java
    Comparator<String> naturalOrder = (String first, String second) -> first.compareTo(second);
    Stream.of("Snail", "Ape", "Bird", "Ant", "Alligator")
        .sorted(naturalOrder)
        .forEachOrdered(System.out::println);
```
This will print out all animals in alphabetical order: Alligator, Ant, Ape, Bird and Snail because the `sorted` operator will sort the elements in the stream according to the provided `Comparator`.

In Speedment, the concept of a {{site.data.javadoc.Field}} is of central importance. Fields can be used to produce Comparators that are related to the field.

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `Film` object:
``` java
    Comparator<Film> title = Film.TITLE.comparator();

    films.stream()
        .sorted(title)
        .forEachOrdered(System.out::println);
```
In this example, the {{site.data.javadoc.StringField}}'s method `Film.TITLE::comparator` returns a `Comparator<Film>` that, when comparing two `Film` objects, will return a negative value if the title of the first `Film` is less than the name of the second `Film`, zero if the title of the `Film` objects are equal, a positive value if the title of the first `Film` is greater than the title of the second `Film`.

When run, the code above will produce the following output:
``` text
FilmImpl { ..., title = ACADEMY DINOSAUR, ...
FilmImpl { ..., title = ACE GOLDFINGER, ...
FilmImpl { ..., title = ADAPTATION HOLES, ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update` 
FROM 
    `sakila`.`film` 
ORDER BY 
    `sakila`.`film`.`title` ASC
```

It would be possible to express the same semantics using `Comparator.comparing` and a method reference:
``` java
    films.stream()
        .sorted(Comparator.comparing(Film::getTitle))
        .forEachOrdered(System.out::println);
```
but Speedment would not be able to recognize and optimize vanilla comparators. Because of this, developers are highly encouraged to use the provided {{site.data.javadoc.Field}}s when obtaining comparators because these comparators, 
when used, can be recognizable by the Speedment query optimizer. 

{% include important.html content= "
Do This: `sorted(Film.TITLE.comparator())` 
Don't do This: `sorted(Comparator.comparing(Film::getTitle))`
" %}

The rest of this chapter will describe how to get comparators from different `Field` types and how these comparators can be used.


## Comparators

Comparators are only available from fields that represents comparable values like `int`, `Integer` and `String`. Fields like `Boolean` cannot be compared because they have no order defined.

The following methods are available to a `ComparableField` that is
always associated to a `Comparable` field (e.g. Integer, String, Date, Time etc.).
Comparable fields can be tested for equality and can also be compared to other objects of the same type.
In the table below, the "Outcome" is a stream where the elements are `sorted()` using a `Comparator<ENTITY>` and they will have the:

| Method                                 |  Outcome                                    | Example    |
| :------------------------------------- | :------------------------------------------ | :--------- |
| comparator()                           | natural order with nulls last               | A, B, null |
| comparator().reversed()                | reversed (natural order with nulls last)    | null, B, A |
| comparatorNullFieldsFirst()            | natural order with nulls first              | null, A, B |
| comparatorNullFieldsFirst().reversed() | reversed (natural order will nulls first)   | B, A, null |

### comparator
The following example prints all films sorted by title:
``` java
    films.stream()
        .sorted(Film.TITLE.comparator())
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { ..., title = ACADEMY DINOSAUR, ...
FilmImpl { ..., title = ACE GOLDFINGER, ...
FilmImpl { ..., title = ADAPTATION HOLES, ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
ORDER BY
     `sakila`.`address`.`address2` is null,
     `sakila`.`film`.`title` ASC
```


### comparator reversed
The following example prints all films sorted by title in reversed order:
``` java
    films.stream()
        .sorted( Film.TITLE.comparator())
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { ..., title = ZORRO ARK, ...
FilmImpl { ..., title = ZOOLANDER FICTION, ...
FilmImpl { ..., title = ZHIVAGO CORE, ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
ORDER BY
    `sakila`.`address`.`address2` is not null,
    `sakila`.`film`.`title` DESC
```


### comparatorNullFieldsFirst
The following example prints the addresses sorted by the address2 field (which is nullable) with null values first:
``` java
    addresses.stream()
        .sorted(Address.ADDRESS2.comparatorNullFieldsFirst())
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
AddressImpl { addressId = 1, address = 47 MySakila Drive, address2 = null, ...
AddressImpl { addressId = 2, address = 28 MySQL Boulevard, address2 = null, ...
AddressImpl { addressId = 3, address = 23 Workhaven Lane, address2 = null, ...
AddressImpl { addressId = 4, address = 1411 Lillydale Drive, address2 = null, ...
AddressImpl { addressId = 256, address = 1497 Yuzhou Drive, address2 = , ...
AddressImpl { addressId = 512, address = 1269 Ipoh Avenue, address2 = , ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `address_id`,`address`,`address2`,`district`,
    `city_id`,`postal_code`,`phone`,`location`,`last_update` 
FROM 
    `sakila`.`address` 
ORDER BY 
    `sakila`.`address`.`address2` is not null,
    `sakila`.`address`.`address2` ASC
```


### comparatorNullFieldsFirst reversed
The following example prints the addresses sorted by the address2 field (which is nullable) with null values first but reversed:
``` java
    addresses.stream()
        .sorted(Address.ADDRESS2.comparatorNullFieldsFirst().reversed())
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
AddressImpl { addressId = 256, address = 1497 Yuzhou Drive, address2 = , ...
AddressImpl { addressId = 512, address = 1269 Ipoh Avenue, address2 = , ...
...
AddressImpl { addressId = 1, address = 47 MySakila Drive, address2 = null, ...
AddressImpl { addressId = 2, address = 28 MySQL Boulevard, address2 = null, ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `address_id`,`address`,`address2`,`district`,
    `city_id`,`postal_code`,`phone`,`location`,`last_update` 
FROM 
    `sakila`.`address` 
ORDER BY 
    `sakila`.`address`.`address2` is null,
    `sakila`.`address`.`address2` DESC
```


## Reversing Comparators
All comparators (including already reversed comparators) can be reversed by calling the `reversed()` method. Reversion means that the result of the Comparator will be inverted (i.e. negative values become positive and positive values become negative). Here is a list of comparators and their corresponding reversion:

{% include tip.html content = "
Reversing a `Comparator` an even number of times will give back the original `Comparator`. E.g. `Film.FILM_ID.comparator().reversed().reversed()` is equivalent to `Film.FILM_ID.comparator()`
" %}



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


## Combining Comparators
Several comparators can be combined to form a composite comparator that will sort entities using a combination of sort keys with different priorities. 

The following example prints the films sorted firstly by rating in reversed order and then secondly (if the rating is the same) by title:

``` java
    films.stream()
        .sorted(
            Film.RATING.comparator().reversed()
                .thenComparing(Film.TITLE.comparator())
        )
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ..., rating = NC-17, ...
FilmImpl { filmId = 10, title = ALADDIN CALENDAR, ..., rating = NC-17, specialFeatures = Trailers,Deleted Scenes, lastUpdate = 2006-02-15 05:03:42.0 }
FilmImpl { filmId = 14, title = ALICE FANTASIA, ..., rating = NC-17, ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
ORDER BY
    `sakila`.`film`.`rating`IS NOT NULL,
    `sakila`.`film`.`rating` DESC,
    `sakila`.`film`.`title` ASC
```

{% include note.html content = "
This feature is available starting from version 3.0.11
" %}

## Examples
The following example prints the films sorted firstly by rating in reversed order and then secondly (if the rating is the same) by title:

``` java
    films.stream()
        .sorted(Film.TITLE.comparator())              // <-- Second order
        .sorted(Film.RATING.comparator().reversed())  // <-- First order
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ..., rating = NC-17, ...
FilmImpl { filmId = 10, title = ALADDIN CALENDAR, ..., rating = NC-17, specialFeatures = Trailers,Deleted Scenes, lastUpdate = 2006-02-15 05:03:42.0 }
FilmImpl { filmId = 14, title = ALICE FANTASIA, ..., rating = NC-17, ...
...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
ORDER BY
    `sakila`.`film`.`rating`IS NOT NULL, 
    `sakila`.`film`.`rating` DESC, 
    `sakila`.`film`.`title` ASC    
```

{% include note.html content = "
Note that the most significant (first order) comparator is given *last* in the order of `.sorted()` operators. This might look like counter-intuitive if you are used to SQL where the order is the other way around. However, this is a consequence of how Streams work. The last `sorted()` operator will supersede any preceeding `sorted()` operator but since sorting is stable (for ordered streams), the previous order will be retained for entities that has the same sort key.

If you use version 3.0.11 or later, it is recommended to use [this](#combining-comparators) way instead.
" %}


{% include prev_next.html %}

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
