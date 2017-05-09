---
permalink: speedment_examples.html
sidebar: mydoc_sidebar
title: Speedment Examples
keywords: Stream, Examples
toc: false
Tags: Stream, Examples
previous: introduction.html
next: getting_started.html
---

{% include prev_next.html %}

This chapter contains a number of typical database queries that can be expressed using Speedment streams.
The example below are based on the "Sakila" example database. An object that corresponds to a row in the database are, by convention, called an "Entity'.

## From
Speedment Streams can be created using a {{site.data.javadoc.Manager}}. Each table in the database has a corresponding `Manager`. For example, the table 'film' has a corresponding `Manager<Film>` allowing us to do like this:
``` java
   films.stream()
```
which will create a `Stream` with all the `Film` entities in the table 'film'.


## Where
By applying a `filter` to a `Stream`, certain entities can be retained in the `Stream` and other entities can be dropped. For example, 
if we want to find a long film (of length greater than 120 minutes) then we can apply a `filter` like this:

``` java
// Searches are optimized in the background!
    films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .forEachOrdered(System.out::println);
```
One important property with Speedment streams are that they are able to optimize its own pipeline by introspection. It looks like the `Stream` will iterate over all 
rows in the 'film' table but this is not the case. Instead, Speedment is able to optimize the SQL query in the background and will instead issue the command:
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE 
    (`sakila`.`film`.`length` > ?), values:[120]
```
This means that only the relevant entities are pulled in from the database into the `Stream`.

## Select
If we do not want to use the entire entity but instead only select one or several fields, we can do that by applying a `map` operation to a `Stream`. Assuming we are only interested in the field 'id' of a `Film` we can select that field like this:
``` java
// Creates a stream with the ids of the films by applying the FILM_ID getter
final IntStream ids = films.stream()
    .mapToInt(Film.FILM_ID.getter());
```
This creates an `IntStream` consisting of the ids of all `Film`s by applying the Film.FILM_ID getter for each hare in the original stream.

If we want to select several fields, we can create a new custom class that holds only the fields in question or we can use a {{site.data.javadoc.Tuple}} to dynamically create a type safe holder.
``` java
// Creates a stream of Tuples with two elements: id and name
Stream<Tuple2<Integer, String>> items = films.stream()
    .map(f -> Tuples.of(f.getFilmId(), f.getTitle()))

```
This creates a stream of Tuples with two elements: filmId (of type `Integer`) and title (of type `String`)

## Group By

## Having

## Joining

## Distinct

## Distinct

## Order By

## Offset

## Limit

## Group By

## Count
Stream counting are optimized to database queries. Consider the following stream:



## Other examples

### Partition By
Collectors.partitioningBy(x -> x > 50)

### Pivot Data



## Database Schema

The film database example "Sakila" used in this manual can be downloaded directly from Oracle [here](https://dev.mysql.com/doc/index-other.html)


{% include prev_next.html %}

