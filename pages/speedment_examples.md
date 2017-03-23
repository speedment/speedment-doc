---
permalink: speedment_examples.html
sidebar: mydoc_sidebar
title: Speedment Examples
keywords: Stream, Examples
toc: false
Tags: Stream, Examples
previous: introduction.html
next: getting_started.html
---

{% include prev_next.html %}

This chapter contains a number of typical database queries that can be expressed using Speedment streams.
The example below are based on four tables named "Hare", "Carrot", "Human" and "Friend" 
and the definition of these tables are listed at the end of this chapter [here](speedment_examples.html#database-schema). An object that corresponds to a row in the database are, by convention, called an "Entity'.

## From
Speedment Streams can be created using a {{site.data.javadoc.Manager}}. Each table in the database has a corresponding `Manager`. For example, the table 'hare' has a corresponding `Manager<Hare>` allowing us to do like this:
``` java
   hares.stream()
```
which will create a `Stream` with all the `Hare` entities in the table 'hare'.


## Where
By applying a `filter` to a `Stream`, certain entities can be retained in the `Stream` and other entities can be dropped. For example, 
if we want to find an old hare (of age greater than 5) then we can apply a `filter` like this:

``` java
// Searches are optimized in the background!
Optional<Hare> oldHare = hares.stream()
    .filter(Hare.AGE.greaterThan(5))
    .findAny();
```
One important property with Speedment streams are that they are able to optimize its own pipeline by introspection. It looks like the `Stream` will iterate over all 
rows in the 'hare' table but this is not the case. Instead, Speedment is able to optimize the SQL query in the background and will instead issue the command:
``` sql
SELECT id, name, color, age FROM hare 
    WHERE (age > 5);
```
This means that only the relevant entities are pulled in from the database into the `Stream`.

## Select
If we do not want to use the entire entity but instead only select one or several fields, we can do that by applying a `map` operation to a `Stream`. Assuming we are only interested in the field 'id' of a `Hare` we can select that field like this:
``` java
// Creates a stream with the ages of the hares by applying the AGE getter
final IntStream ages = hares.stream()
    .mapToInt(Hare.AGE.getter());
```
This creates an `IntStream` consisting of the ages of all `Hare`s by applying the Hare.AGE getter for each hare in the original stream.

If we want to select several fields, we can create a new custom class that holds only the fields in question or we can use a {{site.data.javadoc.Tuple}} to dynamically create a type safe holder.
``` java
// Creates a stream of Tuples with two elements: id and name
Stream<Tuple2<Integer, String>> items = hares.stream()
    .map(h -> Tuples.of(h.getId(), h.getName()))

```
This creates a stream of Tuples with two elements: id (of type `Integer`) and Name (of type `String`)

## Group By

## Having

## Joining

## Distinct

## Distinct

## Order By

## Offset

## Limit

## Group By

## Count
(stream().filter().map().sort().count() -> select * where...)


## Other examples

### Partition By
Collectors.partitioningBy(x -> x > 50)


## Database Schema

``` sql
CREATE DATABASE 'hares';
USE 'hares';

CREATE TABLE `hares`.`hare` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `color` varchar(45) NOT NULL,
  `age` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=100;

CREATE TABLE IF NOT EXISTS `hares`.`carrot` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `owner` int(11) NOT NULL,
  `rival` int(11),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=100;

CREATE TABLE IF NOT EXISTS `hares`.`human` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=100;

CREATE TABLE `hares`.`friend` (
  `hare` int(11) NOT NULL,
  `human` int(11) NOT NULL,
  PRIMARY KEY (`hare`, `human`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `hares`.`carrot`
  ADD CONSTRAINT `carrot_owner_to_hare_id` FOREIGN KEY (`owner`) REFERENCES `hare` (`id`);
ALTER TABLE `hares`.`carrot`
  ADD CONSTRAINT `carrot_rival_to_hare_id` FOREIGN KEY (`rival`) REFERENCES `hare` (`id`);

ALTER TABLE `hares`.`friend`
  ADD CONSTRAINT `friend_hare_to_hare_id` FOREIGN KEY (`hare`) REFERENCES `hare` (`id`);
ALTER TABLE `hares`.`friend`
  ADD CONSTRAINT `friend_human_to_human_id` FOREIGN KEY (`human`) REFERENCES `human` (`id`);
```

## Database Content

``` sql
USE 'hares';

INSERT INTO `hares`.`hare` (`id`,`name`,`color`,`age` ) VALUES (1,'Harry','Gray',3);
INSERT INTO `hares`.`hare` (`id`,`name`,`color`,`age` ) VALUES (2,'Henrietta','White',2);
INSERT INTO `hares`.`hare` (`id`,`name`,`color`,`age` ) VALUES (3,'Henry','Black',9);

INSERT INTO `hares`.`carrot` (`id`,`name`,`owner`, `rival`) VALUES (1,'The big one',1,3);
INSERT INTO `hares`.`carrot` (`id`,`name`,`owner`, `rival`) VALUES (2,'Orange',1,2);
INSERT INTO `hares`.`carrot` (`id`,`name`,`owner`, `rival`) VALUES (3,'The small',2,null);
INSERT INTO `hares`.`carrot` (`id`,`name`,`owner`, `rival`) VALUES (4,'The old and rotten',3,null);

INSERT INTO `hares`.`human` (`id`,`name`) VALUES (1,'Alice');
INSERT INTO `hares`.`human` (`id`,`name`) VALUES (2,'Bob');

INSERT INTO `hares`.`friend` (`hare`,`human`) VALUES (1,1);
INSERT INTO `hares`.`friend` (`hare`,`human`) VALUES (2,1);
INSERT INTO `hares`.`friend` (`hare`,`human`) VALUES (3,1);
INSERT INTO `hares`.`friend` (`hare`,`human`) VALUES (3,2);

commit;
```


{% include prev_next.html %}

