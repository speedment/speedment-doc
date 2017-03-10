---
permalink: demo.html
sidebar: mydoc_sidebar
title: Demo of compoents
keywords: Demo
Tags: Demo
---

## Level 2
Arne 2

### Level 3
Arne 3

#### Level 4
Arne 4

##### Level 5
Arne 5

## Table
Here is the table:

| Method       | Parameter | Outcome                                                |
| :----------  | :-------: | -----------------------------------------------------: |
| left         | Center    | Right                                   |

## Java Code

``` java
    Optional<User> johnSmith = users.stream()
        .filter(u -> "John Smith".equals(u.getName())
        .findAny();
```

## SQL code

``` sql
    SELECT * FROM user;
```

## XML code

``` xml
    <config>
        <debug>true</debug>
    </config>
```

## Javadoc Ref
Check out {{site.data.javadoc.ReferenceField}} for info.


## Alert
<div markdown="span" class="alert alert-info" role="alert">
    <i class="fa fa-info-circle"></i>
    <b>Note:</b> 
    Remember to do this. If you have \"quotes\", you must escape them.
</div>

{% include note.html content = "This is a note. If you have \"quotes\", you must escape them." %}

{% include tip.html content="This is a tip" %}


## Warning
TBW

## Images
TBW

## Reference to Other Part
TBW

## Refs {#refs}
Reference within a [page](#refs) like this

## Foo
TBW

## Google Analytics
TBW

## Edit Me On GitHub
Check out this on the top of this page...  :-)
