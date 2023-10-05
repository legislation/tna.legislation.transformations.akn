<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk ukl local">


<xsl:template match="Addition | Substitution">
	<ins>
		<xsl:call-template name="change" />
	</ins>
</xsl:template>

<xsl:template match="Repeal">
	<del>
		<xsl:call-template name="change" />
	</del>
</xsl:template>

<xsl:template name="change">
	<xsl:variable name="is-first" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="exists(ancestor::Title/parent::P1group/child::P1[1][not(local:heading-before-number(.))])">
				<xsl:variable name="changes-in-number" as="element()*" select="ancestor::Title/following-sibling::P1[1]/child::Pnumber/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(preceding::*[@ChangeId=current()/@ChangeId]) and empty(ancestor::*[@ChangeId=current()/@ChangeId]) and empty($changes-in-number)" />
			</xsl:when>
			<xsl:when test="exists(ancestor::Pnumber/parent::P1[empty(preceding-sibling::*[not(self::Title)])][not(local:heading-before-number(.))])">
				<xsl:variable name="changes-in-title" as="element()*" select="ancestor::Pnumber/parent::P1/parent::P1group/child::Title/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(preceding::*[@ChangeId=current()/@ChangeId] except $changes-in-title) and empty(ancestor::*[@ChangeId=current()/@ChangeId] except $changes-in-title)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="empty(preceding::*[@ChangeId=current()/@ChangeId]) and empty(ancestor::*[@ChangeId=current()/@ChangeId])" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="is-last" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="exists(ancestor::Title/parent::P1group/child::P1[1][not(local:heading-before-number(.))])">
				<xsl:variable name="changes-in-number" as="element()*" select="ancestor::Title/following-sibling::P1[1]/child::Pnumber/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(following::*[@ChangeId=current()/@ChangeId] except $changes-in-number) and empty(descendant::*[@ChangeId=current()/@ChangeId] except $changes-in-number)" />
			</xsl:when>
			<xsl:when test="exists(ancestor::Pnumber/parent::P1[empty(preceding-sibling::*[not(self::Title)])][not(local:heading-before-number(.))])">
				<xsl:variable name="changes-in-title" as="element()*" select="ancestor::Pnumber/parent::P1/parent::P1group/child::Title/descendant::*[@ChangeId=current()/@ChangeId]" />
				<xsl:sequence select="empty(following::*[@ChangeId=current()/@ChangeId]) and empty(descendant::*[@ChangeId=current()/@ChangeId]) and empty($changes-in-title)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="empty(following::*[@ChangeId=current()/@ChangeId]) and empty(descendant::*[@ChangeId=current()/@ChangeId])" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="classes" as="xs:string*">
		<xsl:if test="self::Substitution">
			<xsl:sequence select="lower-case(local-name())" />
		</xsl:if>
		<xsl:if test="$is-first">
			<xsl:sequence select="'first'" />
		</xsl:if>
		<xsl:if test="$is-last">
			<xsl:sequence select="'last'" />
		</xsl:if>
	</xsl:variable>
	<xsl:if test="exists($classes)">
		<xsl:attribute name="class">
			<xsl:value-of select="string-join($classes, ' ')" />
		</xsl:attribute>
	</xsl:if>
	<xsl:apply-templates select="@ChangeId" />
	<xsl:apply-templates select="@CommentaryRef" />
	<xsl:if test="$is-first and exists(@CommentaryRef)">	<!-- exists(@CommentaryRef) for ukpga/1980/9 -->
		<noteRef uk:name="commentary" href="#{ @CommentaryRef }" class="commentary" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="@ChangeId">
	<xsl:attribute name="ukl:ChangeId">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@CommentaryRef">
	<xsl:attribute name="ukl:CommentaryRef">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

</xsl:transform>
