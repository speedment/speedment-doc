---
permalink: enterprise_enums.html
sidebar: mydoc_sidebar
title: HyperStream Enum Serializer Plugin
keywords: Serializer, Enum, Enterprise, Plugin, HyperStream
enterprise: true
toc: false
Tags: Serializer, Enum, Enterprise, Plugin, HyperStream
previous: enterprise_spring.html
next: enterprise_virtualcolumns.html
---

{% include prev_next.html %}

## About
When using the DataStore module included in HyperStream, it is essential to consider memory usage. If a large number of columns are stored as Strings, they will consume a lot of extra memory, sometimes completely unnescessary. In that case, the Enum Serializer Plugin is useful. Using the Tool, a String column can be mapped to a custom generated Java Enum. In that way Strings can be stored using a single or just a few bytes per entity.

### Integration
To include the Enum Serializer Plugin in your HyperStream project, make sure you are using the speedment-enterprise-maven-plugin (as opposed to the open-source speedment-maven-plugin) and add the following to its configuration:

```xml
<plugin>
    <groupId>com.speedment.enterprise</groupId>
    <artifactId>speedment-enterprise-maven-plugin</artifactId>
    <version>${speedment.enterprise.version}</version>
    
    <configuration>
        <components>
            <component>com.speedment.enterprise.datastore.tool.DataStoreToolBundle</component>
            <component>com.speedment.enterprise.plugins.enums.EnumSerializerBundle</component><!-- This -->
        </components>
    </configuration>
</plugin>
```

No runtime dependencies are required.

### Define Enums in the Tool
Open the Tool by running `mvn speedment:tool` and select the String column you would like to enumify.

{% include image.html file="Enum0.png" url="https://www.speedment.com/" alt="Define an Enum - Select a Column" caption="Step 1: Select a Column" %}

If you press the "JDBC Type to Java" dropdown, you will see a new option called `String to Enum`.

{% include image.html file="Enum1.png" url="https://www.speedment.com/" alt="Define an Enum - Set TypeMapper" caption="Step 2: Select 'String to Enum'-typemapper" %}

Some new items should now appear. If the column is defined as an Enum column in the database, then the "Enum Constants" field might already be populated. If it is not, then you can populate it yourself either by adding the options using the "Add Item" button (double click on a created item to change its name) or by clicking the "Populate" button.

{% include image.html file="Enum2.png" url="https://www.speedment.com/" alt="Define an Enum - Edit Constants" caption="Step 3: Edit constants" %}

When the column is configured, press "Generate" to update your project.

{% include image.html file="Enum3.png" url="https://www.speedment.com/" alt="Define an Enum - Generate Code" caption="Step 4: Generate Code" %}

{% include prev_next.html %}

## Questions and Discussion
If you have any question, don't hesitate to reach out to the Speedment developers on [Gitter](https://gitter.im/speedment/speedment).
