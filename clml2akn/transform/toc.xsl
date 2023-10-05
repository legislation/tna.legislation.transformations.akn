<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">

<xsl:template match="Contents">
	<xsl:apply-templates select="ContentsTitle" />
	<toc>
		<xsl:apply-templates select="* except ContentsTitle">
			<xsl:with-param name="level" select="1" />
		</xsl:apply-templates>
	</toc>
</xsl:template>

<xsl:template match="Contents/ContentsTitle">
	<block name="ToCHeading">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="ContentsGroup | ContentsPart | ContentsChapter | ContentsPblock | ContentsPsubBlock | ContentsSchedules | ContentsSchedule | ContentsAppendix | ContentsDivision | ContentsItem">
	<xsl:param name="level" as="xs:integer" select="1" />
	<xsl:call-template name="toc-item">
		<xsl:with-param name="level" select="$level" />
		<xsl:with-param name="ukl-name" select="local-name()" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="toc-item">
	<xsl:param name="level" as="xs:integer" select="1" />
	<xsl:param name="ukl-name" as="xs:string?" select="()" />
	<tocItem>
		<xsl:attribute name="href">
		</xsl:attribute>
		<xsl:attribute name="level">
			<xsl:value-of select="$level" />
		</xsl:attribute>
		<xsl:if test="exists($ukl-name)">
			<xsl:attribute name="ukl:Name">
				<xsl:value-of select="$ukl-name" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="ContentsNumber | ContentsTitle" />
	</tocItem>
	<xsl:apply-templates select="* except (ContentsNumber, ContentsTitle)">
		<xsl:with-param name="level" select="$level + 1" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ContentsNumber">
	<inline name="tocNum" ukl:Name="ContentsNumber">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="ContentsTitle">
	<inline name="tocHeading" ukl:Name="ContentsTitle">
		<xsl:apply-templates />
	</inline>
</xsl:template>


<!--  -->

<xsl:template match="Schedule/Contents">
	<intro>
		<xsl:next-match />
	</intro>
</xsl:template>

</xsl:transform>
