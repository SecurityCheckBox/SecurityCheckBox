# SecurityCheckBox

This repo contains just a pipeline that analyzes code in some repositories that I don't own, but I'm interested in. 

It uses [SonarCloud](https://www.sonarsource.com/products/sonarcloud/) for the analysis.

Here are [the analysis results](https://sonarcloud.io/organizations/security-check-box/projects).

## Setting up your own SonarCloud analysis

I recommend you to set up your own SonarCloud analysis on every repo. 
It helps preventing bugs and security issues. 

It is pretty straightforward - just register in SonarCloud and follow the prompts. 
There are also tons of tutorials to help you.
For example [this one](https://docs.sonarsource.com/sonarcloud/getting-started/github/) and [this one](https://www.sonarsource.com/learn/integrating-sonarcloud-with-github/)

Very useful is the option to integrate SonarCloud code quality check on pull requests.
That way, you can reject pull requests with detected problems.

# Notes for me 

## Running the [pipeline](./.github/workflows/SonarCloud-analysis.yml)

It runs weekly on schedule, but it can also be run manually [here](https://github.com/SecurityCheckBox/SecurityCheckBox/actions/workflows/SonarCloud-analysis.yml).

## Adding a repo

* Add a new config
  * in the [pipeline](./.github/workflows/SonarCloud-analysis.yml) > input > options
  * in the [config generator](./.github/workflows/produce_matrix_items.sh)
* Commit + push
* Run the workflow [manually](https://github.com/SecurityCheckBox/SecurityCheckBox/actions/workflows/SonarCloud-analysis.yml) for the new repo
