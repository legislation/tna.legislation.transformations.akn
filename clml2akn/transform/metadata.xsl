<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	exclude-result-prefixes="xs ukl ukm dc dct atom local">

<xsl:template match="Metadata">
	<meta>
		<xsl:call-template name="identification" />
		<xsl:call-template name="lifecycle" />
		<xsl:call-template name="analysis" />
		<xsl:call-template name="temporal-data" />
		<xsl:call-template name="references" />
		<xsl:call-template name="notes" />
		<xsl:call-template name="proprietary" />
	</meta>
</xsl:template>

<xsl:variable name="work-date" as="xs:string*">
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/PrimaryMetadata/EnactmentDate)">
					<xsl:value-of select="/ukl:Legislation/Metadata/PrimaryMetadata/EnactmentDate/@Date" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="prelim-date" as="xs:string?" select="local:parse-date(/ukl:Legislation/ukl:Primary/ukl:PrimaryPrelims/ukl:DateOfEnactment/ukl:DateText)" />
					<xsl:choose>
						<xsl:when test="exists($prelim-date)">
							<xsl:value-of select="$prelim-date" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(/ukl:Legislation/Metadata/PrimaryMetadata/Year/@Value, '-01-01')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/Made)">
					<xsl:sequence select="/ukl:Legislation/Metadata/SecondaryMetadata/Made/@Date" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="from-prelims" as="xs:string?">
						<xsl:variable name="date-text" as="element()?" select="/ukl:Legislation/ukl:Secondary/ukl:SecondaryPrelims/ukl:MadeDate/ukl:DateText" />
						<xsl:if test="exists($date-text)">
							<xsl:sequence select="local:parse-date($date-text)" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="exists($from-prelims)">
							<xsl:sequence select="string($from-prelims)" />
						</xsl:when>
						<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/Laid)">
							<xsl:sequence select="/ukl:Legislation/Metadata/SecondaryMetadata/Laid/@Date" />
						</xsl:when>
						<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/ComingIntoForce/DateTime)">
							<xsl:sequence select="/ukl:Legislation/Metadata/SecondaryMetadata/ComingIntoForce/DateTime/@Date" />
						</xsl:when>
						<xsl:when test="exists(/ukl:Legislation/@RestrictStartDate)">
							<xsl:sequence select="/ukl:Legislation/@RestrictStartDate" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="concat(/ukl:Legislation/Metadata/SecondaryMetadata/Year/@Value, '-01-01')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:value-of select="/ukl:Legislation/Metadata/EUMetadata/EnactmentDate/@Date" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-date-name" as="xs:string?">
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/PrimaryMetadata/EnactmentDate)">
					<xsl:text>enacted</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="prelim-date" as="xs:string?" select="local:parse-date(/ukl:Legislation/ukl:Primary/ukl:PrimaryPrelims/ukl:DateOfEnactment/ukl:DateText)" />
					<xsl:choose>
						<xsl:when test="exists($prelim-date)">
							<xsl:text>enacted</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>estimated</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/Made)">
					<xsl:text>made</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="from-prelims" as="xs:string?">
						<xsl:variable name="date-text" as="element()?" select="/ukl:Legislation/ukl:Secondary/ukl:SecondaryPrelims/ukl:MadeDate/ukl:DateText" />
						<xsl:if test="exists($date-text)">
							<xsl:sequence select="local:parse-date($date-text)" />
						</xsl:if>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="exists($from-prelims)">
							<xsl:sequence select="'made'" />
						</xsl:when>
						<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/Laid)">
							<xsl:sequence select="'laid'" />
						</xsl:when>
						<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/ComingIntoForce/DateTime)">
							<xsl:sequence select="'comingIntoForce'" />
						</xsl:when>
						<xsl:when test="exists(/ukl:Legislation/@RestrictStartDate)">
							<xsl:sequence select="'start'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="'estimated'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:text>adopted</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-author" as="xs:string">
	<xsl:choose>
		<xsl:when test="starts-with($doc-long-type, 'EuropeanUnion')">
			<xsl:value-of select="EUMetadata/CreatedBy[1]/@URI" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="temp" as="xs:string?">
				<xsl:choose>
					<xsl:when test="$doc-long-type = 'EnglandAct'">
						<xsl:text>legislature/EnglishParliament</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'GreatBritainAct'">
						<xsl:text>legislature/ParliamentOfGreatBritain</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'IrelandAct'">
						<xsl:text>legislature/OldIrishParliament</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandAct'">
						<xsl:text>legislature/NorthernIrelandAssembly</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandAssemblyMeasure'">
						<xsl:text>legislature/NorthernIrelandAssembly</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandParliamentAct'">
						<xsl:text>legislature/NorthernIrelandParliament</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandOrderInCouncil'">
						<xsl:text>government/uk</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandDraftOrderInCouncil'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRule'">government/northern-ireland</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandDraftStatutoryRule'">government/northern-ireland</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishAct'">legislature/ScottishParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishOldAct'">legislature/OldScottishParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishStatutoryInstrument'">government/scotland</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishDraftStatutoryInstrument'">government/scotland</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomChurchInstrument'">legislature/GeneralSynod</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomChurchMeasure'">legislature/GeneralSynod</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomPrivateAct'">legislature/UnitedKingdomParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomPublicGeneralAct'">legislature/UnitedKingdomParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomLocalAct'">legislature/UnitedKingdomParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialOrder'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryInstrument'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomDraftStatutoryInstrument'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshAssemblyMeasure'">legislature/NationalAssemblyForWales</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshNationalAssemblyAct'">legislature/NationalAssemblyForWales</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshStatutoryInstrument'">government/wales</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshDraftStatutoryInstrument'">government/wales</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialDirection'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryRuleOrOrder'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRuleOrOrder'">government/northern-ireland</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', $temp)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-country" as="xs:string">
	<xsl:choose>
		<xsl:when test="$doc-long-type = 'EnglandAct'">
			<xsl:text>GB-ENG</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'GreatBritainAct'">
			<xsl:text>GB-GBN</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'IrelandAct'">
			<xsl:text>IE</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = ('NorthernIrelandAct', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct', 'NorthernIrelandOrderInCouncil', 'NorthernIrelandDraftOrderInCouncil', 'NorthernIrelandStatutoryRule', 'NorthernIrelandDraftStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder')">
			<xsl:text>GB-NIR</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = ('ScottishAct', 'ScottishOldAct', 'ScottishStatutoryInstrument', 'ScottishDraftStatutoryInstrument')">
			<xsl:text>GB-SCT</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = ('WelshAssemblyMeasure', 'WelshNationalAssemblyAct', 'WelshStatutoryInstrument', 'WelshDraftStatutoryInstrument')">
			<xsl:text>GB-WLS</xsl:text>
		</xsl:when>
		<xsl:when test="starts-with($doc-long-type, 'EuropeanUnion')">
			<xsl:text>EU</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<text>GB-UKM</text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-cite" as="xs:string">
	<xsl:variable name="secondary-metadata" select="/ukl:Legislation/Metadata/SecondaryMetadata" />
	<xsl:choose>
		<xsl:when test="$doc-long-type = 'EnglandAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'GreatBritainAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'IrelandAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' [I]')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' (N.I.)')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandAssemblyMeasure'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' (N.I.)')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandParliamentAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' (N.I.)')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandOrderInCouncil' or $doc-long-type = 'NorthernIrelandDraftOrderInCouncil'">
			<xsl:variable name="alt-num" select="$secondary-metadata/AlternativeNumber[@Category='NI']/@Value" />
			<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number, ' (N.I. ', $alt-num, ')')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRule' or $doc-long-type = 'NorthernIrelandDraftStatutoryRule'">
			<xsl:choose>
				<xsl:when test="$secondary-metadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="$secondary-metadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.R. ', $doc-year, '/', $doc-number, ' (C. ', $c-num, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.R. ', $doc-year, '/', $doc-number)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRuleOrOrder'">
			<xsl:choose>
				<xsl:when test="$secondary-metadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="$secondary-metadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.R. &amp; O. (N.I.) ', $doc-year, '/', $doc-number, ' (C. ', $c-num, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.R. &amp; O. (N.I.) ', $doc-year, '/', $doc-number)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'ScottishAct'">
			<xsl:value-of select="concat($doc-year, ' asp ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'ScottishOldAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' [S]')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'ScottishStatutoryInstrument' or $doc-long-type = 'ScottishDraftStatutoryInstrument'">
			<xsl:choose>
				<xsl:when test="$secondary-metadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="$secondary-metadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.S.I. ', $doc-year, '/', $doc-number, ' (C. ', $c-num, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.S.I. ', $doc-year, '/', $doc-number)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomChurchInstrument'">
			<xsl:value-of select="concat('Church Instrument ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomChurchMeasure'">
			<xsl:value-of select="concat($doc-year, ' No. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomPrivateAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomPublicGeneralAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomLocalAct'">
			<xsl:variable name="number">
				<xsl:number value="$doc-number" format="i" />
			</xsl:variable>
			<xsl:value-of select="concat($doc-year, ' c. ', $number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialOrder'">
			<xsl:value-of select="concat('Ministerial Order ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialDirection'">
			<xsl:value-of select="concat('Ministerial Direction ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryInstrument' or $doc-long-type = 'UnitedKingdomDraftStatutoryInstrument'">
			<xsl:variable name="parts" as="xs:string+">
				<xsl:sequence select="concat('S.I. ', $doc-year, '/', $doc-number)" />
				<xsl:for-each select="$secondary-metadata/AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
					<xsl:sequence select="concat('(', @Category, '. ', @Value, ')')" />
				</xsl:for-each>
			</xsl:variable>
			<xsl:sequence select="string-join($parts, ' ')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryRuleOrOrder'">
			<xsl:variable name="parts" as="xs:string+">
				<xsl:sequence select="concat('S.R. &amp; O. ', $doc-year, '/', $doc-number)" />
				<xsl:for-each select="$secondary-metadata/AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
					<xsl:sequence select="concat('(', @Category, '. ', @Value, ')')" />
				</xsl:for-each>
			</xsl:variable>
			<xsl:sequence select="string-join($parts, ' ')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'WelshAssemblyMeasure'">
			<xsl:value-of select="concat($doc-year, ' nawm ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'WelshNationalAssemblyAct'">
			<xsl:value-of select="concat($doc-year, ' anaw ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'WelshStatutoryInstrument' or $doc-long-type = 'WelshDraftStatutoryInstrument'">
			<xsl:variable name="alt-num" as="xs:string?" select="$secondary-metadata/AlternativeNumber[@Category=('W','Cy')]/@Value" />
			<xsl:variable name="c-num" as="xs:string?" select="$secondary-metadata/AlternativeNumber[@Category='C']/@Value" />
			<xsl:choose>
				<xsl:when test="exists($c-num)">
					<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number, ' (W. ', $alt-num, ') (C. ', $c-num,')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number, ' (W. ', $alt-num, ')')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'EuropeanUnionRegulation'">
			<xsl:value-of select="concat('Regulation (EU) ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'EuropeanUnionDecision'">
			<xsl:value-of select="concat('Decision (EU) ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'EuropeanUnionDirective'">
			<xsl:value-of select="concat('Directive (EU) ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="expr-date" as="xs:string">
	<xsl:variable name="dct-valid" as="element()?" select="/ukl:Legislation/Metadata/dct:valid" />
	<xsl:choose>
		<xsl:when test="exists($dct-valid)">
			<xsl:value-of select="$dct-valid" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$work-date" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="expr-date-name" as="xs:string">
	<xsl:variable name="dct-valid" as="element()?" select="/ukl:Legislation/Metadata/dct:valid" />
	<xsl:choose>
		<xsl:when test="exists($dct-valid)">
			<xsl:text>validFrom</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$work-date-name" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="lang" as="xs:string" select="if (/ukl:Legislation/Metadata/dc:language = 'cy') then 'cym' else 'eng'" />


