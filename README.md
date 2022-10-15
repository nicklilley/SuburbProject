## Burb Browser Project
- [Burb Browser Project](#burb-browser-project)
- [Purpose](#purpose)
- [End Product](#end-product)
- [Progress](#progress)
- [Architecture](#architecture)
  - [Diagram](#diagram)
  - [Infrastructure](#infrastructure)
  - [Extract and Load](#extract-and-load)
  - [Transform](#transform)
  - [Visualisation](#visualisation)
    - [Sub-sub-heading](#sub-sub-heading)

## Purpose

The purpose of this project is to:

1) Develop a tool to help Australians find their perfect suburb to rent or buy in, based on criteria that is important to them (e.g price, distance to CBD, school performance, crime rates, etc)

2) Develop a modern stack and apply a suite of tools to a real world scenario

<br/>

## End Product
Insert picture here

<br/>

## Progress

**Release 1.0**
- [X] Develop Extract and Load Python jobs
- [X] Define and deploy injestion infrastructure & data warehouse as code, using Terraform & Snowflake
- [X] Develop Housing Affordability Kimball models and tests, using DBT
- [ ] Develop Housing Affordability visualisations
- [ ] Create web app for visualisations
- [ ] Orchestrate monthly ELT process, using Apache Airflow

**Release 2.0**
- [ ] General Demograhpics Kimball models and tests, using DBT
- [ ] General Demograhpics visualisations
- [ ] Crime Statistics Kimball models and tests, using DBT
- [ ] Crime Statistics visualisations

**Release 3.0**
- [ ] Develop summary visualisations across multiple topics (e.g. Housing affordability + Crime)
- [ ] School Performance Kimball models and tests, using DBT
- [ ] Develop School Performance visualisations
- [ ] Commute Time Kimball models and tests, using DBT
- [ ] Commute Time visualisations

<br/>

## Architecture

<br/>

### Diagram

![image info](./architecture.jpg)

### Infrastructure

### Extract and Load

### Transform

### Visualisation

#### Sub-sub-heading




**crt-shift-v**



> **NOTE**: Put text

First clone the repository into your home directory and follow the steps.

  ```bash
  git clone https://github.com/ABZ-Aaron/Reddit-API-Pipeline.git
  cd Reddit-API-Pipeline
  ```

1. [Overview](instructions/overview.md)
2. [Reddit API Configuration](instructions/reddit.md)