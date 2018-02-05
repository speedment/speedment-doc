---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
toc: false
Tags: Stream
previous: maven.html
next: comparator.html
---

{% include prev_next.html %}

## What is a Predicate?

An instance implementing the Java 8 interface `Predicate<T>` has a boolean function `test` that takes a parameter of type `T` and returns either `true` or `false` when called. Check out the official JavaDoc about {{site.data.javadoc.Predicate}}. 
Let us take a closer look at an example where we have a `Predicate<String>` that we want to return `true` if the `String` begins with an "A" and `false` otherwise:
``` java
    Predicate<String> startsWithA = (String s) -> s.startsWith("A");

    Stream.of("Snail", "Ape", "Bird", "Ant", "Alligator")
        .filter(startsWithA)
        .forEachOrdered(System.out::println);
```
This will print out all animals that starts with "A": Ape, Ant and Alligator because the `filter` operator will only pass forward those elements where its `Predicate` returns `true`.

In Speedment, the concept of a {{site.data.javadoc.Field}} is of central importance. Fields can be used to produce Predicates that are related to the field.

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `Film` object:
``` java
films.stream()
    .filter(Film.TITLE.startsWith("A"))
    .forEachOrdered(System.out::println);
```
In this example, the {{site.data.javadoc.StringField}}'s method `Film.TITLE::startsWith` creates and returns a `Predicate<Film>` that, when tested with a `Film`, will return `true` if and only if that `Film` has a `title` that starts with an "A" (otherwise it will return `false`).

When run, the code above will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, description = ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, description = ...
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
WHERE
    (`sakila`.`film`.`title` LIKE BINARY CONCAT(? ,'%')), values:[A]
```
Note: The question marks (`?`) in the SQL string will be replaced by the values given after the SQL statement (e.g ."`values:[A]`"))

It would be possible to express the same semantics using a standard anonymous lambda:
``` java
films.stream()
    .filter(f -> f.getTitle().startsWith("A"))
    .forEachOrdered(System.out::println);
```
but Speedment would not be able to recognize and optimize vanilla lambdas and will therefore produce the following SQL code:
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update` 
FROM
     `sakila`.`film`, values:[]
```
which will pull in the entire Film table and then the predicate will be applied. Because of this, developers are highly encouraged to use the provided {{site.data.javadoc.Field}}s when obtaining predicates because these predicates, 
when used, will always be recognizable by the Speedment query optimizer. 

{% include important.html content= "
Do This: `filter(Film.TITLE.greaterOrEqual(\"He\"))` 
Don't do This: `filter(\"He\".compareTo(f.getTitle()) <= 0)`
" %}


The rest of this chapter will be about how we can get predicates from different `Field` types and how these predicates can be combined and how they are rendered to SQL.

## Reference Predicates

The following methods are available to all {{site.data.javadoc.ReferenceField}}s (i.e. fields that are not primitive fields). The ‘Condition' in the table below is the condition for which the corresponding `Predicate` will hold `true`:

| Method         | Param Type | Operation          | Condition                                              |
| :------------- | :--------- | :----------------- | :----------------------------------------------------- |
| isNull         | N/A        | field == null      | the field is null                                      |
| isNotNull      | N/A        | field != null      | the field is not null                                  |

A {{site.data.javadoc.ReferenceField}} implements the interface trait {{site.data.javadoc.HasReferenceOperators}}.

## Reference Predicate Examples
Here is a list with examples for the *Reference Predicates*. The source code for the examples below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/predicate/ReferencePredicates.java)

### isNull
We can count all films with a rating that is null like this:
``` java
    long count = films.stream()
        .filter(Film.RATING.isNull())
        .count();
    System.out.format("There are %d films with a null rating %n", count);
```
The code will produce the following output:
``` text 
There are 0 films with a null rating  
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT
    COUNT(*)
FROM (
    SELECT 
        `film_id`,`title`,`description`,`release_year`,
        `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
        `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
    FROM
         `sakila`.`film
    WHERE 
       (`sakila`.`film`.`rating` IS NULL)
) AS A, values:[]
```

### isNotNull
We can count all films with a rating that is *not* null like this:
``` java
    long count = films.stream()
        .filter(Film.RATING.isNotNull())
        .count();
    System.out.format("There are %d films with a non-null rating %n", count);
