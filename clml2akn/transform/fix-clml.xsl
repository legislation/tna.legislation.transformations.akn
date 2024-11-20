<?xml version="1.0" encoding="utf-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs ukm html">

<!-- remove colspan="1" and rowspan="1" -->

<xsl:template match="@colspan | @rowspan" mode="fix-clml">
	<xsl:if test="string(.) != '1'">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<!-- remove valign="middle" -->

<xsl:template match="html:th/@valign | html:td/@valign" mode="fix-clml">
	<xsl:if test="string(.) != 'middle'">
		<xsl:next-match />
	</xsl:if>
</xsl:template>

<!-- correct document numbers -->
<!-- adapted from FuncOutputPrimaryPrelimsPreContents in tna.legislation.transformations.clml-html-fo//legislation_xhtml_core_vanilla.xslt -->

<xsl:variable name="g_ndsMetadata" as="element()" select="/Legislation/ukm:Metadata"/>
<xsl:variable name="g_strDocumentMainType" as="xs:string" select="$g_ndsMetadata/*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
<xsl:template match="PrimaryPrelims/Number" mode="fix-clml">
	<Number>
		<xsl:choose>
			<xsl:when test="$g_strDocumentMainType = ('WelshAssemblyMeasure','WelshNationalAssemblyAct','WelshParliamentAct') ">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="year" select="$g_ndsMetadata//ukm:Year/@Value"/>
				<xsl:apply-templates select="CommentaryRef"/>
				<xsl:value-of select="$year"/>
				<xsl:choose>
					<xsl:when test="$g_strDocumentMainType = 'UnitedKingdomChurchMeasure'">
						<xsl:text> No. </xsl:text>
					</xsl:when>
					<xsl:when test="$g_strDocumentMainType = 'ScottishAct'">
						<xsl:choose>
							<xsl:when test="if ($year castable as xs:integer) then xs:integer($year) &lt; 1800 else false()">
								<xsl:text> c. </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> asp </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$g_strDocumentMainType = 'ScottishOldAct'">
						<xsl:text> c. </xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> CHAPTER </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$g_strDocumentMainType = ('UnitedKingdomLocalAct','UnitedKingdomPrivateOrPersonalAct','GreatBritainPrivateOrPersonalAct','GreatBritainLocalAct')">
						<xsl:number format="i" value="$g_ndsMetadata//ukm:Number/@Value" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$g_ndsMetadata//ukm:Number/@Value" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:for-each select="$g_ndsMetadata//ukm:AlternativeNumber">
					<xsl:if test="@Category = 'Regnal'">
						<xsl:text> </xsl:text>
						<xsl:value-of select="translate(@Value,'_',' ')" />
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</Number>
</xsl:template>

<!-- identity transform -->

<xsl:template match="@*|node()" mode="fix-clml">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()" mode="fix-clml" />
	</xsl:copy>
</xsl:template>

</xsl:transform>
