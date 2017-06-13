---
permalink: enterprise_json.html
sidebar: mydoc_sidebar
title: Enterprise JSON Plugin
keywords: Encoder, JSON, Enterprise, Aggregate
enterprise: true
toc: false
Tags: Encoder, JSON, Enterprise, Aggregate
previous: 
next: enterprise_enums.html
---

{% include prev_next.html %}

## About
Speedment Enterprise offers an advanced JSON Stream Plugin that allows streams of entities to be turned into JSON very efficiently. It is similar to the Open Source Plugin with the same name, but also supports aggregating operations as well as in-place deserialization of individual fields if the Enterprise Datastore module is used.

For information about the Open Source JSON Stream Plugin, see here.

### Integration
To include the Enterprise JSON Stream Plugin in your Speedment project, add the following dependency:

```xml
<dependency>
    <groupId>com.speedment.enterprise.plugins</groupId>
    <artifactId>json-stream</artifactId>
    <version>${speedment.enterprise.version}</version>
</dependency>
```

To activate the plugin in the code, simply add the plugin bundle class to the Speedment Application Builder:

```java
public static void main(String... args) {
    final SakilaApplication app = new SakilaApplicationBuilder()
        .withBundle(DatastoreBundle.class) // Only if Datastore is used
        .withBundle(JsonBundle.class)      // The Enterprise JSON Plugin
        .withUsername("")
        .withPassword("")
        .build();
        
    // The following instances are used in the examples:
    final FilmManager films  = app.getOrThrow(FilmManager.class);
    final JsonComponent json = app.getOrThrow(JsonComponent.class);
    
    ...
}
```

### Encoding Entities
The JSON Plugin uses builders to create optimized encoders and collectors that can then be executed multiple times.

```java
final JsonEncoder<Film> filmEncoder = json.encoder(films).build();
```

The encoder extends `Function<T, String>` so it can be used as argument to the `.map()` operation in an entity stream.

```java
// Print all films as JSON
films.stream()
    .map(filmEncoder)
    .forEachOrdered(System.out::println);
```

#### Remove Unwanted Fields
By default, the `JsonEncoderBuilder` includes all fields in the result. However, if only a subset of the fields are desired, the others can be removed like this:

```java
final JsonEncoder<Film> filmEncoder = json.encoder(films)
    .remove(Film.RENTAL_DURATION)  // Remove a particular field
    .remove("languageId")          // Remove a particular label
    .build();
```

Another way to accomplish this is to create an empty builder and then add the fields to include explicitly.

```java
final JsonEncoder<Film> filmEncoder = json.<Film>emptyEncoder()
    .put(Film.TITLE)
    .putAll(Film.RELEASE_YEAR, Film.LENGTH)
    .build();
```

#### Rename Fields
The `JsonEncoderBuilder` creates a default label for each field using camelCase. If a different name is desired, it can be specified explicitly.

```java
final JsonEncoder<Film> filmEncoder = json.encoder(films)
    .remove(Film.RELEASE_YEAR)
    .put("the_year_is_was_released", Film.RELEASE_YEAR)
    .build();
```

### Collecting Streams
In most cases, an encoder is not used individually but as part of a collector. The most basic example would be to collect a stream of entities into a JSON Array.

```java
films.stream()
    .collect(JsonCollectors.toList(filmEncoder)); // Can also be imported statically
```

This will produce a JSON object like this:

```
[
    {"filmId": 1, "title": ... },
    {"filmId": 2, "title": ... },
    ...
]
```

### Aggregating Fields
To aggregate a stream of entities into a single JSON object, a custom collector can be created. That is also done using a builder pattern. Multiple fields can be aggregated in the same operation, creating a very powerful and performant API.

#### Creating an Aggregate Collector
To include the total number of matched rows in the result, the `JsonCollectors.count()` collector can be used.

```java
final JsonCollector<Film, ?> filmCollector = json.collector(Film.class)
    .put("total", JsonCollectors.count())
    .put("rows", JsonCollectors.toList(filmEncoder))
    .build();
```

We have now created an aggregate collector that can be applied to a stream.

```java
films.stream().collect(filmCollector);
```

