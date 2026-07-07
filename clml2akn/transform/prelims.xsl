<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukm local">


<xsl:template match="PrimaryPrelims">
	<preface eId="preface">
		<xsl:call-template name="add-internal-id-if-necessary" />
		<xsl:apply-templates select="Title | Number" />
		<xsl:choose>
			<xsl:when test="$doc-short-type = 'asp'">
				<xsl:apply-templates select="DateOfEnactment" />
				<xsl:apply-templates select="LongTitle" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="LongTitle | DateOfEnactment" />
			</xsl:otherwise>
		</xsl:choose>
	</preface>
	<xsl:apply-templates select="PrimaryPreamble" />
</xsl:template>

<xsl:template match="PrimaryPrelims/Title | SecondaryPrelims/Title">
	<block name="title">
		<docTitle>
			<xsl:apply-templates />
		</docTitle>
	</block>
</xsl:template>

<xsl:template match="PrimaryPrelims/Number">
	<block name="number">
		<docNumber>
			<xsl:apply-templates />
		</docNumber>
	</block>
</xsl:template>

<xsl:template match="LongTitle">
	<longTitle>
		<p>
			<xsl:apply-templates />
		</p>
	</longTitle>
</xsl:template>

<xsl:template match="DateOfEnactment">
	<block name="dateOfEnactment" refersTo="#date-enacted">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="DateOfEnactment/DateText">
	<xsl:if test="exists(node())">
		<docDate>
			<xsl:attribute name="date">
				<xsl:variable name="this-date" as="xs:string?" select="local:parse-date(string(.))" />
				<xsl:choose>
					<xsl:when test="exists($this-date)">
						<xsl:value-of select="$this-date" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/Legislation/ukm:Metadata/ukm:PrimaryMetadata/ukm:EnactmentDate/@Date" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates />
		</docDate>
	</xsl:if>
</xsl:template>


<!-- secondary -->


<xsl:template match="SecondaryPrelims">
	<preface eId="preface">
		<xsl:call-template name="add-internal-id-if-necessary" />
		<xsl:apply-templates select="* except (LaidDraft | SiftedDate | MadeDate | LaidDate | ComingIntoForce | SecondaryPreamble)" />
		<container name="dates">
			<xsl:apply-templates select="LaidDraft | SiftedDate | MadeDate | LaidDate | ComingIntoForce" />
		</container>
	</preface>
	<xsl:apply-templates select="SecondaryPreamble" />
</xsl:template>

<xsl:template name="banner">
	<xsl:choose>
		<xsl:when test="$doc-short-type = 'uksi'">
			<block name="banner">Statutory Instruments</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'nisr'">
			<block name="banner">Statutory Rules of Northern Ireland</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'nisro'">
		</xsl:when>
		<xsl:when test="$doc-short-type = 'ssi'">
			<block name="banner">Scottish Statutory Instruments</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'wsi'">
			<block name="banner">Welsh Statutory Instruments</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'nisi'">
			<block name="banner">Statutory Instruments</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'uksro'">
			<block name="banner">Statutory Instruments</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'ukmo'">
			<block name="banner">Ministerial Order</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'ukmd'">
			<block name="banner">Ministerial Directions</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'ukci'">
			<block name="banner">Church Instruments</block>
		</xsl:when>
		<xsl:when test="$doc-short-type = 'sdsi'">
			<block name="banner">Draft Scottish Statutory Instruments</block>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="SecondaryPrelims/Number">
	<xsl:call-template name="banner" />
	<block name="number">
		<docNumber>
			<xsl:apply-templates />
		</docNumber>
	</block>
</xsl:template>

<xsl:template match="Correction">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Correction/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Correction/Para/Text">
	<block name="correctionRubric">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="Draft">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Draft/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Draft/Para/Text">
	<block name="proceduralRubric">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="SubjectInformation">
	<container name="subjects">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Subject">
	<container name="subject">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Subject/Title">
	<block name="subject">
		<concept refersTo="#">
			<xsl:apply-templates />
		</concept>
	</block>
</xsl:template>

<xsl:template match="Subject/Subtitle">
	<block name="subsubject">
		<concept refersTo="#">
			<xsl:apply-templates />
		</concept>
	</block>
</xsl:template>

<xsl:template match="Approved">
	<block name="approval">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:function name="local:lower-camel-case" as="xs:string">
	<xsl:param name="s" as="xs:string" />
	<xsl:value-of select="concat(lower-case(substring($s, 1, 1)), substring($s, 2))" />
</xsl:function>

