<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" suppress-indentation="block p num heading subheading" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="Text Emphasis Strong Underline SmallCaps Superior Inferior Uppercase Underline Expanded Strike Definition Proviso Abbreviation Acronym Term Span Citation CitationSubRef InternalLink ExternalLink InlineAmendment Addition Substitution Repeal" />

<xsl:include href="fix-clml.xsl" />
<xsl:include href="globals.xsl" />
<xsl:include href="metadata.xsl" />
<xsl:include href="context.xsl" />
<xsl:include href="prelims.xsl" />
<xsl:include href="toc.xsl" />
<xsl:include href="structure.xsl" />
<xsl:include href="numbers.xsl" />
<xsl:include href="lists.xsl" />
<xsl:include href="tables.xsl" />
<xsl:include href="inline.xsl" />
<xsl:include href="images.xsl" />
<xsl:include href="amendments.xsl" />
<xsl:include href="citations.xsl" />
<xsl:include href="forms.xsl" />
<xsl:include href="footnotes.xsl" />
<xsl:include href="signatures.xsl" />
<xsl:include href="explanatory.xsl" />
<xsl:include href="changes.xsl" />
<xsl:include href="math.xsl" />
<xsl:include href="commentaries.xsl" />
<xsl:include href="resources.xsl" />
<xsl:include href="euretained.xsl" />


<xsl:template match="/">
	<xsl:variable name="fixed" as="document-node()">
		<xsl:document>
			<xsl:apply-templates mode="fix-clml" />
		</xsl:document>
	</xsl:variable>
	<akomaNtoso xsi:schemaLocation="http://docs.oasis-open.org/legaldocml/ns/akn/3.0 http://docs.oasis-open.org/legaldocml/akn-core/v1.0/cos01/part2-specs/schemas/akomantoso30.xsd">
		<xsl:apply-templates select="$fixed/node()" />
	</akomaNtoso>
</xsl:template>

<xsl:template match="Legislation">
	<act name="{ $doc-short-type }">
		<xsl:apply-templates select="*[not(self::Footnotes) and not(self::Versions) and not(self::Resources)]" />
		<xsl:call-template name="components" />
	</act>
</xsl:template>

<xsl:template match="Primary">
	<xsl:apply-templates select="PrimaryPrelims" />
	<body>
		<xsl:if test="exists(Body)">
			<xsl:call-template name="add-internal-id-if-necessary">
				<xsl:with-param name="from" select="Body" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="Body | Appendix | Schedules" />
	</body>
	<xsl:if test="exists(ExplanatoryNotes | Include)">
		<conclusions>
			<xsl:apply-templates select="ExplanatoryNotes | Include" />
		</conclusions>
	</xsl:if>
	<xsl:if test="exists(*[not(self::PrimaryPrelims) and not(self::Body) and not(self::Appendix) and not(self::Schedules) and not(self::ExplanatoryNotes) and not (self::Include)])">
		<xsl:message terminate="yes">
			<xsl:sequence select="*/local-name()" />
		</xsl:message>
	</xsl:if>
</xsl:template>

<xsl:template match="Secondary">
	<xsl:apply-templates select="SecondaryPrelims" />
	<xsl:if test="exists(Body | Appendix | Schedules)">
		<body>
			<xsl:if test="exists(Body)">
				<xsl:call-template name="add-internal-id-if-necessary">
					<xsl:with-param name="from" select="Body" />
				</xsl:call-template>
			</xsl:if>
			<xsl:apply-templates select="Body | Appendix | Schedules" />
		</body>
	</xsl:if>
	<xsl:if test="exists(ExplanatoryNotes | EarlierOrders | Include)">
		<conclusions>
			<xsl:apply-templates select="ExplanatoryNotes | EarlierOrders | Include" />
		</conclusions>
	</xsl:if>
	<xsl:if test="exists(*[not(self::SecondaryPrelims) and not(self::Body) and not(self::Appendix) and not(self::Schedules) and not(self::ExplanatoryNotes) and not(self::EarlierOrders) and not (self::Include)])">
		<xsl:message terminate="yes">
			<xsl:sequence select="*/local-name()" />
		</xsl:message>
	</xsl:if>
</xsl:template>

<xsl:template match="Body">
	<xsl:apply-templates>
		<xsl:with-param name="context" select="('Body')" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>


<!-- blocks -->

<xsl:template match="BlockText">
	<blockContainer ukl:Name="BlockText">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="Para | P1para | P2para | P3para | P4para | P5para | P6para | P7para">
	<xsl:call-template name="para-with-amendment" />
</xsl:template>

<xsl:template match="Text">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>


<!-- text -->

<xsl:template match="text()">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="local:should-add-punctuation-to-number(., $context)">
			<xsl:call-template name="add-punctuation-to-number" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:next-match />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- default -->

<xsl:template match="*">
	<xsl:message terminate="yes">
		<xsl:sequence select="." />
	</xsl:message>
</xsl:template>

</xsl:transform>
