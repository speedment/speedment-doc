---
permalink: crud.html
sidebar: mydoc_sidebar
title: CRUD Operations
keywords: CRUD, Create, Persist, Update, Delete, Remove
toc: false
Tags: CRUD, Create, Persist, Update, Delete, Remove
previous: comparator.html
next: integration.html
---

{% include prev_next.html %}


## CRUD Operations
The term CRUD is a short for Create, Read, Update and Delete. Speedment supports all these operations via table {{site.data.javadoc.Manager}} objects according to the following table:

| Operation      | Direct Method          | Functional Reference       | Effect
| :------------- | :--------------------  | :------------------------- | :----------------------------------------------------------------------------------- |
| Create         | `persist(entity)`      | `persister()`              | Creates a new row in the database table with data from the given entity              |
| Read           | `stream()`             |                            | Returns a Stream over all the rows in the database table                             |
| Update         | `update(entity)`       | `updater()`                | Updates an existing row in the database from the given entity based on primary key(s)|
| Delete         | `remove(entity)`       | `remover()`                | Removes the row in the database that has the same primary key(s) as the given entity |

As we will see, the functional references are often useful when composing streams that will update the underlying database.

## Create with Persist
The `persist()` and `persister()` methods persist a provided entity to the underlying database and return a potentially updated entity. If the persistence fails for any reason, an unchecked `SpeedmentException` is thrown.
The fields of returned entity instance may differ from the provided entity fields due to auto-generated column(s) or because of any other modification that the underlying database imposed on the persisted entity.

Here is an example of how to create a new language in the Sakila database using the `persist()` method:
``` java
    Language language = new LanguageImpl().setName("Deutsch");
    try {
        languages.persist(language);
    } catch (SpeedmentException se) {
        System.out.println("Failed to persist " + language + ". " + se.getMessage());
    }
```

It is often better to use the functional equivalent `persister()` in streams and optionals. This an example of how this can be done:
``` java
    Stream.of("Italiano", "Español")
        .map(ln -> new LanguageImpl().setName(ln))
        .forEach(languages.persister());
```
This creates a Stream of two language names which are subsequently mapped to new languages with those names. Finally, the language persister is applied for the two new languages whereby two new language rows are inserted into the database.

It is unspecified if the returned updated entity is the same provided entity instance or another entity instance. It is erroneous to assume either, so you should use only the returned entity after the method has been called. However, it is guaranteed that the provided entity is untouched if an exception is thrown.

Developers are highly encouraged to use the provided `language.persister()` when obtaining persisters rather than using functional reference `languages::persist` because when used, it can be be recognizable by the Speedment and its stream optimizer.

{% include important.html content= "
Do This: `.forEach(languages.persister())` 
Don't do This: `.forEach(languages::persist)`
" %}

{% include tip.html content= "
Enable logging of the `persist()` and `persister()` operations using the `ApplicationBuilder` method `.withLogging(LogType.PERSIST)`. Read more about logging [here](application_configuration.html#logging)
" %}

{% include important.html content= "
The `persist()` operation will return an entity that is updated with auto-generated keys from the database (if any). Remember that you have to query the database to make sure that you have the latest version of your entity that was stored in the database.
" %}


## Read with Stream

Speedment streams are described extensively in other parts of this manual for example in the [Speedment Examples](https://speedment.github.io/speedment-doc/speedment_examples.html#top) chapter.


## Update with Update
The `update()` and `updater()` methods update the provided entity in the underlying database and return a potentially updated entity. If the update fails for any reason, an unchecked `SpeedmentException` is thrown.
The fields of returned entity instance may differ from the provided entity fields due to auto-generated column(s) or because of any other modification that the underlying database imposed on the persisted entity.
Entities are uniquely identified by their primary key(s).

Here is an example of how to update a new language in the Sakila database using the `update()` method:
``` java
    Optional<Language> italiano = languages.stream()
        .filter(Language.NAME.equal("Italiano"))
        .findFirst();

    italiano.ifPresent(l -> {
        l.setName("Italian");
        languages.update(l);
    });
```

It is often better to use the functional equivalent `updater()` in `Stream` and `Optional` constructs. Here is an example of how to do:
``` java
    languages.stream()
        .filter(Language.NAME.equal("Deutsch"))
        .map(Language.NAME.setTo("German"))
        .forEach(languages.updater());
```
This will create a stream of all languages (most likely just one element) that has a name of "Deutsch" and the replace the name with "German". Lastly, the `updater()` will be applied to all language entities in the stream whereby these entities will be used to update the database.

It is unspecified if the returned updated entity is the same provided entity instance or another entity instance. It is erroneous to assume either, so you should use only the returned entity after the method has been called. However, it is guaranteed that the provided entity is untouched if an exception is thrown.

Developers are highly encouraged to use the provided `language.updater()` when obtaining updaters rather than using functional reference `languages::update` because when used, it can be be recognizable by the Speedment and its stream optimizer.

{% include important.html content= "
Do This: `.forEach(languages.updater())` 
Don't do This: `.forEach(languages::update)`
" %}

{% include tip.html content= "
Enable logging of the `update()` and `updater()` operations using the `ApplicationBuilder` method `.withLogging(LogType.UPDATE)`. Read more about logging [here](application_configuration.html#logging)
" %}

{% include important.html content= "
The `update()` operation will return an entity that may be updated with auto-generated keys from the database (if any) and other fields. Remember that you have to query the database to make sure that you have the exact version of your entity that was stored in the database. If the update operation fails, a `SpeedmentException` will be thrown.
" %}

## Delete with Remove
The `remove()` and `remover()` methods remove a provided entity from the underlying database and returns the provided entity instance. If the deletion fails for any reason, an unchecked `SpeedmentException` is thrown.
Entities are uniquely identified by their primary key(s).

Here is an example of how to remove an existing language in the Sakila database using the `remove()` method:
``` java
    Optional<Language> italiano = languages.stream()
        .filter(Language.NAME.equal("Italiano"))
        .findFirst();

    italiano.ifPresent(l -> languages.remove(l));
```

It is often better to use the functional equivalent `remover()` in `Stream` and `Optional` constructs. Here is an example of how to do:
``` java
    languages.stream()
        .filter(Language.NAME.notEqual("English"))
        .forEach(languages.remover());
```
This will create a stream of all non-English languages and then it will apply the language `remover()` for each of those languages whereby those languages will be deleted from the database.

Developers are highly encouraged to use the provided `language.remover()` when obtaining deleters rather than using functional reference `languages::remove` because when used, it can be be recognizable by the Speedment and its stream optimizer.

{% include important.html content= "
Do This: `.forEach(languages.remover())` 
Don't do This: `.forEach(languages::remove)`
" %}

{% include tip.html content= "
Enable logging of the `remove()` and `remover()` operations using the `ApplicationBuilder` method `.withLogging(LogType.REMOVE)`. Read more about logging [here](application_configuration.html#logging)
" %}

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="crud.html" %}