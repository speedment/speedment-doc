---
permalink: sharding.html
sidebar: mydoc_sidebar
title: Sharding
keywords: Sharding, Data Store
toc: false
Tags: Sharding
previous: aggregations.html
next: computation.html
---

{% include prev_next.html %}

## Sharding
Sharding can be used to sub-divide different data sets into several Speedment instances.

### Immutable Sharding
Immutable sharding means that the set of shard keys will be defined before hand. Once all shards has been defined, they can all
be loaded into memory in a single operation.

TBW

### Mutable Sharding
Mutable sharding means that the set of shard key can be dynamically managed (added and removed) on demand. Thus, the set of chard keys must not be known in advance.

TBW

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="computation.html" %}
