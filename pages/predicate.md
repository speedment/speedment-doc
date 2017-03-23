---
permalink: predicate.html
sidebar: mydoc_sidebar
title: Speedment Predicates
keywords: Predicate, Stream
toc: false
Tags: Stream
previous: comparator.html
next: comparator.html
---

{% include prev_next.html %}

## What is a Predicate

A Java 8 {{site.data.javadoc.Predicate}} of type `T` is something that takes an object of type `T` and returns either `true` or `false` when its `test` method is called. Let us take a closer look at an example where we have a `Predicate<String>` that we want to return `true` if the `String` begins with an "A" and `false` otherwise:
``` java
    Predicate<String> startsWithA = (String s) -> s.startsWith("A");

    Stream.of("Snail", "Ape", "Bird", "Ant", "Alligator")
        .filter(startsWithA)
        .forEachOrdered(System.out::println);
```
This will print out all animals that starts with "A": Ape, Ant and Alligator because the `filter` operator will only pass forward those elements where its `Predicate` returns `true`.

In Speedment, the concept of a {{site.data.javadoc.Field}} are of central importance. Fields can be used to produce Predicates that are related to the field.

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `Hare` object:

``` java
    Predicate<Hare> startsWithH = Hare.NAME.greaterOrEqual("He");
    hares.stream()
        .filter(startsWithH)
        .forEachOrdered(System.out::println);
```
In this example, the {{site.data.javadoc.StringField}}'s method `User.NAME::greaterOrEqual` creates and returns a `Predicate<Hare>` that, when tested with a `Hare`, will return `true` if and only if that `Hare` has a `name` that comes on or after "He" in the alphabet (otherwise it will return `false`).

When run, the code above will produce the following output (given that there are three hares in the table with the name "Harry", "Henrietta" and "Henry"):
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (BINARY `hares`.`hare`.`name` >= 'He')
```

It would be possible to express the same semantics using a standard anonymous lambda:
``` java
    Predicate<Hare> greaterOrEqualH = h -> "He".compareTo(h.getName()) <= 0;
    hares.stream()
        .filter(greaterOrEqualH)
        .forEachOrdered(System.out::println);
```
but Speedment would not be able to recognize and optimize vanilla lambdas and will therefore produce the following SQL code:
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare`
```
Which will pull in the entire Hare table and then the predicate will be applied. Because of this, developers are highly encouraged to use the provided {{site.data.javadoc.Field}}s when obtaining predicates because these predicates, 
when used, will always be recognizable by the Speedment query optimizer. 

{% include important.html content="
Do This: `hares.stream().filter(Hare.NAME.greaterOrEqual("He"))` 
Don't do This: `hares.stream().filter("He".compareTo(h.getName()) <= 0)`
" %}

The rest of this chapter will be about how we can get predicates from different `Field` types and how these predicates can be combined and how they are rendered to SQL.

## Reference Predicates

The following methods are available to all {{site.data.javadoc.ReferenceField}}s (i.e. fields that are not primitive fields). In the table below, The "Outcome" is a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will return `true` if and only if:

| Method         | Param Type | Operation          | Outcome                                                |
| :------------- | :--------- | :----------------- | :----------------------------------------------------- |
| isNull         | N/A        | field == null      | the field is null                                      |
| isNotNull      | N/A        | field != null      | the field is not null                                  |

A {{site.data.javadoc.ReferenceField}} implements the interface trait {{site.data.javadoc.HasReferenceOperators}}.

## Reference Predicate Examples
Here is a list with examples for the *Reference Predicates*. The source code for the examples below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/predicate/ReferencePredicates.java)

### isNull
We can count all hares with a name that is null like this:
``` java
    long count = hares.stream()
        .filter(Hare.NAME.isNull())
        .count();
    System.out.format("There are %d hares with a null name %n", count);
```
The code will produce the following output:
``` text 
There are 0 hares with a null name 
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT COUNT(*) FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` IS NULL)
```