<xsl:template name="identification">
	<identification source="#">
		<FRBRWork>
			<FRBRthis value="{ $doc-long-id }" />
			<FRBRuri value="{ $doc-long-id }" />
			<FRBRdate date="{ $work-date }" name="{ $work-date-name }" />
			<FRBRauthor href="{ $work-author }" />
			<FRBRcountry value="{ $work-country }" />
			<xsl:if test="exists($doc-minor-type)">
				<FRBRsubtype value="{ $doc-minor-type }" />
			</xsl:if>
			<FRBRnumber value="{ $doc-number }" />
			<xsl:for-each select="/ukl:Legislation/Metadata/SecondaryMetadata/AlternativeNumber">
				<FRBRnumber value="{ @Category }. { @Value }" />
			</xsl:for-each>
			<FRBRname value="{ $work-cite }" />
			<FRBRprescriptive value="true" />
		</FRBRWork>
		<FRBRExpression>
			<FRBRthis value="http://www.legislation.gov.uk/{ $doc-short-id }/{ $doc-version }" />
			<FRBRuri value="http://www.legislation.gov.uk/{ $doc-short-id }/{ $doc-version }" />
			<FRBRdate date="{ $expr-date }" name="{ $expr-date-name }" />
			<FRBRauthor href="#" />
			<FRBRlanguage language="{ $lang }" />
		</FRBRExpression>
		<FRBRManifestation>
			<FRBRthis value="http://www.legislation.gov.uk/{ $doc-short-id }/{ $doc-version }/data.akn" />
			<FRBRuri value="http://www.legislation.gov.uk/{ $doc-short-id }/{ $doc-version }/data.akn" />
			<FRBRdate date="{ current-date() }" name="transform" />
			<FRBRauthor href="http://www.legislation.gov.uk" />
			<FRBRformat value="application/akn+xml" />
		</FRBRManifestation>
	</identification>
