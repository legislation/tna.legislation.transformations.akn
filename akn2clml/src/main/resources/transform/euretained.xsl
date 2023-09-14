<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukm uk local">

<xsl:template name="eu-metadata">
	<EUMetadata xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<DocumentClassification>
			<DocumentCategory Value="euretained" />
			<DocumentMainType Value="{ $doc-long-type }" />
			<DocumentStatus>
				<xsl:attribute name="Value">
					<xsl:choose>
						<xsl:when test="$doc-version = 'adopted'">
							<xsl:text>final</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>revised</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</DocumentStatus>
		</DocumentClassification>
		<Year Value="{ $doc-year }" />
		<xsl:if test="exists($doc-number)">
			<Number Value="{ $doc-number }" />
		</xsl:if>
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:EURLexIdentifiers" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:EnactmentDate" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:EURLexModified" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:EURLexExtracted" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:XMLGenerated" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:XMLImported" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:Treaty" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:CreatedBy" />
		<xsl:apply-templates select="meta/proprietary/ukm:EUMetadata/ukm:Subject" />
	</EUMetadata>
</xsl:template>

<xsl:template match="ukm:*">
	<xsl:element name="{ local-name(.) }" xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template name="eu-prelims">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<xsl:variable name="child-context" as="xs:string*" select="('EUPrelims', $context)" />
	<EUPrelims>
		<xsl:call-template name="add-fragment-attributes">
			<xsl:with-param name="from" select="preface" />
		</xsl:call-template>
		<xsl:apply-templates select="preface/*">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="preamble" mode="eu">
			<xsl:with-param name="context" select="$child-context" tunnel="yes" />
		</xsl:apply-templates>
	</EUPrelims>
</xsl:template>

<xsl:template match="preamble" mode="eu">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<EUPreamble>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EUPreamble', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EUPreamble>
</xsl:template>

<xsl:template name="eu-body">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<EUBody>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates select="*[not(self::hcontainer[@name=('schedules','attachments','attachment')])]">
			<xsl:with-param name="context" select="('EUBody', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EUBody>
	<xsl:apply-templates select="hcontainer[@name=('schedules','attachments')]" />
</xsl:template>

<xsl:template match="hcontainer[@name='division']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<Division>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Division', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Division>
</xsl:template>

<xsl:template match="blockContainer[@uk:name='division']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<Division>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Division', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Division>
</xsl:template>


<!-- attachments -->

<xsl:template match="hcontainer[@name='attachments']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<Attachments>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Attachments', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Attachments>
</xsl:template>

<xsl:template match="hcontainer[@name='attachmentGroup']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<AttachmentGroup>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('AttachmentGroup', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</AttachmentGroup>
</xsl:template>

<xsl:template match="hcontainer[@name='attachment']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<Attachment>
		<xsl:call-template name="add-fragment-attributes" />
		<xsl:apply-templates mode="attachment">
			<xsl:with-param name="context" select="('Attachment', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Attachment>
</xsl:template>

<xsl:template match="content | p" mode="attachment">
	<xsl:apply-templates mode="attachment" />
</xsl:template>

<xsl:template match="subFlow[@name='euretained']" mode="attachment">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<EURetained>
		<xsl:apply-templates select="* except container[@name='preamble'][exists(preceding-sibling::*[1][self::container[@name='preface']])]">
			<xsl:with-param name="context" select="('EURetained', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EURetained>
</xsl:template>

<xsl:template match="subFlow[@name='euretained']/container[@name='preface']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<EUPrelims>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EUPrelims', $context)" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="following-sibling::*[1][self::container[@name='preamble']]">
			<xsl:with-param name="context" select="('EUPrelims', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EUPrelims>
</xsl:template>

<xsl:template match="subFlow[@name='euretained']/container[@name='preface']/container[@name='multilineTitle']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<MultilineTitle>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('MultilineTitle', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</MultilineTitle>
</xsl:template>

<xsl:template match="subFlow[@name='euretained']/container[@name='preamble']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<EUPreamble>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EUPreamble', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EUPreamble>
</xsl:template>

<xsl:template match="subFlow[@name='euretained']/hcontainer[@name='body']">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<EUBody>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EUBody', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EUBody>
</xsl:template>

</xsl:transform>
