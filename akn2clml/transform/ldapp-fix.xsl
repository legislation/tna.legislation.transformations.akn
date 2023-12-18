<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	exclude-result-prefixes="uk html">

<xsl:template match="level[descendant::num]">
	<xsl:choose>
		<xsl:when test="(descendant::num | descendant::p)/text()">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
</xsl:template>

<!-- LEGDEV-6301 -->
<xsl:template match="quotedStructure[@uk:docName='uksi' and @uk:context='body']/subsection[@class='prov2']">
	<paragraph>
		<xsl:apply-templates select="@*|node()"/>
	</paragraph>
</xsl:template>

<xsl:template match="intro[empty(following-sibling::*)]">
	<content>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</content>
</xsl:template>

<xsl:template match="p[empty(child::node())]">
	<xsl:message>
		<xsl:text>removing empty p element</xsl:text>
	</xsl:message>
</xsl:template>

<xsl:template match="hcontainer[empty(child::node())]">
	<xsl:message>
		<xsl:text>removing empty hcontainer element</xsl:text>
	</xsl:message>
</xsl:template>

<!-- ignore links within defined terms -->
<xsl:template match="def//ref">
	<xsl:apply-templates />
</xsl:template>
	
<!-- remove page breaks -->
<xsl:template match="block[@name='pageBreak'][empty(child::node())]" />

<xsl:template match="ref[@class='invalid']">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:ref">
	<xsl:choose>
		<xsl:when test="@class='invalid'">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<ref>
				<xsl:apply-templates select="@*|node()"/>
			</ref>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="html:td//html:*" priority="-1">
	<xsl:element name="{ local-name() }">
		<xsl:apply-templates select="@*|node()"/>
	</xsl:element>
</xsl:template>

<xsl:template match="inline[@name='placeholder']">
	<xsl:message>
		<xsl:text disable-output-escaping="yes">skipping &lt;inline name="placeholder"&gt;</xsl:text>
	</xsl:message>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

</xsl:transform>
