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
This will print out all animals that starts with "A": Ape, Ant and Alligator.


Another thing of central importance in Speedment is the concept of a {{site.data.javadoc.Field}}. Fields can be used to produce Predicates that are related to the field.

Here is an example of how a {{site.data.javadoc.StringField}} can be used in conjuction with a `Hare` object:

``` java
    Predicate<Hare> isOld = Hare.AGE.greaterThan(5);
    hares.stream()
        .filter(isOld)
        .forEachOrdered(System.out::println);
```
In this example, the {{site.data.javadoc.StringField}}'s 
method `User.NAME::greaterThan` creates and returns a `Predicate<Hare>` that, when 
tested with a `Hare`, will return `true` if and only if that `Hare` has an age that 
is grater than 5, otherwise it will return `false`. When run, the code above will produce the following SQL code:
``` sql
    SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (`hares`.`hare`.`age` > 5)
```

It would be possible to express the same semantics using a standard anonymous lambda:
``` java
    Predicate<Hare> isOld = h -> h.getAge() > 5;
    hares.stream()
        .filter(isOld)
        .forEachOrdered(System.out::println);
```
but Speedment would not be able to recognize and optimize vanilla lambdas and will therefore produce the following SQL code:
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare`
```
Because of this, developers are encouraged to use the provided {{site.data.javadoc.Field}}s when obtaining predicates because these predicates, 
when used, will always be recognizable by the Speedment query optimizer. 

{% include important.html content="
Do This: `hares.stream().filter(Hare.AGE.greaterThan(5))` 
Don't do This: `hares.stream().filter(h -> h.getAge() > 5)`
" %}

The rest of this chapter will be about how we can get predicates from different `Field` types.

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

| Hare                                                              |
| :---------------------------------------------------------------- |
| HareImpl { id = 1, name = Harry, color = Gray, age = 3 }          |
| HareImpl { id = 2, name = Henrietta, color = White, age = 2 }     |
| HareImpl { id = 3, name = Henry, color = Black, age = 9 }         |


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

| Enum Constant	                | Included Elements |
| :---------------------------- | :---------------- |
| START_INCLUSIVE_END_INCLUSIVE	| [2, 3, 4]         |
| START_INCLUSIVE_END_EXCLUSIVE	| [2, 3]            |
| START_EXCLUSIVE_END_INCLUSIVE	| [3, 4]            |
| START_EXCLUSIVE_END_EXCLUSIVE	| [3]               |

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

| Enum Constant	                | Included Elements |
| :---------------------------- | :---------------- |
| START_INCLUSIVE_END_INCLUSIVE	| [1, 5]            |
| START_INCLUSIVE_END_EXCLUSIVE	| [1, 4, 5]         |
| START_EXCLUSIVE_END_INCLUSIVE	| [1, 2, 5]         |
| START_EXCLUSIVE_END_EXCLUSIVE	| [1, 2, 4, 5]      |

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
The code will not produce any output since all the hares' name starts with "H":
``` text
```
and will be rendered to the following SQL query (for MySQL):
``` sql
SELECT `id`,`name`,`color`,`age` FROM `hares`.`hare` WHERE (NOT((`hares`.`hare`.`name` LIKE BINARY CONCAT('H' ,'%'))))
```

### startsWithIgnoreCase

### notStartsWithIgnoreCase

### endsWith

### notEndsWith

### endsWithIgnoreCase

### notEndsWithIgnoreCase

### contains

### notContains

### containsIgnoreCase

### notContainsIgnoreCase



## Negating Predicates

## Combining Predicates
TBW .filter(p1).filter(p2) == filter(p1.and(p2))


## Primitive Predicates
For performance reasons, there are a number of primitive fields available in addition to reference field. By using a primitive field, unnecessary boxing and auto-boxing cam be avoided. Primitive fields also generates primitive predicates like `IntPredicate` or `LongPredicate`

### IntPrimitiveField
TBW

### LongPrimitiveField
TBW

### DoublePrimitiveField
TBW

### ShortPrimitiveField
TBW

### BytePrimitiveField
TBW

### FloatPrimitiveField
TBW

## Examples
TBW

{% include prev_next.html %}
