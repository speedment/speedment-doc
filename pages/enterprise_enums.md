---
permalink: enterprise_enums.html
sidebar: mydoc_sidebar
title: Enterprise Enum Serializer Plugin
keywords: Serializer, Enum, Enterprise, Plugin
enterprise: true
toc: false
Tags: Serializer, Enum, Enterprise, Plugin
previous: enterprise_json.html
next: 
---

{% include prev_next.html %}

## About
When using the Enterprise Datastore module, it is very important to think about memory usage. If many columns are stored as Strings, they will take up a lot of extra memory, sometimes completely unnescessary. That is where the Enterprise Enum Serializer Plugin is useful. Using the Speedment Tool, a String column can be mapped to a custom generated java enum. In that way it can be stored using a single or just a few bytes per entity.

### Integration
To include the Enterprise Enum Serializer Plugin in your Speedment project, make sure you are using the speedment-enterprise-maven-plugin (as opposed to the open-source speedment-maven-plugin) and add the following to its configuration:

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

### Define Enums in the Speedment Tool
Open the Speedment Tool by running `mvn speedment:tool` and select the String Column you would like to enumify.

{% include image.html file="Enum0.png" url="https://www.speedment.com/" alt="Define an Enum - Select a Column" caption="Step 1: Select a Column" %}

If you press the "JDBC Type to Java" dropdown, you will see a new option called `String to Enum`. Select that.

{% include image.html file="Enum1.png" url="https://www.speedment.com/" alt="Define an Enum - Set TypeMapper" caption="Step 2: Select 'String to Enum'-typemapper" %}

Some new items should now appear. If the column is defined as an enum column in the database, then the "Enum Constants" field might already be populated. If it is not, then you can populate it yourself either by adding the options using the "Add Item" button (double click on a created item to change its name) or by clicking the "Populate" button.

{% include image.html file="Enum2.png" url="https://www.speedment.com/" alt="Define an Enum - Edit Constants" caption="Step 3: Edit constants" %}

When the column is configured, you can press "Generate" and your project will be updated.

{% include image.html file="Enum3.png" url="https://www.speedment.com/" alt="Define an Enum - Generate Code" caption="Step 4: Generate Code" %}

{% include prev_next.html %}

## Discussion
Join the discussion in the comment field below or on [Gitter](https://gitter.im/speedment/speedment)

{% include messenger.html page-url="integration.html" %}
