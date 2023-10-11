<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	exclude-result-prefixes="xs local map">

<xsl:function name="local:clml-element-is-structural" as="xs:boolean">
	<xsl:param name="name" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$name = ('Group', 'Part', 'Chapter')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('Pblock', 'PsubBlock')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('EUPart', 'EUTitle', 'EUChapter', 'EUSection', 'EUSubsection', 'Division')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('P1group', 'P1', 'P2group', 'P2', 'P3group', 'P3', 'P4', 'P5', 'P6', 'P7', 'P')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:clml-element-is-block" as="xs:boolean">
	<xsl:param name="name" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$name = ('OrderedList', 'UnorderedList', 'KeyList', 'Tabular', 'Figure', 'Formula', 'BlockAmendment', 'BlockExtract', 'BlockText', 'Text')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-structure-wrapper" as="xs:string?">
	<xsl:param name="context" as="xs:string+" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="$head = ('P1')">
			<xsl:text>P1para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P2')">
			<xsl:text>P2para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P3')">
			<xsl:text>P3para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P4'">
			<xsl:text>P4para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P5'">
			<xsl:text>P5para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P6'">
			<xsl:text>P6para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P7'">
			<xsl:text>P7para</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-block-wrapper" as="xs:string?">
	<xsl:param name="context" as="xs:string+" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="$head = ('Body', 'EUBody')">
			<xsl:sequence select="'P'" />
		</xsl:when>
		<xsl:when test="$head = ('Group', 'Part', 'Chapter')">
			<xsl:text>P</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P1group'">
			<xsl:text>P</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P1', 'P1group')">
			<xsl:text>P1para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P2', 'P2group')">
			<xsl:text>P2para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('P3', 'P3group')">
			<xsl:text>P3para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P4'">
			<xsl:text>P4para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P5'">
			<xsl:text>P5para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P6'">
			<xsl:text>P6para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'P7'">
			<xsl:text>P7para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'IntroductoryText'">
			<xsl:text>P</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'EnactingText'">
			<xsl:text>Para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'EUPreamble'">
			<xsl:text>P</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('EUPart', 'EUTitle', 'EUChapter', 'EUSection', 'EUSubsection')">
			<xsl:sequence select="'P'" />
		</xsl:when>
		<xsl:when test="$head = 'Division'">
			<xsl:text>Para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('BlockText', 'ListItem', 'FootnoteText', 'MarginNote', 'Commentary', 'TableText', 'th', 'td')">
			<xsl:text>Para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'BlockExtract'">
			<xsl:text>P</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('SignedSection', 'Signatory')">
			<xsl:text>Para</xsl:text>
		</xsl:when>
		<xsl:when test="$head = 'ScheduleBody'">
			<xsl:text>P</xsl:text>
		</xsl:when>
		<xsl:when test="$head = ('ExplanatoryNotes', 'EarlierOrders')">
			<xsl:text>P</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-wrapper" as="xs:string?">
	<xsl:param name="clml" as="xs:string" />
	<xsl:param name="context" as="xs:string+" />
	<xsl:choose>
		<xsl:when test="local:clml-element-is-structural($clml)">
			<xsl:sequence select="local:get-structure-wrapper($context)" />
		</xsl:when>
		<xsl:when test="$clml = ('Tabular', 'Figure', 'Form') and $context[1] = 'ScheduleBody'">
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:when test="$clml = 'BlockText' and $context[1] = ('BlockAmendment', 'td')">
			<xsl:sequence select="'Para'" />
		</xsl:when>
		<xsl:when test="local:clml-element-is-block($clml)">
			<xsl:sequence select="local:get-block-wrapper($context)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">
				<xsl:text>local:get-wrapper: </xsl:text>
				<xsl:value-of select="$clml" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="$context" />
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="wrap-as-necessary">
	<xsl:param name="clml" as="node()+" />
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<xsl:variable name="wrapper" as="xs:string?" select="local:get-wrapper(local-name($clml[1]), $context)" />
	<xsl:choose>
		<xsl:when test="exists($wrapper)">
			<xsl:element name="{ $wrapper }">
				<xsl:copy-of select="$clml" />
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$clml" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="apply-templates-with-context">
	<xsl:param name="name" as="xs:string" />
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<xsl:variable name="wrapper" as="xs:string?" select="local:get-wrapper($name, $context)" />
	<xsl:apply-templates>
		<xsl:with-param name="context" select="($name, $wrapper, $context)" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="create-element-and-wrap-as-necessary">
	<xsl:param name="name" as="xs:string" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="wrapper" as="xs:string?" select="local:get-wrapper($name, $context)" />
	<xsl:variable name="clml" as="element()">
		<xsl:element name="{ $name }">
			<xsl:apply-templates>
				<xsl:with-param name="context" select="($name, $wrapper, $context)" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="exists($wrapper)">
			<xsl:element name="{ $wrapper }">
				<xsl:copy-of select="$clml" />
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$clml" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:transform>
