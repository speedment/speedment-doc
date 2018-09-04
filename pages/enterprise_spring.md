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
To include the Enterprise Spring Boot Plugin in your Speedment project, add the following maven plugin:

```xml
<dependency>
    <groupId>com.speedment.enterprise.plugins</groupId>
    <artifactId>spring-runtime</artifactId>
    <version>${speedment.enterprise.version}</version>
</dependency>
```


In order to run a Spring Boot/Speedment application, you also need to include the Enterprise Spring Boot Plugin runtime dependency in your Speedment project:

```xml
<dependency>
    <groupId>com.speedment.enterprise.plugins</groupId>
    <artifactId>spring-runtime</artifactId>
    <version>${speedment.enterprise.version}</version>
</dependency>
```

To activate the plugin in the code, simply add the plugin bundle class to the Speedment Application Builder:

```java
public static void main(String... args) {
    final SakilaApplication app = new SakilaApplicationBuilder()
        .withBundle(DatastoreBundle.class) // Only if Datastore is used
        .withBundle(JsonBundle.class)      // The Enterprise JSON Plugin
        .withUsername("")
        .withPassword("")
        .build();
        
    // The following instances are used in the examples:
    final FilmManager films  = app.getOrThrow(FilmManager.class);
    final JsonComponent json = app.getOrThrow(JsonComponent.class);
    
    ...
}
```

## TBW
Tbw

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="enterprise_spring.html" %}
