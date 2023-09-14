<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk html local">

<xsl:variable name="all-footnotes" as="element()*">
	<xsl:sequence select="//authorialNote[tokenize(@class,' ')=('footnote','tablenote')]" />
</xsl:variable>

<xsl:function name="local:make-footnote-id" as="xs:string">
	<xsl:param name="e" as="element(authorialNote)" />
	<xsl:variable name="index" as="xs:integer?" select="local:get-first-index-of-node($e, $all-footnotes)" />
	<xsl:variable name="num" as="xs:integer" select="if (exists($index)) then $index else 0" />
	<xsl:sequence select="concat('f', format-number($num,'00000'))" />
</xsl:function>

<xsl:function name="local:make-footnote-id-2" as="xs:string?">
	<xsl:param name="ref" as="element(noteRef)" />
	<xsl:variable name="note" as="element(authorialNote)?" select="key('id', substring($ref/@href, 2), root($ref))" />
	<xsl:if test="exists($note)">
		<xsl:sequence select="local:make-footnote-id($note)" />
	</xsl:if>
</xsl:function>

<xsl:template match="authorialNote[tokenize(@class,' ')=('footnote','tablenote')]">
	<FootnoteRef Ref="{ local:make-footnote-id(.) }" />
</xsl:template>

<xsl:template match="noteRef[tokenize(@class,' ')=('footnote','tablenote')]">
	<FootnoteRef Ref="{ local:make-footnote-id-2(.) }" />
</xsl:template>

<xsl:template name="footnotes">
	<xsl:variable name="bottom-footnotes" as="element(authorialNote)*" select="$all-footnotes[tokenize(@class,' ')='footnote']" />
	<xsl:if test="exists($bottom-footnotes)">
		<Footnotes>
			<xsl:apply-templates select="$bottom-footnotes" mode="footnote" />
		</Footnotes>
	</xsl:if>
</xsl:template>

<xsl:template match="authorialNote" mode="footnote">
	<Footnote id="{ local:make-footnote-id(.) }">
		<xsl:apply-templates select="num">
			<xsl:with-param name="context" select="('Footnote')" tunnel="yes" />
		</xsl:apply-templates>
		<FootnoteText>
			<xsl:apply-templates select="* except num">
				<xsl:with-param name="context" select="('FootnoteText', 'Footnote')" tunnel="yes" />
			</xsl:apply-templates>
		</FootnoteText>
	</Footnote>
</xsl:template>

</xsl:transform>
