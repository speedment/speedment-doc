---
title: Speedment User Guide
keywords: speedment orm java documentation database jdbc stream lambda
Tags: Start
sidebar: mydoc_sidebar
permalink: index.html
toc: false
previous: index.html
next: overview.html
---

{% include prev_next.html %}

## Introduction

Welcome to the Speedment User Guide. This manual includes instructions and examples on how you can configure and use Speedment in you Java database applications. 

The reader of this User Guide needs to be familiar with the Java language and [Apache Maven](https://maven.apache.org/). 

## Speedment Editions
This User Guide covers all editions of Speedment. Throughout this manual:

__Speedment__ refers to all editions of Speedment (including OSS, Stream and HyperStream). Speedment is also the name of the company (Speedment, Inc.) providing the Speedment products.

__Speedment OSS__ is the open-source edition of Speedment which is licensed under Apache 2.0 and available on [GitHub](www.github.com/speedment/speedment). 

__Speedment Stream__ is a commercially licensed edition of Speedment which includes enterprise database connectors (Oracle, SQLServer, DB2 and AS400). Learn more at [speedment.com/stream](https://speedment.com/stream).

__Speedment HyperStream__ is a commercially licensed edition of Speedment which provides hypersonic performance by leveraging the DataStore Memory Management Component in addition to Speedment Stream. Learn more at [speedment.com/hyperstream](https://speedment.com/hyperstream).

__Speedment Enterprise__ refers to all commercially licensed editions of Speedment which provides high-value enterprise features in addition to Speedment OSS.

A full comparison of software licenses is available [here](https://speedment.com/pricing). 

## Speedment Plugins
Speedment's functionality can be extended by using one or several plugins in the form of {{site.data.javadoc.TypeMapper}}s, Components and/or {{site.data.javadoc.InjectBundle}}s. These plugins have their own lifecycles. It is possible for anyone to write a third party Speedment plugin.

See the [Speedment Enterprise Plugins Chapter](enterprise_plugins#top) to view currently available plugins. 

## Speedment Licensing 

Speedment OSS and Speedment User Guide are free and provided under the Apache 2.0 License. Speedment Stream and Speedment HyperStream are commercially licensed by Speedment, Inc.

To license your software, please visit [Speedment Licensing and Pricing](https://speedment.com/pricing). 

## Support
Support for Speedment is provided on a best effort basis via [GitHub](https://github.com/speedment/speedment/issues), [Gitter](https://gitter.im/speedment/speedment) and [StackOverflow](http://stackoverflow.com/questions/tagged/speedment?sort=newest)

For information about professional support, see [Speedment Licensing and Pricing](https://speedment.com/pricing). 

## Resources 
In addition to the information provided in this User Guide the following resources are available: 

__JavaDoc__

The latest online JavaDocs are available [here](http://www.javadoc.io/doc/com.speedment/runtime-deploy).

__Video Tutorials__

Some topics of this User Guide are covered in Video Guides which are freely available [here](https://speedment.com/video-tutorials). 

__Release Notes__

Please refer to the [Release Notes documents](https://github.com/speedment/speedment/releases) for new features, enhancements and fixes performed for each Speedment release.

__Initializer__

An online [Initializer](https://speedment.com/download) that can automatically generate a custom pom-file including the needed Maven dependencies to suit your project. 

{% include image.html file="Initializer.png" url="https://www.speedment.com/initializer" alt="The Speedment Initializer" caption="The Speedment Initializer" %}

## Contributing to Speedment
We gladly welcome, and encourage contributions to Speedment OSS from the community. Read more [here](https://github.com/speedment/speedment/blob/master/CONTRIBUTING.md) on how to make a contribution.

## Phone Home
Speedment sends certain data back to our servers as described [here](https://github.com/speedment/speedment/blob/master/DISCLAIMER.MD).
If you must and/or want to disable this function, [contact us](https://speedment.com/contact).

{% include prev_next.html %}

