---
title: Speedment User's Guide
keywords: speedment orm java documentation database jdbc stream lambda
tags: [getting_started]
sidebar: mydoc_sidebar
permalink: index.html
summary: Learn how to connect a Java 8 Stream to a SQL database in an extremely efficient manner.
---

```xml
<build>
    <plugins>
        
        <plugin>
            <groupId>com.speedment</groupId>
            <artifactId>speedment-maven-plugin</artifactId>
            <version>${speedment.version}</version>
        </plugin>
        
    </plugins>
</build>
<dependencies>
    
    <dependency>
        <groupId>com.speedment</groupId>
        <artifactId>runtime</artifactId>
        <version>${speedment.version}</version>
        <type>pom</type>
    </dependency>
    <dependency>
        <groupId>org.mariadb.jdbc</groupId>
        <artifactId>mariadb-java-client</artifactId>
        <version>1.5.7</version>
        <scope>runtime</scope>
    </dependency>
    
</dependencies>

```

Again, make sure that you use the latest `${speedment.version}` available.

### Requirements
Speedment comes with support for the following databases out-of-the-box:
* MySQL
* MariaDB
* PostgreSQL


This site covers the **Speedment Open Source** project available under the 
[Apache 2 license](http://www.apache.org/licenses/LICENSE-2.0). The 
enterprise product with support for commercial 
databases (i.e. Oracle, MS SQL Server, DB2, AS400) and in-JVM-memory acceleration can be found at 
[www.speedment.com](http://speedment.com/).

Speedment requires `Java 8` or later. Make sure your IDE configured to use JDK 8 (version 1.8.0_40 or newer).

License
-------

Speedment is available under the [Apache 2 License](http://www.apache.org/licenses/LICENSE-2.0).


#### Copyright

Copyright (c) 2014-2017, Speedment, Inc. All Rights Reserved.
Visit [www.speedment.org](http://www.speedment.org/) for more info.