### isNotNull
We can count all hares with a name that is *not* null like this:
``` java
    long count = hares.stream()
        .filter(Hare.NAME.isNotNull())
        .count();
    System.out.format("There are %d hares with a non-null name %n", count);
```
The code will produce the following output:
``` text 
There are 3 hares with a non-null name 
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT COUNT(*) FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` IS NOT NULL)
```


## Comparable Predicates
The following additional methods are available to a {{site.data.javadoc.ReferenceField}} that is always associated to a `Comparable` field (e.g. `Integer`, `String`, `Date`, `Time` etc.). Comparable fields can be tested for equality and can also be compared to other objects of the same type. In the table below, the "Outcome" is a `Predicate<ENTITY>` that when tested with an object of type `ENTITY` will return `true`if and only if:

| Method         | Param Type | Operation                  | Outcome                                                |
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
| in             | `Set<V>`     |  p.contains(field)         | the `Set<V>` contains the field
| notIn          | `V[]`        |  array p does not contain field    | the array parameter does not contain the field
| notIn          | `Set<V>`     |  !p.contains(field)        | the `Set<V>` does not contain the field

{% include tip.html content = "
Fields that are `null` will never fulfill any of the predicates in the list above.
" %}
{% include tip.html content = "
The reason `equal` is not named `equals` is that the latter name is already used as a method name by the `Object` class (that every other class inherits from). The latter method has a different meaning than function than `equal` so a new name had to be used.
" %}

A {{site.data.javadoc.ComparableField}} implements the interface traits {{site.data.javadoc.HasReferenceOperators}} and {{site.data.javadoc.HasComparableOperators}}.

## Comparable Predicate Examples
Here is a list with examples for the *Comparable Predicates*. The source code for the examples below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/predicate/ComparablePredicates.java)

In the examples below, we assume that the database contains the following hares:

| Id | Hare                                                              |
| :- | :---------------------------------------------------------------- |
| 1  | HareImpl { id = 1, name = Harry, color = Gray, age = 3 }          |
| 2  | HareImpl { id = 2, name = Henrietta, color = White, age = 2 }     |
| 3  | HareImpl { id = 3, name = Henry, color = Black, age = 9 }         |


### equal
If we want to count all hares with an age that equals 3 we can write the following snippet:
``` java
    long count = hares.stream()
        .filter(Hare.AGE.equal(3))
        .count();

    System.out.format("There are %d hare(s) with an age of 3 %n", count);
```
The code will produce the following output:
``` text
There are 1 hare(s) with an age of 3 
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT COUNT(*) FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` = 3)
```

### notEqual
The following example shows a solution where we print out all hares that has an age that is *not* 3:
``` java
    hares.stream()
        .filter(Hare.AGE.notEqual(3))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT (`hares`.`hare`.`age` = 3))
```

### lessThan
The following example shows a solution where we print out all hares that has an age that is less than 3:
``` java
    hares.stream()
        .filter(Hare.AGE.lessThan(3))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` < 3)
```

### lessThan
The following example shows a solution where we print out all hares that has an age that is less or equal to 3:
``` java
    hares.stream()
        .filter(Hare.AGE.lessThan(3))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` <= 3)
```

### greaterThan
The following example shows a solution where we print out all hares that has an age that is greater than to 3:
``` java
    hares.stream()
        .filter(Hare.AGE.greaterThan(3))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` >= 3)
```

### greaterOrEqual
The following example shows a solution where we print out all hares that has an age that is greater than to 3:
``` java
    hares.stream()
        .filter(Hare.AGE.greaterOrEqual(3))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` >= 3)
```

### between
The following example shows a solution where we print out all hares that has an age that is between 3 (inclusive) and 9 (exclusive):
``` java
    hares.stream()
        .filter(Hare.AGE.between(3, 9))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` >= 3 AND `hares`.`hare`.`age` < 9)
```
There is also another variant of the `between` predicate where an  {{site.data.javadoc.Inclusion}} parameter determines if a range of results should be start and/or end-inclusive. 

For an example, take the series [1 2 3 4 5]. If we select elements *in* the range (2, 4) from this series, we will get the following results:

| # | `Inclusive` Enum Constant	                     | Included Elements |
| - | :--------------------------------------------- | :---------------- |
| 0 | `START_INCLUSIVE_END_INCLUSIVE`                | [2, 3, 4]         |
| 1 | `START_INCLUSIVE_END_EXCLUSIVE`                | [2, 3]            |
| 2 | `START_EXCLUSIVE_END_INCLUSIVE`                | [3, 4]            |
| 3 | `START_EXCLUSIVE_END_EXCLUSIVE`                | [3]               |

Here is an example showing a solution where we print out all hares that has an age that is between 3 (inclusive) and 9 (inclusive):
``` java
    hares.stream()
        .filter(Hare.AGE.between(3, 9, Inclusion.START_INCLUSIVE_END_INCLUSIVE))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` >= 3 AND `hares`.`hare`.`age` <= 9)
```

