# Testing AKN to CLML XSLTs for UK Legislation

This location is the home of the XSLT test harness for AKN (Akoma Ntoso) transformations to CLML (Crown Legislation Markup Language) for TNA (The National Archives [https://www.nationalarchives.gov.uk/](https://www.nationalarchives.gov.uk/)).

See [akn2clml](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/akn2clml/transform) to convert AKN XML to CLML XML

---
**NOTE**

This test data set being used is under development and will be expanded over time.

---

## Repository location on local drive
The test data and Oxygen Project is located at the same level as the directory for the XSLT transform location inside the akn2clml area of the repo so that the relative paths used in the Oxygen transform scenarios work correctly. Base-Results, Data and Results directories are children of this directory.

## About the XSLTs
The XSLTs used on the data in the repository Oxygen Project Transform Scenarios have been developed using XSLT2 and have been arranged in the following subfolders with a different folder for each process.

The three specific XSL files being tested in order are:

1. ldapp-fix.xsl
2. akn2clml.xsl
3. add-data.xsl

## Test Data
All test data included is available purely for testing purposes and should not be taken as the official representation of that specific data version.

The test data is in two folders, Fail and Pass inside the Data folder

Tests can be run in turn by right-clicking on the Data directory and selecting steps:

- Transform
- Configure Transform Scenario(s)
- Under Project Scenario select the step required
- Apply associated button

Steps run in turn on the appropriate directory are:
1. AKN2CLML-step-1-ldapp-fix on Pass
2. AKN2CLML-step-2-akn2clml on A2C-1-ldapp-fix
3. AKN2CLML-step-3-add-data on A2C-1-akn2clml

The outputs can then be compared for each stage against the original base versions held in Base-Results directory. This Base Results content will change over time as XSLT changes are merged into the repository trunk and the XML results of those updates are accepted as current base code.

## Validation of Results
The data created can be validated against the CLML schema with an Oxygen Project Validation Scenario. This assumes the tna.legislation.schema.clml repository sits at the same level as the tna.legislation.transformations.akn one.

Right click content to be validated and select steps:
- Validate
- Configure Validation Scenario(s)
- AKN2CLML-data-validation