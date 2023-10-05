<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukm dc local">


<!-- keys -->

<xsl:key name="id" match="*" use="@eId" />

<xsl:key name="guid" match="*" use="@GUID" />

<xsl:key name="tlc" match="TLCConcept | TLCProcess" use="@eId" />


<!-- functions -->

<xsl:variable name="long-types" as="element()">
	<longTypes
		ukpga = "UnitedKingdomPublicGeneralAct"
		ukla = "UnitedKingdomLocalAct"
		asp = "ScottishAct"
		asc = "WelshParliamentAct"
		anaw = "WelshNationalAssemblyAct"
		mwa = "WelshAssemblyMeasure"
		ukcm = "UnitedKingdomChurchMeasure"
		nia = "NorthernIrelandAct"
		aosp = "ScottishOldAct"
		aep = "EnglandAct"
		aip = "IrelandAct"
		apgb = "GreatBritainAct"
		mnia = "NorthernIrelandAssemblyMeasure"
		apni = "NorthernIrelandParliamentAct"
		uksi = "UnitedKingdomStatutoryInstrument"
		wsi = "WelshStatutoryInstrument"
		ssi = "ScottishStatutoryInstrument"
		nisi = "NorthernIrelandOrderInCouncil"
		nisr = "NorthernIrelandStatutoryRule"
		ukci = "UnitedKingdomChurchInstrument"
		ukmd = "UnitedKingdomMinisterialDirection"
		ukmo = "UnitedKingdomMinisterialOrder"
		uksro = "UnitedKingdomStatutoryRuleOrOrder"
		nisro = "NorthernIrelandStatutoryRuleOrOrder"
		ukdpb = "UnitedKingdomDraftPublicBill"
		ukdsi = "UnitedKingdomDraftStatutoryInstrument"
		sdsi = "ScottishDraftStatutoryInstrument"
		nidsr = "NorthernIrelandDraftStatutoryRule"
		eur = "EuropeanUnionRegulation"
		eudn = "EuropeanUnionDecision"
		eudr = "EuropeanUnionDirective"
		eut = "EuropeanUnionTreaty"
	/>
</xsl:variable>

<xsl:variable name="short-types" as="element()">
	<shortTypes
		UnitedKingdomPublicGeneralAct = "ukpga"
		UnitedKingdomLocalAct = "ukla"
		ScottishAct = "asp"
		WelshParliamentAct = "asc"
		WelshNationalAssemblyAct = "anaw"
		WelshAssemblyMeasure = "mwa"
		UnitedKingdomChurchMeasure = "ukcm"
		NorthernIrelandAct = "nia"
		ScottishOldAct = "aosp"
		EnglandAct = "aep"
		IrelandAct = "aip"
		GreatBritainAct = "apgb"
		NorthernIrelandAssemblyMeasure = "mnia"
		NorthernIrelandParliamentAct = "apni"
		UnitedKingdomStatutoryInstrument = "uksi"
		WelshStatutoryInstrument = "wsi"
		ScottishStatutoryInstrument = "ssi"
		NorthernIrelandOrderInCouncil = "nisi"
		NorthernIrelandStatutoryRule = "nisr"
		UnitedKingdomChurchInstrument = "ukci"
		UnitedKingdomMinisterialDirection = "ukmd"
		UnitedKingdomMinisterialOrder = "ukmo"
		UnitedKingdomStatutoryRuleOrOrder = "uksro"
		NorthernIrelandStatutoryRuleOrOrder = "nisro"
		UnitedKingdomDraftPublicBill = "ukdpb"
		UnitedKingdomDraftStatutoryInstrument = "ukdsi"
		ScottishDraftStatutoryInstrument = "sdsi"
		NorthernIrelandDraftStatutoryRule = "nidsr"
		EuropeanUnionRegulation = "eur"
		EuropeanUnionDecision = "eudn"
		EuropeanUnionDirective = "eudr"
		EuropeanUnionTreaty = "eut"
	/>
</xsl:variable>

<xsl:variable name="primary-short-types" as="xs:string*" select="
	( 'ukpga', 'ukla', 'asp', 'asc', 'anaw', 'mwa', 'ukcm', 'nia', 'aosp', 'aep', 'aip', 'apgb', 'mnia', 'apni' )
" />

<xsl:variable name="secondary-short-types" as="xs:string*" select="
	( 'uksi', 'wsi', 'ssi', 'nisi', 'nisr', 'ukci', 'ukmd', 'ukmo', 'uksro', 'nisro', 'ukdpb', 'ukdsi', 'sdsi', 'nidsr' )
" />

<xsl:variable name="draft-secondary-short-types" as="xs:string*" select="
	( 'ukdpb', 'ukdsi', 'sdsi', 'nidsr' )
" />

<xsl:variable name="eu-short-types" as="xs:string*" select="
	( 'eur', 'eudn', 'eudr', 'eut' )
" />

<xsl:function name="local:long-type-from-short" as="xs:string">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:value-of select="$long-types/@*[name()=$short-type]" />
</xsl:function>

