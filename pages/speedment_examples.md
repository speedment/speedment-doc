---
permalink: speedment_examples.html
sidebar: mydoc_sidebar
title: Speedment Examples
keywords: Stream, Examples
toc: false
Tags: Stream, Examples
previous: crud.html
next: integration.html
---

{% include prev_next.html %}

This chapter contains a number of typical database queries that can be expressed using Speedment streams. For users that are accustomed to SQL, this chapter provides an overview of how to translate SQL to Streams.
The example below are based on the ["Sakila"](#database-schema) example database. An object that corresponds to a row in the database are, by convention, called an "Entity'.

## SQL Equivalences

### From
`FROM` can be expressed using `.stream()`

Speedment Streams can be created using a {{site.data.javadoc.Manager}}. Each table in the database has a corresponding `Manager`. For example, the table 'film' has a corresponding `Manager<Film>` allowing us to do like this:
``` java
   films.stream()
```
which will create a `Stream` with all the `Film` entities in the table 'film':
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
...
```

### Where 
`WHERE` can be expressed using `.filter()`.

By applying a `filter` to a `Stream`, certain entities can be retained in the `Stream` and other entities can be dropped. For example, 
if we want to find a long film (of length greater than 120 minutes) then we can apply a `filter` like this:

``` java
// Searches are optimized in the background!
    films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .forEachOrdered(System.out::println);
```
This will produce the following output:
``` text
Optional[FilmImpl { filmId = 5, title = AFRICAN EGG,... , length = 130, ...]
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


### Order By
`ORDER BY` can be expressed using `.sorted()`.

If we want to sort all our films in length order then we can do it like this:
``` Java
    List<Film> filmsInLengthOrder = films.stream()
        .sorted(Film.LENGTH)
        .collect(Collectors.toList());
```
The list will have the following content:
``` text
FilmImpl { filmId = 15, title = ALIEN CENTER, ..., length = 46, ...
FilmImpl { filmId = 469, title = IRON MOON, ..., length = 46, ...
FilmImpl { filmId = 730, title = RIDGEMONT SUBMARINE, ..., length = 46, ...
FilmImpl { filmId = 504, title = KWAI HOMEWARD, ..., length = 46, ...
FilmImpl { filmId = 505, title = LABYRINTH LEAGUE, ..., length = 46, ...
FilmImpl { filmId = 784, title = SHANGHAI TYCOON, ..., length = 47, ...
FilmImpl { filmId = 869, title = SUSPECTS QUILLS, ..., length = 47, ...
...
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
    `sakila`.`film`.`length` ASC
```


### Offset
`OFFSET` can be expressed using `.skip()`.

If we want to skip a number of records before we are using them then the `.skip()` operation is useful. Suppose we want to print out the films in title order but staring from the 100:th film then we can do like this:
``` java
    films.stream()
        .sorted(Film.TITLE)
        .skip(100)
        .forEachOrdered(System.out::println);
``` 
This will produce the following output:
``` text
FilmImpl { filmId = 101, title = BROTHERHOOD BLANKET, ...
FilmImpl { filmId = 102, title = BUBBLE GROSSE, ...
FilmImpl { filmId = 103, title = BUCKET BROTHERHOOD, ...
...
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
     223372036854775807 
OFFSET 
     ?, values:[100]     
```


### Limit
`LIMIT` can be expressed using `.limit()`.

If we want to limit the number of records in a stream them then the `.limit()` operation is useful. Suppose we want to print out the 3 first films in title order then we can do like this:
``` java
    films.stream()
        .sorted(Film.TITLE)
        .limit(3)
        .forEachOrdered(System.out::println);
``` 
This will produce the following output:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
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
    ?, values:[10]
```

### Combining Offset and Limit
`LIMIT X OFFSET Y` can be expressed by `.skip(y).limit(x)` (note the order of `skip` and `limit`) 

There are many applications where both `.skip()` and `.limit()` are used. Remember that the order of these stream operations matters and that the order is different from what you might be used to from SQL. In the following example we express a stream where we want to show 50 films starting from the 100:th film in title order:
``` java
    films.stream()
        .sorted(Film.TITLE)
        .skip(100)
        .limit(50)
        .forEachOrdered(System.out::println);
```
This will produce the following output:
``` text
FilmImpl { filmId = 101, title = BROTHERHOOD BLANKET, ...
FilmImpl { filmId = 102, title = BUBBLE GROSSE, ...
FilmImpl { filmId = 103, title = BUCKET BROTHERHOOD, ...
...
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
    ? 
OFFSET 
    ?, values:[50, 100]
```

### Count
`COUNT` can be expressed using `.count()`.

Stream counting are optimized to database queries. Consider the following stream that counts the number of long films (with a length greater than 120 minutes):
``` java
    long noLongFilms = films.stream()
        .filter(Film.LENGTH.greaterThan(120))
        .count();
```
When run, the code will calculate that there are 457 long films.

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

### Group By
`GROUP BY` can be expressed using `collect(groupingBy(...))`

Java has its own group by collector. If we want to group all the Films by the films 'rating' then we can write the following code:
``` java
    Map<String, List<Film>> filmCategories = films.stream()
        .collect(
            Collectors.groupingBy(
                Film.RATING
            )
        );
```
The content of the Map will correspond to:
``` text
Rating PG-13 has 223 films
Rating R     has 195 films
Rating NC-17 has 210 films
Rating G     has 178 films
Rating PG    has 194 films
```
The entire table will be pulled into the application in this example because all films will be in the Map.


### Having
`HAVING` can be expressed by `.filter()` applied on a Stream from a previously collected Stream.

We can expand the previous Group By example by filtering out only those categories having more than 200 films. Such a Stream can be expressed by applying a new stream on a stream that has been previously collected:
``` java 
    Map<String, List<Film>> filmCategories = films.stream()
        .collect(
            Collectors.groupingBy(
                Film.RATING
            )
        )
        .entrySet()
        .stream()
        .filter(e -> e.getValue().size() > 200)
        .collect(
            toMap(Entry::getKey, Entry::getValue)
        );
```
Now that only categories with more than 200 films are shown, the content of the Map will correspond to:
``` text
Rating PG-13 has 223 films
Rating NC-17 has 210 films
```

### Join
`JOIN` can be expressed using `.map()` and `.flatMap()`. However, since version 3.0.23, there is support for semantic joins that are much more efficient for large tables. See below. 

In this example, we want to create a Map that holds which Language is spoken in a Film. This is done by joining the two tables "film" and "language". There is a foreign key from a film to the language table.
``` java
    Map<Language, List<Film>> languageFilmMap = films.stream()
        .collect(
            // Apply this foreign key classifier
            groupingBy(languages.finderBy(Film.LANGUAGE_ID))
        );
```
So the classifier will take a Film and will lookup the corresponding Language when it is called. Upon inspection of the Map we can conclude:
``` text
 There are 1000 films in English 
```
Apparently all films were in English in the database.

{% include note.html content = "
Large tables will be less efficient using this join scheme so users are encouraged to use semantic joins that will improve performance for joins of large tables with Speedment.
" %}

#### Semantic Joins
Semantic joins creates a separate specialized `Stream` with tuples of entities that can be joined dynamically. Here is how we could create a Map that holds which Language is spoken in a Film using semantic joins:
``` java
Join<Tuple2<Film, Language>> join = joinComponent
    .from(FilmManager.IDENTIFIER)
    .innerJoinOn(Language.LANGUAGE_ID).equal(Film.LANGUAGE_ID)
    .build(Tuples::of);

Map<Language, List<Tuple2<Film, Language>>> languageFilmMap = join.stream()
    .collect(
        // Apply this classifier
        groupingBy(Tuple2::get1)
     ); 
 
```

### Distinct
`DISTINCT` can be expressed using `.distinct()`.

If we want to calculate what different ratings there are in the film tables then we can do it like this:
``` java
    Set<String> ratings = films.stream()
        .map(Film.RATING)
        .distinct()
        .collect(Collectors.toSet());
```
In this example, the entire table will be pulled into the application.

### Select
`SELECT` can be expressed using `.map()`

If we do not want to use the entire entity but instead only select one or several fields, we can do that by applying a `map` operation to a `Stream`. Assuming we are only interested in the field 'id' of a `Film` we can select that field like this:
``` java
// Creates a stream with the ids of the films by applying the FILM_ID getter
final IntStream ids = films.stream()
    .mapToInt(Film.FILM_ID);
```
This creates an `IntStream` consisting of the ids of all `Film`s by applying the Film.FILM_ID getter for each hare in the original stream.

If we want to select several fields, we can create a new custom class that holds only the fields in question or we can use a {{site.data.javadoc.Tuple}} to dynamically create a type safe holder.
``` java
    // Creates a stream of Tuples with two elements: title and length
    Stream<Tuple2<String, Integer>> items = films.stream()
        .map(Tuples.toTuple(Film.TITLE, Film.LENGTH.getter()));

```
This creates a stream of Tuples with two elements: title (of type `String`) and length (of type `Integer`).

{% include note.html content = "
Currently, Speedment will read all the columns regardless of subsequent mappings. Future versions might cut down on the columns actually being read following `.map()`, `mapToInt()`, `mapToLong()` and `mapToDouble()` operations.
" %}

### Union all
`UNION ALL` can be expressed using `StreamComposition.concatAndAutoClose(s0, s1, ..., sn)`.
Suppose we want to create a resulting stream with all Films that are of length greater than 120 minutes and then all films that are of rating "PG-13":
``` java
    StreamComposition.concatAndAutoClose(
        films.stream().filter(Film.LENGTH.greaterThan(120)),
        films.stream().filter(Film.RATING.equal("PG-13"))
    )
        .forEachOrdered(System.out::println);
```
The resulting stream will contain duplicates with films that have a length both greater than 120 minutes and have a rating "PG-13".


### Union
`UNION` can be expressed using `StreamComposition.concatAndAutoClose(s0, s1, ..., sn)` followed by `.distinct()`.
Suppose we want to create a resulting stream with all Films that are of length greater than 120 minutes and then all films that are of rating "PG-13":
``` java
    StreamComposition.concatAndAutoClose(
        films.stream().filter(Film.LENGTH.greaterThan(120)),
        films.stream().filter(Film.RATING.equal("PG-13"))
    )
        .distinct()
        .forEachOrdered(System.out::println);
```
The resulting stream will *not* contain duplicates because of the `.distinct()` operator.

Note: It would be more efficient to produce a stream with the same content (but a different order) using this stream:
``` java
 films.stream()
        .filter(Film.LENGTH.greaterThan(120).or(Film.RATING.equal("PG-13")))
        .forEachOrdered(System.out::println);
```


## Stream Examples


### Paging
The following example shows how we can serve request for pages from a GUI or similar applications. The page number (starting with page = 0) and ordering will be given as parameters:
``` java
    private List<Film> getPage(int page, Comparator<Film> comparator) {
        log("getPage(" + page + ", " + comparator + ")");
        return films.stream()
            .sorted(comparator)
            .skip(page * PAGE_SIZE)
            .limit(PAGE_SIZE)
            .collect(Collectors.toList());
    }
```
when this method is called like this:
``` java
    // Show page 2 (zero is first page) of Films order by title desc
    getPage(2, Film.TITLE.reversed());
```

then this will be rendered to the following SQL (for MySQL):
``` sql
SELECT 
    `film_id`,`title`,`description`,`release_year`,
    `language_id`,`original_language_id`,`rental_duration`,`rental_rate`,
    `length`,`replacement_cost`,`rating`,`special_features`,`last_update`
FROM 
    `sakila`.`film` 
ORDER BY 
    `sakila`.`film`.`title`IS NOT NULL, 
    `sakila`.`film`.`title` DESC 
LIMIT ? OFFSET ?, values:[50, 100]
```



### Partition By
Partitioning is a special case of grouping in which there are only two different classes: `false` or `true`. Java has its own partitioner that can be used to classify database entities. In the example below, we want to classify the films in two different categories: films that are or are not long, where a long film is of length greater than 120 minutes.
``` java
    Map<Boolean, List<Film>> map = films.stream()
        .collect(
            Collectors.partitioningBy(Film.LENGTH.greaterThan(120))
        );

    map.forEach((k, v) -> {
        System.out.format("long is %5s has %d films%n", k, v.size());
    });
```

This will print:
``` text
long is false has 543 films
long is  true has 457 films
```

### One-to-Many relations
A One-to-Many relationship is defined as a relationship between two tables where a row from a first table can have multiple matching rows in a second table. For example, many films can be in the same language.

In this example we will print out all films and the corresponding language spoken. More formally, we create a stream of matching pairs (called Tuple2) of `Language` and `Film` entitites where the language ids are equal:

``` java

    Join<Tuple2<Language, Film>> join = joinComponent
        .from(LanguageManager.IDENTIFIER)
        .innerJoinOn(Film.LANGUAGE_ID).equal(Language.LANGUAGE_ID)
        .build(Tuples::of);

       join.stream()
            .forEach(System.out::println);

```
this might print:
``` text
Tuple2Impl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 1, title = ACADEMY DINOSAUR,... }}
Tuple2Impl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 2, title = ACE GOLDFINGER, ... }}
Tuple2Impl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 3, title = ADAPTATION HOLES,... }}
...
```

When we are working with very small tables, we could use an alternate method where values are mapped in from another table for each iteration. In this example we will print out all films that are in the English language:
``` java
    languages.stream()
        .filter(Language.NAME.equal("English"))
        .flatMap(films.finderBackwardsBy(Film.LANGUAGE_ID))
        .forEach(System.out::println);
