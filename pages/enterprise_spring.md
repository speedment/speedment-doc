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

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="enterprise_spring.html" %}
