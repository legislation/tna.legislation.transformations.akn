<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl ukm uk local">

<xsl:variable name="work-date" as="item()?">
	<xsl:variable name="frbr" as="xs:string" select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRdate[1]/@date" />
	<xsl:choose>
		<xsl:when test="starts-with(string($frbr), '9999-')">
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:when test="$frbr castable as xs:date">
			<xsl:sequence select="xs:date($frbr)" />
		</xsl:when>
		<xsl:when test="$frbr castable as xs:dateTime">
			<xsl:sequence select="xs:dateTime($frbr)" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:template name="metadata">
	<Metadata xmlns="http://www.legislation.gov.uk/namespaces/metadata" xmlns:dc="http://purl.org/dc/elements/1.1/">
		<xsl:if test="exists($doc-long-id)">
			<dc:identifier>
				<xsl:value-of select="$doc-long-id" />
				<!-- MR 20230331: LEGDEV-5238 c/o as identifiers are required not URI -->
<!--				<xsl:if test="exists($doc-version)">
					<xsl:text>/</xsl:text>
					<xsl:value-of select="$doc-version" />
				</xsl:if>-->
			</dc:identifier>
		</xsl:if>
		<dc:title>
			<xsl:value-of select="$doc-title" />
		</dc:title>
		<dc:modified>
			<xsl:value-of select="adjust-date-to-timezone(current-date(), ())" />
		</dc:modified>
		<xsl:choose>
			<xsl:when test="$doc-category = 'primary'">
				<xsl:call-template name="primary-metadata" />
			</xsl:when>
			<xsl:when test="$doc-category = 'secondary'">
				<xsl:call-template name="secondary-metadata" />
			</xsl:when>
			<xsl:when test="$doc-category = 'euretained'">
				<xsl:call-template name="eu-metadata" />
			</xsl:when>
		</xsl:choose>
	</Metadata>
</xsl:template>

<xsl:template name="primary-metadata">
	<PrimaryMetadata xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<DocumentClassification>
			<DocumentCategory Value="primary" />
			<DocumentMainType Value="{ $doc-long-type }" />
			<DocumentStatus>
				<xsl:attribute name="Value">
					<xsl:choose>
						<xsl:when test="$doc-version = 'enacted'">
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
		<EnactmentDate Date="{ if (exists($work-date)) then substring(string($work-date), 1, 10) else $ldapp-assent-date }" />
		<xsl:for-each select="/akomaNtoso/*/meta/proprietary//ukm:ISBN">
			<ISBN Value="{ @Value }" />
		</xsl:for-each>
	</PrimaryMetadata>
</xsl:template>

