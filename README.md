# SecurityCheckBox

This repo contains just a pipeline that analyzes code in some repositories that I don't own, but I'm interested in. 

It uses [SonarCloud](https://www.sonarsource.com/products/sonarcloud/) for the analysis.

## Setting up your own SonarCloud analysis

I recommend you to set up your own SonarCloud analysis on every repo. 
It helps preventing bugs and security issues. 

It is pretty straightforward - just register in SonarCloud and follow the prompts. 
There are also tons of tutorials to help you.
Fit example [this one](https://docs.sonarsource.com/sonarcloud/getting-started/github/) and [this one](https://www.sonarsource.com/learn/integrating-sonarcloud-with-github/)

Very useful is the option to integrate SonarCloud code quality check on pull requests.
That way, you can reject pull requests with detected problems.

# Notes for me 

## Running the [pipeline](./.github/workflows/SonarCloud-analysis.yml)

It runs weekly on schedule, but it can also be run manually [here](https://github.com/SecurityCheckBox/SecurityCheckBox/actions/workflows/SonarCloud-analysis.yml).

## Adding a repo

* Create a project in [SonarCloud](https://sonarcloud.io/projects/create)
  * Create a project manually
  * Organization: SecurityCheckBox
  * Display name: (name of the project)
  * Project key: (copy it and use it in the pipeline)
  * Visibility: Public
  * New code: 90 days
* Add a new config in the [pipeline](./.github/workflows/SonarCloud-analysis.yml) > strategy > matrix > config

## TODOs

### Manual run for just one repo

### C code analysis is disabled

It was causing `java.lang.UnsupportedOperationException` errors: 

```
11:26:49.211 INFO  Sensor CFamily [cpp]
11:26:49.242 INFO  CFamily plugin version: 6.60.0.76379 (5be0f75cd1a7285a862a55f79e785691e99cc32b)
11:26:49.244 ERROR 

The only way to get an accurate analysis of C/C++/Objective-C files in Manual Configuration mode is to provide a compilation database through the property "sonar.cfamily.compile-commands"; The option was not specified.

You can generate a compilation database by wrapping your clean build with SonarSource build-wrapper, or by using a third party tool.
For more information consult the documentation at https://docs.sonarsource.com/sonarcloud/advanced-setup/languages/c-family/analysis-modes/

If you don't want to analyze C/C++/Objective-C files, then prevent them from being analyzed by setting the following properties:

    sonar.c.file.suffixes=-
    sonar.cpp.file.suffixes=-
    sonar.objc.file.suffixes=-
```

Disable in the pipeline using:

```properties
-Dsonar.c.file.suffixes=-
-Dsonar.cpp.file.suffixes=-
-Dsonar.objc.file.suffixes=-
```