<xsl:function name="local:category-from-short-type" as="xs:string?">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$short-type = $primary-short-types">
			<xsl:text>primary</xsl:text>
		</xsl:when>
		<xsl:when test="$short-type = $secondary-short-types">
			<xsl:text>secondary</xsl:text>
		</xsl:when>
		<xsl:when test="$short-type = $eu-short-types">
			<xsl:text>euretained</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>


<!-- variables -->

<xsl:variable name="doc-short-type" as="xs:string" select="/akomaNtoso/*/@name" />

<xsl:variable name="doc-long-type" as="xs:string">
	<xsl:value-of select="local:long-type-from-short($doc-short-type)" />
</xsl:variable>

<xsl:variable name="doc-category" as="xs:string">
	<xsl:value-of select="local:category-from-short-type($doc-short-type)" />
</xsl:variable>

<xsl:variable name="doc-subtype" as="xs:string?">
	<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRsubtype/@value" />
	<xsl:variable name="value" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$frbr = ()">
				<xsl:value-of select="$frbr" />
			</xsl:when>
			<xsl:when test="exists($ldapp-doc-subtype)">
				<xsl:value-of select="$ldapp-doc-subtype" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<!-- order, regulation, rule, scheme, resolution, unknown -->
	<xsl:choose>
		<xsl:when test="$value = ('order', 'Order', 'Order in Council')">
			<xsl:sequence select="'order'" />
		</xsl:when>
		<xsl:when test="$value = ('regulation', 'Regulations')">
			<xsl:sequence select="'regulation'" />
		</xsl:when>
		<xsl:when test="$value = ('rule', 'Rules')">
			<xsl:sequence select="'rule'" />
		</xsl:when>
		<xsl:when test="$value = ('scheme', 'Scheme')">
			<xsl:sequence select="'scheme'" />
		</xsl:when>
		<xsl:when test="$value = ('resolution', 'Resolution', 'Resolution (of Parliament)')">
			<xsl:sequence select="'resolution'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'unknown'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-year" as="xs:integer">
	<xsl:variable name="ukm-year" as="element()?" select="/akomaNtoso/*/meta/proprietary/ukm:Year" />
	<xsl:choose>
		<xsl:when test="exists($ukm-year)">
			<xsl:value-of select="xs:integer($ukm-year/@Value)" />
		</xsl:when>
		<xsl:when test="exists($ldapp-doc-year)">
			<xsl:value-of select="$ldapp-doc-year" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="xs:integer(substring(/akomaNtoso/*/meta/identification/FRBRWork/FRBRdate/@date, 1, 4))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-number" as="xs:string?">
	<xsl:variable name="frbr" as="xs:string?" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRnumber/@value[. castable as xs:integer][1]" />
	<xsl:choose>
		<xsl:when test="exists($frbr)">
			<xsl:sequence select="$frbr" />
		</xsl:when>
		<xsl:when test="exists($ldapp-doc-number)">
			<xsl:sequence select="$ldapp-doc-number" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-title" as="xs:string?">
	<xsl:variable name="short-title" as="element(shortTitle)?" select="(//shortTitle)[1]" />
	<xsl:variable name="doc-title" as="element(docTitle)?" select="(//docTitle)[1]" />
	<xsl:variable name="long-title" as="element(longTitle)?" select="(//longTitle)[1]" />
	<xsl:choose>
		<xsl:when test="exists($ldapp-doc-title)">
			<xsl:value-of select="$ldapp-doc-title" />
		</xsl:when>
		<xsl:when test="exists($short-title)">
			<xsl:value-of select="normalize-space($short-title)" />
		</xsl:when>
		<xsl:when test="exists($doc-title)">
			<xsl:value-of select="normalize-space($doc-title)" />
		</xsl:when>
		<xsl:when test="exists($long-title)">
			<xsl:value-of select="normalize-space($long-title)" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-short-id" as="xs:string?">
	<xsl:if test="exists($doc-number)">
		<xsl:sequence select="concat($doc-short-type, '/', $doc-year, '/', $doc-number)" />
	</xsl:if>
</xsl:variable>

<xsl:variable name="doc-long-id" as="xs:string?">
	<xsl:if test="exists($doc-short-id)">
		<!-- MR 20230331: LEGDEV-5238 add 'id/' as identifiers are required not URI -->
		<xsl:sequence select="concat('http://www.legislation.gov.uk/id/', $doc-short-id)" />
	</xsl:if>
</xsl:variable>

<xsl:variable name="doc-version" as="xs:string?">
	<xsl:variable name="exp-uri" as="xs:string" select="/akomaNtoso/*/meta/identification/FRBRExpression/FRBRthis/@value" />
	<xsl:variable name="uri-version" as="xs:string" select="tokenize($exp-uri, '/')[last()]" />
	<xsl:choose>
		<xsl:when test="$uri-version = ('enacted', 'made', 'adopted')">
			<xsl:sequence select="$uri-version" />
		</xsl:when>
		<xsl:when test="$uri-version castable as xs:date">
			<xsl:sequence select="$uri-version" />
		</xsl:when>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:sequence select="'enacted'" />
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:sequence select="'made'" />
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:sequence select="'adopted'" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

</xsl:transform>
