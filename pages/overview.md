---
permalink: overview.html
sidebar: mydoc_sidebar
title: Speedment Overview
keywords: Speedment, Preface, Editions, Arcitecture, Plugins, Licensing, Support, JavaDoc, Contributing
toc: false
Tags: Introduction, Preface, License
previous: introduction.html
next: stream_fundamentals.html
---

{% include prev_next.html %}

## What is Speedment?
Speedment is a Java 8 Stream ORM Toolkit and Runtime. 

With Speedment you can write database applications using Java only. No SQL coding is needed.

## Why Speedment? 

### One-liner
Search for a long `Film` (of length greater than 120 minutes):
``` java
// Searches are optimized in the background!
Optional<Film> longFilm = films.stream()
    .filter(Film.LENGTH.greaterThan(120))
    .findAny();
``` 

Results in the following SQL query:
```sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,
    `last_update` 
FROM 
     `sakila`.`film
WHERE
    (`length` > 120)
```

No need for manually writing SQL-queries any more. Remain in a pure Java world!

### Expressing SQL as Java Streams
When we started the open-source project Speedment, the main objective was to remove the polyglot requirement for Java database application developers. After all, we all love Java and why should we need to know SQL when, instead, we could derive the same semantics directly from Java streams? When one takes a closer look at this objective, it turns out that there is a remarkable resemblance between Java streams and SQL as summarized in this simplified table:

| SQL         | Java Stream Equivalent          |
| :---------- | :-------------------------------- |
| `FROM`       | `stream()`   |
| `SELECT`     | `map()`      |
| `WHERE`      | `filter()` (before collecting) |
| `HAVING`     | `filter()` (after collecting) |
| `JOIN`       | `flatMap()`  |
| `DISTINCT`   | `distinct()` |
| `UNION`      | `concat(s0, s1).distinct()` |
| `ORDER BY`   | `sorted()`   |
| `OFFSET`     | `skip()`     |
| `LIMIT`      | `limit()`    |
| `GROUP BY`   | `collect(groupingBy())` |
| `COUNT`      | `count()`    |

Speedment allows all these Stream operations to be used. Read more on Stream to SQL Equivalences [here](https://speedment.github.io/speedment-doc/speedment_examples.html#sql-equivalences).

## Features

### View Database Tables as Standard Java Streams

* **Pure Java** - Stream API instead of SQL eliminates the need of a query language<br>
* **Dynamic Joins** - Ability to perform joins as Java streams on the application side<br>
* **Parallel Streams** - Workload can automatically be divided over several threads<br>

### Short and Concise Type Safe Code 

* **Code Generation** - Automatic Java representation of the latest state of your database eliminates boilerplate code and the need of manually writing Java Entity classes while minimizing the risk for bugs.<br>
* **Null Protection** - Minimizes the risk involved with database null values by wrapping to Java Optionals<br>
* **Enum Integration** - Mapping of String columns to Java Enums increases memory efficiency and type safety<br>

### Lazy Evaluation for Increased Performance

* **Streams are Lazy** - Content from the database is pulled as elements are needed and consumed<br>
* **Pipeline Introspection** - Optimized performance by short circuiting of stream operations<br>

### Supported Java Versions
Speedment supports Java 8 and upwards. Earlier Java versions are not supported because they do not support Streams. Under Java 9, the new {{site.data.javadoc.StreamTakeWhile}} and {{site.data.javadoc.StreamDropWhile}} Stream operations will be automatically available under Speedment too.

Starting at 3.2.0, Speedment supports the Java Module System (JPMS). The use of the Java Module System is optional (and is not available in Java 8).

When *OpenJDK 1.8* is used, JavaFX needs to be installed separately (e.g. `sudo apt-get install openjfx`) because JavaFX is used by the UI tool and was not shipped in that particular JDK version.


{% include prev_next.html %}
