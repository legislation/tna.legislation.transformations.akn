<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ldapp="#ldapp"
	exclude-result-prefixes="xs uk ldapp">

<xsl:function name="ldapp:is-ldapp" as="xs:boolean">
	<xsl:param name="doc" as="document-node()" />
	<xsl:variable name="identification-source" as="xs:boolean" select="$doc/akomaNtoso/*/meta/identification/@source = '#ldapp'" />
	<xsl:variable name="system-showas" as="xs:boolean" select="$doc/akomaNtoso/*/meta/references/TLCConcept[@eId='varSystem']/@showAs = 'LDAPP'" />
	<xsl:sequence select="$identification-source or $system-showas" />
</xsl:function>

<xsl:key name="ldapp:tlc" match="TLCConcept | TLCProcess | TLCPerson | TLCOrganization | TLCLocation" use="@eId" />

<xsl:function name="ldapp:resolve-tlc-show-as" as="xs:string">
	<xsl:param name="showAs" as="attribute()" />
	<xsl:variable name="components" as="xs:string*">
		<xsl:for-each select="tokenize(normalize-space($showAs), ' ')">
			<xsl:choose>
				<xsl:when test="starts-with(., '#')">
					<xsl:variable name="tlc" as="element()" select="key('ldapp:tlc', substring(., 2), root($showAs))" />
					<xsl:sequence select="ldapp:resolve-tlc-show-as($tlc/@showAs)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="string-join($components, ' ')" />
</xsl:function>


<!-- placeholders -->

<xsl:template match="@value[starts-with(., '#var')]" mode="ldapp" priority="1">
	<xsl:attribute name="value">
		<xsl:variable name="tlc" as="element()?" select="key('ldapp:tlc', substring(., 2))" />
		<xsl:choose>
			<xsl:when test="exists($tlc)">
				<xsl:value-of select="ldapp:resolve-tlc-show-as($tlc/@showAs)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="ref[@class='placeholder']" mode="ldapp">
	<xsl:variable name="tlc" as="element()" select="key('ldapp:tlc', substring(@href, 2))" />
	<xsl:variable name="resolved" as="xs:string" select="ldapp:resolve-tlc-show-as($tlc/@showAs)" />
	<xsl:choose>
		<xsl:when test="exists(node())">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:when test="exists(@uk:dateFormat) and $resolved castable as xs:date">
			<xsl:variable name="date" as="xs:date" select="xs:date($resolved)" />
			<xsl:choose>
				<xsl:when test="@uk:dateFormat = 'd''th'' MMMM yyyy'">
					<xsl:value-of select="format-date($date, '[D1o] [MNn] [Y0001]')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$resolved" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$resolved" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="def" mode="ldapp">	<!-- custom startQuote and endQuote attributes -->
	<xsl:copy>
		<xsl:apply-templates select="@* except (@uk:startQuote, @uk:endQuote)"  mode="ldapp" />
		<xsl:value-of select="@uk:startQuote" />
		<xsl:apply-templates mode="ldapp" />
		<xsl:value-of select="@uk:endQuote" />
	</xsl:copy>
</xsl:template>


<!-- images -->

<xsl:template match="img" mode="ldapp">
	<xsl:copy>
		<xsl:apply-templates select="@*" mode="ldapp" />
		<xsl:if test="exists(@width) and exists(@height)">
			<xsl:variable name="font-size-points" as="xs:decimal" select="10.5" />
			<xsl:variable name="width-mm" as="xs:integer" select="xs:integer(@width)" />
			<xsl:variable name="height-mm" as="xs:integer" select="xs:integer(@height)" />
			<xsl:attribute name="style">
				<xsl:text>width:</xsl:text>
				<xsl:value-of select="$width-mm * 2.83465 div $font-size-points" />
				<xsl:text>em;height:</xsl:text>
				<xsl:value-of select="$height-mm * 2.83465 div $font-size-points" />
				<xsl:text>em</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="node()" mode="ldapp" />
	</xsl:copy>
</xsl:template>

<xsl:template match="img/@width | img/@height" mode="ldapp">
	<xsl:attribute name="{ name() }">
		<xsl:value-of select="round(number(.) * 3.78)" />	<!-- millimeters to pixes -->
	</xsl:attribute>
</xsl:template>


<!-- identity transform -->

<xsl:template match="@*|node()" mode="ldapp">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="ldapp" />
	</xsl:copy>
</xsl:template>

</xsl:transform>