```
The code will produce the following output:
``` text 
There are 1000 films with a non-null rating```

and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT
    COUNT(*)
FROM (
    SELECT 
        `film_id`,`title`,`description`,`release_year`,
        `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
        `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
    FROM
         `sakila`.`film
    WHERE 
       (`sakila`.`film`.`rating` IS NOT NULL)
) AS A, values:[]
```


## Comparable Predicates
The following additional methods are available to a {{site.data.javadoc.ReferenceField}} that is always associated to a `Comparable` field (e.g. `Integer`, `String`, `Date`, `Time` etc.). Comparable fields can be tested for equality and can also be compared to other objects of the same type. The ‘Condition' in the table below is the condition for which the corresponding `Predicate` will hold `true`:

| Method         | Param Type | Operation                  | Condition                                              |
| :------------- | :--------- | :------------------------- | :----------------------------------------------------- |
| equal          | `V`          | Objects.equals(p, field)   | the field is equal to the parameter                    |
| notEqual       | `V`          | !Objects.equals(p, field)  | the field is not equal to the parameter                |
| lessThan       | `V`          | field < p                  | the field is less than the parameter                   |
| lessOrEqual    | `V`          | field <= p                 | the field is less or equal to the the parameter        |
| greaterThan    | `V`          | field > p                  | the field is greater than the parameter                |
| greaterOrEqual | `V`          | field >= p                 | the field is greater or equal to the parameter         |
| between        | `V`,`V`      | field >= s && field < e  | the field is between s (inclusive) and e (exclusive) |
| between        | `V`,`V`, `Inclusion`| field >? s && field <? e  | the field is between s and e with inclusion according to the given Inclusion parameter (`START_INCLUSIVE_END_INCLUSIVE`, `START_INCLUSIVE_END_EXCLUSIVE`, `START_EXCLUSIVE_END_INCLUSIVE` and `START_EXCLUSIVE_END_EXCLUSIVE`)|
| notBetween     | `V`,`V`      | field < s && field >= e  | the field is not between p1 (exclusive) and p2 (inclusive) |
| notBetween     | `V`,`V`, `Inclusion`| field <? s && field >? e  | the field is not between s and e with inclusion according to the given Inclusion parameter (`START_INCLUSIVE_END_INCLUSIVE`, `START_INCLUSIVE_END_EXCLUSIVE`, `START_EXCLUSIVE_END_INCLUSIVE` and `START_EXCLUSIVE_END_EXCLUSIVE`)|
| in             | `V[]`        |  array p contains field    | the array parameter contains the field
| in             | `Collection<V>`     |  p.contains(field)         | the `Collection<V>` contains the field
| notIn          | `V[]`        |  array p does not contain field    | the array parameter does not contain the field
| notIn          | `Collection<V>`     |  !p.contains(field)        | the `Collection<V>` does not contain the field

{% include tip.html content = "
Fields that are `null` will never fulfill any of the predicates in the list above. Thus, neither `equals` nor `notEquals` will return `true` for null values.
" %}
{% include tip.html content = "
The reason `equal` is not named `equals` is that the latter name is already used as a method name by the `Object` class (that every other class inherits from). The latter method has a different meaning than function than `equal` so a new name had to be used.
" %}

A {{site.data.javadoc.ComparableField}} implements the interface traits {{site.data.javadoc.HasReferenceOperators}} and {{site.data.javadoc.HasComparableOperators}}.

## Comparable Predicate Examples
Here is a list with examples for the *Comparable Predicates*. The source code for the examples below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/predicate/ComparablePredicates.java)

In the examples below, we assume that the database contains a number of films with ratings according to the Motion Picture Association of America (MPAA) film rating system:

| Rating | Meaning                                                              |
| :--- | :---------------------------------------------------------------- |
| G | Gerneral Audience |
| PG | Parental Guidance Suggested |
| PG-13 | PG-13 – Parents Strongly Cautioned |
| R | R – Restricted |
| NC-17 | NC-17 – Adults Only |


### equal
If we want to count all films with a rating that equals "PG-13" we can write the following snippet:
``` java
    long count = films.stream()
        .filter(Film.RATING.equal("PG-13"))
        .count();

    System.out.format("There are %d films(s) with a PG-13 rating %n", count);
```
The code will produce the following output:
``` text
There are 223 films(s) with a PG-13 rating 
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT
    COUNT(*)
