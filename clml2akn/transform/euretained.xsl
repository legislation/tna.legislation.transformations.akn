<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk ukl ukm local">

<xsl:template match="ukm:EURLexIdentifiers">
	<xsl:copy>
		<xsl:apply-templates />
	</xsl:copy>
</xsl:template>

<xsl:template match="ukm:EURLexMetadata" />

<xsl:template match="EURetained">
	<xsl:apply-templates select="EUPrelims" />
	<body>
		<xsl:if test="exists(EUBody)">
			<xsl:call-template name="add-internal-id-if-necessary">
				<xsl:with-param name="from" select="EUBody" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="EUBody" />
		<xsl:apply-templates select="EUBody/following-sibling::*" />
	</body>
</xsl:template>

<xsl:template match="EUPrelims">
	<preface eId="preface">
		<xsl:apply-templates select="* except EUPreamble" />
	</preface>
	<xsl:apply-templates select="EUPreamble" />
</xsl:template>

<xsl:template match="EUBody">
	<xsl:apply-templates>
		<xsl:with-param name="context" select="('EUBody')" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>


<!-- prelims -->

<xsl:template match="MultilineTitle">
	<longTitle>
		<xsl:apply-templates />
	</longTitle>
</xsl:template>

<xsl:template match="EUPrelims/Number">
	<block name="number">
		<docNumber>
			<xsl:apply-templates />
		</docNumber>
	</block>
</xsl:template>

<xsl:template match="EUPreamble">
	<preamble>
		<xsl:apply-templates />
	</preamble>
</xsl:template>


<xsl:template match="EUPreamble//Division">
	<blockContainer class="division" uk:name="division">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>


<!-- structure -->

<xsl:template match="EUPart">
	<part>
		<xsl:call-template name="hcontainer" />
	</part>
</xsl:template>

<xsl:template match="EUTitle">
	<title>
		<xsl:call-template name="hcontainer" />
	</title>
</xsl:template>

<xsl:template match="EUChapter">
	<chapter>
		<xsl:call-template name="hcontainer" />
	</chapter>
</xsl:template>

<xsl:template match="EUSection">
	<section>	<!-- group5 -->
		<xsl:call-template name="hcontainer" />
	</section>
</xsl:template>

<xsl:template match="EUSubsection">
	<subsection>	<!-- group6 -->
		<xsl:call-template name="hcontainer" />
	</subsection>
</xsl:template>

<xsl:template match="Division">
	<hcontainer name="division">
		<xsl:if test="exists(@Type)">
			<xsl:attribute name="class">
				<xsl:value-of select="lower-case(@Type)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="hcontainer" />
	</hcontainer>
</xsl:template>

<xsl:template match="ListItem/Division" priority="10">
	<blockContainer uk:name="division">
		<xsl:if test="exists(@Type)">
			<xsl:attribute name="class">
				<xsl:value-of select="lower-case(@Type)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>


<!-- attachments -->

<xsl:template match="Attachments">
	<hcontainer name="attachments">
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="AttachmentGroup">
	<hcontainer name="attachmentGroup">
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="Attachment">
	<hcontainer name="attachment">
		<content>
			<p>
				<subFlow name="euretained">
					<xsl:apply-templates />
				</subFlow>
			</p>
		</content>
	</hcontainer>
</xsl:template>

<xsl:template match="Attachment/EURetained">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Attachment/EURetained/EUPrelims">
	<container name="preface">
		<xsl:apply-templates select="* except EUPreamble" />
	</container>
	<xsl:apply-templates select="EUPreamble" />
</xsl:template>

<xsl:template match="Attachment/EURetained/EUPrelims/MultilineTitle">
	<container name="multilineTitle">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Attachment/EURetained/EUPrelims/EUPreamble">
	<container name="preamble">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Attachment/EURetained/EUBody">
	<hcontainer name="body">
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="Attachment/EURetained/EUBody/P">
	<article ukl:Name="P">
		<content>
			<xsl:apply-templates />
		</content>
	</article>
</xsl:template>

</xsl:transform>