The following JSON object is returned:

```json
{
    "total" : 322787,
    "rows" : [
        {"filmId": 1, "title": ...},
        {"filmId": 2, "title": ... },
        ...
    ]
}
```

#### Formatting Aggregated Fields
By default, the `JsonEncoderBuilder` will apply the `Object::toString` on each field aggregated. However, this behavior can be overridden by providing a "finisher" to each field. The finisher will only be applied to the final result, not the individual elements.

``` java
    JsonCollector<Film, ?> filmCollector = json.collector(Film.class)
        .put(
            "maxLength",
            JsonCollectors.max(
                Film.LENGTH,
                i -> String.format("\"%d hours and %d minutes\"", i / 60, i % 60)
            )
        )
        .build();
        
        System.out.println(
            films.stream().collect(filmCollector)
        );
```
This will produce the following output:

```
{"maxLength":"3 hours and 5 minutes"}
```

#### Available Aggregators
All the available Aggregate Collectors are present as static methods in the `JsonCollectors`-class. These can be mixed and matched to produce very complex objects.

<dl class="dl-horizontal">
  <dt id="fractious">count()</dt>
  <dd>Counts the number of matched results</dd>
  <dt id="gratuitous">commaSeparated(field)</dt>
  <dd>Comma-separated distinct set of strings in alphabetical order</dd>
  <dt id="haughty">toList(encoder)</dt>
  <dd>list of JSON entities using encoder</dd>
  <dt id="benchmark_id">toList(field)</dt>
  <dd>list of field values</dd>
  <dt id="impertinent">min(field)</dt>
  <dd>the smallest value for a field (or null if empty)</dd>
  <dt id="intrepid">max(field)</dt>
  <dd>the greatest value for a field (or null if empty)</dd>
  <dt id="intrepid">average(field)</dt>
  <dd>the average value of a field (or null if empty)</dd>
  <dt id="intrepid">sum(field)</dt>
  <dd>the sum of the values of a field</dd>
  <dt id="intrepid">merge(field)</dt>
  <dd>if all values for field are the same, then that, otherwise null</dd>
</dl>

### Putting It All Together
If you combine encoders, collectors and aggregators into a stream, you could get something like this:

```java
System.out.println(
    films.stream()
        .filter(Film.DESCRIPTION.containsIgnoreCase("kill"))
        .collect(json.collector(Film.class)
            .put("from",    min(Film.TITLE))
            .put("to",      max(Film.TITLE))
            .put("count",   count())
            .put("ratings", commaSeparated(Film.RATING))
            .put("list", toList(json.<Film>emptyEncoder()
                .put(Film.TITLE)
                .put(Film.RATING)
                .put(Film.DESCRIPTION)
                .build()
            ))
            .build()
        )
);
```

**Result:**
```json
{
  "from" : "BACKLASH UNDEFEATED",
  "to" : "WORKING MICROCOSMOS",
  "count" : 43,
  "ratings" : "G,NC-17,PG,PG-13,R",
  "list" : [
    {
      "title" : "BACKLASH UNDEFEATED",
      "rating" : "PG-13",
      "description" : "A Stunning Character Study of a Mad Scientist And a Mad Cow who must Kill a Car in A Monastery"
    },
    {
      "title" : "BEAR GRACELAND",
      "rating" : "R",
      "description" : "A Astounding Saga of a Dog And a Boy who must Kill a Teacher in The First Manned Space Station"
    },
    ...
    {
      "title" : "WARDROBE PHANTOM",
      "rating" : "G",
      "description" : "A Action-Packed Display of a Mad Cow And a Astronaut who must Kill a Car in Ancient India"
    },
    {
      "title" : "WHALE BIKINI",
      "rating" : "PG-13",
      "description" : "A Intrepid Story of a Pastry Chef And a Database Administrator who must Kill a Feminist in A MySQL Convention"
    },
    {
      "title" : "WORKING MICROCOSMOS",
      "rating" : "R",
      "description" : "A Stunning Epistle of a Dentist And a Dog who must Kill a Madman in Ancient China"
    }
  ]
}
```

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="integration.html" %}