```
This will print:
``` text
FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ...
FilmImpl { filmId = 2, title = ACE GOLDFINGER, ...
FilmImpl { filmId = 3, title = ADAPTATION HOLES, ...
...
```


### Many-to-One relations
A Many-to-One relationship is defined as a relationship between two tables where many multiple rows from a first table can match the same single row in a second table. For example, a single language may be used in many films.

In this example we will print out the languages that are used for all films with a rating of "PG-13":
``` java

    Join<Tuple2<Film, Language>> join = joinComponent
        .from(FilmManager.IDENTIFIER).where(Film.RATING.equal("PG-13"))
        .innerJoinOn(Language.LANGUAGE_ID).equal(Film.LANGUAGE_ID)
        .build(Tuples::of);

    join.stream()
        .forEach(System.out::println);
```
this might print:
``` text
Tuple2Impl {FilmImpl { filmId = 7, title = AIRPLANE SIERRA,...., rating = PG-13, ... }, LanguageImpl { languageId = 1, name = English, ... }}
Tuple2Impl {FilmImpl { filmId = 9, title = ALABAMA DEVIL, ..., rating = PG-13, ... }, LanguageImpl { languageId = 1, name = English, ... }}
Tuple2Impl {FilmImpl { filmId = 18, title = ALTER VICTORY, ..., rating = PG-13, ... }, LanguageImpl { languageId = 1, name = English, ... }}

```

When we are working with very small tables, we could use an alternate method where values are mapped in from another table for each iteration.
``` java 
    films.stream()
        .filter(Film.RATING.equal("PG-13"))
        .map(languages.finderBy(Film.LANGUAGE_ID))
        .forEach(System.out::println);
```
this will print:
``` text
LanguageImpl { languageId = 1, name = English, lastUpdate = 2006-02-15 05:02:19.0 }
LanguageImpl { languageId = 1, name = English, lastUpdate = 2006-02-15 05:02:19.0 }
LanguageImpl { languageId = 1, name = English, lastUpdate = 2006-02-15 05:02:19.0 }
...
```


### Many-to-Many relations

A Many-to-Many relationship is defined as a relationship between two tables where many multiple rows from a first table can match multiple rows in a second table. Often a third table is used to form these relations. For example, an actor may participate in several films and a film usually have several actors.

In this example we will create a filmography for all actors using a third table `film_actors` that contains foreign keys to both films and actors.

``` java 
    Join<Tuple3<FilmActor, Film, Actor>> join = joinComponent
        .from(FilmActorManager.IDENTIFIER)
        .innerJoinOn(Film.FILM_ID).equal(FilmActor.FILM_ID)
        .innerJoinOn(Actor.ACTOR_ID).equal(FilmActor.ACTOR_ID)
        .build(Tuples::of);

        Map<Actor, List<Film>> filmographies = join.stream()
            .collect(
                groupingBy(Tuple3::get2, // Applies Actor as classifier
                    mapping(
                        Tuple3::get1, // Extracts Film from the Tuple
                        toList() // Use a List collector for downstream aggregation.
                    )
                )
            );

        filmographies.forEach((a, fl) -> {
            System.out.format("%s -> %s %n",
                a.getFirstName() + " " + a.getLastName(),
                fl.stream().map(Film::getTitle).sorted().collect(toList())
            );
        });

```
this might print:
``` text

    MICHAEL BOLGER -> [AIRPLANE SIERRA, BREAKFAST GOLDFINGER, CHARIOTS CONSPIRACY, ...] 
    LAURA BRODY -> [AMELIE HELLFIGHTERS, BLOOD ARGONAUTS, CAT CONEHEADS, ...] 
    CAMERON ZELLWEGER -> [BEAUTY GREASE, BLACKOUT PRIVATE, BRIGHT ENCOUNTERS, CLUELESS BUCKET, ...] 
```
As can be seen in the example above, the table `FilmActor` is not used within the join stream and can be discarded once the join is made as illustrated in this snippet:

``` java

    Join<Tuple2<Film, Actor>> join = joinComponent
        .from(FilmActorManager.IDENTIFIER)
        .innerJoinOn(Film.FILM_ID).equal(FilmActor.FILM_ID)
        .innerJoinOn(Actor.ACTOR_ID).equal(FilmActor.ACTOR_ID)
        .build((fa, f, a) -> Tuples.of(f, a)); // Apply a custom constructor, discarding FilmActor

```


### Pivot Data
Pivoting can be made using a `Join`. The following example shows a pivot table of all the actors and the number of films they have participated in for each film rating category (e.g. "PG-13"):
``` java
    Join<Tuple3<FilmActor, Film, Actor>> join = joinComponent
        .from(FilmActorManager.IDENTIFIER)
        .innerJoinOn(Film.FILM_ID).equal(FilmActor.FILM_ID)
        .innerJoinOn(Actor.ACTOR_ID).equal(FilmActor.ACTOR_ID)
        .build(Tuples::of);

    Map<Actor, Map<String, Long>> pivot = join.stream()
        .collect(
            groupingBy(
                Tuple3::get2, // Applies Actor as classifier
                groupingBy(
                    tu -> tu.get1().getRating().get(), // Applies rating as second level classifier
                    counting() // Counts the elements 
                )
            )
        );
    }

```
This is a more advanced example and it requires some thinking to understand.

This will produce the following output:
``` text
MICHAEL BOLGER  {PG-13=9, R=3, NC-17=6, PG=4, G=8} 
LAURA BRODY  {PG-13=8, R=3, NC-17=6, PG=6, G=3} 
CAMERON ZELLWEGER  {PG-13=8, R=2, NC-17=3, PG=15, G=5}  
...
```


## Database Schema

The film database example "Sakila" used in this manual can be downloaded directly from Oracle [here](https://dev.mysql.com/doc/index-other.html)


{% include prev_next.html %}

