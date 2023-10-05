<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk local">


<xsl:template match="SignedSection">
	<hcontainer name="signatures">
		<xsl:choose>
			<xsl:when test="empty(Signatory)"> <!-- P is invalid but exists in uksi/2018/15/2018-04-06 -->
				<content>
					<xsl:apply-templates />
				</content>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="exists(Signatory[1]/preceding-sibling::*)">
					<intro>
						<xsl:apply-templates select="Signatory[1]/preceding-sibling::*" />
					</intro>
				</xsl:if>
				<xsl:apply-templates select="Signatory" />
			</xsl:otherwise>
		</xsl:choose>
	</hcontainer>
</xsl:template>

<xsl:template match="Signatory">
	<hcontainer name="signatureBlock">
		<content>
			<xsl:apply-templates />
		</content>
	</hcontainer>
</xsl:template>

<xsl:template match="Signee">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="PersonName">
	<block name="signature">
		<signature refersTo="#">
			<xsl:apply-templates />
		</signature>
	</block>
</xsl:template>

<xsl:template match="JobTitle">
	<block name="role">
		<role refersTo="#">
			<xsl:apply-templates />
		</role>
	</block>
</xsl:template>

<xsl:template match="Department">
	<block name="organization">
		<organization refersTo="#">
			<xsl:apply-templates />
		</organization>
	</block>
</xsl:template>

<xsl:template match="Address">
	<blockContainer class="address">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="AddressLine">
	<p>
		<location refersTo="#">
			<xsl:apply-templates />
		</location>
	</p>
</xsl:template>

<xsl:template match="DateSigned">
	<block name="date">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="DateSigned/DateText">
	<date>
		<xsl:attribute name="date">
			<xsl:choose>
				<xsl:when test="../@Date castable as xs:date">
					<xsl:value-of select="../@Date" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:parse-date(.)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates />
	</date>
</xsl:template>

<xsl:template match="LSseal">
	<block name="seal">
		<xsl:choose>
			<xsl:when test="@ResourceRef">
				<img src="{ key('id', @ResourceRef)/ExternalVersion/@URI }" />
			</xsl:when>
			<xsl:when test="@Date">
				<date date="{ @Date }">
					<xsl:apply-templates />
				</date>
			</xsl:when>
			<xsl:when test="exists(child::node())">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<marker name="seal" />
			</xsl:otherwise>
		</xsl:choose>
	</block>
</xsl:template>

</xsl:transform>
