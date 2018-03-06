---
permalink: join.html
sidebar: mydoc_sidebar
title: Join Operations
keywords: Join
toc: false
Tags: Join
previous: comparator.html
next: crud.html
---

{% include prev_next.html %}


## The Join Component

The `JoinComponent` (available in Speedment 3.0.23 and later) can be used to create type safe joins between tables. It allows up to six table to be joined in different ways as described in this chapter.


## Join Types
The following join types are supported:

| Join Type      |  Method       | Description of Join Output                           |
| :------------- | :------------ | :---------------------------------------------------------------------------------- |
| INNER JOIN     | innerJoinOn() | A Stream with entities from tables (A and B) in the join with matching column values. Inner join creates Tuples by combining entities from two tables (A and B) based upon the join-predicate. The stream compares each entity of A with each entity of B to find all pairs of entities which satisfy the join-predicate. When the join-predicate is satisfied by matching non-NULL values, entities for each matched pair of rows of A and B are combined into a result Tuple.
| LEFT JOIN      | leftJoinOn()  | A Stream with entities from tables (A and B) in the join with matching column values or just an entity from A. The result of a left join for tables A and B always contains all entities of the "left" table (A), even if the join-condition does not find any matching row in the "right" table (B). This means that if the ON clause matches 0 (zero) entities in B (for a given entity in A), the join will still return an entity in the result Tuple (for that row)—but with an entity from B that is `null` in the Tuple. A left join returns all the values from an inner join plus all values in the left table (A) that do not match to the right table (B), including rows with NULL (empty) values in the linking column.
| RIGHT JOIN     | rightJoinOn() | A Stream with entities from tables (A and B) in the join with matching column values or just an entity from B. The result of a right join for tables A and B always contains all entities of the "right" table (B), even if the join-condition does not find any matching row in the "left" table (A). This means that if the ON clause matches 0 (zero) entities in A (for a given entity in B), the join will still return a entity in the result Tuple (for that row)—but with an entity from A that is `null` in the Tuple. A right join returns all the values from an inner join plus all values in the left table (B) that do not match to the right table (A), including rows with NULL (empty) values in the linking column.
| CROSS JOIN     | crossJoin()   | A Stream with the Cartesian product of entities from tables (A and B) in the join. In other words, it will produce a Stream with Tuples from two tables (A and B) which combine each entity from the A table with each entity from the B table.

`LEFT JOIN` and `RIGHT JOIN` creates Tuples with entities that are `null` for elements that are not part of the inner set whereas `INNER JOIN` and `CROSS JOIN` creates Tuples with entities that are never `null`.

Below is a picture of the different categories of Tuples a join can produce. The yellow circle marked with A is the "left" table and the blue circle marked with B is the "right" table. The middle category marked 2 (where the circles overlaps) represents Tuple(A entity, B entity) of entities where the join-condition matches. The category marked 1 represents Tuples(A entity, null) of A entities where the join-condition have no match in B. Finally, the category marked 3 represents Tuples(null, B entity) of B entities where the join-condition have no match in A.

{% include image.html file="JoinTypes.png" alt="Join Types" caption="Different Categories of Tuples produced by a Join" %}

Given the picture above, the joins produce Tuples as indicated in the following table:

| Join Type      | Tuples from the Categories| Tuples Produced
| :------------- | :------------------------ | :---------------
| INNER JOIN     | {2}                       | Tuple(A, B)
| LEFT JOIN      | {1, 2}                    | Tuple(A, B) and Tuple(A, null)
| RIGHT JOIN     | {2, 3}                    | Tuple(A, B) and Tuple(null, B)

