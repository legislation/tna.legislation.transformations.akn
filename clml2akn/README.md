# XSLTs for Conversion of CLML data to AKN

CLML (Crown Legislation Markup Language) is the existing UK XML standard for legislation and is used to store, publish and deliver UK legislation.

AKN (Akoma Ntoso) is an international XML standard for parliamentary, legislative and judiciary documents.

The XSLTs in this folder are designed to convert data from CLML format to AKN format.

See https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/ for links to further information about CLML and AKN.

## Transformation Stages

There is one main transformation that is used to create AKN data from CLML.

[clml2akn.xsl](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/clml2akn/transform/clml2akn.xsl) - top level XSLT (includes other modules from this folder).

## XSLT Processor Compatibility

The XSLT2 transformations in this folder should be compatible with Saxon 9.1 and 10.