{% include tip.html content = "
The order of the two parameters `start` and `end` is significant. If the `start` parameter is larger than the `end` parameter, then the `between` `Predicate` will always evaluate to `false`.
" %}


### notBetween
The following example shows a solution where we print out all hares that has an age that is *not* between 3 (inclusive) and 9 (exclusive):
``` java
    hares.stream()
        .filter(Hare.AGE.notBetween(3, 9))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`age` >= 3 AND `hares`.`hare`.`age` <= 9)))
```
Note that the hare with age 9 is printed because 9 is outside the range 3 (inclusive) and 9 (exclusive) (because 9 is NOT in the range as 9 is exclusive).

There is also another variant of the `notBetween` predicate where an  {{site.data.javadoc.Inclusion}} parameter determines if a range of results should be start and/or end-inclusive. 

For an example, take the series [1 2 3 4 5]. If we select elements *not in* the range (2, 4) from this series, we will get the following results:

| # | `Inclusive` Enum Constant                      | Included Elements |
| - | :--------------------------------------------- | :---------------- |
| 0 | `START_INCLUSIVE_END_INCLUSIVE`                | [1, 5]            |
| 1 | `START_INCLUSIVE_END_EXCLUSIVE`                | [1, 4, 5]         |
| 2 | `START_EXCLUSIVE_END_INCLUSIVE`                | [1, 2, 5]         |
| 3 | `START_EXCLUSIVE_END_EXCLUSIVE`                | [1, 2, 4, 5]      |

Here is an example showing a solution where we print out all hares that has an age that is *not* between 3 (inclusive) and 9 (inclusive):
``` java
    hares.stream()
        .filter(Hare.AGE.notBetween(3, 9, Inclusion.START_INCLUSIVE_END_INCLUSIVE))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`age` >= 3 AND `hares`.`hare`.`age` <= 9)))
```

{% include tip.html content = "
The order of the two parameters `start` and `end` is significant. If the `start` parameter is larger than the `end` parameter, then the `notBetween` `Predicate` will always evaluate to `true`.
" %}


### in
Here is an example showing a solution where we print out all hares that has an age that is either 2, 3 or 4:
``` java
    hares.stream()
        .filter(Hare.AGE.in(2, 3, 4))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` IN (2,3,4))
```
There is also a variant of the `in` predicate that takes a `Set` as a parameter:
``` java
        Set<Integer> set = Stream.of(2, 3, 4).collect(toSet());

        hares.stream()
            .filter(Hare.AGE.in(set))
            .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` IN (2,3,4))
```

### notIn
Here is an example showing a solution where we print out all hares that has an age that is *neither* 2, 3 *nor* 4:
``` java
    hares.stream()
        .filter(Hare.AGE.notIn(2, 3, 4))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`age` IN (2,3,4))))
```
There is also a variant of the `noIn` predicate that takes a `Set` as a parameter:
``` java
        Set<Integer> set = Stream.of(2, 3, 4).collect(toSet());

        hares.stream()
            .filter(Hare.AGE.notIn(set))
            .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`age` IN (2,3,4))))
```

## String Predicates
The following additional methods (over {{site.data.javadoc.ReferenceField}}) are available to a {{site.data.javadoc.StringField}}:

| Method                  | Param Type   | Operation                  | Outcome                                                         |
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
Fields that are `null` will never fulfill any of the predicates in the list above.
" %}

A {{site.data.javadoc.StringField}} implements the interface traits {{site.data.javadoc.HasReferenceOperators}}, {{site.data.javadoc.HasComparableOperators}} and {{site.data.javadoc.HasStringOperators}}.

{% include note.html content = "
An informal notation of method references is made in the table above with \"!\" indicating the `Predicate::negate` method. I.e. it means that the Operation indicates a `Predicate` that will return the negated value. The notation \"ic\" means that the method reference shall be applied ignoring case
" %}

## String Predicate Examples
Here is a list with examples for the *String Predicates*. The source code for the examples below can be found [here on GitHub](https://github.com/speedment/speedment-doc-examples/blob/master/src/main/java/com/speedment/documentation/predicate/StringPredicates.java)

### isEmpty
The following example shows a solution where we print out the number hares that has a name that is empty (e.g. is equal to ""):
``` java
    long count = hares.stream()
        .filter(Hare.NAME.isEmpty())
        .count();

        System.out.format("There are %d hare(s) with an empty name %n", count);
```
The code will produce the following output:
``` text
There are 0 hare(s) with an empty name 
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT COUNT(*) FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` = '')
```

### isNotEmpty
The following example shows a solution where we print out the hares that has a name that is *not*  empty (e.g. is *not* equal to ""):
``` java
    hares.stream()
        .filter(Hare.NAME.isNotEmpty())
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` <> '')
```

### equalIgnoreCase
The following example shows a solution where we print out the hares that has a name that equals to "HaRry" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.equalIgnoreCase("HaRry"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (LOWER(`hares`.`hare`.`name`) = LOWER('HaRry'))
```

### notEqualIgnoreCase
The following example shows a solution where we print out the hares that has a name that does *not* equal to "HaRry" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.notEqualIgnoreCase("HaRry"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((LOWER(`hares`.`hare`.`name`) = LOWER('HaRry'))))
```

### startsWith
The following example shows a solution where we print out the hares that has a name that starts with "H":
``` java
    hares.stream()
        .filter(Hare.NAME.startsWith("H"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` LIKE BINARY CONCAT('H' ,'%'))
```

### notStartsWith
The following example shows a solution where we print out the hares that has a name that does *not* start with "H":
``` java
    hares.stream()
        .filter(Hare.NAME.notStartsWith("H"))
        .forEachOrdered(System.out::println);
```
The code will not produce any output since all the hare names start with "H":
``` text
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`name` LIKE BINARY CONCAT('H' ,'%'))))
```

### startsWithIgnoreCase
The following example shows a solution where we print out the hares that has a name that starts with "he" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.startsWithIgnoreCase("he"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (LOWER(`hares`.`hare`.`name`) LIKE BINARY CONCAT(LOWER('he') ,'%'))
```