{% include tip.html content= "
A `FULL OUTER JOIN` (with tuples from the categories {1, 2, 3}) can be obtained by creating a concatenation of distinct elements from a `LEFT JOIN` and a `RIGHT JOIN` like this: `crossJoinStream = Stream.concat(leftJoin.stream(), rightJoin.stream()).distinct()`. However, because the stream is using the `.distinct()` operation, it must first produce all elements in the Stream before they can be consumed.
" %}

## Join Operators
The most common way of joining tables is by means of an equality operator (i.e. `equal()`). However, tables can also be joined using a number of other operators as indicated in the table below:

| Operator       | Effect
| :------------- | :----------------------------------------------------------------------------------- |
| equal()        | Matches a column from table A that is *equal to* a column in table B
| notEqual()     | Matches a column from table A that is *not equal to* a column in table B
| lessThan()     | Matches a column from table A that is *less than* a column in table B
| lessOrEqual()  | Matches a column from table A that is *less than or equal to* a column in table B
| greaterThan()  | Matches a column from table A that is *greater than* a column in table B
| lessOrEqual()  | Matches a column from table A that is *less than or equal to* a column in table B
| between()      | Matches a column from table A that is *between* a first column in table B and a second column in table B
| notBetween()   | Matches a column from table A that is *not between* a first column in table B and a second column in table B


## Join Streams
Using a builder pattern, the `JoinComponent` can produce reusable `Join` objects that, in turn, can be used to create streams. The interface `Join` looks similar to this:

``` java
public interface Join<T> {
    Stream<T> stream();
}
```
Thus, once a `Join` object of a certain type `T` has been obtained, we can use that `Join` object over and over again to create streams with elements of type `T`. It should be noted that the order in which elements appear in the stream is unspecified, even between different invocations on the same Join object. It shall further be noted that by default, elements appearing in the stream may be deeply immutable meaning that Tuples in the stream are immutable and that entities contained in the Tuple may also be immutable.

Here is a full example of how a `Join` object can be created and used:

``` java
    SakilaApplication app = ...;
    
    JoinComponent joinComponent = app.getOrThrow(JoinComponent.class);
     
    Join<Tuple2OfNullables<Language, Film>> join = joinComponent
        // Start with the Language table
        .from(LanguageManager.IDENTIFIER)
        // Join with the Film table where the column
        // 'film,language_id` is equal to the column
        // `language.language.id'.
        .innerJoinOn(Film.LANGUAGE_ID).equal(Language.LANGUAGE_ID)
        // Create elements in the stream using the JoinComponents 
        // default element constructor (that creates
        // Tuple2OfNullables<Language, Film>
        .build();

        // Use the Join object to create Tuples of matching entities
        join.stream()
            .forEach(System.out::println);

```
This might produce the following output:
``` text
Tuple2OfNullablesImpl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ... }}
Tuple2OfNullablesImpl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 2, title = ACE GOLDFINGER, ... }}
Tuple2OfNullablesImpl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 3, title = ADAPTATION HOLES, ... }}
...
```


## Tuple Constructors
By default, tuples are of type `TupleXOfNullables` where X is the number of tables that are joined. If you are using only `INNER JOIN` or `CROSS JOIN`, the entities are never `null` and this allows us to use elements of type `TupleX` instead as shown here:

``` java
    Join<Tuple2<Language, Film>> join = joinComponent
        .from(LanguageManager.IDENTIFIER)
        .innerJoinOn(Film.LANGUAGE_ID).equal(Language.LANGUAGE_ID)
        // Use a custom Tuple constructor that takes a Language and
        // Film as input.
        .build(Tuples::of);

    join.stream()
        .forEach(System.out::println);
```
This might produce the following output:
``` text
Tuple2Impl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ... }}
Tuple2Impl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 2, title = ACE GOLDFINGER, ... }}
Tuple2Impl {LanguageImpl { languageId = 1, name = English, ... }, FilmImpl { filmId = 3, title = ADAPTATION HOLES, ... }}
...
```

It might not look as a big difference compared to the default case where we got `Tuple2OfNullables` but `Tuple2` are slightly easier to use because they can be used to retrieve entities directly rather then indirectly via an `Optional` object. In the general case, *any* constructor can be provided upon building a `Join` object, allowing great flexibility. We might, for example, create a specialized object in the stream that can be constructed from a `Language` entity and a `Film` entity as shown hereunder:

``` java

    private final class TitleLanguageName {

        private final String title;
        private final String languageName;

        private TitleLanguageName(Language language, Film film) {
            this.title = film.getTitle();
            this.languageName = language.getName();
        }

        public String title() {
            return title;
        }

        public String languageName() {
            return languageName;
        }

        @Override
        public String toString() {
            return "TitleLanguageName{" + "title=" + title + ", languageName=" + languageName + '}';
        }

    }

    ...

    Join<TitleLanguage> join = joinComponent
        .from(LanguageManager.IDENTIFIER)
        .innerJoinOn(Film.LANGUAGE_ID).equal(Language.LANGUAGE_ID)
        // Use a custom constructor that takes a Language entity and
        // a Film entity as input.
        .build(TitleLanguage::new);

        join.stream()
            .forEach(System.out::println);

```

This might produce the following output:
``` text
TitleLanguageName{title=ACADEMY DINOSAUR, languageName=English}
TitleLanguageName{title=ACE GOLDFINGER, languageName=English}
TitleLanguageName{title=ADAPTATION HOLES, languageName=English}
...
```

### Filtering Tables
Many times, we want to restrict the number of entities from a table that can appear in a join stream. This can be done using the `.where()` method in the join builder as exemplified below:

``` java
    Join<Tuple2<Film, Language>> join = joinComponent
        .from(FilmManager.IDENTIFIER)
            // Restrict films so that only PG-13 rated films appear            
            .where(Film.RATING.equal("PG-13"))
        .crossJoin(LanguageManager.IDENTIFIER)
            // Restrict languages so that only films where English is spoken appear
            .where(Language.NAME.equal("English"))
        .build(Tuples::of);

    join.stream()
       .forEach(System.out::println);