<xsl:template match="LaidDraft | SiftedDate | MadeDate | LaidDate | ComingIntoForce[empty(ComingIntoForceClauses)] | ComingIntoForceClauses">
	<block>
		<xsl:attribute name="name">
			<xsl:choose>
				<xsl:when test="self::LaidDraft">
					<xsl:text>laidInDraft</xsl:text>
				</xsl:when>
				<xsl:when test="self::ComingIntoForce or self::ComingIntoForceClauses">
					<xsl:text>commenceDate</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:lower-camel-case(local-name())" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:choose>
			<xsl:when test="self::SiftedDate">
				<xsl:attribute name="refersTo">
					<xsl:text>#date-sifted</xsl:text>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="self::MadeDate">
				<xsl:attribute name="refersTo">
					<xsl:text>#date-made</xsl:text>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="self::LaidDate">
				<xsl:attribute name="refersTo">
					<xsl:text>#date-laid-</xsl:text>
					<xsl:value-of select="count(preceding-sibling::LaidDate) + 1" />
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="self::ComingIntoForce">
				<xsl:attribute name="refersTo">
					<xsl:text>#date-cif-</xsl:text>
					<xsl:value-of select="count(preceding-sibling::ComingIntoForce) + 1" />
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates />
	</block>
</xsl:template>
<xsl:template match="ComingIntoForce[exists(ComingIntoForceClauses)]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="LaidDraft/Text | SiftedDate/Text | MadeDate/Text | LaidDate/Text | ComingIntoForce[empty(ComingIntoForceClauses)]/Text | ComingIntoForceClauses/Text">
	<span>
		<xsl:apply-templates />
	</span>
</xsl:template>
<xsl:template match="ComingIntoForce[exists(ComingIntoForceClauses)]/Text">
	<block name="commenceDate">
		<span>
			<xsl:apply-templates />
		</span>
	</block>
</xsl:template>

<xsl:template match="SiftedDate/DateText | MadeDate/DateText | LaidDate/DateText | ComingIntoForce/DateText | ComingIntoForceClauses/DateText">
	<xsl:variable name="date" as="xs:string?">
		<xsl:variable name="from-text" as="xs:string?" select="local:parse-date(.)" />
		<xsl:choose>
			<xsl:when test="exists($from-text)">
				<xsl:sequence select="$from-text" />
			</xsl:when>
			<xsl:when test="parent::SiftedDate">
				<xsl:sequence select="/Legislation/ukm:Metadata/ukm:*/ukm:Sifted/@Date" />
			</xsl:when>
			<xsl:when test="parent::MadeDate">	<!-- could add and exists(/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Made) -->
				<xsl:variable name="ukm-made" as="element(ukm:Made)?" select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Made" />
				<xsl:sequence select="$ukm-made/@Date" />
			</xsl:when>
			<xsl:when test="parent::LaidDate">
				<xsl:variable name="pos" as="xs:integer" select="count(parent::*/preceding-sibling::LaidDate) + 1" />
				<xsl:sequence select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Laid[$pos]/@Date" />
			</xsl:when>
			<xsl:when test="parent::ComingIntoForce">
				<xsl:sequence select="/Legislation/ukm:Metadata/ukm:*/ukm:ComingIntoForce/ukm:DateTime/@Date" />
			</xsl:when>
			<xsl:when test="parent::ComingIntoForceClauses">
				<xsl:variable name="pos" as="xs:integer" select="count(../preceding-sibling::ComingIntoForceClauses) + 1" />
				<xsl:sequence select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:ComingIntoForce/ukm:DateTime[$pos]/@Date" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="exists($date)">
			<docDate date="{ $date }">
				<xsl:apply-templates />
			</docDate>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<!-- preamble -->

<xsl:template match="PrimaryPreamble">
	<xsl:if test="exists(*[not(self::EnactingTextOmitted)]) or exists(EnactingTextOmitted/*)">
	<preamble>
		<xsl:apply-templates />
	</preamble>
	</xsl:if>
</xsl:template>

<xsl:template match="SecondaryPreamble">
	<preamble>
		<xsl:apply-templates />
	</preamble>
</xsl:template>

<xsl:template match="RoyalPresence">
	<container name="royalPresence">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="RoyalPresence/Para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Resolution">
	<container name="resolution">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="IntroductoryText">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="IntroductoryText[P]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="IntroductoryText/P[P3]">
	<blockContainer>
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="IntroductoryText/P/P3">
	<blockContainer class="P3">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="EnactingText">
	<formula name="enactingText">
		<xsl:apply-templates />
	</formula>
</xsl:template>

<xsl:template match="EnactingTextOmitted">
</xsl:template>

</xsl:transform>
