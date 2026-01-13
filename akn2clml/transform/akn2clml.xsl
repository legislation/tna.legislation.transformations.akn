<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	xmlns:saxon="http://saxon.sf.net/"
	exclude-result-prefixes="xs uk ukl local saxon">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="block p docTitle docNumber docDate num heading subheading ref def term abbr date inline b i u sup sub span a mod quotedText ins" />

<xsl:include href="ldapp.xsl" />
<xsl:include href="id.xsl" />
<xsl:include href="globals.xsl" />
<xsl:include href="metadata.xsl" />
<xsl:include href="context.xsl" />
<xsl:include href="prelims.xsl" />
<xsl:include href="toc.xsl" />
<xsl:include href="structure.xsl" />
<xsl:include href="numbers.xsl" />
<xsl:include href="lists.xsl" />
<xsl:include href="tables.xsl" />
<xsl:include href="images.xsl" />
<xsl:include href="amendments.xsl" />
<xsl:include href="citations.xsl" />
<xsl:include href="forms.xsl" />
<xsl:include href="footnotes.xsl" />
<xsl:include href="signatures.xsl" />
<xsl:include href="explanatory.xsl" />
<xsl:include href="changes.xsl" />
<xsl:include href="math.xsl" />
<xsl:include href="resources.xsl" />
<xsl:include href="euretained.xsl" />


<xsl:template match="/akomaNtoso">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="/akomaNtoso/*">
	<Legislation>
		<xsl:variable name="welshLang" select="parent::akomaNtoso/*/meta/identification/FRBRExpression/FRBRlanguage/@language" as="xs:string?"/>
		<xsl:call-template name="add-Legislation-attributes">
			<xsl:with-param name="welshLang" select="$welshLang"/>
		</xsl:call-template>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:call-template name="metadata">
			<xsl:with-param name="welshLang" select="$welshLang"/>
		</xsl:call-template>
		<xsl:if test="exists(body)">
			<xsl:call-template name="main" />
		</xsl:if>
		<xsl:call-template name="footnotes" />
		<xsl:call-template name="margin-notes" />
		<xsl:call-template name="resources" />
		<xsl:call-template name="commentaries" />
	</Legislation>
</xsl:template>

<xsl:template name="add-Legislation-attributes">
	<xsl:param name="welshLang" as="xs:string?"/>
	<xsl:attribute name="SchemaVersion" select="'2.0'"/>
	<xsl:attribute name="xsi:schemaLocation" select="'http://www.legislation.gov.uk/namespaces/legislation http://www.legislation.gov.uk/schema/legislation.xsd'"/>
	<xsl:if test="$welshLang = 'cym'">
		<xsl:attribute name="xml:lang" select="'cy'"/>
	</xsl:if>
</xsl:template>

<xsl:template name="main">
	<xsl:variable name="name" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$doc-category = 'primary'">
				<xsl:text>Primary</xsl:text>
			</xsl:when>
			<xsl:when test="$doc-category = 'secondary'">
				<xsl:text>Secondary</xsl:text>
			</xsl:when>
			<xsl:when test="$doc-category = 'euretained'">
				<xsl:text>EURetained</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{ $name }">
		<xsl:call-template name="prelims">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:call-template>
		<xsl:apply-templates select="body">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="conclusions">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="coverPage/blockContainer[@class = 'explanatoryNote']">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="coverPage/blockContainer[@class = 'commencementHistory']">
			<xsl:with-param name="context" select="$name" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:element>
	<xsl:if test="exists(*[not(self::meta) and not(self::coverPage) and not(self::preface) and not(self::preamble) and not(self::body) and not(self::conclusions) and not(self::components)])">
		<xsl:message><xsl:text>ERROR for handling: </xsl:text><xsl:value-of select="self::*/local-name()"/></xsl:message>
		<Error><xsl:text>ERROR for handling: </xsl:text><xsl:value-of select="self::*/local-name()"/></Error>
	</xsl:if>
</xsl:template>


<!-- body -->

<xsl:template match="body">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$context[1] = 'EURetained'">
			<xsl:call-template name="eu-body" />
		</xsl:when>
		<xsl:otherwise>
			<Body>
				<xsl:call-template name="add-fragment-attributes" />
				<xsl:apply-templates select="*[not(self::hcontainer[@name='schedules'])]">
					<xsl:with-param name="context" select="('Body', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:if test="exists(hcontainer[@name='schedules']/following-sibling::node())">
					<xsl:message><xsl:text>ERROR for hcontainer with name 'schedules' that has following-sibling: </xsl:text><xsl:value-of select="hcontainer[@name='schedules']/following-sibling::node()/local-name()"/></xsl:message>
					<Error><xsl:text>ERROR for hcontainer with name 'schedules' that has following-sibling: </xsl:text><xsl:value-of select="hcontainer[@name='schedules']/following-sibling::node()/local-name()"/></Error>
				</xsl:if>
			</Body>
			<xsl:apply-templates select="hcontainer[@name='schedules']" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- blocks -->