```

The `.where()` method can be called several times with different predicates to further reduce the number of elements in the stream. The different predicates will be combined using an `AND` operation.

{% include important.html content= "
Currently, only predicates obtained from the entity fields can be used (thus, anonymous lambdas cannot be used). Furthermore, predicates cannot be composed using the `.and()` and `.or()` methods. Instead. several invocations of the `.where()` method can be used to express `AND` compositions. This [limitation](https://github.com/speedment/speedment/issues/601) will be removed in a future version of Speedment.
" %}


## Join Examples
This section contains examples of a number of commonly used join scenarios. 

### Cross Join
Here is an example of a `CROSS JOIN`. All possible combinations of `Film` and `Language` entities will appear in the Stream.
``` java
   Join<Tuple2<Film, Language>> join = joinComponent
        .from(FilmManager.IDENTIFIER)
        .crossJoin(LanguageManager.IDENTIFIER)
        .build(Tuples::of);

    join.stream()
        .forEach(System.out::println);
```
This might produce the following output:
``` text
Tuple2Impl {FilmImpl { filmId = 1, title = ACADEMY DINOSAUR, ... }, LanguageImpl { languageId = 1, name = English, ... }}
Tuple2Impl {FilmImpl { filmId = 2, title = ACE GOLDFINGER, ... }, LanguageImpl { languageId = 1, name = English, ... }}
Tuple2Impl {FilmImpl { filmId = 3, title = ADAPTATION HOLES, ... }, LanguageImpl { languageId = 1, name = English, ... }}
...
```

### Collect Join Stream to Map
A join steam can easily be collected to a `Map` as shown hereunder:

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
If we only want lists of Film objects instead of Tuple2 we can re-map the down-stream elements like this:

``` java
        Join<Tuple2<Film, Language>> join = joinComponent
            .from(FilmManager.IDENTIFIER)
            .innerJoinOn(Language.LANGUAGE_ID).equal(Film.LANGUAGE_ID)
            .build(Tuples::of);

        Map<Language, List<Film>> languageFilmMap2 = join.stream()
            .collect(
                // Apply this classifier
                groupingBy(Tuple2::get1,
                    // Map down-stream elements and collect to a list
                    mapping(Tuple2::get0, toList())
                )
            );

        languageFilmMap2.forEach((l, fl)
            -> System.out.format("%s: %s%n", l.getName(), fl.stream().map(Film::getTitle).collect(joining(", ")))
        );
```
this might produce the following output:

``` text
English: ACADEMY DINOSAUR, ACE GOLDFINGER, ADAPTATION HOLES, ...
```


### Self Join
Here is an example of a self join where Actors with the same first name are matched:

``` java

    Join<Tuple2<Actor, Actor>> join = joinComponent
        .from(ActorManager.IDENTIFIER)
        .innerJoinOn(Actor.FIRST_NAME).equal(Actor.FIRST_NAME)
        .build(Tuples::of);

    join.stream()
        .forEach(System.out::println);

```

This might produce the following output:
``` text
Tuple2Impl {ActorImpl { actorId = 1, firstName = PENELOPE, lastName = GUINESS, ... }, ActorImpl { actorId = 1, firstName = PENELOPE, lastName = GUINESS, ... }}
Tuple2Impl {ActorImpl { actorId = 54, firstName = PENELOPE, lastName = PINKETT, ... }, ActorImpl { actorId = 1, firstName = PENELOPE, lastName = GUINESS, ... }}
Tuple2Impl {ActorImpl { actorId = 104, firstName = PENELOPE, lastName = CRONYN, ... }, ActorImpl { actorId = 1, firstName = PENELOPE, lastName = GUINESS, ...}}
...
```

### Other Examples
See other join examples in the manual here: 

[One-to-Many](https://speedment.github.io/speedment-doc/speedment_examples.html#one-to-many-relations) 
[Many-to-One](https://speedment.github.io/speedment-doc/speedment_examples.html#many-to-one-relations) 
[Many-to-Many](https://speedment.github.io/speedment-doc/speedment_examples.html#many-to-many-relations)

## Limitations
If there is a Join that contains the same table several times, there might be cases where we are not able to specify which of these table instances we want to use when specifying join conditions. For example, self-joins of levels greater or equal to three will resolve predicates to the first variant of the table. Currently, the API does not allow us to specify other instances of the table.



{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="join.html" %}