<xsl:template name="secondary-metadata">
	<SecondaryMetadata xmlns="http://www.legislation.gov.uk/namespaces/metadata">
		<DocumentClassification>
			<DocumentCategory Value="secondary" />
			<DocumentMainType Value="{ $doc-long-type }" />
			<DocumentStatus>
				<xsl:attribute name="Value">
					<xsl:choose>
						<xsl:when test="$doc-short-type = $draft-secondary-short-types">
							<xsl:text>draft</xsl:text>
						</xsl:when>
						<xsl:when test="$doc-version = 'made'">
							<xsl:text>final</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>revised</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</DocumentStatus>
			<DocumentMinorType Value="{ $doc-subtype }" />
		</DocumentClassification>
		<Year Value="{ $doc-year }" />

		<xsl:if test="exists($doc-number)">
			<Number Value="{ $doc-number }" />
		</xsl:if>
		<xsl:variable name="lgu-alt-numbers" as="xs:string*">
			<xsl:sequence select="/akomaNtoso/*/meta/identification/FRBRWork/FRBRnumber/@value[matches(.,'^(C|L|S|NI|W|Cy)\. \d+$')]" />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="exists($lgu-alt-numbers)">
				<xsl:for-each select="$lgu-alt-numbers">
					<xsl:variable name="parts" as="xs:string*" select="tokenize(., '\. ')" />
					<AlternativeNumber Category="{ $parts[1] }" Value="{ $parts[2] }" />
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="exists($ldapp-doc-subsid-numbers)">
				<xsl:for-each select="$ldapp-doc-subsid-numbers">
					<xsl:variable name="parts" as="xs:string*" select="tokenize(., ' ')" />
					<AlternativeNumber Category="{ $parts[1] }" Value="{ $parts[2] }" />
				</xsl:for-each>
			</xsl:when>
		</xsl:choose>

		<xsl:for-each select="/akomaNtoso/*/preface/container[@name='dates']/block[@name=('siftedDate','otherDate')][docDate]">
			<Sifted>
				<xsl:attribute name="Date">
					<xsl:value-of select="substring(docDate/@date, 1, 10)" />
				</xsl:attribute>
				<xsl:if test="docDate/@date castable as xs:dateTime">
					<xsl:attribute name="Time">
						<xsl:value-of select="xs:time(xs:dateTime(docDate/@date))"/>
					</xsl:attribute>
				</xsl:if>
			</Sifted>
		</xsl:for-each>

		<xsl:if test="exists($ldapp-made-date) or exists($work-date)">
			<Made>
				<xsl:variable name="made-date">
					<xsl:choose>
						<xsl:when test="exists($ldapp-made-date)">
							<xsl:sequence select="$ldapp-made-date" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="$work-date" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:attribute name="Date">
					<xsl:value-of select="substring(string($made-date), 1, 10)" />
				</xsl:attribute>
				<xsl:if test="$made-date instance of xs:dateTime">
					<xsl:attribute name="Time">
						<xsl:value-of select="xs:time($made-date)"/>
					</xsl:attribute>
				</xsl:if>
			</Made>
		</xsl:if>

		<xsl:for-each select="/akomaNtoso/*/preface/container[@name='dates']/block[@name='laidDate'][docDate]">
			<Laid>
				<xsl:attribute name="Date">
					<xsl:value-of select="substring(docDate/@date, 1, 10)" />
				</xsl:attribute>
				<xsl:if test="docDate/@date castable as xs:dateTime">
					<xsl:attribute name="Time">
						<xsl:value-of select="xs:time(xs:dateTime(docDate/@date))"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="Class">
					<xsl:variable name="event-ref" as="element(eventRef)?" select="key('id', substring(@refersTo, 2))" />
					<xsl:variable name="source" as="element(TLCOrganization)?" select="key('id', substring($event-ref/@source, 2))" />
					<xsl:choose>
						<xsl:when test="exists($source)">
							<xsl:value-of select="$source/@showAs" />
						</xsl:when>
						<xsl:when test="$doc-short-type = ('uksi', 'ukdsi', 'nisi', 'uksro')">
							<xsl:text>UnitedKingdomParliament</xsl:text>
						</xsl:when>
						<xsl:when test="$doc-short-type = ('ssi', 'sdsi')">
							<xsl:text>ScottishParliament</xsl:text>
						</xsl:when>
						<xsl:when test="$doc-short-type = ('wsi', 'wdsi')">
							<xsl:text>WelshAssembly</xsl:text>
						</xsl:when>
						<xsl:when test="$doc-short-type = ('nisr', 'nidsr', 'nisro')">
							<xsl:text>NorthernIrelandAssembly</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</Laid>
		</xsl:for-each>

 		<xsl:variable name="cif-dates" as="element(block)*" select="/akomaNtoso/*/preface/container[@name='dates']/block[@name='commenceDate'][docDate]" />
		<xsl:if test="exists($cif-dates)">
			<ComingIntoForce>
				<xsl:for-each select="$cif-dates">
					<DateTime>
						<xsl:attribute name="Date">
							<xsl:value-of select="substring(docDate/@date, 1, 10)" />
						</xsl:attribute>
						<xsl:if test="docDate/@date castable as xs:dateTime">
							<xsl:attribute name="Time">
								<xsl:value-of select="xs:time(xs:dateTime(docDate/@date))"/>
							</xsl:attribute>
						</xsl:if>
					</DateTime>
				</xsl:for-each>
			</ComingIntoForce>
		</xsl:if>

		<xsl:for-each select="/akomaNtoso/*/meta/proprietary//ukm:ISBN">
			<ISBN Value="{ @Value }" />
		</xsl:for-each>
	</SecondaryMetadata>
</xsl:template>


<!-- start and end -->

<xsl:key name="temporal-restriction" match="restriction[starts-with(@refersTo, '#period')]" use="substring(@href, 2)" />

<xsl:template name="add-restrict-date-attrs">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="restriction" as="element(restriction)?">
		<xsl:choose>
			<xsl:when test="exists($from/@eId)">
				<xsl:sequence select="key('temporal-restriction', $from/@eId)[1]" /> <!-- [1] protects against duplicate ids -->
			</xsl:when>
			<xsl:when test="$from/parent::akomaNtoso">
				<xsl:sequence select="key('temporal-restriction', '')[1]" />	<!-- for [1] see ukpga/Geo5/2-3/30 -->
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($restriction)">
		<xsl:variable name="period-id" as="xs:string" select="substring($restriction/@refersTo, 2)" />
		<xsl:variable name="period" as="element(temporalGroup)" select="key('id', $period-id)" />
		<xsl:variable name="interval" as="element(timeInterval)" select="$period/timeInterval" />
		<xsl:if test="exists($interval/@start)">
			<xsl:attribute name="RestrictStartDate">
				<xsl:value-of select="substring($interval/@start, 7)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists($interval/@end)">
			<xsl:attribute name="RestrictEndDate">
				<xsl:value-of select="substring($interval/@end, 7)" />
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>


