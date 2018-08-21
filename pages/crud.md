---
permalink: crud.html
sidebar: mydoc_sidebar
title: CRUD Operations
keywords: CRUD, Create, Persist, Update, Delete, Remove
toc: false
Tags: CRUD, Create, Persist, Update, Delete, Remove
previous: join.html
next: speedment_examples.html
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
The fields of returned entity instance may differ from the provided entity fields due to auto-generated key column(s).

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

{% include tip.html content= "
Grouping several persist operations in a single transaction will often improve performance considerable. Read more about transactions [here](#transactions)
" %}

{% include important.html content= "
The `persist()` operation will return an entity that is updated with auto-generated keys from the database (if any) nut not default and trigger calculated column values. Remember that you have to query the database to make sure that you have the latest version of your entity that was stored in the database.
" %}

### Persist Field Handling
Beginning from Speedment version 3.1.5, changes to an entity made via its setters will be tracked using a set of modification flags. These modifiaction flags are subsequently used
by the persister to determine which fields shall be conveyed to the database using a corresponding SQL `INSERT` statement. Flagged fields are sent to the database where as their un-flagged counterparts are not.

This scheme allows default column values in the database to be honored properly. This also means that if a `null` value is to be inserted in the database, the corresponding setter must be invoked with a `null` argument, or else the field will not be flagged for `INSERT` inclusion.

If a primary key field is changed, all modification flags are implicitly set because in that case, it is equivalent that the entity (representing the new primary key(s)) are all derived from the same entity (representing the old primary key(s)).

Setting a field to the same value it alredy has, will set its modification flag.

Following a successful persistence to the database, all modification flags are cleared.

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

{% include tip.html content= "
Grouping several update operations in a single transaction will often improve performance considerable. Read more about transactions [here](#transactions)
" %}

{% include important.html content= "
Only the database is updated, the entity itself will not be updated by the updater. If the database impose additional modifications (e.g. via triggers) to columns, they are not seen in the entity. Remember that you have to query the database to make sure that you have the exact version of your entity that was stored in the database. If the update operation fails, a `SpeedmentException` will be thrown.
" %}

### Update Field Handling
Beginning from Speedment version 3.1.5, changes to an entity made via its setters will be tracked using a set of modification flags. These modifiaction flags are subsequently used
by the updater to determine which fields shall be conveyed to the database using a corresponding SQL `UPDATE` statement. Flagged fields are sent to the database where as their un-flagged counterparts are not.

This scheme makes sure that only touched fields are updated in the database improving performance and reducing the risk of inconsistencies due to overwritten column values.

If a primary key field is changed, all modification flags are implicitly set because in that case, it is equivalent that the entity (representing the new primary key(s)) are all derived from the same entity (representing the old primary key(s)).

Setting a field to the same value it alredy has, will set its modification flag.

Following a successful update of the database, all modification flags are cleared.


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

## Transactions
From version 3.0.17 and onwards, Speedment supports transactions whereby a compound set of work-items can be atomically executed independent of other transactions. Transactions can be used to guarantee ACID property compliance (i.e. Atomic, Consistent, Isolated and Durable).

A transaction is an "all-or-nothing" proposition meaning that either all work-units complete or non of the work-items complete, whereby in the latter case, the database remains completely untouched.

A Speedment transaction supports all types of CRUD operations within the same transaction. Later work-items will see changes made by previous work-items within the transaction as opposed to other threads which will not see these changes until they are fully committed. Changes by other threads will not be seen within the transaction regardless of committed or not. 

### Preparations
The `TransactionComponent` is responsible of handling transaction within the Speedment runtime and it can be used to issue `TransactionHandler` objects for different transaction domains such as a particular database. This is how you can obtain a `TransactionHandler`:

``` java
    SakilaApplication app = ....
    FilmManager films = app.getOrThrow(FilmManager.class);
    LanguageManager languages = app.getOrThrow(LanguageManager.class);
    TransactionComponent transactionComponent = app.getOrThrow(TransactionComponent.class);
    TransactionHandler txHandler = transactionComponent.createTransactionHandler();
```

### Using Transactions
Once a `TransactionHandler` has been obtained, new transactions can easily be created and used. The `TransactionHandler` provides two ways to create and use a transaction:

| Operation      | Argument                 | Description
| :------------- | :----------------------  | :------------------------------------------------------------------------------------------------------------- |
| createAndAccept| Consumer<Transaction>    | Creates a new Transaction and invokes the provided action with the new transaction. Any uncommitted data will be automatically rolled back when the method returns.
| createAndApply | Function<Transaction, T> | Creates a new Transaction and applies the provided mapping function with the new transaction and returns the value. Any uncommitted data will be automatically rolled back when the method returns.


Here is a hypothetical example where we add the number of films with a length greater than 75 with the number of languages and print out the result. Because we are computing the sum within a transaction, we are immune to any changes to the database while we are summing the data:

``` java
    txHandler.createAndAccept(
        tx -> System.out.println(
            films.stream().filter(Film.LENGTH.greaterThan(75)).count()
            + languages.stream().count()
        )
    );
```

Here is another example where we instead return the sum outside the transaction for later use:

``` java
    long sumCount = txHandler.createAndApply(
        tx -> films.stream().filter(Film.LENGTH.greaterThan(75)).count() + languages.stream().count()
    );
```

Uncommitted data changes are discarded unless we commit our changes explicitly as shown in this example:

``` java
    long noLanguagesInTransaction = txHandler.createAndApply(
        tx -> {
            Stream.of(
                new LanguageImpl().setName("Italian"),
                new LanguageImpl().setName("German")
            ).forEach(languages.persister());
            return languages.stream().count();
            // The transaction is implicitly rolled back 
        }
    );
    long noLanguagesAfterTransaction = languages.stream().count();

    System.out.format(
        "no languages in tx %d, no languages after transaction %d %n",
        noLanguagesInTransaction,
        noLanguagesAfterTransaction
    );
```
This will produce the following output:
```
no languages in tx 3, no languages after transaction 1 
```
Thus, the two new `Language` entities we created and persisted to the database were rolled back.

Data changes are committed to the database upon invoking the `Transaction::commit` method as shown hereunder:

``` java
    long noLanguagesInTransaction = txHandler.createAndApply(
        tx -> {
            Stream.of(
                new LanguageImpl().setName("Italian"),
                new LanguageImpl().setName("German")
            ).forEach(languages.persister());
            tx.commit(); // Commit the changes and make them visible outside the tx
            return languages.stream().count();
        }
    );
    long noLanguagesAfterTransaction = languages.stream().count();

    System.out.format(
        "no languages in tx %d, no languages after transaction %d %n",
        noLanguagesInTransaction,
        noLanguagesAfterTransaction
    );
```
This will produce the following output:
```
no languages in tx 3, no languages after transaction 3 
```

#### Handling Simultaneous Read and Writes
Most databases cannot handle having a ResultSet open and then accepting updates on the same connection. In these situations is it advised to collect the entities in a separate `Set` or `List` and then perform actions on the collection rather than using a direct continuous stream as shown in this example:

```
    txHandler.createAndAccept(
        tx -> {
           // Collect to a list before performing actions
            List<Language> toDelete = languages.stream()
                .filter(Language.LANGUAGE_ID.notEqual((short) 1))
                .collect(toList());

            // Do the actual actions
            toDelete.forEach(languages.remover());
                
            tx.commit();
        }
    );
    long cnt = languages.stream().count();
    System.out.format("There are %d languages after delete %n", cnt);
```

#### Transaction Isolation Level
The `TransactionHandler` provides methods to control the level of isolation across transactions. The `Isolation` level will have the following affect when passed to the `Transaction::setIsolation` method:

| Operation          | Effect
| :----------------- | :----------------------------------------------------------------------------------------------------------- |
| DEFAULT            | Restores the Isolation level to the default for the given transaction object
| READ_UNCOMMITTED   | Dirty reads, non-repeatable reads and phantom reads can occur. This level allows a row changed by one transaction to be read by another transaction before any changes in that row have been committed (a "dirty read"). If any of the changes are rolled back, the second transaction will have retrieved an invalid row.
| READ_COMMITTED     | Dirty reads are prevented; non-repeatable reads and phantom reads can occur. This level only prohibits a transaction from reading a row with uncommitted changes in it.
| REPEATABLE_READ    | dirty reads and non-repeatable reads are prevented; phantom reads can occur. This level prohibits a transaction from reading a row with uncommitted changes in it, and it also prohibits the situation where one transaction reads a row, a second transaction alters the row, and the first transaction rereads the row, getting different values the second time (a "non-repeatable read").
| SERIALIZABLE       | Dirty reads, non-repeatable reads and phantom reads are prevented. This level includes the prohibitions in `TRANSACTION_REPEATABLE_READ` and further prohibits the situation where one transaction reads all rows that satisfy a `WHERE` condition, a second transaction inserts a row that satisfies that `WHERE` condition, and the first transaction rereads for the same condition, retrieving the additional "phantom" row in the second read.

More advanced Isolation levels often requirer more resources being used by the underlying transaction domain (e.g. database).

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="crud.html" %}
