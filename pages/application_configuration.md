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

Configuration is done using an `ApplicationBuilder` that is generated for your project. Once the `ApplicationBuilder` is configured, its `build()` method is called and a configured `Application` is returned. Upon building, all the configuration parameters are frozen (made immutable) in the returned `Application`. 

## Configurations
The table below summarizes the most important methods of the `ApplicationBuilder`. Check out the official JavaDoc about the  {{site.data.javadoc.ApplicationBuilder}} for more detailed information about all configuration methods.

| Method               | Parameters                      | Description                                                                                   |
| :------------------- | :------------------------------ | :-------------------------------------------------------------------------------------------- |
| `withPassword`       | `String`                        | Sets the password to use when connecting to the database. (*)                                 |
| `withPassword`       | `char[]` (i)                    | Sets the password to use when connecting to the database. (*)                                 |
| `withPassword`       | `HasDatabaseName`, `String`     | Sets the password to use when connecting to the identified database. (**)                     |
| `withPassword`       | `HasDatabaseName`, `char[]` (i) | Sets the password to use when connecting to the identified database. (**)                     |
| `withUsername`       | `String`                        | Sets the username to use when connecting to the database. (*)                                 |
| `withUsername`       | `HasDatabaseName`, `String`     | Sets the username to use when connecting to the identified database. (**)                     |
| `withIpAddress`      | `String`                        | Sets the IP address to use when connecting to the database. (*)                               |
| `withIpAddress`      | `HasDatabaseName`, `String`     | Sets the IP address to use when connecting to the identified database. (**)                   |
| `withPort`           | `int`                           | Sets the Port to use when connecting to the database. (*)                                     |
| `withPort`           | `HasDatabaseName`, `int`        | Sets the Port to use when connecting to the identified database. (**)                         |
| `withConnectionUrl`  | `String`                        | Sets the connection URL to use when connecting to the database. (*)                           |
| `withConnectionUrl`  | `HasDatabaseName`, `String`     | Sets the connection URL to use when connecting to the identified database. (**)               |
| `withLogging`        | `HasLoggerName`,                | Enables a named logger. See [Logging](#logging) below.                                        |
| `withManager`        | `Class<? extends Manager>`,     | Adds a custom manager to Speedment.                                                           |
| `withParam`          | `String`, `String`              | Sets a key/value configuration. These values can be used to configure components.             |
| `withComponent`      | `Class`                         | Adds a custom component implementation class to Speedment.                                    |
| `withBundle`         | `Class<? extends InjectBundle>` | Adds a custom bundle of dependency injectable implementation classes to Speedment.            |
| `withAllowStreamIteratorAndSpliterator()` |            | Allows `Stream::iterator` and `Stream:spliterators` to be called on Speedment streams. (***)  |
| `withSkipCheckDatabaseConnectivity()` |                | Skips the initial database connectivity check that otherwise takes place during `build()`.    |

* (*) There can only be one (1) database in your project if this method is called.
* (**) There can be any number (1-N) of databases in your project.
* (***) After calling `Stream::iterator` and `Stream:spliterators`, the Speedment stream *must* be closed manually to release its underlying database connection.
* (i) Character arrays can be erased after being used to prevent password Strings being held within the JVM.

## Logging
The class {{site.data.javadoc.ApplicationBuilder.LogType}} contains a number of predefined logger names that can be used to make Speedment show what is going on internally. These LogTypes can be used in conjunction with the `withLogging()` method.

| LogType Name in Enum | Enables Logging Related to                                                                |
| :------------------- | :---------------------------------------------------------------------------------------- |
| `APPLICATION_BUILDER`| configurating the application platform, dependency injection, component configuration etc |
| `CONNECTION`         | Connection handling (connection pooling, Java EE connections, etc)                        |
| `PERSIST`            | Persisting new entities into the database.                                                |
| `REMOVE`             | Removing existing entities from the database.                                             |
| `STREAM`             | Querying the data source.                                                                 |
| `STREAM_OPTIMIZER`   | Stream optimization (e.g. how a stream is rendered to a SQL statement).                   |
| `UPDATE          `   | Updating existing entities from the database.                                             |

These are the standard logging alternatives. Custom components can have other log names.

If we want to enable logging of the application platform, stream and stream optimization we can do like this:
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword("Jz237@h1J19!")
        .withLogging(LogType.APPLICATION_BUILDER)
        .withLogging(LogType.STREAM)
        .withLogging(LogType.STREAM_OPTIMIZER)
        .build();
```


## Examples

### Default Configuration
The following example shows the most simple solution where we accept all the default configurations and where we do not have a password set for the database (needless to say, you should always protect your database with a password).
``` java
    SakilaApplication app = new SakilaApplicationBuilder().build();
```

### Setting the Database Password
The following example shows the most typical solution where we accept all the default configurations but where we set the database password.
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword("Jz237@h1J19!")
        .build();
```

### Setting the Database Password for Different Databases
The following example shows a solution where we set different database passwords for two different databases.
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        // Set the password for the database that holds Film etc.
        .withPassword(Film.FILM_ID.identifier(), "Jz237@h1J19!")
        // Set the password for the database that holds Book etc.
        .withPassword(Book.BOOK_ID.identifier(), "AuW78hd&J19!")
         .build();
```


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="application_configuration.html" %}