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
	<coverPage>
		<xsl:apply-templates select="ContentsTitle | ContentsEUTitle" />
		<toc>
			<xsl:apply-templates select="* except (ContentsTitle, ContentsEUTitle)" />
		</toc>
	</coverPage>
</xsl:template>

<xsl:template match="Contents/ContentsTitle | Contents/ContentsEUTitle">
	<block name="title">
		<docTitle>
			<xsl:apply-templates />
		</docTitle>
	</block>
</xsl:template>

	<xsl:template match="ContentsGroup | ContentsPart | ContentsChapter | ContentsEUChapter | ContentsEUSection | ContentsPblock | ContentsPsubBlock | ContentsSchedules | ContentsSchedule | ContentsAppendix | ContentsDivision | ContentsItem | ContentsAttachments | ContentsAttachment">
	<xsl:param name="level" as="xs:integer" select="if (self::ContentsSchedules) then 0 else 1" />
	<xsl:if test="exists(ContentsNumber | ContentsTitle | ContentsEUTitle)">
		<tocItem level="{ $level }" href="{ @DocumentURI }" ukl:Name="{ local-name() }">
			<xsl:apply-templates select="ContentsNumber | ContentsTitle | ContentsEUTitle" />
		</tocItem>
	</xsl:if>
	<xsl:apply-templates select="* except (ContentsNumber, ContentsTitle, ContentsEUTitle)">
		<xsl:with-param name="level" select="$level + 1" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="ContentsNumber">
	<inline name="tocNum">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="ContentsTitle | ContentsEUTitle">
	<inline name="tocHeading">
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
