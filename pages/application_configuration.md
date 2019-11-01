---
permalink: application_configuration.html
sidebar: mydoc_sidebar
title: Application Configuration
keywords: Configuration, Application
toc: false
Tags: Configuration, Application
previous: getting_started.html
next: maven.html
---

{% include prev_next.html %}

## Why Configure?
Most Speedment configuration is done automatically during inspection of the database meta data model including things like tables, columns, user name and connection URL. However, it is common to override one or several configuration parameters, for example when deploying an application and want to connect to a different database than used for development.

One thing that always needs to be configured is the database password. For security reasons, Speedment never stores the database password in generated classes or configuration files.

Configuration is done using an `ApplicationBuilder` that is generated for your project. Once the `ApplicationBuilder` is configured, its `build()` method is called and a configured `Application` is returned. Upon building, all the configuration parameters are frozen (made immutable) in the returned `Application`. 

## Configurations
The table below summarizes the most important methods of the `ApplicationBuilder`. Check out the official JavaDoc about the  {{site.data.javadoc.ApplicationBuilder}} for more detailed information about all configuration methods.

| Method               | Parameters                      | Description                                                                                   |
| :------------------- | :------------------------------ | :-------------------------------------------------------------------------------------------- |
| `withPassword`       | `String`                        | Sets the password to use when connecting to the database. (*)                                 |
| `withLogging`        | `HasLoggerName`,                | Enables a named logger. See [Logging](#logging) below.                                        |
| `withParam`          | `String`, `String`              | Sets a key/value configuration. These values can be used to configure components.             |
| `withComponent`      | `Class`                         | Adds a custom component injectable implementation class to Speedment.                         |
| `withBundle`         | `Class<? extends InjectBundle>` | Adds a custom bundle of dependency injectable implementation classes to Speedment.            |

| Method               | Parameters                      | Description                                                                                   |
| :------------------- | :------------------------------ | :-------------------------------------------------------------------------------------------- |
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
| `withSchema`         | `String`                        | Sets the schema name to use when connecting to the database. Useful for multi-tenant apps. (*)|
| `withSchema`         | `HasSchemaName`, `String`       | Sets the schema name to use when connecting to the identified database. (multi-tenant) (**)   |
| `withManager`        | `Class<? extends Manager>`,     | Adds a custom manager to Speedment.                                                           |
| `withAllowStreamIteratorAndSpliterator()` |            | Allows `Stream::iterator` and `Stream:spliterators` to be called on Speedment streams. (***)  |
| `withSkipCheckDatabaseConnectivity()` |                | Skips the initial database connectivity check that otherwise takes place during `build()`.    |

* (*) There can only be one (1) database in your project if this method is called.
* (**) There can be any number (1-N) of databases in your project.
* (***) After calling `Stream::iterator` or `Stream:spliterators`, the underlying Speedment stream must be closed manually to release its underlying database connection.
* (i) Character arrays can be erased after being used to prevent password Strings being held within the JVM.

## Logging
The class {{site.data.javadoc.ApplicationBuilder.LogType}} contains a number of predefined logger names that can be used to make Speedment show what is going on internally. These LogTypes can be used in conjunction with the `withLogging()` method.

| LogType Name         | Enables Logging Related to                                                                |
| :------------------- | :---------------------------------------------------------------------------------------- |
| `APPLICATION_BUILDER`| Configuring the application platform, dependency injection, component configuration etc   |
| `CONNECTION`         | Connection handling (connection pooling, Java EE connections, etc)                        |
| `PERSIST`            | Persisting new entities into the database.                                                |
| `REMOVE`             | Removing existing entities from the database.                                             |
| `STREAM`             | Querying the data source.                                                                 |
| `STREAM_OPTIMIZER`   | Stream optimization (e.g. how a stream is rendered to a SQL statement).                   |
| `UPDATE`             | Updating existing entities from the database.                                             |
| `TRANSACTION`        | Handling of transactions.                                                                 |
| `JOIN`               | Creating and performing table joins.                                                      |
| `SQL_RETRY`          | Retrying SQL commands                                                                     |
| `MODULE_SYSTEM`      | The Java Module System (JPMS)                                                             |

These are the standard logging alternatives.

There are also some Enterprise specific logger name defined for features that are unique to Enterprise features:

| HasLoggerName              | Enables Logging Related to                                                                |
| :------------------------- | :-------------------------------------------------------------------------------- |
| `LicenseComponent.LICENSE` | Handling of commercial licenses.                                                  |
| `Aggregator.AGGREGATE`     | Computation of aggregates.                                                        |

Custom components can have other log names.

Logging of the application platform, stream and stream optimization can be achieved as following: 
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withBundle(MySqlBundle.class)
        .withPassword("Jz237@h1J19!")
        .withLogging(LogType.APPLICATION_BUILDER)
        .withLogging(LogType.STREAM)
        .withLogging(LogType.STREAM_OPTIMIZER)
        .build();
```

## The Speedment Lifecycle
A Speedment application can move its state from Building to Started to Closed.

### Building an Application
A `SpeedmentApplication` is built using a `SpeedmentApplicationBuilder`. During build, the application does not exist, it is merely configured. Once the builders `build()` method is called, the applications components are brought to life by passing through a series of States:

| Component State   | Triggered by | Action                                                                      |
| :---------------- | : ------------------------------------------------------------------------- |
| CREATED           | `build()`    | The Injectable has been created but has not been exposed anywhere yet
| INITIALIZED       | `build()`    | The Injectable has been initialized
| RESOLVED          | `build()`    | The Injectable has been initialized and resolved
| STARTED           | `build()`    | The Injectable has been initialized, resolved and started.
| STOPPED           | `stop()`     | The Injectable has been initialized, resolved, started and stopped

So, upon `build()` each and every component will traverse the sequence CREATED -> INITIALIZED -> RESOLVED -> STARTED

### Starting an Application
A `SpeedmentApplication` is automatically started by the `SpeedmentApplicationBuilder::build` method.

### Closing an Application
Once the application has completed, is it advised to call the `SpeedmentApplication::stop` method so that the application can release any resources it is holding and clean up external resources if any. 

The example below shows a complete Speedment lifecycle from configuration to stop.
``` java
    // This builds and starts the application
    SakilaApplication app = new SakilaApplicationBuilder()
        .withPassword("Jz237@h1J19!")
        .build();

    FilmManager films = app.getOrThrow(FilmManager.class);

    long count = films.stream().count();

    // This stops the application.
    app.stop();

```


## Examples

### Default Configuration
The following example shows the most simple solution where the default configurations are used and no password is set for the database (needless to say, you should always protect your database with a password).
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withBundle(MySqlBundle.class)
        .build();
```
### Setting the Database Password
The following example shows the most typical solution where the default configurations are used and a database password is provided.
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withBundle(MySqlBundle.class)
        .withPassword("Jz237@h1J19!")
        .build();
```

### Setting the Database Password for Different Databases
The following example demonstrates the use of two database passwords for two different databases.
``` java
    SakilaApplication app = new SakilaApplicationBuilder()
        .withBundle(MySqlBundle.class)
        // Set the password for the database that holds Film etc.
        .withPassword(Film.FILM_ID.identifier(), "Jz237@h1J19!")
        // Set the password for the database that holds Book etc.
        .withPassword(Book.BOOK_ID.identifier(), "AuW78hd&J19!")
         .build();
```


{% include prev_next.html %}

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