FROM (
    SELECT
       `film_id`,`title`,`description`,`release_year`,
       `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
       `length`,`replacement_cost`,`rating`,`special_features`,
       `last_update` 
    FROM
       `sakila`.`film` 
    WHERE 
       (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin)
) AS A, values:[PG-13]
```

### notEqual
The following example shows a solution where we print out all films that has a rating that is *not* "PG-13":
``` java
    films.stream()
        .filter(Film.RATING.notEqual("PG-13"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ..., rating = PG, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ..., rating = G, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ..., rating = NC-17, ...
FilmImpl { filmId = 4, title = AFFAIR PREJUDICE, ..., rating = G, ...
FilmImpl { filmId = 5, title = AFRICAN EGG, ..., rating = G, ...
FilmImpl { filmId = 6, title = AGENT TRUMAN, ..., rating = PG, ...
FilmImpl { filmId = 8, title = AIRPORT POLLOCK, ..., rating = R, ...
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
WHERE 
    (NOT (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin)), values:[PG-13]
```

### lessThan
The following example shows a solution where we print out all films that has a length that is less than 120:
``` java
    films.stream()
        .filter(Film.LENGTH.lessThan(120))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ..., length = 86, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ..., length = 48, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ..., length = 50, ...
FilmImpl { filmId = 4, title = AFFAIR PREJUDICE, ..., length = 117, ...
FilmImpl { filmId = 7, title = AIRPLANE SIERRA, ..., length = 62, ...
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
WHERE 
    (`sakila`.`film`.`length` < ?), values:[120]
```

### lessThan
The following example shows a solution where we print out all films that has a length that is less or equal to 120:
``` java
    films.stream()
        .filter(Film.LENGTH.lessThan(120))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ..., length = 86, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ..., length = 48, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ..., length = 50, ...
FilmImpl { filmId = 4, title = AFFAIR PREJUDICE, ..., length = 117, ...
FilmImpl { filmId = 7, title = AIRPLANE SIERRA, ..., length = 62, ...
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
WHERE 
    (`sakila`.`film`.`length` <= ?), values:[120]
```

### greaterThan
The following example shows a solution where we print out all films that has a length that is greater than 120:
``` java
    films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 5, title = AFRICAN EGG, ..., length = 130, ...
FilmImpl { filmId = 6, title = AGENT TRUMAN, ..., length = 169, ...
FilmImpl { filmId = 11, title = ALAMO VIDEOTAPE, ..., length = 126, ...
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
WHERE 
    (`sakila`.`film`.`length` > ?), values:[120]
```

### greaterOrEqual
The following example shows a solution where we print out all films that has a length that is greater than or equal to 120:
``` java
    films.stream()
        .filter(Film.LENGTH.greaterOrEqual(120))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 5, title = AFRICAN EGG, ..., length = 130, ...
FilmImpl { filmId = 6, title = AGENT TRUMAN, ..., length = 169, ...
FilmImpl { filmId = 11, title = ALAMO VIDEOTAPE, ..., length = 126, ...
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
WHERE 
    (`sakila`.`film`.`length` >= ?), values:[120]
```

### between
The following example shows a solution where we print out all films that has a length that is between 60 (inclusive) and 120 (exclusive):
``` java
    films.stream()
        .filter(Film.LENGTH.between(60, 120))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ..., length = 86, ...
FilmImpl { filmId = 4, title = AFFAIR PREJUDICE, ...,, length = 117, ...
FilmImpl { filmId = 7, title = AIRPLANE SIERRA, ..., length = 62, ...
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ..., length = 114, ...
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
WHERE 
    (`sakila`.`film`.`length` >= ? AND `sakila`.`film`.`length` < ?), values:[60, 120]
```
There is also another variant of the `between` predicate where an  {{site.data.javadoc.Inclusion}} parameter determines if a range of results should be start and/or end-inclusive. 

For an example, take the series [1 2 3 4 5]. If we select elements *in* the range (2, 4) from this series, we will get the following results:

| # | `Inclusive` Enum Constant	                     | Included Elements |
| - | :--------------------------------------------- | :---------------- |
| 0 | `START_INCLUSIVE_END_INCLUSIVE`                | [2, 3, 4]         |
| 1 | `START_INCLUSIVE_END_EXCLUSIVE`                | [2, 3]            |
| 2 | `START_EXCLUSIVE_END_INCLUSIVE`                | [3, 4]            |
| 3 | `START_EXCLUSIVE_END_EXCLUSIVE`                | [3]               |

Here is an example showing a solution where we print out all films that has a length that is between 3 (inclusive) and 9 (inclusive):
``` java
    films.stream()
        .filter(Film.LENGTH.between(60, 120, Inclusion.START_INCLUSIVE_END_INCLUSIVE))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ..., length = 86, ...
FilmImpl { filmId = 4, title = AFFAIR PREJUDICE, ...,, length = 117, ...
FilmImpl { filmId = 7, title = AIRPLANE SIERRA, ..., length = 62, ...
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ..., length = 114, ...
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
WHERE 
    (`sakila`.`film`.`length` >= ? AND `sakila`.`film`.`length` <= ?), values:[60, 120]
```

{% include tip.html content = "
The order of the two parameters `start` and `end` is significant. If the `start` parameter is larger than the `end` parameter, then the `between` `Predicate` will always evaluate to `false`.
" %}


### notBetween
The following example shows a solution where we print out all films that has a length that is *not* between 60 (inclusive) and 120 (exclusive):
``` java
    films.stream()
        .filter(Film.LENGTH.notBetween(60, 120))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 2, ..., length = 48, ...
FilmImpl { filmId = 3, ..., length = 50, ...
FilmImpl { filmId = 5, ..., length = 130, ...
FilmImpl { filmId = 6, ..., length = 169, ...
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
WHERE 
    (NOT((`sakila`.`film`.`length` >= ? AND `sakila`.`film`.`length` < ?)))
```
Note that a film with length 120 is printed because 120 is outside the range 60 (inclusive) and 120 (exclusive) (because 120 is NOT in the range as 120 is exclusive).

There is also another variant of the `notBetween` predicate where an  {{site.data.javadoc.Inclusion}} parameter determines if a range of results should be start and/or end-inclusive. 

For an example, take the series [1 2 3 4 5]. If we select elements *not in* the range (2, 4) from this series, we will get the following results:

| # | `Inclusive` Enum Constant                      | Included Elements |
| - | :--------------------------------------------- | :---------------- |
| 0 | `START_INCLUSIVE_END_INCLUSIVE`                | [1, 5]            |
| 1 | `START_INCLUSIVE_END_EXCLUSIVE`                | [1, 4, 5]         |
| 2 | `START_EXCLUSIVE_END_INCLUSIVE`                | [1, 2, 5]         |
| 3 | `START_EXCLUSIVE_END_EXCLUSIVE`                | [1, 2, 4, 5]      |

Here is an example showing a solution where we print out all films that has a length that is *not* between 60 (inclusive) and 120 (inclusive):
``` java
    films.stream()
        .filter(Film.LENGTH.notBetween(60, 120, Inclusion.START_INCLUSIVE_END_INCLUSIVE))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 2, ..., length = 48, ...
FilmImpl { filmId = 3, ..., length = 50, ...
FilmImpl { filmId = 5, ..., length = 130, ...
FilmImpl { filmId = 6, ..., length = 169, ...
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
WHERE 
    (NOT((`sakila`.`film`.`length` >= ? AND `sakila`.`film`.`length` <= ?))), values:[60, 120]
```

{% include tip.html content = "
The order of the two parameters `start` and `end` is significant. If the `start` parameter is larger than the `end` parameter, then the `notBetween` `Predicate` will always evaluate to `true`.
" %}


### in
Here is an example showing a solution where we print out all films that has a rating that is either "G", "PG" or "PG-13":
``` java
    films.stream()
        .filter(Film.RATING.in("G", "PG", "PG-13"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, ..., rating = PG, ...
FilmImpl { filmId = 2, ..., rating = G, ...
FilmImpl { filmId = 4, ..., rating = G, ...
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
WHERE 
    (`sakila`.`film`.`rating` COLLATE utf8_bin IN (?,?,?)), values:[PG-13, G, PG]
```
There is also a variant of the `in` predicate that takes a `Collection` as a parameter. For example like this:
``` java
    Set<String> set = Stream.of("G", "PG", "PG-13").collect(toSet());

    films.stream()
        .filter(Film.RATING.in(set))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, ..., rating = PG, ...
FilmImpl { filmId = 2, ..., rating = G, ...
FilmImpl { filmId = 4, ..., rating = G, ...
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
WHERE 
    (`sakila`.`film`.`rating` COLLATE utf8_bin IN (?,?,?)), values:[PG-13, G, PG]
```

### notIn
Here is an example showing a solution where we print out all films that has a rating that is *neither* "G", "PG" *nor* "PG-13":
``` java
    films.stream()
        .filter(Film.RATING.notIn("G", "PG", "PG-13"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 3, ..., rating = NC-17, ...
FilmImpl { filmId = 8, ..., rating = R, ...
FilmImpl { filmId = 10, ..., rating = NC-17, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE 
    (NOT((`sakila`.`film`.`rating` COLLATE utf8_bin IN (?,?,?)))), values:[PG-13, G, PG]
```
There is also a variant of the `noIn` predicate that takes a `Collection` as a parameter. For example like this:
``` java
    Set<String> set = Stream.of("G", "PG", "PG-13").collect(toSet());

    films.stream()
        .filter(Film.RATING.notIn(set))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 3, ..., rating = NC-17, ...
FilmImpl { filmId = 8, ..., rating = R, ...
FilmImpl { filmId = 10, ..., rating = NC-17, ...
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
WHERE 
    (NOT((`sakila`.`film`.`rating` COLLATE utf8_bin IN (?,?,?)))), values:[PG-13, G, PG]
```

## String Predicates
The following additional methods (over {{site.data.javadoc.ReferenceField}}) are available to a {{site.data.javadoc.StringField}}. The ‘Condition' in the table below is the condition for which the corresponding `Predicate` will hold `true`:

| Method                  | Param Type   | Operation                  | Condition                                                       |
| :---------------------- | :----------- | :------------------------- | :-------------------------------------------------------------- |
| isEmpty                 | `String`     | String::isEmpty            | the field is empty (i.e. field.length() == 0)                   |
| isNotEmpty              | `String`     | !String::isEmpty           | the field is not empty (i.e. field.length() !=0)                |
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
| containsIgnoreCase      | `String`     | String::contains ic        | the field contains the given parameter ignoring case            |
| notContainsIgnoreCase   | `String`     | !String::contains ic       | the field does not contain the given parameter ignoring case    |


{% include tip.html content = "
Fields that are `null` will never fulfill any of the predicates in the list above. Thus, neither `contains` nor `notContains` will return `true` for null values.
" %}

A {{site.data.javadoc.StringField}} implements the interface traits {{site.data.javadoc.HasReferenceOperators}}, {{site.data.javadoc.HasComparableOperators}} and {{site.data.javadoc.HasStringOperators}}.

{% include note.html content = "
An informal notation of method references is made in the table above with \"!\" indicating the `Predicate::negate` method. I.e. it means that the Operation indicates a `Predicate` that will return the negated value. The notation \"ic\" means that the method reference shall be applied ignoring case
" %}

## String Predicate Examples
Here is a list with examples for the *String Predicates*. The source code for the examples below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/predicate/StringPredicates.java)

### isEmpty
The following example shows a solution where we print out the number of films that has a title that is empty (e.g. is equal to ""):
``` java
    long count = films.stream()
        .filter(Film.TITLE.isEmpty())
        .count();

    System.out.format("There are %d films(s) with an empty title %n", count);
```
The code will produce the following output:
``` text
There are 0 films(s) with an empty title 
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    COUNT(*)
FROM (
    SELECT 
        `film_id`,`title`,`description`,`release_year`,
        `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
        `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
    FROM 
        `sakila`.`film` 
    WHERE
    (`sakila`.`film`.`title` = '')
) AS A, values:[]
```

### isNotEmpty
The following example shows a solution where we print out the films that has a title that is *not* empty (e.g. is *not* equal to ""):
``` java
    films.stream()
        .filter(Film.TITLE.isNotEmpty())
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (`sakila`.`film`.`title` = ''), values:[]
```

### equalIgnoreCase
The following example shows a solution where we print out the films that has a title that equals to "AlABama dEVil" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.equalIgnoreCase("AlABama dEVil"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (`sakila`.`film`.`title`  = ? COLLATE utf8_general_ci), values:[AlABama dEVil]
```

### notEqualIgnoreCase
The following example shows a solution where we print out the films that has a title that does *not* equal to "AlABama dEVil" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.notEqualIgnoreCase("AlABama dEVil"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (NOT((`sakila`.`film`.`title`  = ? COLLATE utf8_general_ci))), values:[AlABama dEVil]
```

### startsWith
The following example shows a solution where we print out the films that has a title that starts with "ALABAMA":
``` java
    films.stream()
        .filter(Film.TITLE.startsWith("ALABAMA"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (`sakila`.`film`.`title` LIKE BINARY CONCAT(? ,'%')), values:[ALABAMA]
```

### notStartsWith
The following example shows a solution where we print out the films that has a title that does *not* start with "ALABAMA":
``` java
    films.stream()
        .filter(Film.TITLE.notStartsWith("ALABAMA"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (`sakila`.`film`.`title` LIKE BINARY CONCAT(? ,'%')), values:[ALABAMA]
```

### startsWithIgnoreCase
The following example shows a solution where we print out the films that has a title that starts with "ala" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.startsWithIgnoreCase("ala"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (LOWER(`sakila`.`film`.`title`) LIKE BINARY CONCAT(LOWER(?) ,'%')), values:[ala]
```

### notStartsWithIgnoreCase
The following example shows a solution where we print out the films that has a title that does *not* start with "ala" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.notStartsWithIgnoreCase("ala"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (NOT((LOWER(`sakila`.`film`.`title`) LIKE BINARY CONCAT(LOWER(?) ,'%')))), values:[ala]
```

### endsWith
The following example shows a solution where we print out the films that has a title that ends with "DEVIL":
``` java
    films.stream()
        .filter(Film.TITLE.endsWith("DEVIL"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ...
FilmImpl { filmId = 155, title = CLEOPATRA DEVIL, ...
FilmImpl { filmId = 313, title = FIDELITY DEVIL, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (`sakila`.`film`.`title` LIKE BINARY CONCAT('%', ?)), values:[DEVIL]
```

### notEndsWith
The following example shows a solution where we print out the films that has a title that does *not* end with "DEVIL":
``` java
    films.stream()
        .filter(Film.TITLE.notEndsWith("DEVIL"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (NOT((`sakila`.`film`.`title` LIKE BINARY CONCAT('%', ?)))), values:[DEVIL]
```

### endsWithIgnoreCase
The following example shows a solution where we print out the films that has a title that ends with "deVIL" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.endsWithIgnoreCase("deVIL"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 9, title = ALABAMA DEVIL, ...
FilmImpl { filmId = 155, title = CLEOPATRA DEVIL, ...
FilmImpl { filmId = 313, title = FIDELITY DEVIL, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (LOWER(`sakila`.`film`.`title`) LIKE BINARY CONCAT('%', LOWER(?))), values:[deVIL]
```

### notEndsWithIgnoreCase
The following example shows a solution where we print out the films that has a title that does *not* start with "deVIL" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.notEndsWithIgnoreCase("deVIL"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (NOT((LOWER(`sakila`.`film`.`title`) LIKE BINARY CONCAT('%', LOWER(?))))), values:[deVIL]
```

### contains
The following example shows a solution where we print out the films that has a title that contains the string "CON":
``` java
    films.stream()
        .filter(Film.TITLE.contains("CON"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 23, title = ANACONDA CONFESSIONS, ...
FilmImpl { filmId = 127, title = CAT CONEHEADS, ...
FilmImpl { filmId = 138, title = CHARIOTS CONSPIRACY, ...
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (`sakila`.`film`.`title` LIKE BINARY CONCAT('%', ? ,'%')), values:[CON]
```

### notContains
The following example shows a solution where we print out the films that has a title that does *not* contain the string "CON":
``` java
    films.stream()
        .filter(Film.TITLE.notContains("CON"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (NOT((`sakila`.`film`.`title` LIKE BINARY CONCAT('%', ? ,'%')))), values:[CON]
```

### containsIgnoreCase
The following example shows a solution where we print out the films that has a title that contains the string "CoN" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.containsIgnoreCase("CoN"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 23, title = ANACONDA CONFESSIONS, ...
FilmImpl { filmId = 127, title = CAT CONEHEADS, ...
FilmImpl { filmId = 138, title = CHARIOTS CONSPIRACY, ...
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
WHERE
    (LOWER(`sakila`.`film`.`title`) LIKE BINARY CONCAT('%', LOWER(?) ,'%')), values:[CoN]
```

### notContainsIgnoreCase
The following example shows a solution where we print out the films that has a title that does *not* contain the string "CoN" ignoring case:
``` java
    films.stream()
        .filter(Film.TITLE.containsIgnoreCase("CoN"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
WHERE
    (NOT((LOWER(`sakila`.`film`.`title`) LIKE BINARY CONCAT('%', LOWER(?) ,'%')))), values:[CoN]
```


## Negating Predicates
All predicates (including already negated predicates) can be negated by calling the `negate()` method. Negation means that the result of the Predicate will be inverted (i.e. `true` becomes `false` and `false` becomes `true`). Here is a list of predicates and their corresponding negation:

### Reference Predicates

| Predicate                    | Equivalent Predicate    |
| :--------------------------- | :---------------------- |
| isNull().negate()            | isNotNull()             |
| isNotNull().negate()         | isNull()                |

### Comparable Predicates

| Predicate                    | Equivalent Predicate    |
| :--------------------------- | :---------------------- |
| equal.negate(p)              | notEqual(p)             |
| notEqual(p).negate()         | equal(p)                |
| lessThan(p).negate()         | greaterOrEqual(p)       |
| lessOrEqual(p).negate()      | greaterThan(p)          |
| greaterThan(p).negate()      | lessOrEqual(p)          |
| greaterOrEqual(p).negate()   | lessThan(p)             |
| between(s, e).negate()       | notBetween(s, e)        |
| notBetween(s, e).negate()    | between(s, e)           |
| in(a, b, c).negate()         | notIn(a, b, c)          |
| notIn(a, b, c).negate()      | in(a, b, c)             |

### String Predicates

| Predicate                           | Equivalent Predicate        |
| :-----------------------------------| :-------------------------- |
| isEmpty().negate()                  | isNotEmpty()                |
| isNotEmpty().negate()               | isEmpty()                   |
| equalIgnoreCase(p).negate()         | notEqualIgnoreCase(p)       |
| notEqualIgnoreCase(p).negate()      | equalIgnoreCase(p)          |
| startsWith(p).negate()              | notStartsWith(p)            |
| notStartsWith(p).negate()           | startsWith(p)               |
| startsWithIgnoreCase(p).negate()    | notStartsWithIgnoreCase(p)  |
| notStartsWithIgnoreCase(p).negate() | startsWithIgnoreCase(p)     |
| endsWith(p).negate()                | notEndsWith(p)              |
| notEndsWith(p).negate()             | endsWith(p)                 |
| endsWithIgnoreCase(p).negate()      | notEndsWithIgnoreCase(p)    |
| notStartsWithIgnoreCase(p).negate() | startsWithIgnoreCase(p)     |
| contains(p).negate()                | notContains(p)              |
| notContains(p).negate()             | contains(p)                 |
| containsIgnoreCase(p).negate()      | notContainsIgnoreCase(p)    |
| notContainsIgnoreCase(p).negate()   | containsIgnoreCase(p)       |

so, for example, `Film.FILM_ID.equal(1).negate()` is equivalent to `Film.FILM_ID.notEqual(1)` and `Film.FILM_ID.between(1,100).negate()` is equivalent to `Film.FILM_ID.notBetween(1, 100)`.

{% include tip.html content = "
Negating a `Predicate` an even number of times will give back the original `Predicate`. E.g. `Film.FILM_ID.equal(1).negate().negate()` is equivalent to `Film.FILM_ID.equal(1)`
" %}

## Combining Predicates
A predicate Predicate can be composed of other predicates by means of the `and()` and `or()` methods as shown in the examples below. 

### and
The `and()` method returns a composed predicate that represents a short-circuiting logical AND of a first predicate and another given second predicate. When evaluating the composed composed predicate, if the first predicate is evaluated to `false`, then the second predicate is not evaluated.

The following code sample will print out all films that are long (apparently a film is long when its length is greater than 120 minutes) and that has a rating that is "PG-13":
``` java
    Predicate<Film> isLong = Film.LENGTH.greaterThan(120);
    Predicate<Film> isPG13 = Film.RATING.equal("PG-13");
        
    films.stream()
        .filter(isLong.and(isPG13))
        .forEachOrdered(System.out::println);
```
This will produce the following output:
``` text
FilmImpl { filmId = 33, title = APOLLO TEEN, ... , length = 153, ..., rating = PG-13, ...
FilmImpl { filmId = 35, title = ARACHNOPHOBIA ROLLERCOASTER, ..., length = 147, ..., rating = PG-13, ...
FilmImpl { filmId = 36, title = ARGONAUTS TOWN, ..., length = 127, ..., rating = PG-13, ...
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
WHERE
        ((`sakila`.`film`.`length` > ?)
    AND 
        (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin)), values:[120, PG-13]
```

The same result can be achieved by just stacking two `filter` operations on top of each other. So this:
``` java
    films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .filter(Film.RATING.equal("PG-13"))
```
is equivalent to:
``` java
    films.stream()
        .filter(Film.LENGTH.greaterThan(120).and(Film.RATING.equal("PG-13"))
        .forEachOrdered(System.out::println);
```

### or
The `or()` method returns a composed predicate that represents a short-circuiting logical OR of a first predicate and another given second predicate. When evaluating the composed composed predicate, if the first predicate is evaluated to `true`, then the second predicate is not evaluated.
The following code sample will print out all films that are either long (length > 120) or has a rating of "PG-13":
``` java
        Predicate<Film> isLong = Film.LENGTH.greaterThan(120);
        Predicate<Film> isPG13 = Film.RATING.equal("PG-13");

        films.stream()
            .filter(isLong.or(isPG13))
            .forEachOrdered(System.out::println);
```
This will produce the following output:
``` text
FilmImpl { filmId = 5, title = AFRICAN EGG, ..., length = 130, ..., rating = G, ...
FilmImpl { filmId = 6, title = AGENT TRUMAN, ..., length = 169, ..., rating = PG, ...
FilmImpl { filmId = 7, title = AIRPLANE SIERRA, ..., length = 62, ..., rating = PG-13, ...
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
WHERE
        ((`sakila`.`film`.`length` > ?)
    OR 
        (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin)), values:[120, PG-13]
```

As for the `and()` method, there is an equivalent way of expressing compositions with `or()`. Here is an example of how streams can be concatenated whereby we obtain the same functionality as above:
``` java
    StreamComposition.concatAndAutoClose(
        films.stream().filter(Film.LENGTH.greaterThan(120)),
        films.stream().filter(Film.RATING.equal("PG-13"))
    )
        .distinct()
        .forEachOrdered(System.out::println);
```
``` text
FilmImpl { filmId = 5, title = AFRICAN EGG, ..., length = 130, ..., rating = G, ...
FilmImpl { filmId = 6, title = AGENT TRUMAN, ..., length = 169, ..., rating = PG, ...
{... a number of films with length > 120}
FilmImpl { filmId = 7, title = AIRPLANE SIERRA, ..., length = 62, ..., rating = PG-13, ...
{... a number of films with rating = "PG-13}
...
```
and will be rendered to the following SQL queries (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (`sakila`.`film`.`length` > ?), values:[120]


SELECT 
    `film_id`,`title`,`description`,`release_year`,
   `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
   `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
WHERE
    (`sakila`.`film`.`rating`  = ? COLLATE utf8_bin), values:[PG-13]

```
In this case, optimized queries will be used for the two sub-streams but the films must be handled by the JVM from the `.distinct()` operation.

{% include tip.html content = "
Speedment can optimize `Predicate::or` better than a concatenation of streams followed by a `distinct()` operation.
" %}


## Primitive Predicates
For performance reasons, there are a number of primitive field types available in addition to the reference field type. By using a primitive field, unnecessary boxing and auto-boxing can be avoided. Primitive fields also generates primitive predicates like `IntEqualPredicate` or `LongEqualPredicate`

The following primitive types and their corresponding field types are supported by Speedment:

| Primitive Type | Primitive Field Type   | Example of Predicate implementations                    |
| :------------- | :--------------------- | :------------------------------------------------------ |
| `byte`         | `ByteField`            | `ByteEqualPredicate` and `ByteGreaterThanPredicate`     |
| `short`        | `ShortField`           | `ShortEqualPredicate` and `ShortGreaterThanPredicate`   |
| `int`          | `IntField`             | `IntEqualPredicate` and `IntGreaterThanPredicate`       |
| `long`         | `LongField`            | `LongEqualPredicate` and `LongGreaterThanPredicate`     |
| `float`        | `FloatField`           | `FloatEqualPredicate` and `FloatGreaterThanPredicate`   |
| `double`       | `DoubleField`          | `DoubleEqualPredicate` and `DoubleGreaterThanPredicate` |
| `char`         | `CharField`            | `CharEqualPredicate` and `CharGreatersThanPredicate`    |
| `boolean`      | `BooleanField`         | `BooleanPredicate`                                      |

This is something that is handled automatically by Speedment under the hood and does not require any additional coding. Our code will simply run faster width these specializations.

## Predicate Examples
In the example below we want to print all films that has a `rating` that is either "G" or "PG", has a `length` greater than 120 and has a `specialFeature` that includes "Commentaries":
``` java
    films.stream()
        .filter(Film.RATING.in("G", "PG"))
        .filter(Film.LENGTH.greaterThan(120))
        .filter(Film.SPECIAL_FEATURES.contains("Commentaries"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
FilmImpl { filmId = 11, title = ALAMO VIDEOTAPE, ..., length = 126, ..., rating = G, specialFeatures = Commentaries,Behind the Scenes, ...
FilmImpl { filmId = 12, title = ALASKA PHANTOM, ..., length = 136, ..., rating = PG, specialFeatures = Commentaries,Deleted Scenes, ...
FilmImpl { filmId = 50, title = BAKED CLEOPATRA, ..., length = 182, ..., rating = G, specialFeatures = Commentaries,Behind the Scenes, ...
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
WHERE
        (`sakila`.`film`.`rating` COLLATE utf8_bin IN (?,?))
    AND 
        (`sakila`.`film`.`length` > ?) 
    AND
        (`sakila`.`film`.`special_features` LIKE BINARY CONCAT('%', ? ,'%')), values:[G, PG, 120, Commentaries]
```

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="predicate.html" %}
