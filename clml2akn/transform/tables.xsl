<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl html local">


<xsl:template match="Tabular">
	<tblock class="table" ukl:Orientation="{ @Orientation }">
		<xsl:apply-templates />
	</tblock>
</xsl:template>

<xsl:template match="TableText">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:table">
	<foreign>
		<xsl:copy>
			<xsl:copy-of select="@* except @cols" />
			<xsl:apply-templates select="*[not(self::html:tfoot)]" />
			<xsl:apply-templates select="html:tfoot" />
		</xsl:copy>
	</foreign>
</xsl:template>

<xsl:template match="html:col">
	<xsl:copy>
		<xsl:copy-of select="@* except @width" />
		<xsl:if test="exists(@width)">
			<xsl:attribute name="style" select="concat('width:', @width)" />
		</xsl:if>
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>

<xsl:template match="html:tfoot[every $n in html:tr/html:*/node() satisfies $n/self::Footnote[local:footnote-has-ref(.)]]" />

<xsl:template match="html:tfoot/html:tr[every $n in html:*/node() satisfies $n/self::Footnote[local:footnote-has-ref(.)]]" />

<!-- orphan table footnotes -->
<xsl:template match="html:tfoot//Footnote[not(local:footnote-has-ref(.))]">
	<authorialNote placement="inline">
		<xsl:attribute name="eId">
			<xsl:value-of select="@id" />
		</xsl:attribute>
		<xsl:attribute name="marker">
			<xsl:choose>
				<xsl:when test="exists(Number)">
					<xsl:value-of select="normalize-space(Number)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="number(substring(@id , 2))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'authorialNote'" tunnel="yes" />
		</xsl:apply-templates>
	</authorialNote>
</xsl:template>

<xsl:template match="html:th | html:td">
	<xsl:copy>
		<xsl:copy-of select="@* except (@valign, @align, @char)" />
		<xsl:variable name="styles" as="xs:string*">
			<xsl:if test="exists(@valign)">
				<xsl:sequence select="concat('vertical-align:', @valign)" />
			</xsl:if>
			<xsl:if test="exists(@align) and not(@align = 'char')">
				<xsl:sequence select="concat('text-align:', @align)" />
			</xsl:if>
		</xsl:variable>
		<xsl:if test="exists($styles)">
			<xsl:attribute name="style">
				<xsl:sequence select="string-join($styles, ';')" />
			</xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="exists(*[local:is-inline(.)]) or exists(text()[normalize-space(.)])">
				<p>
					<xsl:apply-templates />
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<xsl:template match="html:*">
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>

</xsl:transform>
