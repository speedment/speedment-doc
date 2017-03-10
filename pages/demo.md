---
permalink: demo.html
sidebar: mydoc_sidebar
title: Demo of Components
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


## Tips

{% include note.html content = "This is a note. If you have \"quotes\", you must escape them." %}

{% include tip.html content="This is a tip" %}

{% include warning.html content="This is a warning" %}

{% include important.html content="This is important" %}

{% include callout.html content="This is a callout" type="primary" %}


## Warning
TBW

## Images
{% include image.html file="spire.png" alt="Jekyll" caption="This is a sample caption" %}

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
