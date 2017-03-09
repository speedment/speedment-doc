---
permalink: maven.html
sidebar: mydoc_sidebar
title: Speedment Maven Plugin
keywords: Maven, Plugin, Tool, Generate, Reload, Clear
Tags: Installation
---

## Maven Targets

The Speedment Mavan Plugin has four Maven targets that can be used to simplify and/or automate your build process.

## Installation

To install the Speedment Maven Plugin we have to add it as a plugin in our pom.xml file as described hereunder:

``` xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>{{ site.data.speedment.version }}</version>
            </plugin>
        </plugins>
    </build>
```

The Speedment Maven Plugin autmatically depends on relevant version of open-source JDBC database drivers. These dependencies can be overridden 
should we want to use another version. In the example below, we override the MySql JDBC version with an older one:

``` xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
                <dependencies>
                    <dependency>
                        <groupId>mysql</groupId>
                        <artifactId>mysql-connector-java</artifactId>
                        <version>5.1.38</version>
                    </dependency>
                </dependencies> 
            </plugin>
        </plugins>
    </build>
```


## Targets
There are four Maven targets in the Speedment Maven Plugin
  * tool
  * generate
  * reload
  * clear

### Tool (speedment:tool)
Stuff about Tool

### Generate (speedment:generate)
Stuff about Generate

### Reload (speedment:reload)
Stuff about Reload

### Clear (speedment:clear)
Stuff about Clear


## Configuration

The Speedment Maven Plugin can be configured in many ways

### Adding Type Mappers
TBW

##$ Adding Bundles
TBW

### Enable Debug
If we want to follow more closely what is going on in the Speedment Maven Plugin, we can enable *Debug Mode*. In this mode, information about 
what classes are initiated...


