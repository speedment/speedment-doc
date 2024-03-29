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
The example below are based on the ["Sakila"](#database-schema) example database. 

An object that corresponds to a row in the database are, by convention, called an "Entity'.

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
to find a long film (of length greater than 120 minutes) you can apply a `filter` like this:

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

Sorting all our films in length order can be done this way:
``` java
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

Several "ORDER BY" columns can be used by composing comparators:
``` java
    .sorted(Film.LENGTH.thenComparing(Film.TITLE.comparator())
```
Note that the `.comparator()` method must be used for secondary fields.

Descending order can be obtained by calling, for example, `Film.LENGHT.reversed()`. 

### Offset
`OFFSET` can be expressed using `.skip()`.

The `.skip()` operation is useful to skip a number of records before using them. Suppose you want to print out the films in title order but staring from the 100:th film then the skip-operation can be used like this:
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

The number of records in a stream can be controlled using the `.limit()` operation. This example will print out the 3 first films in title order:
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

and is rendered to the following SQL query (for MySQL):
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

There are many applications where both `.skip()` and `.limit()` are used. Remember that the order of these stream operations matters and that the order is different from what you might be used to from SQL. The following example expresses a stream used to show 50 films starting from the 100:th film in title order:
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

Java has its own group-by `collector`. The example below groups all the Films by 'rating': 
``` java
    Map<String, List<Film>> filmCategories = films.stream()
        .collect(
            Collectors.groupingBy(
                Film.RATING
            )
        );

        map.forEach((k, v) ->
            System.out.format(
                 "Rating %-5s maps to %d films %n", k, v.size()
            )
        );

```
This might produce the following output:
``` text
Rating PG-13 has 223 films
Rating R     has 195 films
Rating NC-17 has 210 films
Rating G     has 178 films
Rating PG    has 194 films
```
The entire table will be pulled into the application in this example because all films will be in the Map.

To only count the occurrences of items for different classifications a down-stream `Collector` can be used instead:

``` java
Map<String, Long> map = films.stream()
    .collect(
        Collectors.groupingBy(
            // Apply this classifier
            Film.RATING,
            // Then apply this down-stream collector
            Collectors.counting()
        )
    );

    System.out.println(map);
```
This might produce the following output:
``` text
{PG-13=223, R=195, NC-17=210, G=178, PG=194}
```


### Having
`HAVING` can be expressed by `.filter()` applied on a Stream from a previously collected Stream.

The previous Group By example can be expanded by filtering out only those categories having more than 200 films. Such a Stream can be expressed by applying a new stream on a stream that has been previously collected:
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

#### Semantic Joins
Semantic joins creates a separate specialized `Stream` with tuples of entities that can be joined dynamically. The following example creates a `Map` that holds which `Language` is spoken in a `Film` using semantic joins:
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

`JOIN` can also be expressed using `.map()` and `.flatMap()`. Semantic joins that are much more efficient for large tables. See above. 

The example creates a `Map` that holds which `Language` is spoken in a `Film`. This is done by joining the two tables "film" and "language". There is a foreign key from a film to the language table.
``` java
    Map<Language, List<Film>> languageFilmMap = films.stream()
        .collect(
            // Apply this foreign key classifier
            groupingBy(languages.finderBy(Film.LANGUAGE_ID))
        );
```
So the classifier will take a `Film` and will lookup the corresponding Language when it is called. Inspection of the `Map` yield the following conclusion:
``` text
 There are 1000 films in English 
```
Apparently all films were in English in the database.

{% include note.html content = "
Large tables will be less efficient using this join scheme so users are encouraged to use semantic joins that will improve performance for joins of large tables with Speedment.
" %}


### Distinct
`DISTINCT` can be expressed using `.distinct()`.

The following code can be used to calculate what different ratings there are in the film tables:
``` java
    Set<String> ratings = films.stream()
        .map(Film.RATING)
        .distinct()
        .collect(Collectors.toSet());
```
In this example, the entire table will be pulled into the application.

### Select
`SELECT` can be expressed using `.map()`

If you do not want to use the entire entity but instead only select one or several fields, that can be done by applying a `Map` operation to a `Stream`. Assuming for example you are only interested in the field 'id' of a `Film` you can select that field like this:
``` java
// Creates a stream with the ids of the films by applying the FILM_ID getter
final IntStream ids = films.stream()
    .mapToInt(Film.FILM_ID);
```
This creates an `IntStream` consisting of the ids of all `Film`s by applying the Film.FILM_ID getter for each entity in the original stream.

To select several fields, you can create a custom class that holds only the fields in question or use a {{site.data.javadoc.Tuple}} to dynamically create a type-safe holder.
``` java
    // Creates a stream of Tuples with two elements: title and length
    Stream<Tuple2<String, Integer>> items = films.stream()
        .map(Tuples.toTuple(Film.TITLE, Film.LENGTH.getter()));

```
This creates a stream of `Tuples` with two elements: title (of type `String`) and length (of type `Integer`).

{% include note.html content = "
Currently, Speedment will read all the columns regardless of subsequent mappings. Future versions might cut down on the columns actually being read following `.map()`, `mapToInt()`, `mapToLong()` and `mapToDouble()` operations.
" %}

### Union all
`UNION ALL` can be expressed using `StreamComposition.concatAndAutoClose(s0, s1, ..., sn)`.
The following example creates a resulting `Stream` with all Films that are of length greater than 120 minutes and then all films that are of rating "PG-13":
``` java
    StreamComposition.concatAndAutoClose(
        films.stream().filter(Film.LENGTH.greaterThan(120)),
        films.stream().filter(Film.RATING.equal("PG-13"))
    )
        .forEachOrdered(System.out::println);
```
The resulting `Stream` will contain duplicates with films that have a length both greater than 120 minutes and have a rating "PG-13".

### Union
`UNION` can be expressed using `StreamComposition.concatAndAutoClose(s0, s1, ..., sn)` followed by `.distinct()`.
The following example creates a resulting `Stream` with all Films that are of length greater than 120 minutes and then all films that are of rating "PG-13":
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
The following example demonstrates how to serve request for pages from a GUI or similar applications. The page number (starting with page = 0) and ordering will be given as parameters:
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
Partitioning is a special case of grouping in which there are only two different classes: `false` or `true`. Java has its own partitioner that can be used to classify database entities. The example below classifies the films in two different categories: films that are or are not long, where a long film is of length greater than 120 minutes.
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

### Join, Group By and Order By
The following example shows a Join with a Group By operation where keys are sorted in a certain way. In the example, two keys are used for the grouping and sorting: `Film::getRating` and `Actor::getLastName`:
```` java
    Join<Tuple3<FilmActor, Film, Actor>> join = joinComponent
        .from(FilmActorManager.IDENTIFIER)
        .innerJoinOn(Film.FILM_ID).equal(FilmActor.FILM_ID)
        .innerJoinOn(Actor.ACTOR_ID).equal(FilmActor.ACTOR_ID)
        .build(Tuples::of);

    Comparator<Tuple2<String, String>> comparator = Comparator.comparing((Function<Tuple2<String, String>, String>) Tuple2::get0).thenComparing(Tuple2::get1);

    Map<Tuple2<String, String>, Long> grouped = join.stream()
        .collect(
            groupingBy(t -> Tuples.of(t.get1().getRating().orElse("Unknown"), t.get2().getLastName()), () -> new TreeMap<>(comparator), counting())
        );

    grouped.forEach((k, v) -> {
        System.out.format("%-32s, %,d%n", k, v);
    });

````
This will produce the following output (shortened for brevity):
``` text
Tuple2Impl {G, AKROYD}          , 7
Tuple2Impl {G, ALLEN}           , 13
Tuple2Impl {G, ASTAIRE}         , 6
Tuple2Impl {G, BACALL}          , 2
Tuple2Impl {G, BAILEY}          , 3
Tuple2Impl {G, BALE}            , 2
...
Tuple2Impl {NC-17, AKROYD}      , 13
Tuple2Impl {NC-17, ALLEN}       , 13
Tuple2Impl {NC-17, ASTAIRE}     , 11
Tuple2Impl {NC-17, BACALL}      , 5
...

```

### One-to-Many relations
A One-to-Many relationship is defined as a relationship between two tables where a row from a first table can have multiple matching rows in a second table. For example, many films can be in the same language.

The following example will print out all films and the corresponding language spoken. More formally, a `Stream` of matching pairs (called Tuple2) is created of `Language` and `Film` entities where the language ids are equal:

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

If you are working with very small tables, an alternate method can be used where values are mapped in from another table for each iteration. The following example will print out all films that are in the English language:
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

{% include warning.html content = "
Flattmapping with `finderBy` cannot be used in conjunction with transactions.
" %}


### Many-to-One relations
A Many-to-One relationship is defined as a relationship between two tables where many multiple rows from a first table can match the same single row in a second table. For example, a single language may be used in many films.

The example below prints out the languages that are used for all films with a rating of "PG-13":
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

When you are working with very small tables, an alternate method can be used where values are mapped in from another table for each iteration.
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

{% include warning.html content = "
Flattmapping with `finderBy` cannot be used in conjunction with transactions.
" %}


### Many-to-Many relations

A Many-to-Many relationship is defined as a relationship between two tables where many multiple rows from a first table can match multiple rows in a second table. Often a third table is used to form these relations. For example, an actor may participate in several films and a film usually have several actors.

The example below creates a filmography for all actors using a third table `film_actors` that contains foreign keys to both films and actors.

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
The film example database "Sakila" used in this manual can be downloaded directly from Oracle [here](https://dev.mysql.com/doc/index-other.html) or as a Docker image [here](https://hub.docker.com/r/restsql/mysql-sakila)


{% include prev_next.html %}

