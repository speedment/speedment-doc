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
The plugin can also generate complete REST endpoints for tables and views. These endpoints can be queried using filters, sorters and/or pagers.


### Integration
To include the Enterprise Spring Boot Plugin in your Speedment project, add the `SpringGeneratorBundle` to the speedment-enterprise-maven-plugin:
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

{% include important.html content= "
The `Main.java` file that starts Spring must be located in a package above or on the same level as the generated files or else the Controllers and rest points will not be picked up by Spring's class scanner.
" %}


### Spring Configuration
The Spring Boot plugin will automatically generate Spring configuration files that can be picked up by Spring's dependency injection features. For example, the following file will be generated if the plugin runs against the Sakila database (`GeneratedSakilaConfiguration.java` truncated for brievity):

``` Java
@GeneratedCode("Speedment")
public class GeneratedSakilaConfiguration {

    @Bean
    public SakilaApplication getApplication() {
        return getApplicationBuilder().build();
    }

    public SakilaApplicationBuilder getApplicationBuilder() {
        ...
    }

    @Bean
    public JsonComponent getJsonComponent(SakilaApplication app) {
        return app.getOrThrow(JsonComponent.class);
    }

    @Bean
    public JoinComponent getJoinComponent(SakilaApplication app) {
        return app.getOrThrow(JoinComponent.class);
    }

    @Bean
    public FilmActorManager getFilmActorManager(SakilaApplication app) {
        return app.getOrThrow(FilmActorManager.class);
    }

    ...

}
```

These beans can then be picked up in Spring application by means of the `@Autowired` annotation as shown here:

``` java

    @Autowired FilmManager films:

    ...

    public long countAllFilms() {
        return films.stream().count();
     }

```

This greatly simplifies application development and creates a losened coupling between components compared to explicitly handling the components.


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
| spring.speedment.license  | The licnse key to be used when initializing a Speedment application|

These parameters can be set in resource files and/or on the command line.

The following command sets the database password to "sakila-password" for application when run:

```
java -jar target/rest-api-example-1.0.0-SNAPSHOT.jar --spring.speedment.password=sakila-password
```

The parameter resource file can be located either in the file '/src/main/resources/application.yml' and/or in a file 'application.yml' located in the current directory of the application. Elements in the latter file will take precidence over eleeents in the former file and elements on the command line will take absoulte precidence. The following `application.yml` file sets the database password to "sakila-password":

``` yml
spring:
  speedment:
    password: sakila-password
```

{% include tip.html content = "
It is also possible to use `application.properties` files instead if the property file format is preferred
" %}

### Automatic Loading of DataStore
If you use DataStore in combination with the Spring Plugin, a method will automatically be generated that will load the `DataStoreComponent` from the database. By default, all the database content will be loaded. If you want to provide your own custom loader (e.g. if you only want to load a subset of the data), override the `populateCahe()` method as exemplified below:
```java
public final class SakilaApplicationImpl 
extends GeneratedSakilaApplicationImpl 
implements SakilaApplication {

    @Override
    public void populateCache() {
        DataStoreComponent dataStoreComponent= getOrThrow(DataStoreComponent.class);
        dataStoreComponent.load(/* provide custom settings here */);
    }
}
```


### CRUD Operations
In order to enable CRUD functionality, the REST controllers must be enabled in the Speedment Tool for the corresponding table as shown in the picture below:\

{% include image.html file="spring-plugin-table-props.png" alt="Spring Plugin Table Properties" caption="Tool: How to Enable REST Table Access." %}


### Listing Entities

When the `REST Enable LIST` is enabled for a table, its contents can be retrieved through a GET request. For example, elements from the "film" table can be retrieved like this:

 ```
 curl localhost:8080/sakila/film
 ```

This will retrieve the first 25 films (where only the first two elements are shown for brievity):

``` json
[
   {
        "description": "A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies",
        "filmId": 1,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "86",
        "originalLanguageId": null,
        "rating": "PG",
        "releaseYear": "2006-01-01",
        "rentalDuration": 6,
        "rentalRate": "0.99",
        "replacementCost": "20.99",
        "specialFeatures": "Deleted Scenes,Behind the Scenes",
        "title": "ACADEMY DINOSAUR"
    },
    {
        "description": "A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China",
        "filmId": 2,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "48",
        "originalLanguageId": null,
        "rating": "G",
        "releaseYear": "2006-01-01",
        "rentalDuration": 3,
        "rentalRate": "4.99",
        "replacementCost": "12.99",
        "specialFeatures": "Trailers,Deleted Scenes",
        "title": "ACE GOLDFINGER"
    },
    ....
]
```
By default, only the first 25 elements are returned. See [paging](#using-paging) for information on retrieving any number of elements.

{% include tip.html content = "
All the discovered REST end points are printed out in the logs when Spring starts up.
" %}


#### Using Filters
The spring plugin supports remote filtering. It means that the frontend can send predicates encoded as JSON-objects to the server, and the server will respond with a filtered JSON response. Speedment automatically parses the JSON filters into a SQL SELECT-statement or an in-memroy index search.

The syntax for the JSON filters is straight forward and is using a property/operator/value tuple to define the filters:

```
filter={"property":"xx","operator":"yy","value":zz}
```

The "property" xx is the name of the column you want to apply the filter to. For example "length" or "name".

The "operator" yy can be any operator shown in the table below:

| Operator | Equivalence | Meaning             |
| :------- | :---------- | :------------------ |
| eq       | `=`         | Equal to            |
| ne       | `!=`        | Not equal to        |
| lt       | `<`         | Less than           |
| le       | `<=`        | Less or equal to    |
| gt       | `>`         | Greater than        |
| ge       | `>=`        | Greater or equal to |
| like     | contains()  | Contains            |

The "value" zz is the fixed numeric or string value to use when applying the operator. For example, 60 or "The Golden Era".

The following example shows how to retrieve films with a length less than 60 minutes:

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'filter={"property":"length","operator":"lt","value":60}'
```

(The -G argument makes sure that the command is sent as a GET request and not a POST request)

This will produce the following output (only the first two elements are shown for brievity):

``` json
[
    {
        "description": "A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China",
        "filmId": 2,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "48",
        "originalLanguageId": null,
        "rating": "G",
        "releaseYear": "2006-01-01",
        "rentalDuration": 3,
        "rentalRate": "4.99",
        "replacementCost": "12.99",
        "specialFeatures": "Trailers,Deleted Scenes",
        "title": "ACE GOLDFINGER"
    },
    {
        "description": "A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory",
        "filmId": 3,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "50",
        "originalLanguageId": null,
        "rating": "NC-17",
        "releaseYear": "2006-01-01",
        "rentalDuration": 7,
        "rentalRate": "2.99",
        "replacementCost": "18.99",
        "specialFeatures": "Trailers,Deleted Scenes",
        "title": "ADAPTATION HOLES"
    },
    ...
]
```


Multiple filters can be used by wrapping the filters objects into an array like this:

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'filter=[{"property":"length","operator":"lt","value":60},
   {"property":"length","operator":"ge","value":30}]'
```

This will return all films with a length between 30 and 60 minutes. By default, all the operators in the filter array are assumed to be separated with AND-operators. Thus, all the conditions must apply for a row to pass the filter. It is also possible to use an explicit OR-statement as shown hereunder:

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'filter={"or":[{"property":"length","operator":"lt","value":30},
   {"property":"length","operator":"ge","value":60}]}'
```

This will return all films that are *either* shorter than 30 minutes or longer than one hour.


#### Using Sorters
The order in which elements appear in the output is undefined. To define a certain order, the `sort` command can be used.

The following example shows how to sort film elements by lenght in the default order (ascending):

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'sort={"property":"length"}'
```
This will produce the following output (only the first two elements are shown for brievity):

``` json
[
    {
        "description": "A Brilliant Drama of a Cat And a Mad Scientist who must Battle a Feminist in A MySQL Convention",
        "filmId": 15,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "46",
        "originalLanguageId": null,
        "rating": "NC-17",
        "releaseYear": "2006-01-01",
        "rentalDuration": 5,
        "rentalRate": "2.99",
        "replacementCost": "10.99",
        "specialFeatures": "Trailers,Commentaries,Behind the Scenes",
        "title": "ALIEN CENTER"
    },
    {
        "description": "A Fast-Paced Documentary of a Mad Cow And a Boy who must Pursue a Dentist in A Baloon",
        "filmId": 469,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "46",
        "originalLanguageId": null,
        "rating": "PG",
        "releaseYear": "2006-01-01",
        "rentalDuration": 7,
        "rentalRate": "4.99",
        "replacementCost": "27.99",
        "specialFeatures": "Commentaries,Behind the Scenes",
        "title": "IRON MOON"
    },
    ...
]
```


The following example shows how to sort film elements by lenght in reversed (decending) order:

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'sort={"property":"length","direction":"DESC"}'
```

This will produce the following output (only the first two elements are shown for brievity):

``` json
[
    {
        "description": "A Lacklusture Panorama of a A Shark And a Pioneer who must Confront a Student in The First Manned Space Station",
        "filmId": 817,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "185",
        "originalLanguageId": null,
        "rating": "R",
        "releaseYear": "2006-01-01",
        "rentalDuration": 7,
        "rentalRate": "4.99",
        "replacementCost": "27.99",
        "specialFeatures": "Trailers,Commentaries,Deleted Scenes,Behind the Scenes",
        "title": "SOLDIERS EVOLUTION"
    },
    {
        "description": "A Taut Character Study of a Woman And a A Shark who must Confront a Frisbee in Berlin",
        "filmId": 349,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "185",
        "originalLanguageId": null,
        "rating": "PG-13",
        "releaseYear": "2006-01-01",
        "rentalDuration": 4,
        "rentalRate": "2.99",
        "replacementCost": "27.99",
        "specialFeatures": "Behind the Scenes",
        "title": "GANGS PRIDE"
    },
    ...
]
```


By wrapping sort objects into an array, several sort orders can be use as shown hereunder:

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'sort=[{"property":"length","direction":"DESC"},
   {"property":"title","direction":"ASC"}]'
```

This will prouduce an output sorded by lenght in decending order as primary sort criteria and by title in ascending order as secondary sort cirteria (only the first two elements are shown for brievity):

``` json
[
    {
        "description": "A Fateful Yarn of a Mad Cow And a Waitress who must Battle a Student in California",
        "filmId": 141,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "185",
        "originalLanguageId": null,
        "rating": "PG-13",
        "releaseYear": "2006-01-01",
        "rentalDuration": 6,
        "rentalRate": "4.99",
        "replacementCost": "11.99",
        "specialFeatures": "Deleted Scenes,Behind the Scenes",
        "title": "CHICAGO NORTH"
    },
    {
        "description": "A Fateful Documentary of a Robot And a Student who must Battle a Cat in A Monastery",
        "filmId": 182,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "185",
        "originalLanguageId": null,
        "rating": "G",
        "releaseYear": "2006-01-01",
        "rentalDuration": 7,
        "rentalRate": "4.99",
        "replacementCost": "9.99",
        "specialFeatures": "Commentaries",
        "title": "CONTROL ANTHEM"
    },
    ...
]
```

#### Using Paging
The last feature of the spring plugin plugin is the ability to page results to avoid sending unnecessary large objects to the consuming end. This is enabled by default, which is why at most 25 results are seen when querying the backend. To skip a number of results (not pages), the ?start= parameter can be used as shown here:

```
curl localhost:8080/sakila/film?start=25
```

This will skip the first 25 elements and begin at the 26th. The default page size can also be changed by adding the ?limit= parameter:

```
curl 'localhost:8080/sakila/film?start=25&limit=5'
```

This also begins at the 26th element, but only returns 5 elements instead of 25 as show hereunder (all five element are shown):

``` json
[
    {
        "description": "A Amazing Panorama of a Pastry Chef And a Boat who must Escape a Woman in An Abandoned Amusement Park",
        "filmId": 26,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "86",
        "originalLanguageId": null,
        "rating": "G",
        "releaseYear": "2006-01-01",
        "rentalDuration": 3,
        "rentalRate": "0.99",
        "replacementCost": "15.99",
        "specialFeatures": "Commentaries,Deleted Scenes",
        "title": "ANNIE IDENTITY"
    },
    {
        "description": "A Amazing Reflection of a Database Administrator And a Astronaut who must Outrace a Database Administrator in A Shark Tank",
        "filmId": 27,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "179",
        "originalLanguageId": null,
        "rating": "NC-17",
        "releaseYear": "2006-01-01",
        "rentalDuration": 7,
        "rentalRate": "0.99",
        "replacementCost": "12.99",
        "specialFeatures": "Deleted Scenes,Behind the Scenes",
        "title": "ANONYMOUS HUMAN"
    },
    {
        "description": "A Touching Panorama of a Waitress And a Woman who must Outrace a Dog in An Abandoned Amusement Park",
        "filmId": 28,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "91",
        "originalLanguageId": null,
        "rating": "PG-13",
        "releaseYear": "2006-01-01",
        "rentalDuration": 5,
        "rentalRate": "4.99",
        "replacementCost": "16.99",
        "specialFeatures": "Deleted Scenes,Behind the Scenes",
        "title": "ANTHEM LUKE"
    },
    {
        "description": "A Fateful Yarn of a Womanizer And a Feminist who must Succumb a Database Administrator in Ancient India",
        "filmId": 29,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "168",
        "originalLanguageId": null,
        "rating": "NC-17",
        "releaseYear": "2006-01-01",
        "rentalDuration": 5,
        "rentalRate": "2.99",
        "replacementCost": "11.99",
        "specialFeatures": "Trailers,Commentaries,Deleted Scenes",
        "title": "ANTITRUST TOMATOES"
    },
    {
        "description": "A Epic Story of a Pastry Chef And a Woman who must Chase a Feminist in An Abandoned Fun House",
        "filmId": 30,
        "languageId": 1,
        "lastUpdate": "2006-02-15 14:03:42.0",
        "length": "82",
        "originalLanguageId": null,
        "rating": "R",
        "releaseYear": "2006-01-01",
        "rentalDuration": 4,
        "rentalRate": "2.99",
        "replacementCost": "27.99",
        "specialFeatures": "Trailers,Deleted Scenes,Behind the Scenes",
        "title": "ANYTHING SAVANNAH"
    }
]
```

#### Combinations
Filters, sorters and paging can be combined to create a compound REST backend operation.

The following example will retrieve all films that are shorter than 60 minutes and that are sorted by title showing the third page (i.e. skipping 150 films and showing the following 50 films):

```
curl -G localhost:8080/sakila/film --data-urlencode \
   'filter={"property":"length","operator":"lt","value":60} \
   &sort={"property":"length"} \
   &start=150 \
   &limit50'
```

### Retrieving specific Entities

When the `REST Enable GET` is enabled for a table, a specific entity can be retrieved through a GET request. For example, an entity from the "film" table can be retrieved like this:

 ```
 curl localhost:8080/sakila/film/1
 ```

 This will retrieve a film entity with which has a PK column with the value of `1`:
 
 ```json
 {
    "description": "A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies",
    "filmId": 1,
    "languageId": 1,
    "lastUpdate": "2006-02-15 14:03:42.0",
    "length": "86",
    "originalLanguageId": null,
    "rating": "PG",
    "releaseYear": "2006-01-01",
    "rentalDuration": 6,
    "rentalRate": "0.99",
    "replacementCost": "20.99",
    "specialFeatures": "Deleted Scenes,Behind the Scenes",
    "title": "ACADEMY DINOSAUR"
}
 ```

 {% include note.html content = "
Single entity retrieval is supported for entities with exactly one Primary Key column.
" %}

### Creating Entities

Entity creation via the REST API is done by executing a POST request to the base REST route of the table you are creating the entity in. For example, to create a new "film" entity we would execute the following request:

```
curl -d '{“filmId”: 1000,“title”: “Interstellar”,"languageId": 1,"rentalDuration": 100,"rentalRate": 100,"replacementCost": 15}' -H "Content-Type: application/json" -X POST localhost:8080/sakila/film
```

The POST body of the request, by default, consists of all columns of the table that is being used to create an entity. Additionally, all included fields are required by default. See ['Customizing Request Bodies'](#customizing-request-bodies) for information on request body options.

### Updating Entities

Entity updating via the REST API is done by executing a PATCH request to the base REST route of the table you are updating the entity in. This route must be suffixed by the Primary Key column value of the entity that is being updated. For example, to update a "film" entity we would execute the following request:

```
curl -d '{“title”: Some other great movie}' -H "Content-Type: application/json" -X PATCH localhost:8080/sakila/film/1000
```

The PATCH body of the request, by default, consists of all columns, except the Primary Key column, of the table that is being used to create an entity. Additionally, all included fields are required by default. See ['Customizing Request Bodies'](#customizing-request-bodies) for information on request body options.

 {% include note.html content = "
Entity updating is supported for entities with exactly one Primary Key column.
" %}

### Deleting Entities

Entity deletion via the REST API is done by executing a DELETE request to the base REST route of the table you are deleting the entity from. This route must be suffixed by the Primary Key column value of the entity that is being deleted. For example, to delete a "film" entity we would execute the following request:

```
curl -X DELETE localhost:8080/sakila/film/1000
```

 {% include note.html content = "
Entity deletion is supported for entities with exactly one Primary Key column.
" %}

#### Customizing Request Bodies

When creating and updating entities, a JSON request body with specific key value pairs as value is required to be present. By default, the request bodies must include all columns (except the Primary Key column if updating) of the table we are try to act upon.

These requirements can be customized by enabling/disabling specific options in the tool, as shown in the picture below:

{% include image.html file="spring-plugin-column-props.png" alt="Spring Plugin Column Properties" caption="Tool: Spring Table Properties" %}

The "Include in Create Body" and "Include in Update Body" options tell the Spring plugin whether or not to expect that specific column in the request body.

In order to ensure that a specific column must be present in the request body, the option "Required in Create Body" or "Create in Update Body" must be enabled.

{% include prev_next.html %}

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
