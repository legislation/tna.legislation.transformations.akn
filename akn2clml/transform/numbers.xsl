<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:function name="local:should-strip-punctuation-from-number" as="xs:boolean">
	<xsl:param name="text" as="text()" />
	<xsl:param name="context" as="xs:string+" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="not($head = 'Pnumber')">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="not($text/ancestor::num/descendant::text()[normalize-space()][last()] is $text)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="true()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:should-add-punc-before-and-punc-after-attributes" as="xs:boolean">
	<xsl:param name="num" as="element(num)" />
	<xsl:param name="context" as="xs:string+" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:choose>
				<xsl:when test="$head = 'P1'">
					<xsl:sequence select="not(matches(normalize-space($num), '^\d+[A-Z]*$'))" />
				</xsl:when>
				<xsl:when test="$head = ('P2', 'P3' ,'P4', 'P5', 'P6', 'P7')">
					<xsl:sequence select="not(matches(normalize-space($num), '^\([a-zA-Z\d]+\)$'))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="false()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:choose>
				<xsl:when test="$head = 'P1'">
					<xsl:sequence select="not(matches(normalize-space($num), '^\d+[A-Z]*\.$'))" />
				</xsl:when>
				<xsl:when test="$head = ('P2', 'P3' ,'P4', 'P5', 'P6', 'P7')">
					<xsl:sequence select="not(matches(normalize-space($num), '^\([a-zA-Z\d]+\)$'))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="false()" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="add-punc-before-and-punc-after-attributes">
	<xsl:param name="num" as="element(num)" select="." />
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<xsl:variable name="num" as="xs:string" select="normalize-space($num)" />
	<xsl:if test="($context[1] = 'P1') and $num and (not(matches($num, '^[a-zA-Z\d]')) or not(matches($num, '[a-zA-Z\d]$')))">
		<xsl:attribute name="PuncBefore">
			<xsl:analyze-string select="$num" regex="^([^a-zA-Z\d]+)">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:attribute>
		<xsl:attribute name="PuncAfter">
			<xsl:analyze-string select="$num" regex="[a-zA-Z\d]([^a-zA-Z\d]+)$">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:attribute>
	</xsl:if>
	<xsl:if test="not($context[1] = 'P1') and $num and (not(matches($num, '^\([a-zA-Z\d]')) or not(matches($num, '[a-zA-Z\d]$')))">
		<xsl:attribute name="PuncBefore">
			<xsl:analyze-string select="$num" regex="^([^a-zA-Z\d]*)[a-zA-Z\d]">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:attribute>
		<xsl:attribute name="PuncAfter">
			<xsl:analyze-string select="$num" regex="[a-zA-Z\d]([^a-zA-Z\d]+)$">
				<xsl:matching-substring>
					<xsl:value-of select="regex-group(1)" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:function name="local:strip-punctuation-from-number" as="xs:string">
	<xsl:param name="num" as="xs:string" />
	<xsl:variable name="pattern" as="xs:string">
		<xsl:text>()[].“”‘’"'</xsl:text>
	</xsl:variable>
	<xsl:sequence select="translate(normalize-space($num), $pattern, '')" />
</xsl:function>

<xsl:template name="strip-punctuation-from-number">
	<xsl:if test="starts-with(., ' ')">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:variable name="pattern" as="xs:string">
		<xsl:text>()[].“”‘’"'</xsl:text>
	</xsl:variable>
	<xsl:value-of select="translate(normalize-space(.), $pattern, '')" />
	<xsl:if test="ends-with(., ' ')">
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>

<xsl:function name="local:strip-punctuation-for-number-override" as="xs:string">
	<xsl:param name="num" as="element(num)" />
	<xsl:param name="decor" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$decor = ('parens', 'brackets')">
			<xsl:value-of select="substring($num, 2, string-length($num) - 2)" />
		</xsl:when>
		<xsl:when test="$decor = ('parenRight', 'bracketRight', 'period', 'colon')">
			<xsl:value-of select="substring($num, 1, string-length($num) - 1)" />
		</xsl:when>
		<xsl:when test="$decor = 'none'">
			<xsl:value-of select="$num" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$num" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

</xsl:transform>
