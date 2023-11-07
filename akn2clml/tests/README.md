# Testing AKN to CLML XSLTs for UK Legislation

This location is the home of AKN (Akoma Ntoso) related XSL TEST transformations to CLML (Crown Legislation Markup Language) for TNA (The National Archives [https://www.nationalarchives.gov.uk/](https://www.nationalarchives.gov.uk/)).

---
**NOTE**

This repository (its structure and content) are currently under development.

---


## About AKN

AKN (Akoma Ntoso) is an international XML standard for parliamentary, legislative and judiciary documents (see [http://www.akomantoso.org/](http://www.akomantoso.org/)).

AKN XML is created by the Lawmaker system as the format for new UK legislation.

Information on AKN XML can be found on the [AKN website](http://www.akomantoso.org/?page_id=27) and the standard XML schema for AKN used for AKN can be found on [GitHub](https://github.com/oasis-open/legaldocml-akomantoso).

UK legislation uses a subset of the AKN model and an [unofficial RNG schema](https://github.com/jurisdatum/tna-akn-subschema/tree/main/src/main/resources/relaxng) that describes model. 

## About CLML

CLML (Crown Legislation Markup Language) is the existing UK XML standard for legislation and is used to store, publish and deliver UK legislation.

CLML XML is available from the [UK legislation website](https://www.legislation.gov.uk/) see [https://www.legislation.gov.uk/developer/formats/xml](https://www.legislation.gov.uk/developer/formats/xml) with information on the API available at [https://www.legislation.gov.uk/developer](https://www.legislation.gov.uk/developer).

The schema itself is available at [https://www.legislation.gov.uk/schema/legislation.xsd](https://www.legislation.gov.uk/schema/legislation.xsd) with a user guide and extensive interactive documentation and diagrams at [https://legislation.github.io/clml-schema/](https://legislation.github.io/clml-schema/).

## Repository location on local drive
The test data and Oxygen Project is located at the same level as the directory for the XSLT transform location inside the akn2clml area of the repo so that the relative paths used in the Oxygen transform scenarios work correctly. Base-Results, Data and Results directories are children of this directory.

## About the XSLTs
The XSLTs used on the data in the repository Oxygen Project Transform Scenarios have been developed using XSLT2 and have been arranged in the following subfolders with a different folder for each process.

- [akn2clml](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/akn2clml/transform) to convert AKN XML to CLML XML
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

The outputs can then be compared for each stage against the original base versions held in Base-Results directory. This Base Results content will change over time as XSLT changes are merged into the repository trunk and accepted as current base code.

## Validation of Results
The data created can be validated against the CLML schema with an Oxygen Project Validation Scenario. This assumes the tna.legislation.schema.clml repository sits at the same level as the tna.legislation.transformations.akn one.

Right click content to be validated and select steps:
- Validate
- Configure Validation Scenario(s)
- AKN2CLML-data-validation