<!-- extent -->

<xsl:key name="extent-restriction" match="restriction[starts-with(@refersTo, '#extent')]" use="substring(@href, 2)" />

<xsl:template name="add-restrict-extent-attr">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="restriction" as="element(restriction)?">
		<xsl:choose>
			<xsl:when test="exists($from/@eId)">
				<xsl:sequence select="key('extent-restriction', $from/@eId)[1]" />	<!-- [1] protects against duplicate ids -->
			</xsl:when>
			<xsl:when test="$from/parent::akomaNtoso">
				<xsl:sequence select="key('extent-restriction', '')[1]" />	<!-- [1] for id="" in ukla/Geo6/14/3 -->
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($restriction)">
		<xsl:variable name="extent-id" as="xs:string" select="substring($restriction/@refersTo, 2)" />
		<xsl:variable name="extent" as="element(TLCLocation)" select="key('id', $extent-id)" />
		<xsl:attribute name="RestrictExtent">
			<xsl:value-of select="$extent/@showAs" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>


<!-- status -->

<xsl:key name="status" match="uk:status" use="substring(@href, 2)" />

<xsl:template name="add-status-attribute">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="status" as="element(uk:status)?">
		<xsl:choose>
			<xsl:when test="exists($from/@eId)">
				<xsl:sequence select="key('status', $from/@eId)[1]" />	<!-- [1] protects against duplicate ids -->
			</xsl:when>
			<xsl:when test="$from/parent::akomaNtoso">
				<xsl:sequence select="key('status', '')" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($status)">
		<xsl:variable name="status-id" as="xs:string" select="substring($status/@refersTo, 2)" />
		<xsl:variable name="status" as="element(TLCConcept)" select="key('id', $status-id)" />
		<xsl:attribute name="Status">
			<xsl:value-of select="$status/@showAs" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>


<!-- confers power -->

<xsl:key name="confers-power" match="uk:confersPower" use="substring(@href, 2)" />

<xsl:template name="add-confers-power-attribute">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="confers-power" as="element(uk:confersPower)?">
		<xsl:choose>
			<xsl:when test="exists($from/@eId)">
				<xsl:sequence select="key('confers-power', $from/@eId)[1]" />	<!--  -->
			</xsl:when>
			<xsl:when test="$from/parent::akomaNtoso">
				<xsl:sequence select="key('confers-power', '')[1]" />	<!--  -->
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($confers-power)">
		<xsl:attribute name="ConfersPower">
			<xsl:value-of select="$confers-power/@value" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>


<!-- match -->

<xsl:key name="match" match="uk:match" use="substring(@href, 2)" />

<xsl:template name="add-match-attribute">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="match" as="element(uk:match)?">
		<xsl:choose>
			<xsl:when test="exists($from/@eId)">
				<xsl:sequence select="key('match', $from/@eId)[1]" />	<!-- [1] protects against duplicate ids -->
			</xsl:when>
			<xsl:when test="$from/parent::akomaNtoso">
				<xsl:sequence select="key('match', '')" />
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="exists($match)">
		<xsl:attribute name="Match">
			<xsl:value-of select="$match/@value" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>



<!--  -->

<xsl:template name="add-fragment-attributes">
	<xsl:param name="from" as="element()" select="." />
	<xsl:param name="including-id" as="xs:boolean" select="true()" />
	<xsl:if test="$including-id">
		<xsl:call-template name="add-id-if-necessary">
			<xsl:with-param name="e" select="$from" />
		</xsl:call-template>
	</xsl:if>
	<xsl:call-template name="add-restrict-extent-attr">
		<xsl:with-param name="from" select="$from" />
	</xsl:call-template>
	<xsl:call-template name="add-restrict-date-attrs">
		<xsl:with-param name="from" select="$from" />
	</xsl:call-template>
	<xsl:call-template name="add-status-attribute">
		<xsl:with-param name="from" select="$from" />
	</xsl:call-template>
	<xsl:call-template name="add-confers-power-attribute">
		<xsl:with-param name="from" select="$from" />
	</xsl:call-template>
	<xsl:call-template name="add-match-attribute">
		<xsl:with-param name="from" select="$from" />
	</xsl:call-template>
</xsl:template>


</xsl:transform>
