---
permalink: integration.html
sidebar: mydoc_sidebar
title: Integration
keywords: Spring, Spring Boot, Java EE
toc: false
Tags: Spring, Spring Boot, Java EE
previous: speedment_examples.html
next: advanced_features.html
---

{% include prev_next.html %}

## Integration
Speedment is a completely self-contained runtime with no external transitive dependencies. This is important because it allows you to avoid potential version conflicts with other libraries and the ever lurking “Jar Hell”. Furthermore, there is a “deploy” variant available where all Speedment runtime modules have been packed together into a single compound JAR.

## Spring Boot
It is easy to integrate Speedment with Spring Boot. Here is an example of a Speedment Configuration file for Spring:
``` java
@Configuration
public class AppConfig {
    private @Value("${dbms.username}") String username;
    private @Value("${dbms.password}") String password;
    private @Value("${dbms.schema}") String schema;

    @Bean
    public SakilaApplication getSakilaApplication() {
        return new SakilaApplicationBuilder()
            .withUsername(username)
            .withPassword(password)
            .withSchema(schema)
            .build();
    }

    // Individual managers
    @Bean
    public FilmManager getFilmManager(
         SakilaApplication app
    ) {
        return app.getOrThrow(FilmManager.class);
    }
}
```
So, when you need to use a `Manager` in a Spring MVC Controller, you can now simply auto-wire it:
``` java
private @Autowired FilmManager films;
```

There is a specific Spring Boot plugin that you can add to your speedment maven plugin of you use the Enterprise version.

Read more on how to use the Speedment with Spring Boot [here](https://github.com/speedment/speedment/wiki/Tutorial:-Speedment-Spring-Boot-Integration)


## Java EE
Integrating Speedment with Java EE can be done effortlessly. Here is an example of a Singleton Bean for Java EE and Speedment:
``` java
@Startup
@Singleton
public class AppBean {
  private SakilaApplication app;

  @PostConstruct
  void init {
      app = new SakilaApplicationBuilder()
            .withUsername(System.getProperty("dbms.username"))
            .withPassword(System.getProperty("dbms.password"))
            .withSchema(System.getProperty("dbms.schema"))
            .build();
  }

  public FilmManager getFilmManager() {
      return app.getOrThrow(FilmManager.class);
  }

}
```

Speedment gets its database connections using the `DriverManager`. Sometimes the Java EE server needs to be setup to work efficiently for such connecions.  A guide on how to setup a JDBC connection in GlassFish is available [here](https://netbeans.org/kb/docs/web/mysql-webapp.html).

Read more on Java EE and Speedment in the original Speedment Wiki [here](https://github.com/speedment/speedment/wiki/Tutorial:-Use-Speedment-with-Java-EE).

## REST
Writing web applications and REST endpoints using, for example, Spring Boot or Java EE is an easy task. Speedment is a perfect match for providing data to such applications.
 
In this example, the assignment is to write a method `serveFilms(String rating, int page)` that returns a stream of `Film` entities. The rating controls the stream, allowing only films with the given rating to appear in the stream. If rating is null, then all films will be returned. Furthermore, the page parameter indicates which page to be rendered on the web user’s screen. The first page is page 0, the next is 1 et cetera. Finally, all films shall be ordered by length.

This can be done like this:
``` java
private static final int PAGE_SIZE = 50;
 
private Stream<Film> serveFilms(
      String rating, int page
    ) {
 
     Stream<Film> stream = films.stream();
 
    if (rating != null) {
        stream = stream.filter(Film.RATING.equal(rating));
    }
 
    return stream
        .sorted(Film.LENGTH.comparator())
        .skip(page * PAGE_SIZE)
        .limit(PAGE_SIZE);
}

```
The code snippet above could easily be improved to take parameters specifying a dynamic sort order and a custom page size.

## JSON
Often when you write database applications you will need to send different output to a client app. There are many protocols for sending results over a network. One of the most common is JSON.

A number of third party JSON libraries can be used in conjunction with Speeedment including GSON. Speedment can also handle JSON output using the Speedment JSON plugin.

This is how you add the Speedment JSON plugin to your project:
``` xml
    <dependency>
        <groupId>com.speedment.plugins</groupId>
        <artifactId>json-stream</artifactId>
        <version>${speedment.version}</version>
    </dependency>
```
Once the plugin is added, you gain access to a number of additional methods related to JSON handling.

A more advanced JSON Plugin is available in Speedment Enterprise. [Read more about that here](enterprise_json#top).

## Enum
If you have a database where String columns are stored as a limited number of distinct values (i.e. has low cardinality), consider using the Speedment Enum plugin. It will enable mapping of String columns to java enums, allowing more efficient use of memory and increased type safety.

This is how you add the Speedment Enum plugin to your project:
``` xml
    <plugin>
        <groupId>com.speedment</groupId>
        <artifactId>speedment-maven-plugin</artifactId>
        <version>${speedment.version}</version>
        
        <configuration>
          <components>
            <component>com.speedment.plugins.enums.EnumGeneratorBundle</component>
          </components>
        </configuration>
    </plugin>
```

When the plugin has been configured, you gain access to additional methods related to Enum handling. 

{% include image.html file="Enum5.png" url="https://www.speedment.com/" alt="Define an Enum - Select a Column" caption="Options for Enums are enabled in the Speedment Tool" %}

A more advanced Enum Plugin is available in Speedment Enterprise. [Read more about that here](enterprise_enums#top).

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="integration.html" %}
