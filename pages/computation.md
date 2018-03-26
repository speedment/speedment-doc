---
permalink: computation.html
sidebar: mydoc_sidebar
title: General Computation
keywords: Data Store, Computation, Compute
toc: false
Tags: Compute
previous: datastore.html
next: enterprise_plugins.html
---

{% include prev_next.html %}

## General Computation
It is possible to use Speedment as a General Computation model whereby results are computed between several Speedment instances. Each successive step will read directly from memory from a previous stage and not from a regular database. 


| Step # | Data Source            | Action
| :----- | :--------------------- | ------------------------------- |
|  0     | Database               | The initial step reads from a general data source as per default case.
|  1     | Step 0                 | Step 1 reads input data from Step 0
|  2     | Step 0 and/or Step 1   | Step 1 reads input data from any previous step 0, 1
|  ...   | ...                    | ...
|  N     | Step (0..N-1)          | Step N reads input data from any previous step 0, 1, ..., N-1


### Setup
TBW

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="computation.html" %}
