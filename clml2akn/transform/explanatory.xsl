<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	exclude-result-prefixes="xs ukl">


<xsl:template match="ExplanatoryNotes">
	<blockContainer class="explanatoryNote">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="Comment">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Comment/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Comment/Para/Text">
	<subheading>
		<xsl:apply-templates />
	</subheading>
</xsl:template>

<xsl:template match="ExplanatoryNotes//UnorderedList[@Class='Definition']" priority="1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<blockList class="definition">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('blockList', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</blockList>
</xsl:template>


<!-- earlier orders -->

<xsl:template match="EarlierOrders">
	<blockContainer class="commencementHistory">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>


<!--  -->

<xsl:template match="ExplanatoryNotes//P1group | EarlierOrders//P1group">
	<blockContainer ukl:Name="{ local-name(.) }">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P1 | EarlierOrders//P1">
	<blockContainer ukl:Name="{ local-name(.) }" class="prov1">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P | EarlierOrders//P">
	<blockContainer ukl:Name="{ local-name(.) }" >
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P2 | EarlierOrders//P2">
	<blockContainer ukl:Name="P2" class="prov2">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P3 | EarlierOrders//P3">
	<blockContainer ukl:Name="P3" class="para1">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P4 | EarlierOrders//P4">
	<blockContainer ukl:Name="P4" class="para2">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P5 | EarlierOrders//P5">
	<blockContainer ukl:Name="P5" class="para3">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P6 | EarlierOrders//P6">
	<blockContainer ukl:Name="P6" class="para4">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

</xsl:transform>
