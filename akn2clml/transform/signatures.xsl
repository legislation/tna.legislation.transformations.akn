<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:template match="hcontainer[@name='signatures']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<SignedSection>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('SignedSection', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</SignedSection>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureGroup']" name="signatory">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Signatory>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Signatory', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Signatory>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureBlock'][not(parent::hcontainer[@name='signatureGroup'])]" priority="1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Signatory>
		<xsl:next-match>
			<xsl:with-param name="context" select="('Signatory', $context)" tunnel="yes" />
		</xsl:next-match>
	</Signatory>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureBlock']">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="hcontainer[@name='signatureBlock']/content">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="seal" as="element(block)?" select="block[@name='seal']" />
	<xsl:variable name="intro" as="element()*">
		<xsl:choose>
			<xsl:when test="exists($seal)">
				<xsl:sequence select="$seal/preceding-sibling::*" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="p[every $sib in preceding-sibling::* satisfies $sib/self::p]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:apply-templates select="$intro" />
	<Signee>
		<xsl:apply-templates select="* except $intro">
			<xsl:with-param name="context" select="('Signee', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Signee>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureBlock']/content/p">
	<Para>
		<Text>
			<xsl:apply-templates />
		</Text>
	</Para>
</xsl:template>

<xsl:template match="block[@name=('signature','signee')]">
	<PersonName>
		<xsl:apply-templates />
	</PersonName>
</xsl:template>

<xsl:template match="block[@name=('role','jobTitle')]">
	<JobTitle>
		<xsl:apply-templates />
	</JobTitle>
</xsl:template>

<xsl:template match="block[@name=('organization','department')]">
	<Department>
		<xsl:apply-templates />
	</Department>
</xsl:template>

<xsl:template match="blockContainer[@class='address'] | tblock[@class='address']">
	<Address>
		<xsl:apply-templates />
	</Address>
</xsl:template>

<xsl:template match="blockContainer[@class='address']/p | tblock[@class='address']/block">
	<AddressLine>
		<xsl:apply-templates />
	</AddressLine>
</xsl:template>

<xsl:template match="block[@name='location'][not(parent::tblock[@class='address'])]"><!-- for old LDAPP documents -->
	<Address>
		<AddressLine>
			<xsl:apply-templates />
		</AddressLine>
	</Address>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureBlock']/content/block[@name='date'] | hcontainer[@name='signatureBlock']/content/p[date]">
	<DateSigned>
		<xsl:if test="*[1]/@date castable as xs:date">
			<xsl:attribute name="Date">
				<xsl:value-of select="*[1]/@date" />
			</xsl:attribute>
		</xsl:if>
		<DateText>
			<xsl:apply-templates />
		</DateText>
	</DateSigned>
</xsl:template>

<xsl:template match="hcontainer[@name='signatureBlock']/content/block[@name='date']/date | hcontainer[@name='signatureBlock']/content/p/date">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="date" priority="-1">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="signature | person | role | organization | location">
	<xsl:apply-templates />
</xsl:template>


<!-- seal -->

<xsl:template match="block[@name='seal'] | p[img[@class='seal']] | p[date[@class='seal']] | p[inline[@name='seal']] | p[marker[@name='seal']]" priority="1">
	<LSseal>
		<xsl:apply-templates />
	</LSseal>
</xsl:template>

<xsl:template match="img[@class='seal']">
	<xsl:attribute name="ResourceRef">
		<xsl:value-of select="local:make-resource-id(.)" />
	</xsl:attribute>
</xsl:template>

<xsl:template match="date[@class='seal']">
	<xsl:attribute name="Date">
		<xsl:value-of select="@Date" />
	</xsl:attribute>
</xsl:template>

<xsl:template match="inline[@name='seal']">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="marker[@name='seal']">
</xsl:template>

</xsl:transform>