<xsl:template match="intro | content | wrapUp">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="p">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(mod)">
			<xsl:call-template name="wrap-as-necessary">
				<xsl:with-param name="clml" as="node()+">
					<xsl:call-template name="block-with-mod">
						<xsl:with-param name="context" select="(local:get-block-wrapper($context), $context)" tunnel="yes" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="exists(embeddedStructure)">
			<xsl:choose>
				<xsl:when test="$context[1] = 'BlockAmendment'">
					<Para>
						<xsl:apply-templates>
							<xsl:with-param name="context" select="('Para', $context)" tunnel="yes" />
						</xsl:apply-templates>
					</Para>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="create-element-and-wrap-as-necessary">
				<xsl:with-param name="name" select="'Text'" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="blockContainer[@ukl:Name='BlockText']" priority="2">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" select="'BlockText'" />
	</xsl:call-template>
</xsl:template>


<!-- inline -->

<xsl:template match="i">
	<Emphasis>
		<xsl:apply-templates />
	</Emphasis>
</xsl:template>

<xsl:template match="b">
	<Strong>
		<xsl:apply-templates />
	</Strong>
</xsl:template>

<xsl:template match="u">
	<Underline>
		<xsl:apply-templates />
	</Underline>
</xsl:template>

<xsl:template match="inline[@name='smallCaps']">
	<SmallCaps>
		<xsl:apply-templates />
	</SmallCaps>
</xsl:template>

<xsl:template match="sup">
	<Superior>
		<xsl:apply-templates />
	</Superior>
</xsl:template>

<xsl:template match="sub">
	<Inferior>
		<xsl:apply-templates />
	</Inferior>
</xsl:template>

<xsl:template match="docTitle | shortTitle | docNumber | docStage | docDate">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="abbr">
	<xsl:element name="{ if (@class = 'acronym') then 'Acronym' else 'Abbreviation' }">
		<xsl:if test="exists(@title)">
			<xsl:attribute name="Expansion">
				<xsl:value-of select="@title" />
			</xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="def">
	<xsl:value-of select="@uk:startQuote" />
	<xsl:element name="{ if (@ukl:Name='Definition') then 'Definition' else 'Term' }">
		<xsl:if test="exists(@ukl:TermRef)">
			<xsl:attribute name="TermRef">
				<xsl:value-of select="@ukl:TermRef" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
	<xsl:value-of select="@uk:endQuote" />
</xsl:template>

<xsl:template match="term">
	<Term>
		<xsl:if test="exists(@eId)">
			<xsl:attribute name="id">
				<xsl:value-of select="@eId" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</Term>
</xsl:template>

<xsl:template match="inline[@name='proviso']">
	<Proviso>
		<xsl:apply-templates />
	</Proviso>
</xsl:template>

<xsl:template match="span">
	<Span>
		<xsl:apply-templates />
	</Span>
</xsl:template>

<xsl:template match="span[@ukl:Name]">
	<Character Name="{ @ukl:Name }" />
</xsl:template>

<!-- there is no analog to an unqualified date -->
<xsl:template match="date">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="inline[@name='uppercase']">
	<Uppercase>
		<xsl:apply-templates />
	</Uppercase>
</xsl:template>

<xsl:template match="inline[@name='strike']">
	<Strike>
		<xsl:apply-templates />
	</Strike>
</xsl:template>

<xsl:template match="inline[@name='expanded']">
	<Expanded>
		<xsl:apply-templates />
	</Expanded>
</xsl:template>

<xsl:template match="inline[@name='dropCap']">
	<Uppercase>
		<xsl:apply-templates />
	</Uppercase>
</xsl:template>


<!-- text -->

<xsl:template match="text()">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="local:should-strip-punctuation-from-number(., $context)">
			<xsl:call-template name="strip-punctuation-from-number" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="normalized" as="xs:string" select="normalize-space(.)" />
			<xsl:if test="matches(., '^\s')">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="$normalized" />
			<xsl:if test="matches(., '\s$') and $normalized">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- default -->

<xsl:template match="*" priority="-100">
	<xsl:message><xsl:text>ERROR no template match for element: </xsl:text><xsl:value-of select="self::*/local-name()"/></xsl:message>
	<Error><xsl:text>ERROR no template match for element: </xsl:text><xsl:value-of select="self::*/local-name()"/><xsl:text> : </xsl:text><xsl:sequence select="." /></Error>
</xsl:template>

</xsl:transform>
