---
permalink: application_configuration.html
sidebar: mydoc_sidebar
title: Application Configuration
keywords: Configuration, Application
toc: false
Tags: Configuration, Application
previous: application_configuration.html
next: application_configuration.html
---

{% include prev_next.html %}

## Why Configure?
Most Speedment configuration is done automatically during inspection of the database meta data model including things like tables, columns, user name and connection URL. However, many times we need to override one or several configuration parameters, for example if we deploy our application and want it to connect to a different database compared to what we used for development.

There is one thing that we always need to configure and that is the database password. For security reasons, Speedment never stores the database password in generated classes or configuration files.

Configuration is done using an ApplicationBuilder that is generated for your project. Once the `ApplicationBuilder` is configured, its `build()` method is called and a configured `Application` is returned. Upon building, all the configuration parameters are frozen (made immutable) in the returned `Application`.
Check out the official JavaDoc about {{site.data.javadoc.ApplicationBuilder}} for more detailed information about configuration.

## Configurations
The table below summarizes the most important methods of the `ApplicationBuilder`:

| Method         | Parameters             | Description              |
| :------------- | :--------------------- | :----------------------- |
| `withPassword` | `String` or `char[]`   | Sets the password of     |



## Logging
TBW



## Examples

### Default Configuration
The following example shows the most simple solution where we accept all the default configurations and where we do not have a password set for the database (needless to say, you should always protect your database with a password).
``` java
    SakilaApplication app = new SakilaApplicationBuilder().build();
```

### Setting the Database Password
The following example shows the most simple solution where we accept all the default configurations and where we do not have a password set for the database (needless to say, you should always protect your database with a password).
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
    .withPassword("Jz237@h1J19!")
    .build();
```


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="application_configuration.html" %}