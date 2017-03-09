---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
Tags: Stream
---

## Predicate

Predicates are...

## Examples

To install the Speedment Maven Plugin we just add it as a plugin in our pom.xml file as described hereunder:

``` java
    Optional<User> johnSmith = users.stream()
        .filter(User.ID.equal("john.smith")
        .findAny();
```


## Object Predicates
TBW

## Comparable Predicates
TBW

## String Predicates
TBW
