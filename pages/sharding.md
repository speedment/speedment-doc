---
permalink: sharding.html
sidebar: mydoc_sidebar
title: Sharding
keywords: Sharding, Data Store
toc: false
Tags: Sharding
previous: aggregations.html
next: computation.html
---

{% include prev_next.html %}

## Sharding
Sharding can be used to sub-divide different data sets into several Speedment instances. This can potentially increase performance since we are able to reduce the data set to search using a knowm sharding key. The sharding key can be of any type but are many times a `String` or an `int`.
For example, if we have a number of countries, we can shard them using the first character of the name. When we later use the name (an potentially other search arguments), we can immediately look up the correct shard that contains the name we are looking for.

Sharded Speedment instances come in two different flavors:

`ShardedSpeedment` which is using immutable sharding with ahead-of-time sharding key

`MutableShardedSpeedment` which can use dynamic sharding keys discovered at run-time

### Immutable Sharding
Immutable sharding means that the set of shard keys will be defined ahead-of-time. Once all shards has been defined, their corresponding data sets can all
be loaded into memory in a single operation and once loaded, they are instantly available.

The following example will shard all countries that starts with an "A" in one shard and all the countries that starts with a "B" in another shard. Countries that begins with any other letter will not be loaded at all and cannot be accessed.

``` java

// Creates a builder from a sharding key.
// In this example we are not considering the sharding key for
// the builder itself.
Function<String, SpeedmentTestApplicationBuilder> builderMapper = shardKey ->
    new SpeedmentTestApplicationBuilder()
        .withPassword("speedment_test")
        .withBundle(InMemoryBundle.class);


// Creates a ShardedSpeedment object with two keys "A" and "B"
// The content of the different shards are controlled by the given stream decorator
ShardedSpeedment<String> shardedSpeedemnt = ShardedSpeedment.builder(String.class)
    .withApplicationBuilder(builderMapper)
    .putStreamDecorator(CountryManager.IDENTIFIER, (shardKey, stream) -> stream.filter(Country.NAME.startsWith(shardKey)))
    .putShardKey("A")
    .putShardKey("B")
    .build();

// Loads all the shards into memory
shardedSpeedemnt.load();

// Prints all countries in the "A" shard
shardedSpeedemnt
    .getOrThrow("A")
    .getOrThrow(CountryManager.class)
    .stream()
    .forEachOrdered(System.out::println);

// Prints all countries in the "B" shard
shardedSpeedemnt
    .getOrThrow("B")
    .getOrThrow(CountryManager.class)
    .stream()
    .forEachOrdered(System.out::println);

// Closes all the shards
shardedSpeedemnt.close();

```

This will produce the following output:

