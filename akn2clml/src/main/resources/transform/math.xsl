<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs math local">


<xsl:template match="tblock[@class='formula']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Formula>
		<xsl:if test="*[1][self::foreign]/*[1][self::math:math/@altimg]">
			<xsl:attribute name="AltVersionRefs">
				<xsl:value-of select="local:make-version-id(*[1]/*[1])" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Formula', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Formula>
</xsl:template>

<xsl:template match="tblock[@class='formula']/num">
	<equationNumber>
		<xsl:apply-templates />
	</equationNumber>
</xsl:template>

<xsl:template match="subFlow[@name='formula']">
	<Span>
		<xsl:if test="*[1][self::foreign]/*[1][self::math:math/@altimg]">
			<xsl:attribute name="AltVersionRefs">
				<xsl:value-of select="local:make-version-id(*[1]/*[1])" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</Span>
</xsl:template>

<xsl:template match="math:*">
	<xsl:element name="{ local-name() }" namespace="http://www.w3.org/1998/Math/MathML">
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="blockContainer[@class='where']">
	<Where>
		<Para>
			<xsl:call-template name="group-definitions-for-block-amendment">
				<xsl:with-param name="elements" select="*" />
			</xsl:call-template>
		</Para>
	</Where>
</xsl:template>

</xsl:transform>