</xsl:template>

<!-- notes template in commentaries.xsl -->

<xsl:template name="proprietary">
	<proprietary source="#">
		<xsl:namespace name="ukm" select="'http://www.legislation.gov.uk/namespaces/metadata'" />
		<xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'" />
		<xsl:namespace name="dct" select="'http://purl.org/dc/terms/'" />
		<xsl:apply-templates select="/ukl:Legislation/ukm:Metadata/*" />
	</proprietary>
</xsl:template>

<xsl:template match="ukm:* | dc:* | dct:*">
	<xsl:variable name="name" as="xs:string">
		<xsl:choose>
			<xsl:when test="self::ukm:*">
				<xsl:value-of select="concat('ukm:', local-name())" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{ $name }">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="atom:*" />

<xsl:variable name="elements-with-restrict-dates" as="element()*" select="//*[@RestrictStartDate or @RestrictEndDate][empty(ancestor-or-self::ukl:Attachments)]" />

<!-- lifecycle -->

<xsl:template name="lifecycle">
	<lifecycle source="#">
		<xsl:apply-templates select="PrimaryMetadata/EnactmentDate" mode="event-ref" />
		<xsl:apply-templates select="SecondaryMetadata/(Sifted | Made | Laid | ComingIntoForce)" mode="event-ref" />
		<xsl:apply-templates select="EUMetadata/EnactmentDate | EUMetadata/ComingIntoForce" mode="event-ref" />
		<xsl:if test="exists($elements-with-restrict-dates)">
			<xsl:variable name="event-dates" as="xs:string*">
				<xsl:for-each-group select="$elements-with-restrict-dates/@RestrictStartDate | $elements-with-restrict-dates/@RestrictEndDate" group-by=".">
					<xsl:sort />
					<xsl:value-of select="." />
				</xsl:for-each-group>
			</xsl:variable>
			<xsl:for-each select="$event-dates">
		        <eventRef date="{.}" eId="date-{.}" source="#" />
			</xsl:for-each>
		</xsl:if>
	</lifecycle>
