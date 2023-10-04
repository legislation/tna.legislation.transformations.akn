# XSLTs for Conversion of CLML data to AKN

CLML (Crown Legislation Markup Language) is the existing UK XML standard for legislation and is used to store, publish and deliver UK legislation.
The XSLTs in this folder are designed to convert data from CLML format to AKN format. See https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/ for links to further information about CLML and AKN.

## Transformation Stages

There are currently three transformations (run as a pipeline) that are used to create AKN data from CLML


1. [ldapp-fix.xsl](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/akn2clml/src/main/resources/transform/ldapp-fix.xsl) - a first pass used to filter out unwanted or empty markup in the AKN source 
2. [akn2clml.xsl](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/akn2clml/src/main/resources/transform/akn2clml.xsl)akn2clml.xsl - second pass containing the majority of the transformation logic (contained in this XSLT file and in other modules included from this folder).
3. add-data.xsl[add-data.xsl](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/akn2clml/src/main/resources/transform/add-data.xsl) - final pass optionally adding in the schemaLocation, publisher metadata and ISBN metadata if available (passed in as XSLT parameters)


## XSLT Processor Compatibility

The XSLT2 transformations in this folder should be compatible with Saxon 9.1 and 10.
