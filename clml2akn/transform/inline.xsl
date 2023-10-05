<?xml version="1.0" encoding="utf-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">

<xsl:template match="Emphasis">
	<i>
		<xsl:apply-templates />
	</i>
</xsl:template>

<xsl:template match="Strong">
	<b>
		<xsl:apply-templates />
	</b>
</xsl:template>

<xsl:template match="Underline">
	<u>
		<xsl:apply-templates />
	</u>
</xsl:template>

<xsl:template match="SmallCaps">
	<inline name="smallCaps">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Uppercase">
	<inline name="uppercase">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Strike">
	<inline name="strike">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Expanded">
	<inline name="expanded">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Superior">
	<sup>
		<xsl:apply-templates />
	</sup>
</xsl:template>

<xsl:template match="Inferior">
	<sub>
		<xsl:apply-templates />
	</sub>
</xsl:template>

<xsl:template match="Term">
	<term refersTo="#{local:make-term-id(.)}">
		<xsl:if test="exists(@id)">
			<xsl:attribute name="eId">
				<xsl:value-of select="@id" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</term>
</xsl:template>

<xsl:template match="Abbreviation">
	<abbr>
		<xsl:if test="exists(@Expansion)">
			<xsl:attribute name="title">
				<xsl:value-of select="@Expansion" />
			</xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</abbr>
</xsl:template>

<xsl:template match="Acronym">
	<abbr class="acronym">
		<xsl:if test="exists(@Expansion)">
			<xsl:attribute name="title">
				<xsl:value-of select="@Expansion" />
			</xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</abbr>
</xsl:template>

<xsl:template match="Definition">
	<def ukl:Name="Definition">
		<xsl:if test="exists(@TermRef)">
			<xsl:attribute name="ukl:TermRef">
				<xsl:value-of select="@TermRef" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</def>
</xsl:template>

<xsl:template match="Proviso">
	<inline name="proviso">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Span">
	<span>
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="Character">
	<span ukl:Name = "{ @Name }">
		<xsl:choose>
			<xsl:when test="@Name = 'DotPadding'">
				<marker name="dotPadding" />
			</xsl:when>
			<xsl:when test="@Name = 'EmSpace'">
				<xsl:text>&#x2003;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'EnSpace'">
				<xsl:text>&#x2002;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'LinePadding'">
				<xsl:text>&#x0009;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'NonBreakingSpace'">
				<xsl:text>&#x00a0;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'Minus'">
				<xsl:text>&#x2212;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'ThinSpace'">
				<xsl:text>&#x2009;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</span>
</xsl:template>

<xsl:function name="local:is-inline" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::Emphasis">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strong">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Underline">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::SmallCaps">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Uppercase">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Strike">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Expanded">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Superior">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Inferior">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Term">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Abbreviation">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Acronym">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Definition">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Proviso">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Span">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Character">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Addition">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Repeal">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Substitution">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Citation">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::CitationSubRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::InternalLink">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::ExternalLink">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::CommentaryRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::FootnoteRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::MarginNoteRef">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::Image">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

</xsl:transform>