</xsl:template>

<xsl:template match="EnactmentDate" mode="tlc-event">
	<TLCEvent eId="enactment" href="" showAs="EnactmentDate" />
</xsl:template>
<xsl:template match="EnactmentDate" mode="event-ref">
	<eventRef refersTo="#enactment" date="{ @Date }" eId="date-enacted" source="#" />
</xsl:template>

<xsl:template match="EUMetadata/EnactmentDate" mode="tlc-event">
	<TLCEvent eId="adopted" href="" showAs="AdoptedDate" />
</xsl:template>
<xsl:template match="EUMetadata/EnactmentDate" mode="event-ref">
	<eventRef refersTo="#adopted" date="{ @Date }" eId="date-adopted" source="#" />
</xsl:template>


<xsl:template match="Sifted" mode="tlc-event">
	<TLCEvent eId="sifted" href="" showAs="Sifted" />
</xsl:template>
<xsl:template match="Sifted" mode="event-ref">
	<eventRef refersTo="#sifted" date="{ @Date }" eId="date-sifted" source="#" />
</xsl:template>

<xsl:template match="Made" mode="tlc-event">
	<TLCEvent eId="made" href="" showAs="Made" />
</xsl:template>
<xsl:template match="Made" mode="event-ref">
	<eventRef refersTo="#made" date="{ @Date }" eId="date-made" source="#" />
