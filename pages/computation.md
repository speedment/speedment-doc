---
permalink: computation.html
sidebar: mydoc_sidebar
title: General Computation
keywords: Data Store, Computation, Compute
toc: false
Tags: Compute
previous: datastore.html
next: enterprise_plugins.html
---

{% include prev_next.html %}

## General Computation
It is possible to use Speedment as a General Computation engine whereby results are computed between several Speedment instances. Each successive step will read directly from memory from one or more previous stages instead of reading from a regular database. 

In the table below, the steps 0 - N are illustrated where the initial step 0 is populated from a database:

| Step # | Data Source     | Action
| :----- | :-------------- | ------------------------------- |
|  0     | Database        | Step 0 (the initial step) reads from a general data source as per default a database
|  1     | Step 0          | Step 1 reads input data from Step 0
|  2     | Step {0-1}      | Step 2 reads input data from a set of previous steps {0, 1}
|  ...   | ...             | ...
|  N     | Step {0..N-1}   | Step N reads input data from a set of previous steps {0, 1, ..., N-1}

The General Computation engine features will be improved over the course of the coming releases.


### Setup
By replacing the `SqlStreamSupplierComponent` in a step, that step can be made to read from previous stages instead of reading from a database. The method of using Custom Stream Suppliers is generally described [here](advanced_features.html#custom-stream-suppliers).

The following example shows how a simplistic two-step computation engine can be implemented for the Sakila Database. No modification of the data is made between the steps in this simple example.

``` java
public class SimpleTwoStepExample {

    public static void main(String[] args) {

        // The First Step Reads From the Database
        final SakilaApplication step0 = new SakilaApplicationBuilder()
            .withPassword("sakila-password")
            .withBundle(DataStoreBundle.class)
            .build();

        step0.get(DataStoreComponent.class).ifPresent(DataStoreComponent::load);

        final FilmManager filmsStep0 = step0.getOrThrow(FilmManager.class);
        // Print out the first 4 Films, Data was read from the database
        filmsStep0.stream().limit(4).forEach(System.out::println);

        // The Second Step Reads From the firstStepApp in-JVM-memory data
        final SakilaApplication step1 = new SakilaApplicationBuilder()
            .withSkipCheckDatabaseConnectivity()
            .withBundle(DataStoreBundle.class)
            .withComponent(StepStreamSupplierComponent.class)
            .build();

        step1.get(StepStreamSupplierComponent.class).ifPresent(p -> p.setPreviousStage(step0));
        step1.get(DataStoreComponent.class).ifPresent(DataStoreComponent::load);

        final FilmManager filmsStep1 = step1.getOrThrow(FilmManager.class);
        // Print out the first 4 Films, Data was read from the first step
        filmsStep1.stream().limit(4).forEach(System.out::println);

        step0.stop();
        step1.stop();
    }

    private static class StepStreamSupplierComponent implements SqlStreamSupplierComponent {

        private SakilaApplication previousStageApp;

        @Override
        @SuppressWarnings("unchecked")
        public <ENTITY> Stream<ENTITY> stream(TableIdentifier<ENTITY> tableIdentifier, ParallelStrategy strategy) {
            final StreamSupplierComponent ssc = previousStageApp.getOrThrow(StreamSupplierComponent.class);
            return ssc.stream(tableIdentifier, strategy);
        }

        @Override
        public <ENTITY> void install(TableIdentifier<ENTITY> tableIdentifier, SqlFunction<ResultSet, ENTITY> entityMapper) {
        }

        public void setPreviousStage(SakilaApplication previousStageApp) {
            this.previousStageApp = requireNonNull(previousStageApp);
        }

    }
}

```
It should be noted that in a more realistic example than above, the data model may be different for each step and the stream content may also be modified. In such cases, the same principle as shown above can be applied but the implementation of the custom stream supplier's `stream()` method must be tailored to match the input requirements of the new stage.


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="computation.html" %}
