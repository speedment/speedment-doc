---
permalink: introduction.html
sidebar: mydoc_sidebar
title: Introduction
keywords: Speedment, Preface, Editions, Arcitecture, Plugins, Licensing, Support, JavaDoc, Contributing
toc: false
Tags: Introduction, Preface, License
previous: introduction.html
next: stream_fundamentals.html
---

{% include prev_next.html %}

## What is Speedment?
__Speedment is a Java 8 Stream ORM Toolkit and Runtime__ 

### One-liner
Search for an old `Hare` (of age greater than 5):
```java
// Searches are optimized in the background!
Optional<Hare> oldHare = hares.stream()
    .filter(Hare.AGE.greaterThan(5))
    .findAny();
``` 

Results in the following SQL query:
```sql
SELECT id, name, color, age FROM hare 
    WHERE (age > 5)
    LIMIT 1;
```

No need for manually writing SQL-queies any more. Remain in a pure Java world!

### Expressing SQL as Java 8 Streams
When we started the open-source project Speedment, the main objective was to remove the polyglot requirement for Java database application developers. After all, we all love Java and why should we need to know SQL when, instead, we could derive the same semantics directly from Java streams? When one takes a closer look at this objective, it turns out that there is a remarkable resemblance between Java streams and SQL as summarized in this simplified table:

| SQL         | Java 8 Stream Equivalent          |
| :---------- | :-------------------------------- |
| `FROM`       | `stream()`   |
| `SELECT`     | `map()`      |
| `WHERE`      | `filter()` (before collecting) |
| `HAVING`     | `filter()` (after collecting) |
| `JOIN`       | `flatMap()`  |
| `DISTINCT`   | `distinct()` |
| `UNION`      | `concat().distinct()` |
| `ORDER BY`   | `sorted()`   |
| `OFFSET`     | `skip()`     |
| `LIMIT`      | `limit()`    |
| `GROUP BY`   | `collect(groupingBy())` |
| `COUNT`      | `count()`    |

Speedment allows all these Stream operations to be used.

### Additional Features
Here are some of the many other features packed into the Speedment tool!

#### Database centric
Speedment is using the database as the source-of-truth, both when it comes to the domain model and the actual data itself. Perfect if you are tired of configuring and debuging complex ORMs. After all, your data is more important than programming tools, is it not?

#### Code generation
Speedment inspects your database and can automatically generate code that reflects the latest state of your database. Nice if you have changed the data structure (like columns or tables) in your database. Optionally, you can change the way code is generated using an intuitive UI or programatically using your own code.

#### Modular Design
Speedment is built with the ambition to be completely modular! If you don’t like the current implementation of a certain function, plug in you own! Do you have a suggestion for an alternative way of solving a complex problem? Share it with the community!

#### Type Safety
When the database structure changes during development of a software there is always a risk that bugs sneak into the application. Thats why type-safety is such a big deal! With Speedment, you will notice if something is wrong seconds after you generate your code instead of weeks into the testing phase.

#### Null Protection
Ever seen a `NullPointerException` suddenly thrown out of nowhere? Null-pointers have been called the billion-dollar-mistake of java, but at the same time they are used in almost every software project out there. To minimize the production risks of using null values, Speedment analyzes if null values are allowed by a column in the database and wraps the values as appropriate in Java 8 Optionals.


## Speedment Resources

### JavaDoc
On-line JavaDocs are available [here](http://www.javadoc.io/doc/com.speedment/runtime-deploy/{{site.data.speedment.version}})

### Release Notes
Please refer to the [Release Notes documents](https://github.com/speedment/speedment/releases) for new features, enhancements and fixes performed for each Speedment release.

## Fast Facts About Speedment
Here are some fast facts about Speedment:

### Supported Java Versions
Speedment supports Java 8 and upwards. Earlier Java versions are not supported because they do not support Streams.

### Speedment Editions
This Reference Manual covers all editions of Speedment:
  * **Speedment** referes to the open-source edition of the product that can connect to open-source databases. It is also the name of the company (Speedment, Inc.) that provides the Speedment products.
  * **Speedment Enterprise**, is a commercially licensed product providing connectivity to commercial databases like Oracle, SQL Server, DB2, AS400 etc. Speedment Enterprise also contains in-JVM-memory acceleration and other enterprise features.

### Speedment Plugins
We can extend Speedment's functionality by using one or several plugins in the form of {{site.data.javadoc.TypeMapper}}s, Components and/or {{site.data.javadoc.InjectBundle}}s. These plugins have their own lifecycles. It is possible for anyone to write a Speedment plugin.

### Licensing
Speedment open-source is licensed under the Apache 2 license. Speedment Enterprise is licensed under a commercial license.

### Customer Support
Open-source support for Speedment is provided on a best effort bases via [GitHub](https://github.com/speedment/speedment/issues), [Gitter](https://gitter.im/speedment/speedment) and [StackOverflow](http://stackoverflow.com/questions/tagged/speedment)

Commercial support can be purcased for both Speedment and Speedment Enterprise. Read more on [speedment.com](http://www.speedment.com)

### Contributing to Speedment
Speedment is open-source and so we are happy to accept pull requests and improvement suggestions from the community. Read more [here](https://github.com/speedment/speedment/blob/master/CONTRIBUTING.md) on how to contribute to Speedment.

### Phone Home
Speedment sends certain data back to our servers as described [here](https://github.com/speedment/speedment/blob/master/DISCLAIMER.MD) 

{% include prev_next.html %}