</xsl:template>

<xsl:function name="local:lisp-case" as="xs:string">
	<xsl:param name="s" as="xs:string" />
	<xsl:variable name="s" as="xs:string" select="normalize-space($s)" />
	<xsl:variable name="s" as="xs:string" select="translate($s, ' ', '-')" />
	<xsl:variable name="s2" as="xs:string" select="replace($s, '([A-Z])', concat('-', '$1'))" />
	<xsl:variable name="s2" as="xs:string" select="lower-case($s2)" />
	<xsl:value-of select="if (starts-with($s2, '-')) then substring($s2, 2) else $s2" />
</xsl:function>

<xsl:template match="Laid" mode="tlc-organization">
	<TLCOrganization eId="{ local:lisp-case(@Class) }" href="" showAs="{ @Class }" />
</xsl:template>
<xsl:template match="Laid" mode="tlc-event">
	<TLCEvent eId="laid" href="" showAs="Laid" />
</xsl:template>
<xsl:template match="Laid" mode="event-ref">
	<eventRef refersTo="#laid" date="{ @Date }" eId="date-laid-{ count(preceding-sibling::Laid) + 1 }" source="#{ local:lisp-case(@Class) }" />
</xsl:template>

<xsl:template match="ComingIntoForce" mode="tlc-event">
	<TLCEvent eId="cif" href="" showAs="ComingIntoForce" />
</xsl:template>
<xsl:template match="ComingIntoForce" mode="event-ref">
	<xsl:apply-templates mode="event-ref" />
</xsl:template>

<xsl:template match="ComingIntoForce/DateTime" mode="event-ref">
	<eventRef refersTo="#coming-into-force" date="{ @Date }" eId="date-cif-{ count(preceding-sibling::DateTime) + 1 }" source="#" />
</xsl:template>


<!-- analysis -->

<xsl:variable name="elements-with-restrict-extent" as="element()*" select="//*[@RestrictExtent][empty(ancestor-or-self::ukl:Attachments)]" />

<xsl:variable name="elements-with-status" as="element()*" select="//*[@Status][empty(ancestor-or-self::ukl:Attachments)]" />
<xsl:variable name="elements-with-confers-power" as="element()*" select="//*[@ConfersPower][empty(ancestor-or-self::ukl:Attachments)]" />
<xsl:variable name="elements-with-match" as="element()*" select="//*[@Match][empty(ancestor-or-self::ukl:Attachments)]" />

<xsl:variable name="has-restrictions" as="xs:boolean" select="exists($elements-with-restrict-extent) or exists($elements-with-restrict-dates)" />

<xsl:variable name="has-analysis" as="xs:boolean" select="$has-restrictions or exists($elements-with-status) or exists($elements-with-confers-power) or exists($elements-with-match)" />

<xsl:template name="analysis">
	<analysis source="#">
		<xsl:call-template name="restrictions" />
	</analysis>
</xsl:template>