``` text
CountryImpl { id = 1, abbrevation = AD, name = Andorra, fullName = Principality of Andorra, iso3 = AND, number = 20, region = 4 }
CountryImpl { id = 3, abbrevation = AF, name = Afghanistan, fullName = Islamic Republic of Afghanistan, iso3 = AFG, number = 4, region = 3 }
CountryImpl { id = 4, abbrevation = AG, name = Antigua and Barbuda, fullName = Antigua and Barbuda, iso3 = ATG, number = 28, region = 5 }
CountryImpl { id = 5, abbrevation = AI, name = Anguilla, fullName = Anguilla, iso3 = AIA, number = 660, region = 5 }
CountryImpl { id = 6, abbrevation = AL, name = Albania, fullName = Republic of Albania, iso3 = ALB, number = 8, region = 4 }
CountryImpl { id = 7, abbrevation = AM, name = Armenia, fullName = Republic of Armenia, iso3 = ARM, number = 51, region = 3 }
CountryImpl { id = 9, abbrevation = AO, name = Angola, fullName = Republic of Angola, iso3 = AGO, number = 24, region = 1 }
CountryImpl { id = 10, abbrevation = AQ, name = Antarctica, fullName = Antarctica (the territory South of 60 deg S), iso3 = ATA, number = 10, region = 2 }
CountryImpl { id = 11, abbrevation = AR, name = Argentina, fullName = Argentine Republic, iso3 = ARG, number = 32, region = 7 }
CountryImpl { id = 12, abbrevation = AS, name = American Samoa, fullName = American Samoa, iso3 = ASM, number = 16, region = 6 }
CountryImpl { id = 13, abbrevation = AT, name = Austria, fullName = Republic of Austria, iso3 = AUT, number = 40, region = 4 }
CountryImpl { id = 14, abbrevation = AU, name = Australia, fullName = Commonwealth of Australia, iso3 = AUS, number = 36, region = 6 }
CountryImpl { id = 15, abbrevation = AW, name = Aruba, fullName = Aruba, iso3 = ABW, number = 533, region = 5 }
CountryImpl { id = 17, abbrevation = AZ, name = Azerbaijan, fullName = Republic of Azerbaijan, iso3 = AZE, number = 31, region = 3 }
CountryImpl { id = 61, abbrevation = DZ, name = Algeria, fullName = People's Democratic Republic of Algeria, iso3 = DZA, number = 12, region = 1 }
CountryImpl { id = 18, abbrevation = BA, name = Bosnia and Herzegovina, fullName = Bosnia and Herzegovina, iso3 = BIH, number = 70, region = 4 }
CountryImpl { id = 19, abbrevation = BB, name = Barbados, fullName = Barbados, iso3 = BRB, number = 52, region = 5 }
CountryImpl { id = 20, abbrevation = BD, name = Bangladesh, fullName = People's Republic of Bangladesh, iso3 = BGD, number = 50, region = 3 }
CountryImpl { id = 21, abbrevation = BE, name = Belgium, fullName = Kingdom of Belgium, iso3 = BEL, number = 56, region = 4 }
CountryImpl { id = 22, abbrevation = BF, name = Burkina Faso, fullName = Burkina Faso, iso3 = BFA, number = 854, region = 1 }
CountryImpl { id = 23, abbrevation = BG, name = Bulgaria, fullName = Republic of Bulgaria, iso3 = BGR, number = 100, region = 4 }
CountryImpl { id = 24, abbrevation = BH, name = Bahrain, fullName = Kingdom of Bahrain, iso3 = BHR, number = 48, region = 3 }
CountryImpl { id = 25, abbrevation = BI, name = Burundi, fullName = Republic of Burundi, iso3 = BDI, number = 108, region = 1 }
CountryImpl { id = 26, abbrevation = BJ, name = Benin, fullName = Republic of Benin, iso3 = BEN, number = 204, region = 1 }
CountryImpl { id = 28, abbrevation = BM, name = Bermuda, fullName = Bermuda, iso3 = BMU, number = 60, region = 5 }
CountryImpl { id = 29, abbrevation = BN, name = Brunei Darussalam, fullName = Brunei Darussalam, iso3 = BRN, number = 96, region = 3 }
CountryImpl { id = 30, abbrevation = BO, name = Bolivia, fullName = Republic of Bolivia, iso3 = BOL, number = 68, region = 7 }
CountryImpl { id = 31, abbrevation = BR, name = Brazil, fullName = Federative Republic of Brazil, iso3 = BRA, number = 76, region = 7 }
CountryImpl { id = 32, abbrevation = BS, name = Bahamas, fullName = Commonwealth of the Bahamas, iso3 = BHS, number = 44, region = 5 }
CountryImpl { id = 33, abbrevation = BT, name = Bhutan, fullName = Kingdom of Bhutan, iso3 = BTN, number = 64, region = 3 }
CountryImpl { id = 34, abbrevation = BV, name = Bouvet Island, fullName = Bouvet Island (Bouvetoya), iso3 = BVT, number = 74, region = 2 }
CountryImpl { id = 35, abbrevation = BW, name = Botswana, fullName = Republic of Botswana, iso3 = BWA, number = 72, region = 1 }
CountryImpl { id = 36, abbrevation = BY, name = Belarus, fullName = Republic of Belarus, iso3 = BLR, number = 112, region = 4 }
CountryImpl { id = 37, abbrevation = BZ, name = Belize, fullName = Belize, iso3 = BLZ, number = 84, region = 5 }
CountryImpl { id = 105, abbrevation = IO, name = British Indian Ocean Territory, fullName = British Indian Ocean Territory (Chagos Archipelago), iso3 = IOT, number = 86, region = 3 }
```


### Mutable Sharding
Mutable sharding means that the set of shard key can be dynamically managed (added and removed) on demand. Thus, the set of shard keys must not be known in advance. However, when a new shard is first used, the
data set corresponding to that shard must be loaded into memory, implying an initial first time delay.

The following example will shard countries on demand as shard keys are first seen.

