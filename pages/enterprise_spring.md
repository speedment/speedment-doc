---
permalink: enterprise_spring.html
sidebar: mydoc_sidebar
title: Enterprise Spring Plugin
keywords: Spring, Spring Boot, REST, JSON, Plugin
enterprise: true
toc: false
Tags: Spring, Spring Boot, REST, JSON, Plugin
previous: enterprise_json.html
next: enterprise_enums.html
---

{% include prev_next.html %}

## About
Speedment Enterprise offers a Spring Boot plugin that allows generation of Spring configurations, greatly simplifying integration between Speedment and Spring.
The plugin can also generate complete REST endpints for tables and views. These endponds can be queried using filters, sorters and pagers.


### Integration
To include the Enterprise Spring Boot Plugin in your Speedment project, add the `SpringGeneratorBundle` to the speedment enterprise maven plugin:
```xml
<plugin>
    <groupId>com.speedment.enterprise</groupId>
    <artifactId>speedment-enterprise-maven-plugin</artifactId>
    <version>${speedment.version}</version>

    <configuration>
        <components>
            <component>com.speedment.enterprise.plugins.spring.SpringGeneratorBundle</component>
        </components>
        <appName>${project.artifactId}</appName>
        <packageName>${project.groupId}</packageName>
     </configuration>

     ...

</plugin>

```

In order to run a Spring Boot/Speedment application, you also need to include the Enterprise Spring Boot Plugin runtime dependency in your Speedment project:

```xml
<dependency>
    <groupId>com.speedment.enterprise.plugins</groupId>
    <artifactId>spring-runtime</artifactId>
    <version>${speedment.enterprise.version}</version>
</dependency>
```

### Spring Configuration
TBW

### Application Settings
There are a number of custom application settings that can be set without modifying any code:

| Name                      | Meaning |
| :------------------------ | :-------|
| spring.speedment.password | The database password credential to be used when loging into the backing database |
| spring.speedment.username | The database username credential to be used when loging into the backing database. If not set, uses the same username that was used for code generation |
| spring.speedment.host     | The database host name to be used when connecting to the backing database. If not set, uses the same address that was used for code generation|
| spring.speedment.port     | The port number of the Spring web server (1 - 65535). If not set, uses the same port that was used for code generation |
| spring.speedment.logging  | If set to `true`, enables logging of various evenst such as streaming and application build |
| spring.speedment.url      | The database connection URL to be used when connecting to the backing database. If not set, a default conneciton URL is used|

These parameters can be set on the command line or in a resource file.

### REST Controllers
TBW


### REST Syntax

#### Using Filters
The spring-generator plugin supports remote filtering. It means that the frontend can send predicates encoded as JSON-objects to the server, and the server will respond with a filtered JSON response. Speedment automatically parses the JSON filters into a SQL SELECT-statement or an in-memroy index search.

The syntax for the JSON filters is straight forward and is using a property/operator/value tuple to define the filters:

```
filter={"property":"xx","operator":"yy","value":zz}
```

The "property" is the name of the column you want to apply the filter to. For example `length' or `name`.

The "operator" can be any operator shown in the table below:

| Operator | Equivalence | Meaning             |
| :------- | :---------- | :------------------ |
| eq       | `=`         | Equal to            |
| ne       | `!=`        | Not equal to        |
| lt       | `<`         | Less than           |
| le       | `<=`        | Less or equal to    |
| gt       | `>`         | Greater than        |
| ge       | `>=`        | Greater or equal to |
| like     | contains()  | Contains            |

The "value" is the fixed numeric or string value to use when comparing. For example, 60 or "The Golden Era".

The following example shows how to get films with a length less than 60 minutes:

```
curl -G localhost:8080/film --data-urlencode \
   'filter={"property":"length","operator":"lt","value":60}'
```

(The -G argument makes sure that the command is sent as a GET request and not a POST request)

Multiple filters can be used by wrapping the filters objects into a list like this:

```
curl -G localhost:8080/film --data-urlencode \
   'filter=[{"property":"length","operator":"lt","value":60},
   {"property":"length","operator":"ge","value":30}]'
```

This will return all films with a length between 30 and 60 minutes. By default, all the operators in the filter list are assumed to be separated with AND-operators. Thus, all the conditions must apply for a row to pass the filter. It is also possible to use an explicit OR-statement as shown hereunder:

```
curl -G localhost:8080/film --data-urlencode \
   'filter={"or":[{"property":"length","operator":"lt","value":30},
   {"property":"length","operator":"ge","value":60}]}'
```

This will return all films that are *either* shorter than 30 minutes or longer than one hour.


#### Using Sorters
The order in which elements appear in the output is undefined. To define a certain order, the `sort` command can be used.

The following example shows how to sort film elements by lenght in the default order (ascending):

```
curl -G localhost:8080/film --data-urlencode \
   'sort={"property":"length"}
```

The following example shows how to sort film elements by lenght in reversed (decending) order:

```
curl -G localhost:8080/film --data-urlencode \
   'sort={"property":"length","direction":"DESC"}'
```

Several sort orders can be use as shown hereunder:

```
curl -G localhost:8080/film --data-urlencode \
   'sort=[{"property":"length","direction":"DESC"},
   {"property":"title","direction":"ASC"}]'
```

#### Using Paging
The last feature of the spring-generator plugin is the ability to page results to avoid sending unnecessary large objects to the consuming end. This is enabled by default, which is why at most 25 results are seen when querying the backend. To skip a number of results (not pages), the ?start= parameter can be used as shown here:

```
curl localhost:8080/film?start=25
```

This will skip the first 25 elements and begin at the 26th. The default page size can also be changed by adding the ?limit= parameter:

```
curl 'localhost:8080/film?start=25&limit=5'
```

This also begins at the 26th element, but only returns 5 elements instead of 25.

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="enterprise_spring.html" %}