<xsl:template name="restrictions">
	<xsl:if test="$has-restrictions">
		<restrictions source="#">
			<xsl:call-template name="extent-restrictions" />
			<xsl:call-template name="temporal-restrictions" />
		</restrictions>
	</xsl:if>
	<otherAnalysis source="">
		<xsl:call-template name="status-analysis" />
		<xsl:call-template name="confers-power-analysis" />
		<xsl:call-template name="match-analysis" />
		<xsl:apply-templates select="/" mode="other-analysis" />
	</otherAnalysis>
</xsl:template>


<!-- temporal data -->

<xsl:function name="local:make-period-id" as="xs:string">
	<xsl:param name="restrict-start-date" as="xs:string?" />
	<xsl:param name="restrict-end-date" as="xs:string?" />
	<xsl:variable name="parts" as="xs:string*">
		<xsl:text>period-</xsl:text>
		<xsl:if test="exists($restrict-start-date)">
			<xsl:text>from-</xsl:text>
			<xsl:value-of select="$restrict-start-date" />
		</xsl:if>
		<xsl:if test="exists($restrict-start-date) and exists($restrict-end-date)">
			<xsl:text>-</xsl:text>
		</xsl:if>
		<xsl:if test="exists($restrict-end-date)">
			<xsl:text>to-</xsl:text>
			<xsl:value-of select="$restrict-end-date" />
		</xsl:if>
	</xsl:variable>
	<xsl:value-of select="string-join($parts, '')" />
</xsl:function>

<xsl:template name="temporal-data">
	<xsl:if test="exists($elements-with-restrict-dates)">
		<temporalData source="#">
			<xsl:for-each-group select="$elements-with-restrict-dates" group-by="concat(@RestrictStartDate, '-', @RestrictEndDate)">
				<xsl:sort select="concat(@RestrictStartDate, '-', @RestrictEndDate)" />
				<temporalGroup>
					<xsl:attribute name="eId">
						<xsl:text>period-</xsl:text>
						<xsl:if test="exists(@RestrictStartDate)">
							<xsl:text>from-</xsl:text>
							<xsl:value-of select="@RestrictStartDate" />
						</xsl:if>
						<xsl:if test="exists(@RestrictStartDate) and exists(@RestrictEndDate)">
							<xsl:text>-</xsl:text>
						</xsl:if>
						<xsl:if test="exists(@RestrictEndDate)">
							<xsl:text>to-</xsl:text>
							<xsl:value-of select="@RestrictEndDate" />
						</xsl:if>
					</xsl:attribute>
					<timeInterval>
						<xsl:if test="@RestrictStartDate">
							<xsl:attribute name="start">
								<xsl:text>#date-</xsl:text>
								<xsl:value-of select="@RestrictStartDate" />
							</xsl:attribute>
						</xsl:if>
						<xsl:if test="@RestrictEndDate">
							<xsl:attribute name="end">
								<xsl:text>#date-</xsl:text>
								<xsl:value-of select="@RestrictEndDate" />
							</xsl:attribute>
						</xsl:if>
						<xsl:attribute name="refersTo">
							<xsl:text>#</xsl:text>
						</xsl:attribute>
					</timeInterval>
				</temporalGroup>
			</xsl:for-each-group>
		</temporalData>
	</xsl:if>
</xsl:template>

<xsl:template name="temporal-restrictions">
	<xsl:for-each select="$elements-with-restrict-dates">
		<xsl:if test="not(self::ukl:P1group and child::ukl:P1[@RestrictStartDate or @RestrictEndDate])"> <!-- asp/2000/1/2018-03-29 -->
			<restriction>
				<xsl:if test="not(self::ukl:Legislation)">
					<xsl:attribute name="href">
						<xsl:text>#</xsl:text>
						<xsl:value-of select="local:get-internal-id-for-ref(.)" />
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="refersTo">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="local:make-period-id(@RestrictStartDate, @RestrictEndDate)" />
				</xsl:attribute>
				<xsl:attribute name="type">
					<xsl:text>jurisdiction</xsl:text>
				</xsl:attribute>
			</restriction>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<!-- references -->

