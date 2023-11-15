<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	exclude-result-prefixes="html">

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
	
<xsl:template match="intro[empty(following-sibling::*)]">
	<content>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</content>
</xsl:template>

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
