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
The term CRUD is a short for Create, Read, Update and Delete. Speedment supports all these operations via table {{site.data.javadoc.Manager}} objects and more according to the following table:

| Operation      | Direct Method          | Functional Reference       | Effect
| :------------- | :--------------------  | :------------------------- | :----------------------------------------------------------------------------------- |
| Create         | `persist(entity)`      | `persister()`              | Creates a new row in the database table with data from the given entity              |
| Read           | `stream()`             |                            | Returns a Stream over all the rows in the database table                             |
| Update         | `update(entity)`       | `updater()`                | Updates an existing row in the database from the given entity based on primary key(s)|
| Delete         | `remove(entity)`       | `remover()`                | Removes the row in the database that has the same primary key(s) as the given entity |
| Merge          | `merge(entity)`        | `merger()`                 | If the row does not exists; Creates the row, otherwise Updates the row in the database that has the same primary key(s) as the given entity |

As you will see, the functional references are often useful when composing streams that will update the underlying database.

## Create with Persist
The `persist()` and `persister()` methods persist a provided entity to the underlying database and return a potentially updated entity. If the persistence fails for any reason, an unchecked `SpeedmentException` is thrown.
The fields of returned entity instance may differ from the provided entity fields due to auto-generated key column(s).

Here is an example of how to create a new language in the Sakila database using the `persist()` method:
``` java
    Language language = languages.create().setName("Deutsch");
    try {
        languages.persist(language);
    } catch (SpeedmentException se) {
        System.out.println("Failed to persist " + language + ". " + se.getMessage());
    }
```

It is often better to use the functional equivalent `persister()` in streams and optionals. This an example of how this can be done:
``` java
    Stream.of("Italiano", "Español")
        .map(ln -> languages.create().setName(ln))
        .forEach(languages.persister());
```
This creates a Stream of two language names which are subsequently mapped to new languages with those names. Finally, the language persister is applied for the two new languages whereby two new language rows are inserted into the database.

It is unspecified if the returned updated entity is the same provided entity instance or another entity instance. It is erroneous to assume either, so you should use only the returned entity after the method has been called. However, it is guaranteed that the provided entity is untouched if an exception is thrown.

Developers are highly encouraged to use the provided `language.persister()` when obtaining persisters rather than using functional reference `languages::persist` because when used, it can be recognized by Speedment and its stream optimizer.

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
The `persist()` operation will return an entity that is updated with auto-generated keys from the database (if any) and not default and trigger calculated column values. Remember that you have to query the database to make sure that you have the latest version of your entity that was stored in the database.
" %}

### Selecting fields to persist
By default, the persister will persist the values of all non-generated fields of the given entity. 
In some cases it is useful to be able to exclude some fields from the database persistence
operation. This can be done since Speedment 3.1.6 by supplying a `FieldSet` when retrieving the persister. 

Assume that the `Language` table in the database has a field called `REF` for which `null` values are not allowed, but
the database will create a default value if none is given. In such a situation it is useful to be able to instruct
Speedment not to mention that field in the `SQL INSERT` statement.

The following code will use SQL statements that do not mention the REF of the Language. In case the
default persister was used, the `INSERT` statement would have tried to insert the Language with a `REF` 
value that equals `null`, since REF is not explicitly set in the `LanguageImpl`.

``` java
    Persister<Language> persister = languages.persister(FieldSet.allExcept(Language.REF));
    Stream.of("Italiano", "Español")
        .map(ln -> languages.create().setName(ln))
        .forEach(persister);
``` 

Analogously, the fields to use can be given in a white-list. The following persister will yield `INSERT` statements
that only explicitly sets the `NAME` column.

``` java
    Persister<Language> persister = languages.persister(FieldSet.of(Language.NAME));
``` 

