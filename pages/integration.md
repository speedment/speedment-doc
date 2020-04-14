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

## Java Platform Module System
As of version 3.2.0, Speedment is internally modularized and fully supports the Java Platform Module System (JSR 376, JPMS). In order to run the application under JPMS, a `module-info.java` file has to be added in the project. The recommended place for this file is under the directory `src/java`. This is how a standard `module-info.java` file for use with a MySQL database should look like:
```java
module mymodule {
    requires com.speedment.runtime.application;
    requires com.speedment.runtime.connector.mysql;
}
```
The module `com.speedment.runtime.application` will transitively pull in other modules that are required to run speedment. This is how the module graph looks like for the example above:
{% include image.html file="module-dependencies.png" alt="Module Dependencies" caption="Module Dependencies as per jdeps" %}

Depending on database type usage, additional modules are required:

| Feature        | GroupId                             | ArtifactId           | Required module(s)                             |
| :------------- | :---------------------------------- | :------------------- | :--------------------------------------------- |
| MySQL          | com.speedment.runtime               | connector-mysql      | com.speedment.runtime.connector.mysql          |
| MariaDB        | com.speedment.runtime               | connector-mariadb    | com.speedment.runtime.connector.mariadb        |
| PostgreSQL     | com.speedment.runtime               | connector-postgres   | com.speedment.runtime.connector.postgres       |
| SQLite         | com.speedment.runtime               | connector-sqlite     | com.speedment.runtime.connector.sqlite         |
| DB2/AS400      | com.speedment.enterprise.connectors | db2-connector        | com.speedment.enterprise.connectors.dbtwo      |
| Oracle         | com.speedment.enterprise.connectors | oracle-connector     | com.speedment.enterprise.connectors.oracle     |
| SQL Server     | com.speedment.enterprise.connectors | sqlserver-connector  | com.speedment.enterprise.connectors.sqlserver  |
  
Depending on optional feature usage, additional modules are required:  

| Feature        | GroupId                             | ArtifactId           | Required module(s)                             |
| :------------- | :---------------------------------- | :------------------- | :--------------------------------------------- |
| HyperStream    | com.speedment.enterprise            | datastore-runtime    | com.speedment.enterprise.datastore.runtime     |
| Sharding       | com.speedment.enterprise            | sharding             | com.speedment.enterprise.sharding              |
| VirtualColumn  | com.speedment.enterprise            | virtualcolumn-runtime| com.speedment.enterprise.virtualcolumn.runtime |
| Enum Plugin    | com.speedment.enterprise.plugins    | enum-serializer      | com.speedment.enterprise.plugins.enums         |
| JSON Plugin    | com.speedment.enterprise.plugins    | json-stream          | com.speedment.enterprise.plugins.json          |
| AvroFiles      | com.speedment.enterprise.plugins    | avro-runtime         | com.speedment.enterprise.plugins.avro.runtime  |
| Spring Plugin  | com.speedment.enterprise.plugins    | spring-runtime       | com.speedment.enterprise.plugins.spring.runtime, spring.boot, spring.web, java.annotation, spring.webmvc, spring.beans, spring.context, spring.core, spring.boot.autoconfigure |

By adding the following line to the `ApplicationBuilder` we can log JPMS module related information 
`.withLogging(LogType.MODULE_SYSTEM)`

## Gradle
Even though there is no official Gradle plugin available for the Speedment Tool, using the Speedment Runtime with Gradle is certainly possible. A `build.gradle` file for a Speedment project running a MySQL database would look like so:
``` groovy
plugins {
    id 'java'
}

group 'my-app'
version '1.0.0-SNAPSHOT'

sourceCompatibility = 1.8

repositories {
    mavenCentral()
}

dependencies {
    implementation group: 'mysql', name: 'mysql-connector-java', version: "$mysqlVersion"
    implementation group: 'com.speedment', name: 'runtime', version: "$speedmentVersion"
}
```

The `$mysqlVersion` and `$speedmentVersion` properties are stored in the `gradle.properties` file:
```
mysqlVersion=8.0.18
speedmentVersion=3.2.2
```

Depending on what your underlying database is, the connector used in the `build.gradle` file will change.

{% include note.html content = "
To generate the required Speedment files in a fresh Gradle project, we recommend creating a new Maven project to generate the files and copy them over to you Gradle project.
" %}

## Spring Boot
It is easy to integrate any Speedment project with Spring Boot. Here is an example of a Speedment Configuration file for Spring:
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

There is a specific [Spring Boot plugin](https://github.com/speedment/speedment/wiki/Tutorial:-Speedment-Spring-Boot-Integration) that you can add to your Speedment Maven-plugin if you use Speedment Stream or HyperStream. 


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

A more advanced JSON Plugin is available for Speedment Stream and HyperStream. [Read more about it here](enterprise_json#top).

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

## Custom Traits
This feature is available form 3.2.9 and onwards and allows entities to implement any custom interface(s).

A comma-separated list of interface name can be provided via the Speedment Tool. Upon generation, those interfaces will be added to the generated classes.

To add a custom interface to a table, select that table in the Speedment Tool and and add the interface name to the text field called `Implements`:

{% include image.html file="Implements.png" url="https://www.speedment.com/" alt="Implements" caption="Implements" %}

{% include prev_next.html %}

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
