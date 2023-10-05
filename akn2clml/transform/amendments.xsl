<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl2="http://legislation.gov.uk/namespaces/legis"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk ukl ukl2 local">


<xsl:function name="local:get-target-class" as="xs:string?">
	<xsl:param name="qs" as="element(quotedStructure)" />
	<xsl:choose>
		<xsl:when test="exists($qs/@ukl:TargetClass)">
			<xsl:sequence select="$qs/@ukl:TargetClass" />
		</xsl:when>
		<xsl:when test="exists($qs/@uk:docName)">
			<xsl:sequence select="local:category-from-short-type($qs/@uk:docName)" />
		</xsl:when>
		<xsl:when test="exists($qs/@ukl2:docName)">	<!-- legacy for LDAPP error -->
			<xsl:sequence select="local:category-from-short-type($qs/@ukl2:docName)" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-source-class" as="xs:string?">
	<xsl:param name="es" as="element(embeddedStructure)" />
	<xsl:choose>
		<xsl:when test="exists($es/@ukl:SourceClass)">
			<xsl:sequence select="$es/@ukl:SourceClass" />
		</xsl:when>
		<xsl:when test="exists($es/@uk:docName)">
			<xsl:sequence select="local:category-from-short-type($es/@uk:docName)" />
		</xsl:when>
		<xsl:when test="exists($es/@ukl2:docName)">	<!-- legacy for LDAPP error -->
			<xsl:sequence select="local:category-from-short-type($es/@ukl2:docName)" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-target-subclass" as="xs:string">
	<xsl:param name="qs" as="element(quotedStructure)" />
	<xsl:choose>
		<xsl:when test="exists($qs/@ukl:TargetSubClass)">
			<xsl:value-of select="$qs/@ukl:TargetSubClass" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>unknown</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:target-is-schedule" as="xs:boolean?">
	<xsl:param name="qs" as="element()" />
	<xsl:choose>
		<xsl:when test="exists($qs/@ukl:Context)">
			<xsl:value-of select="$qs/@ukl:Context = 'schedule'" />
		</xsl:when>
		<xsl:when test="exists($qs/descendant::*[@class = ('schProv1', 'schProv2')])">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-structure-format" as="xs:string">
	<xsl:param name="lead-in" as="element()" />
	<xsl:param name="source" as="element()" /> <!-- quotedStructure or embeddedStructure -->
	<xsl:choose>
		<xsl:when test="$lead-in/@startQuote='“' and $source/@endQuote='”'">
			<xsl:text>double</xsl:text>
		</xsl:when>
		<xsl:when test="$lead-in/@startQuote='‘' and $source/@endQuote='’'">
			<xsl:text>single</xsl:text>
		</xsl:when>
		<xsl:when test="empty($lead-in/@startQuote) and empty($source/@endQuote)">
			<xsl:text>none</xsl:text>
		</xsl:when>
		<xsl:when test="$lead-in/@startQuote='' and $source/@endQuote=''">
			<xsl:text>none</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>default</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-structure-format" as="xs:string">
	<xsl:param name="source" as="element()" /> <!-- quotedStructure or embeddedStructure -->
	<xsl:sequence select="local:get-structure-format($source, $source)" />
</xsl:function>


<xsl:template name="block-with-mod">
	<xsl:variable name="mod" as="element(mod)" select="mod" />
	<xsl:variable name="before" as="node()*" select="$mod/preceding-sibling::node()" />
	<xsl:if test="exists($before[normalize-space(.)])">
		<Text>
			<xsl:apply-templates select="$before" />
		</Text>
	</xsl:if>
	<xsl:apply-templates select="$mod" />
	<xsl:apply-templates select="$mod/following-sibling::node()" />
</xsl:template>