{% include important.html content= "
Just as normal `persist()`, a `persist()` with selected fields to persist will return an entity that is updated with auto-generated keys from the database (if any) and not default and trigger calculated column values. Remember that you have to query the database to make sure that you have the latest version of your entity that was stored in the database.
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

{% include tip.html content= "
Grouping several update operations in a single transaction will often improve performance considerable. Read more about transactions [here](#transactions)
" %}

{% include important.html content= "
Only the database is updated, the entity itself will not be updated by the updater. If the database impose additional modifications (e.g. via triggers) to columns, they are not seen in the entity. Remember that you have to query the database to make sure that you have the exact version of your entity that was stored in the database. If the update operation fails, a `SpeedmentException` will be thrown.
" %}

### Selecting Fields to Update
By default, the updater returned from `updater()` will update the values of all non-generated fields of the given entity. 
In some cases, for example when updating a particular field, it is useful to be able to exclude some fields from the database update
operation. This can be done since Speedment 3.1.6 by supplying a field set definition when retrieving the updater. 

The following code will use SQL `UPDATE` statements that only refer to the `NAME` field (in addition to the 
primary keys, of course). If the default updater were used instead, the `UPDATE` statement 
would set all fields.

``` java
    Updater<Language> updater = languages.updater(FieldSet.of(Language.NAME));
    languages.stream()
        .map(ln -> ln.setName(ln.getName() + " 2"))
        .forEach(updater);
``` 

#### Piecewise Definition of FieldSets
As described above, both persisters and updaters can be created to apply only to a subset of the fields
of the entity. This is done by supplying a `FieldSet` that determines the fields to use. In addition to the 
`FieldSet.allExcept()` and `FieldSet.of()` methods, there is a way to iteratively build a `FieldSet`. 

This can be done by starting with the empty set of fields and iteratively adding the fields,

``` java
    FieldSet<Language> fields = FieldSet.noneOf(Language.class);  // The empty set of fields
    fields = fields.add(Language.NAME);
    languages.persister(fields).apply(language);  // Will persist the language entity by only mentioning name    
```

or by starting with all fields and excluding unwanted fields.

``` java
    FieldSet<Language> fields = FieldSet.allOf(Language.class);  // All fields of the Language
    fields = fields.except(Language.REF);
    languages.persister(fields).apply(language);  // Will persist the language entity by mentioning all fields wxcept the `REF` field.    
```

More elaborate chaining is also allowed, meaning that  

``` java
    manager.updater(FieldSet.of(F1, F2, F3, F4).and(F5).except(F4).except(F1))
```

is a complicated way of expressing the same set of fields as

``` java
    manager.updater(FieldSet.of(F2, F3, F5))
```

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

## Merge with Merge
Merge is available from version 3.2.2 and onwards.
The `merge()` and `merger()` methods really rely on a combination of `persist()` and `update()`. If the provided entity does not exist in the underlying database, it is created. If the provided entity does exist, it is updated in the underlying database.

If the merging fails for any reason, an unchecked `SpeedmentException` is thrown. Entities are uniquely identified by their primary key and merge does only support entities with exactly one primary key.

Here is an example of how to merge an existing language in the Sakila database using the `merge()` method:
``` java
    Language italiano = languages.create()
        .setName("Italiano")
        ... // other setters not shown

    languages.merge(italiano);
```

If there are several entities to merge, it is often better to use the method `MergeUtil::merge` because of its ability to handle existence check for several entities in a single sweep. 
``` java
    Set<Languages> languagesToMerge = ...;
    
    Set<Languages> resultingDbLanguages = MergeUtil.merge(languages, languagesToMerge);
```
This will merge all the entities in the `languageToMerge` Set in a single operation. The returned
set `resultingDbLanguages` will contain the entities as they look in the database after the merge operation.

{% include important.html content= "
If there are several entities to merge:
Do This: `MergeUtil.merge(manager, entitiesToMerge)` 
Don't do This: `entitiesToMerge.forEach(languages.merger())`
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


Here is a hypothetical example where the number of films with a length greater than 75 are added with the number of languages and print out the result. Since the sum is computed within a transaction, the application is immune to any changes in the database while the computation is performed.

``` java
    txHandler.createAndAccept(
        tx -> System.out.println(
            films.stream().filter(Film.LENGTH.greaterThan(75)).count()
            + languages.stream().count()
        )
    );
```

Here is another example that returns the sum outside the transaction for later use:

``` java
    long sumCount = txHandler.createAndApply(
        tx -> films.stream().filter(Film.LENGTH.greaterThan(75)).count() + languages.stream().count()
    );
```

Uncommitted data changes are discarded unless you commit your changes explicitly as shown in this example:

``` java
    long noLanguagesInTransaction = txHandler.createAndApply(
        tx -> {
            Stream.of(
                languages.create().setName("Italian"),
                languages.create().setName("German")
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
Thus, the two new `Language` entities that were created and persisted to the database were rolled back.

Data changes are committed to the database upon invoking the `Transaction::commit` method as shown hereunder:

``` java
    long noLanguagesInTransaction = txHandler.createAndApply(
        tx -> {
            Stream.of(
                languages.create().setName("Italian"),
                languages.create().setName("German")
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

#### Transactions and Threads
A `Transaction` is, by default, only valid to the `Thread` in which it was created. It is not possible to hand off a `transaction` to another `Thread` or to a `CompletableFuture` unless the new `Thread` is attached to the existing transaction.

A new `Thread` can attach to a transaction created by another `Thread` using the `Transaction::attachCurrentThread` method. It is imperative that the new `Thread` detach from the `Transaction` once its task is completed using the `Transaction::detachCurrentThread` method or else transaction resources cannot be released.  
 
Rather than create a `Transaction` in one `Thread` and then attaching it to a new `Thread`, it is many times better to create and complete the entire `Transaction` in the new `Thread`.   
 

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

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
