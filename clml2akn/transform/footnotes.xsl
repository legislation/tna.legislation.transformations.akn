<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk html local">

<xsl:key name="footnote-ref" match="FootnoteRef" use="@Ref" />

<xsl:function name="local:footnote-has-ref" as="xs:boolean">
	<xsl:param name="footnote" as="element(Footnote)" />
	<xsl:sequence select="exists($footnote/@id) and exists(key('footnote-ref', $footnote/@id, root($footnote)))" />
</xsl:function>

<xsl:template match="FootnoteRef">
	<xsl:variable name="footnote" as="element()*" select="key('id', @Ref)" />
	<xsl:variable name="class" as="xs:string">
		<xsl:choose>
			<xsl:when test="exists($footnote[1]/ancestor::html:tfoot)">
				<xsl:sequence select="'tablenote'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="'footnote'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="marker" as="xs:string">
		<xsl:choose>
			<xsl:when test="exists($footnote[1]/Number)">
				<xsl:value-of select="normalize-space($footnote[1]/Number)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number(substring(@Ref , 2))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test=". is key('footnote-ref', @Ref)[1]">	<!-- empty(preceding::FootnoteRef[@Ref=current()/@Ref]) -->
			<authorialNote class="{ $class }" eId="{ $footnote[1]/@id }" marker="{ $marker }">
				<xsl:apply-templates select="$footnote[1]/node() except $footnote[1]/Number">
					<xsl:with-param name="context" select="'authorialNote'" tunnel="yes" />
				</xsl:apply-templates>
			</authorialNote>
		</xsl:when>
		<xsl:otherwise>
			<noteRef class="{ $class }" href="#{ @Ref }" marker="{ $marker }" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="FootnoteText">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
