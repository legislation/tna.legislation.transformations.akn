<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">


<!-- <xsl:function name="local:get-image-uri" as="xs:string">
	<xsl:param name="res-id" as="xs:string" />
	<xsl:value-of select="key('id', $res-id)/ExternalVersion/@URI" />
</xsl:function> -->



<!-- adds alternative versions of a provision -->

<xsl:template name="insert-alt-versions">
	<xsl:param name="alt-version-refs" as="attribute()?" select="./@AltVersionRefs" />
	<xsl:param name="alternative-to" as="xs:string" select="local:get-internal-id(.)" />
	<xsl:if test="exists($alt-version-refs) and empty(ancestor::Version)">
		<xsl:variable name="alt-ids" as="xs:string*" select="tokenize($alt-version-refs, ' ')" />
		<xsl:for-each select="$alt-ids">
			<xsl:variable name="alt-version" select="key('id', ., root($alt-version-refs))" />
			<xsl:apply-templates select="$alt-version">
				<xsl:with-param name="alternative-to" select="$alternative-to" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template match="Version">
	<xsl:apply-templates />
</xsl:template>


<!-- add alternativeTo attribute -->

<xsl:template name="add-alt-attr">
	<xsl:param name="e" as="element()" select="." />
	<xsl:param name="alternative-to" as="xs:string?" select="()" tunnel="yes" />
	<xsl:if test="exists($e/parent::Version)">
		<xsl:attribute name="alternativeTo">
			<xsl:value-of select="$alternative-to" />
		</xsl:attribute>
		<xsl:if test="exists($e/parent::Version/@Description)">
			<xsl:attribute name="ukl:Description">
				<xsl:value-of select="$e/parent::Version/@Description" />
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>


<!-- included documents -->

<xsl:template match="IncludedDocument">
	<componentRef src="#{ @ResourceRef }" showAs="" />
</xsl:template>

<xsl:template name="components">
	<xsl:variable name="components" as="element(IncludedDocument)*" select="//IncludedDocument[not(parent::Form)]" />
	<xsl:if test="exists($components)">
		<components>
			<xsl:apply-templates select="$components" mode="component" />
		</components>
	</xsl:if>
</xsl:template>

<xsl:template match="IncludedDocument" mode="component">
	<xsl:variable name="reference" select="key('id', @ResourceRef)" />
	<component eId="{ @ResourceRef }">
		<xsl:apply-templates select="$reference/node()" />
	</component>
</xsl:template>

<xsl:template match="InternalVersion">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="XMLcontent">
	<xsl:choose>
		<xsl:when test="exists(Contents)">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<interstitial>
				<p>
					<subFlow name="InternalVersion">
						<xsl:apply-templates />
					</subFlow>
				</p>
			</interstitial>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:transform>