<xsl:template name="references">
	<references source="#">
		<xsl:for-each-group select="SecondaryMetadata/Laid" group-by="@Class">
			<xsl:apply-templates select="." mode="tlc-organization" />
		</xsl:for-each-group>
		<xsl:apply-templates select="PrimaryMetadata/EnactmentDate" mode="tlc-event" />
		<xsl:apply-templates select="SecondaryMetadata/(Sifted | Made | Laid | ComingIntoForce)" mode="tlc-event" />
		<xsl:apply-templates select="EUMetadata/EnactmentDate | EUMetadata/ComingIntoForce" mode="tlc-event" />
		<xsl:call-template name="extent-locations" />
		<xsl:call-template name="status-concepts" />
	</references>
</xsl:template>


<!-- extent -->

<xsl:function name="local:make-extent-id" as="xs:string">
	<xsl:param name="value" as="xs:string" />
	<xsl:value-of select="concat('extent-', lower-case(replace($value, '\.', '')))" />
</xsl:function>

<xsl:template name="extent-restrictions">
	<xsl:for-each select="$elements-with-restrict-extent">
		<restriction>
			<xsl:if test="not(self::ukl:Legislation)">
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="local:get-internal-id-for-ref(.)" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="refersTo">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="local:make-extent-id(@RestrictExtent)" />
			</xsl:attribute>
			<xsl:attribute name="type">
				<xsl:text>jurisdiction</xsl:text>
			</xsl:attribute>
		</restriction>
	</xsl:for-each>
</xsl:template>

<xsl:template name="extent-locations">
	<xsl:for-each-group select="$elements-with-restrict-extent" group-by="local:make-extent-id(@RestrictExtent)">
		<TLCLocation>
			<xsl:attribute name="eId">
				<xsl:value-of select="local:make-extent-id(@RestrictExtent)" />
			</xsl:attribute>
			<xsl:attribute name="href"></xsl:attribute>
			<xsl:attribute name="showAs">
				<xsl:value-of select="@RestrictExtent" />
			</xsl:attribute>
		</TLCLocation>
	</xsl:for-each-group>
</xsl:template>


<!-- status, confers power, match -->

<xsl:function name="local:make-status-id" as="xs:string">
	<xsl:param name="value" as="xs:string" />
	<xsl:value-of select="concat('status-', lower-case($value))" />
</xsl:function>

<xsl:template name="status-analysis">
	<xsl:for-each select="$elements-with-status">
		<xsl:if test="not(self::ukl:P1group and child::ukl:P1[@Status])"> <!-- asp/2001/8/2011-04-01 -->
			<uk:status>
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="local:get-internal-id-for-ref(.)" />
				</xsl:attribute>
				<xsl:attribute name="refersTo">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="local:make-status-id(@Status)" />
				</xsl:attribute>
			</uk:status>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template name="status-concepts">
	<xsl:for-each-group select="$elements-with-status" group-by="@Status">
		<TLCConcept>
			<xsl:attribute name="eId">
				<xsl:value-of select="local:make-status-id(@Status)" />
			</xsl:attribute>
			<xsl:attribute name="href"></xsl:attribute>
			<xsl:attribute name="showAs">
				<xsl:value-of select="@Status" />
			</xsl:attribute>
		</TLCConcept>
	</xsl:for-each-group>
</xsl:template>

<xsl:template name="confers-power-analysis">
	<xsl:for-each select="$elements-with-confers-power">
		<xsl:if test="not(self::ukl:P1group and child::ukl:P1[@ConfersPower])"> <!-- asp/2010/2/2014-08-01 -->
			<uk:confersPower>
				<xsl:attribute name="href">
					<xsl:text>#</xsl:text>
					<xsl:value-of select="local:get-internal-id-for-ref(.)" />
				</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="@ConfersPower" />
				</xsl:attribute>
			</uk:confersPower>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template name="match-analysis">
	<xsl:for-each select="$elements-with-match">
		<uk:match>
			<xsl:attribute name="href">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="local:get-internal-id-for-ref(.)" />
			</xsl:attribute>
			<xsl:attribute name="value">
				<xsl:value-of select="@Match" />
			</xsl:attribute>
		</uk:match>
	</xsl:for-each>
</xsl:template>

</xsl:transform>
