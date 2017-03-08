---
title: Speedment User's Guide
keywords: speedment orm java documentation database jdbc stream lambda
tags: [getting_started]
sidebar: mydoc_sidebar
permalink: index.html
summary: Learn how to connect a Java 8 Stream to a SQL database in an extremely efficient manner.
---

<img src="https://raw.githubusercontent.com/speedment/speedment-resources/master/src/main/resources/wiki/frontpage/Forest.png" alt="Spire the Hare" title="Spire" align="right" width="240px" />

Speedment is a Java Stream ORM toolkit and runtime. 
The toolkit analyzes the metadata of an existing legacy SQL database 
and creates a Java representation of the data model which together with 
the Speedment runtime allows the user to create scalable and efficient 
Java applications using **standard Java 8** streams without any
specific query language or any new API. 

### One-liner
Search for an old hare (of age greater than 5):
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

Documentation
-------------
You can read the [API quick start examples here](https://github.com/speedment/speedment#examples)!

## Tutorials
* [Tutorial 1 - Set up the IDE](https://github.com/speedment/speedment/wiki/Tutorial:-Set-up-the-IDE)
* [Tutorial 2 - Get started with the UI](https://github.com/speedment/speedment/wiki/Tutorial:-Get-started-with-the-UI)
* [Tutorial 3 - Hello Speedment](https://github.com/speedment/speedment/wiki/Tutorial:-Hello-Speedment)
* [Tutorial 4 - Build a Social Network](https://github.com/speedment/speedment/wiki/Tutorial:-Build-a-Social-Network)
* [Tutorial 5 - Log errors in a database](https://github.com/speedment/speedment/wiki/Tutorial:-Log-errors-in-a-database)
* [Tutorial 6 - Use Speedment with Java EE](https://github.com/speedment/speedment/wiki/Tutorial:-Use-Speedment-with-Java-EE)
* [Tutorial 7 - Writing your own extensions](https://github.com/speedment/speedment/wiki/Tutorial:-Writing-your-own-extensions)
* [Tutorial 8 - Plug-in a Custom TypeMapper](https://github.com/speedment/speedment/wiki/Tutorial:-Plug-in-a-Custom-TypeMapper)
* [Tutorial 9 - Create Event Sourced Systems](https://github.com/speedment/speedment/wiki/Tutorial:-Create-an-Event-Sourced-System)

Quick Start
