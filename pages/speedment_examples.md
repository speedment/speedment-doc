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

This chapter contains a number of typical database queries that can be expressed using Speedment streams. For users that are accustomed to SQL this chapter provides an overview of how translate SQL to Streams.
The example below are based on the ["Sakila"](#database_schema) example database. An object that corresponds to a row in the database are, by convention, called an "Entity'.

## From
FROM can be expressed using `.stream()'
Speedment Streams can be created using a {{site.data.javadoc.Manager}}. Each table in the database has a corresponding `Manager`. For example, the table 'film' has a corresponding `Manager<Film>` allowing us to do like this:
``` java
   films.stream()
```
which will create a `Stream` with all the `Film` entities in the table 'film'.


## Where 
WHERE can be expressed using `.filter()`.
By applying a `filter` to a `Stream`, certain entities can be retained in the `Stream` and other entities can be dropped. For example, 
if we want to find a long film (of length greater than 120 minutes) then we can apply a `filter` like this:

``` java
// Searches are optimized in the background!
    films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .forEachOrdered(System.out::println);
```
One important property with Speedment streams are that they are able to optimize its own pipeline by introspection. It looks like the `Stream` will iterate over all 
rows in the 'film' table but this is not the case. Instead, Speedment is able to optimize the SQL query in the background and will instead issue the command (for MysQL):
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
SELECT can be expressed using `.map()'
If we do not want to use the entire entity but instead only select one or several fields, we can do that by applying a `map` operation to a `Stream`. Assuming we are only interested in the field 'id' of a `Film` we can select that field like this:
``` java
// Creates a stream with the ids of the films by applying the FILM_ID getter
final IntStream ids = films.stream()
    .mapToInt(Film.FILM_ID.getter());
```
This creates an `IntStream` consisting of the ids of all `Film`s by applying the Film.FILM_ID getter for each hare in the original stream.

If we want to select several fields, we can create a new custom class that holds only the fields in question or we can use a {{site.data.javadoc.Tuple}} to dynamically create a type safe holder.
``` java
    // Creates a stream of Tuples with two elements: title and length
    Stream<Tuple2<String, Integer>> items = films.stream()
        .map(Tuples.toTuple(Film.TITLE.getter(), Film.LENGTH.getter()));

```
This creates a stream of Tuples with two elements: title (of type `String`) and length (of type `Integer`).

{% include note.html content = "
Currently, Speedment will read all the columns regardless of subsequent mappings. Future versions might cut down on the columns actually being read following a `.map()' operation.
" %}


## Group By
GROUP BY can be expressed using `collect(groupingBy(...))`
Java has its own group by collector. If we want to group all the Films by the films 'rating' then we can write the following code:
``` Java
    Map<String, List<Film>> filmCategories = films.stream()
        .collect(
            Collectors.groupingBy(
                Film.RATING.getter()
            )
        );
```

## Having
HAVING can be expressed by `.filter()` applied on a Stream from a previously collected Stream.
We can expand the previous Group By example by filtering out only those categories having more than 200 films. Such a Stream can be expressed by applying a new stream on a stream that has been previously collected:
``` Java 
    Map<String, List<Film>> filmCategories = films.stream()
        .collect(
            Collectors.groupingBy(
                Film.RATING.getter()
            )
        )
        .entrySet()
        .stream()
        .filter(e -> e.getValue().size() > 200)
        .collect(
            toMap(Entry::getKey, Entry::getValue)
        );
```

## Join
JOIN can be expressed using `.map()` and `.flatMap()`
TBW

## Distinct
DISTINCT can be expressed using `.distinct()`.
If we want to calculate what different ratings there are in the film tables then we can do it like this:
``` Java
    Set<String> ratings = films.stream()
        .map(Film.RATING.getter())
        .distinct()
        .collect(Collectors.toSet());
```

## Order By
ORDER BY can be expressed using `.sorted()`.
If we want to sort all our films in length order then we can do it like this:
``` Java
    List<Film> filmsInLengthOrder = films.stream()
        .sorted(Film.LENGTH.comparator())
        .collect(Collectors.toList());
```

## Offset
OFFSET can be expressed using `.skip()`.
If we want to skip a number of records before we are using them then the `.skip()` operation is useful. Suppose we want to print out the films in title order but staring from the 100:th film then we can do like this:
``` Java
    films.stream()
        .sorted(Film.TITLE.comparator())
        .skip(100)
        .forEachOrdered(System.out::println);
``` 

This stream is rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update` 
FROM 
    `sakila`.`film` 
ORDER BY 
    `sakila`.`film`.`title` ASC 
LIMIT
     LIMIT ?, values:[10]
```


## Limit
LIMIT can be expressed using `.limit()`.
If we want to limit the number of records in a stream them then the `.limit()` operation is useful. Suppose we want to print out the 10 first films in title order then we can do like this:
``` Java
    films.stream()
        .sorted(Film.TITLE.comparator())
        .limit(10)
        .forEachOrdered(System.out::println);
``` 

This stream is rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update` 
FROM 
    `sakila`.`film` 
ORDER BY 
    `sakila`.`film`.`title` ASC 
LIMIT
     223372036854775807 OFFSET ?, values:[100]
```

## Count
COUNT can be expressed using `.count()`.
Stream counting are optimized to database queries. Consider the following stream:
''' java
    long noLongFilms = films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .count();
```
This will be rendered to the following SQL (for MySQL):
``` SQL
SELECT 
    COUNT(*) 
FROM 
   (
       SELECT 
           `film_id`,`title`,`description`,`release_year`,`language_id`,
           `original_language_id`,`rental_duration`,`rental_rate`,
           `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
       FROM 
           `sakila`.`film` 
       WHERE
           (`sakila`.`film`.`length` > ?)
    ) AS A, values:[120]
```

## Union all
UNION ALL can be expressed using `Stream.concat(s0, s1)`.
TBW

## Union
UNION can be expressed using `Stream.concat(s0, s1)` followed by `.distinct()`.
TBW


## Other examples


### Paging
The following example shows how we can serve request for pages from a GUI or similar applications. 
TBW

### Partition By
Collectors.partitioningBy(x -> x > 50)
TBW

### Pivot Data
TBW


## Database Schema

The film database example "Sakila" used in this manual can be downloaded directly from Oracle [here](https://dev.mysql.com/doc/index-other.html)


{% include prev_next.html %}

