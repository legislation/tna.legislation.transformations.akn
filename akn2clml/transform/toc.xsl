<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">

<xsl:template match="block[@name='ToCHeading']" />

<xsl:template match="block[@name='ToCHeading']" mode="toc">
	<ContentsTitle>
		<xsl:apply-templates />
	</ContentsTitle>
</xsl:template>

<xsl:template match="toc">
	<Contents>
		<xsl:apply-templates select="preceding-sibling::block[@name='ToCHeading']" mode="toc" />
		<xsl:call-template name="toc-items" />
	</Contents>
</xsl:template>

<xsl:template name="toc-items">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:param name="items" as="element(tocItem)*" select="*" />
	<xsl:param name="level" as="xs:integer" select="1" />
	<xsl:for-each-group select="$items" group-starting-with="tocItem[@level=$level]">
		<xsl:element name="{ if (exists(@ukl:Name)) then @ukl:Name else 'ContentsItem' }">
			<xsl:apply-templates />
			<xsl:call-template name="toc-items">
				<xsl:with-param name="items" select="current-group()[position() gt 1]" />
				<xsl:with-param name="level" select="$level + 1" />
				<xsl:with-param name="context" select="(if (exists(@ukl:Name)) then @ukl:Name else 'ContentsItem', $context)" tunnel="yes" />
			</xsl:call-template>
		</xsl:element>
	</xsl:for-each-group>
</xsl:template>

<xsl:template match="inline[@name='tocNum']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ContentsNumber>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ContentsNumber', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ContentsNumber>
</xsl:template>

<xsl:template match="inline[@name='tocHeading']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ContentsTitle>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ContentsTitle', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ContentsTitle>
</xsl:template>

</xsl:transform>
