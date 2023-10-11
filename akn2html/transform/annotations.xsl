<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://jurisdatum.com/tna/akn2html"
	exclude-result-prefixes="xs math ukl ukm uk local">

<xsl:key name="commentaries" match="otherAnalysis/uk:commentary" use="substring(@href, 2)" />

<xsl:template name="annotations">
	<xsl:param name="within-quoted-structure" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:if test="not($within-quoted-structure)">
		<xsl:variable name="commentary-refs" as="element(uk:commentary)*" select="key('commentaries', @eId)" />
		<xsl:if test="exists($commentary-refs)">
			<xsl:variable name="notes" as="element(note)*">
				<xsl:for-each select="$commentary-refs">
					<xsl:sequence select="key('id', substring(@refersTo, 2))" />
				</xsl:for-each>
			</xsl:variable>
			<xsl:element name="{ 'footer' }">
				<xsl:attribute name="class">annotations</xsl:attribute>
				<div>Annotations:</div>
				<xsl:call-template name="display-f-notes">
					<xsl:with-param name="f-notes" select="$notes[@ukl:Type='F']" />
				</xsl:call-template>
				<xsl:call-template name="display-c-notes">
					<xsl:with-param name="c-notes" select="$notes[@ukl:Type='C']" />
				</xsl:call-template>
				<xsl:call-template name="display-e-notes">
					<xsl:with-param name="e-notes" select="$notes[@ukl:Type='E']" />
				</xsl:call-template>
				<xsl:call-template name="display-i-notes">
					<xsl:with-param name="i-notes" select="$notes[@ukl:Type='I']" />
				</xsl:call-template>
				<xsl:call-template name="display-p-notes">
					<xsl:with-param name="p-notes" select="$notes[@ukl:Type='P']" />
				</xsl:call-template>
				<xsl:call-template name="display-m-notes">
					<xsl:with-param name="m-notes" select="$notes[@ukl:Type='M']" />
				</xsl:call-template>
				<xsl:call-template name="display-x-notes">
					<xsl:with-param name="x-notes" select="$notes[@ukl:Type='X']" />
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="display-f-notes">
	<xsl:param name="f-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$f-notes" />
		<xsl:with-param name="type" select="'F'" />
		<xsl:with-param name="heading" select="'Amendments (Textual)'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-c-notes">
	<xsl:param name="c-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$c-notes" />
		<xsl:with-param name="type" select="'C'" />
		<xsl:with-param name="heading" select="'Modifications etc. (not altering text)'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-e-notes">
	<xsl:param name="e-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$e-notes" />
		<xsl:with-param name="type" select="'E'" />
		<xsl:with-param name="heading" select="'Extent Information'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-i-notes">
	<xsl:param name="i-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$i-notes" />
		<xsl:with-param name="type" select="'I'" />
		<xsl:with-param name="heading" select="'Commencement Information'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-p-notes">
	<xsl:param name="p-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$p-notes" />
		<xsl:with-param name="type" select="'P'" />
		<xsl:with-param name="heading" select="'Subordinate Legislation Made'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-m-notes">
	<xsl:param name="m-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$m-notes" />
		<xsl:with-param name="type" select="'M'" />
		<xsl:with-param name="heading" select="'Marginal Citations'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-x-notes">
	<xsl:param name="x-notes" as="element(note)*" />
	<xsl:call-template name="display-notes">
		<xsl:with-param name="notes" select="$x-notes" />
		<xsl:with-param name="type" select="'X'" />
		<xsl:with-param name="heading" select="'Editorial Information'" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="display-notes">
	<xsl:param name="notes" as="element(note)*" />
	<xsl:param name="type" as="xs:string" />
	<xsl:param name="heading" as="xs:string" />
	<xsl:if test="exists($notes)">
		<div>
			<div>
				<xsl:value-of select="$heading" />
			</div>
			<xsl:for-each select="$notes">
				<div class="note commentary { $type }">
					<span class="marker">
						<xsl:value-of select="@marker" />
					</span>
					<xsl:apply-templates />
				</div>
			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
