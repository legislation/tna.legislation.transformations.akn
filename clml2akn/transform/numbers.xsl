<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">

<xsl:function name="local:should-add-punctuation-to-number" as="xs:boolean">
	<xsl:param name="text" as="text()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:choose>
		<xsl:when test="empty($text/ancestor::Pnumber)">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="not($text/ancestor::Pnumber/descendant::text()[normalize-space()][last()] is $text)">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="exists($text/ancestor::Pnumber/@PuncBefore) or exists($text/ancestor::Pnumber/@PuncAfter)">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="exists($text/ancestor::Pnumber/parent::P1) and $doc-category = 'secondary'">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="exists($text/ancestor::Pnumber/parent::P1)">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^\d+[A-Z]*$')">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^[a-z]+$')">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^[A-Z]+$')">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="add-punctuation-to-number">
	<xsl:if test="matches(., '^\s')">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="exists(ancestor::Pnumber/@PuncBefore)">
			<xsl:value-of select="ancestor::Pnumber/@PuncBefore" />
		</xsl:when>
		<xsl:when test="exists(ancestor::Pnumber/parent::P1)" />
		<xsl:otherwise>
			<xsl:text>(</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:value-of select="normalize-space(.)" />
	<xsl:choose>
		<xsl:when test="exists(ancestor::Pnumber/@PuncAfter)">
			<xsl:value-of select="ancestor::Pnumber/@PuncAfter" />
		</xsl:when>
		<xsl:when test="exists(ancestor::Pnumber/parent::P1) and $doc-category = 'secondary'">
			<xsl:text>.</xsl:text>
		</xsl:when>
		<xsl:when test="exists(ancestor::Pnumber/parent::P1)" />
		<xsl:otherwise>
			<xsl:text>)</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="matches(., '\s$')">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>

<xsl:function name="local:format-list-number" as="xs:string?">
	<xsl:param name="number" as="xs:string" />
	<xsl:param name="list-decor" as="attribute(Decoration)?" />
	<xsl:choose>
		<xsl:when test="empty($list-decor)">
			<xsl:value-of select="$number" />
		</xsl:when>
		<xsl:when test="$list-decor = 'none'">
			<xsl:value-of select="$number" />
		</xsl:when>
		<xsl:when test="$list-decor = 'parens'">
			<xsl:value-of select="concat('(', $number, ')')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'parenRight'">
			<xsl:value-of select="concat($number, ')')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'brackets'">
			<xsl:value-of select="concat('[', $number, ']')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'bracketRight'">
			<xsl:value-of select="concat($number, ']')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'period'">
			<xsl:value-of select="concat($number, '.')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'colon'">
			<xsl:value-of select="concat($number, ':')" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:format-number-override" as="xs:string?">
	<xsl:param name="number-override" as="attribute(NumberOverride)" />
	<xsl:param name="list-decor" as="attribute(Decoration)?" />
	<xsl:variable name="number" as="xs:string" select="string($number-override)" />
	<xsl:choose>
		<xsl:when test="empty($list-decor)">
			<xsl:sequence select="$number" />
		</xsl:when>
		<xsl:when test="$list-decor = 'none'">
			<xsl:sequence select="$number" />
		</xsl:when>
		<xsl:when test="$list-decor = 'parens' and not(starts-with($number, '(')) and not(ends-with($number, ')'))">
			<xsl:sequence select="concat('(', $number, ')')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'parenRight' and not(ends-with($number, ')'))">
			<xsl:sequence select="concat($number, ')')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'brackets' and not(starts-with($number, '[')) and not(ends-with($number, ']'))">
			<xsl:sequence select="concat('[', $number, ']')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'bracketRight' and not(ends-with($number, ']'))">
			<xsl:sequence select="concat($number, ']')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'period' and not(ends-with($number, '.'))">
			<xsl:sequence select="concat($number, '.')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'colon' and not(ends-with($number, ':'))">
			<xsl:sequence select="concat($number, ':')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$number" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

</xsl:transform>
