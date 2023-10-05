<?xml version="1.0" encoding="utf-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml" exclude-result-prefixes="html">


<!-- remove colspan="1" and rowspan="1" -->

<xsl:template match="@colspan | @rowspan" mode="fix-clml">
	<xsl:if test="string(.) != '1'">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<!-- remove valign="middle" -->

<xsl:template match="html:th/@valign | html:td/@valign" mode="fix-clml">
	<xsl:if test="string(.) != 'middle'">
		<xsl:next-match />
	</xsl:if>
</xsl:template>


<!-- identity transform -->

<xsl:template match="@*|node()" mode="fix-clml">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="fix-clml" />
	</xsl:copy>
</xsl:template>

</xsl:transform>