``` java
// Creator that, when applied, will create a Speedment instance for
// a given shard key
final Function<String, SpeedmentTestApplication> creator = shardKey -> {
    SpeedmentTestApplication app = TestUtil.createSpeedmentBuilder().build();
    app.getOrThrow(DataStoreComponent.class).reload(
        ForkJoinPool.commonPool(),
        StreamSupplierComponentDecorator.builder()
            .withStreamDecorator(CountryManager.IDENTIFIER, s -> s.filter(Country.NAME.startsWith(shardKey)))
            .build()
        );
    return app;
};

// Creates a MutableShardedSpeedment
MutableShardedSpeedment<String> shardedSpeedemnt = MutableShardedSpeedment.create(String.class);

// Acquires a Speedment instance for the shard key "A"
// (if the shard is already created, returns the shard,
// if the shard is not created, creates and returns a new
// shard that will be reused for subsequent calls for the
// same shard key.
SpeedmentTestApplication aApp = shardedSpeedemnt.computeIfAbsent("A", creator);

SpeedmentTestApplication bApp = shardedSpeedemnt.computeIfAbsent("B", creator);

final CountryManager aCountryManager = aApp.getOrThrow(CountryManager.class);
final CountryManager bCountryManager = bApp.getOrThrow(CountryManager.class);

// Prints all countries in an "A" shard
aCountryManager.stream().forEach(System.out::println);

// Prints all countries in an "B" shard
bCountryManager.stream().forEach(System.out::println);

// Closes all the shards
shardedSpeedemnt.close();

```

This will produce the same output as the immutable shard example above.

### Shard Keys of Type int
There is a specialized `IntShardedSpeedment` implemetation that can be used if shard keys are of the primitive type `int`. The following example shows how it can be used to shard countries on regions rather than on first-letter-names.

``` java
// Creates a builder from an int sharding key.
// In this example we are not considering the sharding key for
// the builder itself.
IntFunction<SpeedmentTestApplicationBuilder> builderMapper = shardKey ->
    new SpeedmentTestApplicationBuilder()
    .withPassword("speedment_test")
    .withBundle(InMemoryBundle.class);


// Creates an IntShardedSpeedment object with two keys 1 and 2
// The content of the different shards are controlled by the given stream decorator
IntShardedSpeedment shardedSpeedemnt = IntShardedSpeedment.builder()
    .withIntApplicationBuilder(builderMapper)
    .putStreamDecorator(
        CountryManager.IDENTIFIER,
        (shardKey, stream) -> stream.filter(Country.REGION.equal(shardKey))
    )
    .putShardKey(1)
    .putShardKey(2)
    .build();

// Loads all the shards into memory
shardedSpeedemnt.load();

// Prints all countries in the 1 shard
shardedSpeedemnt
    .getByIntOrThrow(1)
    .getOrThrow(CountryManager.class)
    .stream()
    .forEachOrdered(System.out::println);

// Closes all the shards
shardedSpeedemnt.close();

```

This will produce the following output (truncated for brievity):

``` text
CountryImpl { id = 9, abbrevation = AO, name = Angola, fullName = Republic of Angola, iso3 = AGO, number = 24, region = 1 }
CountryImpl { id = 22, abbrevation = BF, name = Burkina Faso, fullName = Burkina Faso, iso3 = BFA, number = 854, region = 1 }
CountryImpl { id = 25, abbrevation = BI, name = Burundi, fullName = Republic of Burundi, iso3 = BDI, number = 108, region = 1 }
CountryImpl { id = 26, abbrevation = BJ, name = Benin, fullName = Republic of Benin, iso3 = BEN, number = 204, region = 1 }
CountryImpl { id = 35, abbrevation = BW, name = Botswana, fullName = Republic of Botswana, iso3 = BWA, number = 72, region = 1 }
CountryImpl { id = 40, abbrevation = CD, name = Congo (Kinshasa), fullName = Democratic Republic of the Congo, iso3 = COD, number = 180, region = 1 }
CountryImpl { id = 41, abbrevation = CF, name = Central African Republic, fullName = Central African Republic, iso3 = CAF, number = 140, region = 1 }
CountryImpl { id = 42, abbrevation = CG, name = Congo (Brazzaville), fullName = Republic of the Congo, iso3 = COG, number = 178, region = 1 }
CountryImpl { id = 44, abbrevation = CI, name = Côte d'Ivoire, fullName = Republic of Cote d'Ivoire, iso3 = CIV, number = 384, region = 1 }
CountryImpl { id = 47, abbrevation = CM, name = Cameroon, fullName = Republic of Cameroon, iso3 = CMR, number = 120, region = 1 }
CountryImpl { id = 52, abbrevation = CV, name = Cape Verde, fullName = Republic of Cape Verde, iso3 = CPV, number = 132, region = 1 }
CountryImpl { id = 57, abbrevation = DJ, name = Djibouti, fullName = Republic of Djibouti, iso3 = DJI, number = 262, region = 1 }
CountryImpl { id = 61, abbrevation = DZ, name = Algeria, fullName = People's Democratic Republic of Algeria, iso3 = DZA, number = 12, region = 1 }
...

```


{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="sharding.html" %}
