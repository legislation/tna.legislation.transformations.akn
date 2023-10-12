# XSLTs for Conversion of AKN data to HLML

AKN (Akoma Ntoso) is an international XML standard for parliamentary, legislative and judiciary documents.

Current HTML outputs from include XHTML (used by publishing) and HTML5 (used by the Legislation website and Lawmaker) but this folder's XSLT currently contain only the XHTML publishing transform.

The transformations in this folder will be enhanced to allow production of all required HTML output for the relevent systems from a single code base.

See https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/ for links to further information about AKN.

## Transformations

Publishing currently calls [akn2xhtml.xsl](https://bitbucket.org/tsoltd/tna.legislation.transformations.akn/src/main/akn2html/transform/akn2xhtml.xsl) as the top level XSLT to produce XHTML.

This XSLT imports akn2html.xsl (an ammended copy of the original v3.0.5 akn2html.xsl) that currently produces XML (so that it can be post-processed inside a variable in akn2xhtml.xsl).

New top level XSLTs should be created to output HTML5, XHTML and even XML if required with the common code in a new included file (and sub files of that file).

## XSLT Processor Compatibility

The XSLT2 transformations in this folder should be compatible with Saxon 9.1 and 10.