<xsl:template match="mod">
	<xsl:choose>
		<xsl:when test="empty(quotedStructure)">
			<Text>
				<xsl:apply-templates />
			</Text>
		</xsl:when>
		<xsl:when test="exists(quotedText) and quotedText/following-sibling::node()[1][self::quotedStructure]">
			<!-- lead in  -->
			<!-- there can be two quotedTexts before the quotedStructure, only the first of which is a lead-in, e.g., asp/2003/1/2003-02-11 -->
			<xsl:if test="count(quotedStructure) ne 1 or exists(quotedStructure/following-sibling::quotedText)">
				<xsl:message terminate="yes">
					<xsl:sequence select="." />
				</xsl:message>
			</xsl:if>
			<xsl:variable name="lead-in" as="element(quotedText)" select="quotedStructure/preceding-sibling::quotedText[1]" />
			<xsl:variable name="before" as="node()*" select="$lead-in/preceding-sibling::node()" />
			<xsl:choose>
				<xsl:when test="exists($before) and not(every $n in $before satisfies ($n/self::text() and not(normalize-space($n))))">
					<Text>
						<xsl:apply-templates select="$before" />
						<xsl:apply-templates select="$lead-in" />
					</Text>
					<xsl:call-template name="block-amendment">
						<xsl:with-param name="lead-in" select="()" />
						<xsl:with-param name="source" select="quotedStructure" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="block-amendment">
						<xsl:with-param name="lead-in" select="$lead-in" />
						<xsl:with-param name="source" select="quotedStructure" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="quotedStructure/following-sibling::node()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="qs1" as="element(quotedStructure)" select="quotedStructure[1]" />
			<xsl:variable name="before" as="node()*" select="$qs1/preceding-sibling::node()" />
			<xsl:if test="exists($before[not(self::text()[not(normalize-space(.))])])">
				<Text>
					<xsl:apply-templates select="$before" />
				</Text>
			</xsl:if>
			<xsl:apply-templates select="$qs1" />
			<xsl:apply-templates select="$qs1/following-sibling::node()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="block-amendment">
	<xsl:param name="lead-in" as="element(quotedText)?" />
	<xsl:param name="source" as="element(quotedStructure)" select="." />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<BlockAmendment>
		<xsl:attribute name="TargetClass">
			<xsl:value-of select="local:get-target-class($source)" />
		</xsl:attribute>
		<xsl:attribute name="TargetSubClass">
			<xsl:value-of select="local:get-target-subclass($source)" />
		</xsl:attribute>
		<xsl:attribute name="Context">
			<xsl:choose>
				<xsl:when test="exists($source/@ukl:Context)">
					<xsl:value-of select="$source/@ukl:Context" />
				</xsl:when>
				<xsl:when test="local:target-is-schedule($source)">
					<xsl:text>schedule</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>main</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="Format">
			<xsl:choose>
				<xsl:when test="exists($source/@ukl:Format)">
					<xsl:value-of select="$source/@ukl:Format" />
				</xsl:when>
				<xsl:when test="exists($lead-in)">
					<xsl:value-of select="local:get-structure-format($lead-in, $source)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:get-structure-format($source)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="exists($lead-in)">
			<Text>
				<xsl:apply-templates select="$lead-in/node()" />
			</Text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="exists($source/*) and (every $child in $source/* satisfies $child/self::hcontainer[@name='definition'])">
				<xsl:call-template name="definition-list">
					<xsl:with-param name="definitions" select="$source/*" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="exists($source/hcontainer[@name='definition']) and (every $child in $source/* satisfies ($child/self::p or $child/self::hcontainer[@name='definition']))">
				<xsl:call-template name="group-definitions-for-block-amendment">
					<xsl:with-param name="elements" select="$source/*" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="exists($source/tocItem) and (every $child in $source/* satisfies $child/self::tocItem)">
				<xsl:call-template name="toc-items" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$source/*">
					<xsl:with-param name="context" select="('BlockAmendment', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</BlockAmendment>
</xsl:template>

<xsl:template match="quotedStructure">
	<xsl:call-template name="block-amendment">
		<xsl:with-param name="lead-in" select="()" />
		<xsl:with-param name="source" select="." />
	</xsl:call-template>
</xsl:template>

<xsl:template match="inline[@name=('appendText','AppendText')]">
	<AppendText>
		<xsl:apply-templates />
	</AppendText>
</xsl:template>

<xsl:template match="quotedText">
	<InlineAmendment>
		<xsl:value-of select="@startQuote" />
		<xsl:apply-templates />
		<xsl:value-of select="@endtQuote" />
	</InlineAmendment>
</xsl:template>

<xsl:template match="embeddedStructure">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="clml" as="element()+">
		<BlockExtract>
			<xsl:attribute name="SourceClass">
				<xsl:value-of select="if (exists(@ukl:SourceClass)) then @ukl:SourceClass else 'unknown'" />
			</xsl:attribute>
			<xsl:attribute name="SourceSubClass">
				<xsl:value-of select="if (exists(@ukl:SourceSubClass)) then @ukl:SourceSubClass else 'unknown'" />
			</xsl:attribute>
			<xsl:attribute name="Context">
				<xsl:choose>
					<xsl:when test="exists(@ukl:Context)">
						<xsl:value-of select="@ukl:Context" />
					</xsl:when>
					<xsl:when test="local:target-is-schedule(.)">
						<xsl:text>schedule</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>main</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="Format">
				<xsl:value-of select="local:get-structure-format(.)" />
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="exists(*) and (every $child in * satisfies $child/self::hcontainer[@name='definition'])">
					<xsl:call-template name="definition-list">
						<xsl:with-param name="definitions" select="*" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="exists(hcontainer[@name='definition']) and (every $child in * satisfies ($child/self::p or $child/self::hcontainer[@name='definition']))">
					<xsl:call-template name="group-definitions-for-block-amendment">
						<xsl:with-param name="elements" select="*" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates>
						<xsl:with-param name="context" select="('BlockExtract', $context)" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:otherwise>
			</xsl:choose>
		</BlockExtract>
	</xsl:variable>
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" select="$clml" />
	</xsl:call-template>
</xsl:template>

<!-- FragmentNumber and FragmentTitle -->

<xsl:template match="quotedStructure/*[self::part or self::chapter][empty(*[not(self::num or self::heading)])]" priority="1">
	<xsl:apply-templates mode="fragment" />
</xsl:template>

<xsl:template match="num" mode="fragment">
	<FragmentNumber>
		<xsl:attribute name="Context">
			<xsl:choose>
				<xsl:when test="exists(parent::part)">
					<xsl:text>Part</xsl:text>
				</xsl:when>
				<xsl:when test="exists(parent::chapter)">
					<xsl:text>Chapter</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<Number>
			<xsl:apply-templates/>
		</Number>
	</FragmentNumber>
</xsl:template>

<xsl:template match="heading" mode="fragment">
	<FragmentTitle>
		<xsl:attribute name="Context">
			<xsl:choose>
				<xsl:when test="exists(parent::part)">
					<xsl:text>Part</xsl:text>
				</xsl:when>
				<xsl:when test="exists(parent::chapter)">
					<xsl:text>Chapter</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<Title>
			<xsl:apply-templates/>
		</Title>
	</FragmentTitle>
</xsl:template>


</xsl:transform>
