# Maven Targets

The Speedment Mavan Plugin has four Maven targets that can be used to simplify and/or automate your build process.

# Installation

To install the Speedment Maven Plugin we have to add it as a plugin in our pom.xml file as described hereunder:

``` xml
    <build>
        <plugins>
            <plugin>
                <groupId>com.speedment</groupId>
                <artifactId>speedment-maven-plugin</artifactId>
                <version>${speedment.version}</version>
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


# Configuration

You can read the API Quick Start [here](https://github.com/speedment/speedment/wiki/Speedment-API-Quick-Start).

# Targets
There are four Maven targets in the Speedment Maven Plugin
  * tool
  * generate
  * reload
  * clear

## Tool (speedment:tool)
Stuff about Tool

## Generate (speedment:generate)
Stuff about Generate

## Reload (speedment:reload)
Stuff about Reload

## Clear (speedment:clear)
Stuff about Clear