### notStartsWithIgnoreCase
The following example shows a solution where we print out the hares that has a name that does *not* start with "he" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.notStartsWithIgnoreCase("he"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
 { id = 1, name = Harry, color = Gray, age = 3 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((LOWER(`hares`.`hare`.`name`) LIKE BINARY CONCAT(LOWER('he') ,'%'))))
```

### endsWith
The following example shows a solution where we print out the hares that has a name that ends with "y":
``` java
    hares.stream()
        .filter(Hare.NAME.endsWith("y"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` LIKE BINARY CONCAT('%', 'y'))
```

### notEndsWith
The following example shows a solution where we print out the hares that has a name that does *not* end with "y":
``` java
    hares.stream()
        .filter(Hare.NAME.notEndsWith("y"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`name` LIKE BINARY CONCAT('%', 'y'))))
```

### endsWithIgnoreCase
The following example shows a solution where we print out the hares that has a name that ends with "Y" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.endsWithIgnoreCase("Y"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (LOWER(`hares`.`hare`.`name`) LIKE BINARY CONCAT('%', LOWER('Y')))
```

### notEndsWithIgnoreCase
The following example shows a solution where we print out the hares that has a name that does *not* start with "Y" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.notEndsWithIgnoreCase("Y"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
 HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((LOWER(`hares`.`hare`.`name`) LIKE BINARY CONCAT('%', LOWER('Y')))))
```

### contains
The following example shows a solution where we print out the hares that has a name that contains the string "tt":
``` java
    hares.stream()
        .filter(Hare.NAME.contains("tt"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` LIKE BINARY CONCAT('%', 'tt' ,'%'))
```

### notContains
The following example shows a solution where we print out the hares that has a name that does *not* contain the string "tt":
``` java
    hares.stream()
        .filter(Hare.NAME.notContains("tt"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`name` LIKE BINARY CONCAT('%', 'tt' ,'%'))))
```

### containsIgnoreCase
The following example shows a solution where we print out the hares that has a name that contains the string "Tt" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.containsIgnoreCase("Tt"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (LOWER(`hares`.`hare`.`name`) LIKE BINARY CONCAT('%', LOWER('Tt') ,'%'))
```

### notContainsIgnoreCase
The following example shows a solution where we print out the hares that has a name that does *not* contain the string "Tt" ignoring case:
``` java
    hares.stream()
        .filter(Hare.NAME.notContainsIgnoreCase("Tt"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((LOWER(`hares`.`hare`.`name`) LIKE BINARY CONCAT('%', LOWER('Tt') ,'%'))))
```


## Negating Predicates
All predicates can be negated by calling the `negate()` method. Negation means that the result of the Predicate will be inverted (i.e. `true` becomes `false` and `false` becomes `true`). Here is a list of predicates and their corresponding negation:

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

so, for example, `Hare.ID.equal(1).negate()` is equivalent to `Hare.ID.notEqual(1)` and `Hare.ID.between(1,100).negate()` is equivalent to `Hare.ID.notBetween(1, 100)`.

{% include tip.html content = "
Negating a `Predicate` an even number of times will give back the original `Predicate`. E.g. `Hare.ID.equal(1).negate().negate()` is equivalent to `Hare.ID.equal(1)`
" %}

## Combining Predicates
A predicate Predicate can be composed of other predicates by means of the `and()` and `or()` methods as shown in the examples below. 

### and
The `and()` method returns a composed predicate that represents a short-circuiting logical AND of a first predicate and another given second predicate. When evaluating the composed composed predicate, if the first predicate is evaluated to `false`, then the second predicate is not evaluated.

The following code sample will print out all hares that are adults (apparently a hare is adult when its age is greater than 2) and that has a name that contains the letter 'e':
``` java
    Predicate<Hare> isAdult = Hare.AGE.greaterThan(2);
    Predicate<Hare> nameContains_e = Hare.NAME.contains("e");

    Predicate<Hare> isAdultAndNameContains_e = isAdult.and(nameContains_e);

    hares.stream()
        .filter(isAdultAndNameContains_e)
        .forEachOrdered(System.out::println);
```
This will produce the following output:
``` text
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` > 2) AND (`hares`.`hare`.`name` LIKE BINARY CONCAT('%', 'e' ,'%'))
```

The same result can be achieved by just stacking two `filter` operations on top of each other. So this:
``` java
    hares.stream()
        .filter(Hare.AGE.greaterThan(2))
        .filter(Hare.NAME.contains("e"))
```
is equivalent to:
``` java
    hares.stream()
        .filter(Hare.AGE.greaterThan(2).and(Hare.NAME.contains("e")))
```

### or
Returns a composed predicate that represents a short-circuiting logical OR of a first predicate and another given second predicate. When evaluating the composed composed predicate, if the first predicate is evaluated to `true`, then the second predicate is not evaluated.
The following code sample will print out all hares that are adults (age > 2) and that has a name that contains the letter 'e':
``` java
    Predicate<Hare> isAdult = Hare.AGE.greaterThan(2);
    Predicate<Hare> nameContains_e = Hare.NAME.contains("e");

    Predicate<Hare> isAdultOrNameContains_e = isAdult.or(nameContains_e);

    hares.stream()
        .filter(isAdultOrNameContains_e)
        .forEachOrdered(System.out::println);
```
This will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare`
```
As can be seen, Speedment is currently unable to optimize predicates that are composed using the `or()` method. See issue [#389](https://github.com/speedment/speedment/issues/389)

As for the `and()` method, there is an equivalent way of expressing compositions with `or()`. Here is an example of how streams can be concatenated whereby we obtain the same functionality as above:
``` java
    StreamComposition.concatAndAutoClose(
        hares.stream().filter(Hare.AGE.greaterThan(2)),
        hares.stream().filter(Hare.NAME.contains("e"))
    )
        .distinct()
        .forEachOrdered(System.out::println);
```
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 3, name = Henry, color = Black, age = 9 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL queries (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` > 2)
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`name` LIKE BINARY CONCAT('%', 'e' ,'%'))
```
In this case, optimized queries will be used for the two sub-streams.



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

## Examples
In the example below we want to print all hares that has a `color` that is either "Gray" or "White", has an `age` greater than 1 and has a `name` that lies in the first half of the alphabet:
``` java
    hares.stream()
        .filter(Hare.COLOR.in("Gray", "White"))
        .filter(Hare.AGE.greaterThan(1))
        .filter(Hare.NAME.between("A", "K"))
        .forEachOrdered(System.out::println);
```
The code will produce the following output:
``` text
HareImpl { id = 1, name = Harry, color = Gray, age = 3 }
HareImpl { id = 2, name = Henrietta, color = White, age = 2 }
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age`
FROM `hares`.`hare` 
WHERE 
        (BINARY `hares`.`hare`.`color` IN ('Gray','White')) 
    AND
        (`hares`.`hare`.`age` > 1)
    AND
        (`hares`.`hare`.`name` >= 'A' AND `hares`.`hare`.`name` < 'K')
```

{% include prev_next.html %}

## Discussion
Join the discussion here or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="predicate.html" %}

