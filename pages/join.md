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

The `JoinComponent` can be used to create type safe joins between tables. Any number between two and six tables can be joined.


## Join Types
The following join types are supported:

| Join Type      |  Method       | Description of Join Output                           |
| :------------- | :------------ | :---------------------------------------------------------------------------------- |
| INNER JOIN     | innerJoinOn() | A Stream with entities from tables (A and B) in the join with matching column values. Inner join creates Tuples by combining entities from two tables (A and B) based upon the join-predicate. The query compares each entity of A with each entity of B to find all pairs of entities which satisfy the join-predicate. When the join-predicate is satisfied by matching non-NULL values, entities for each matched pair of rows of A and B are combined into a result Tuple.
| LEFT JOIN      | leftJoinOn()  | A Stream with entities from tables (A and B) in the join with matching column values or just an entity from A. The result of a left join for tables A and B always contains all entities of the "left" table (A), even if the join-condition does not find any matching row in the "right" table (B). This means that if the ON clause matches 0 (zero) entities in B (for a given entity in A), the join will still return an entity in the result Tuple (for that row)—but with an entity from B that is `null` in the Tuple. A left join returns all the values from an inner join plus all values in the left table (A) that do not match to the right table (B), including rows with NULL (empty) values in the linking column.
| RIGHT JOIN     | rightJoinOn() | A Stream with entities from tables (A and B) in the join with matching column values or just an entity from B. The result of a right join for tables A and B always contains all entities of the "right" table (B), even if the join-condition does not find any matching row in the "left" table (A). This means that if the ON clause matches 0 (zero) entities in A (for a given entity in B), the join will still return a entity in the result Tuple (for that row)—but with an entity from A that is `null` in the Tuple. A right join returns all the values from an inner join plus all values in the left table (B) that do not match to the right table (A), including rows with NULL (empty) values in the linking column.
| CROSS JOIN     | crossJoin()   | A Stream with Cartesian products of entities from tables in the join. In other words, it will produce a Stream with Tuples from two tables (A and B) which combine each entity from the A table with each entity from the B table.

Left Join and Right Join creates Tuples with entities that are `null` for elements that are not part of the inner set. 

Below is a picture of the different set of Tuples a join can produce. The yellow circle marked with A is the "left" table and the blue circle marked with B is the "right" table. The middle set marked 2 represents Tuple(A entity, B entity) of entities where the join-condition matches. The set marked 1 represents Tuples(A entity, null) of A entities where the join-condition have no match in B. Finally, set marked 3 represents Tuples(null, B entity) of B entities where the join-condition have no match in A.

{% include image.html file="JoinTypes.png" alt="Join Types" caption="The different join areas" %}

Given the picture above, the joins produces Tuples as indicated in the following table:

| Join Type      |  Method       | Tuples from the Set       |
| :------------- | :------------ | :------------------------ |
| INNER JOIN     | innerJoinOn() | {2}
| LEFT JOIN      | leftJoinOn()  | {1, 2}
| RIGHT JOIN     | rightJoinOn() | {2, 3}

{% include tip.html content= "
A `FULL OUTER JOIN` can be obtained by creating a concatenation of distinct elements from a `LEFT JOIN` and a `RIGHT JOIN` like this: `crossJoinStream = Stream.concat(leftJoin.stream(), rightJoin.stream()).distinct()`. However, because the stream is using the `.distinct()` operation, it must first produce all elements in the Stream before they can be consumed.
" %}

## Join Operations
The most common way of joining tables is by means of an equality operation. However, tables can be joined by means of a number of operations as indicated in the table below:


| Operation      | Effect
| :------------- | :----------------------------------------------------------------------------------- |
| equal()        | Matches columns from table A that is equal to a column in table B
| notEqual()     | ne
| lessThan()     | lt
| lessOrEqual()  | le


## Join Streams
Join objects...

## Tuple Constructors
By default, tuples are of type `TupleXOfNullables` where X is the number of tables that are joined. If you are using only 'INNER JOIN' or 'CROSS JOIN', the entities are never `null` and this allows us to use `TupleX` instead. In fact, any java object can be used as a tuple by providing a custom constructor in the `JoinComponent`s `build()` method.

## Examples

### Cross Join

### Self Join


## Limitations
TBW


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="join.html" %}
