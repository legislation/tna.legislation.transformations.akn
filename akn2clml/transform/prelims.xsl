<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs local">

<xsl:template name="prelims">
	<xsl:param name="context" as="xs:string+" tunnel="yes" />
	<xsl:variable name="head" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="$head = 'Primary'">
			<PrimaryPrelims>
				<xsl:variable name="child-context" as="xs:string*" select="('PrimaryPrelims', $context)" />
				<xsl:call-template name="add-fragment-attributes">
					<xsl:with-param name="from" select="preface" />
				</xsl:call-template>
				<xsl:choose>
					<xsl:when test="$doc-short-type = 'asp'">	<!-- move date of enactment to end -->
						<xsl:variable name="date-of-enactment" as="element()*" select="preface/block[@name=('dateOfEnactment','DateOfEnactment')] | preface/p[exists(docDate/@class='assentDate')]" />
						<xsl:apply-templates select="preface/* except $date-of-enactment">
							<xsl:with-param name="context" select="$child-context" tunnel="yes" />
						</xsl:apply-templates>
						<xsl:apply-templates select="$date-of-enactment">
							<xsl:with-param name="context" select="$child-context" tunnel="yes" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="preface/*">
							<xsl:with-param name="context" select="$child-context" tunnel="yes" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="preamble">
					<xsl:with-param name="context" select="$child-context" tunnel="yes" />
				</xsl:apply-templates>
			</PrimaryPrelims>
		</xsl:when>
		<xsl:when test="$head = 'Secondary'">
			<xsl:variable name="child-context" as="xs:string*" select="('SecondaryPrelims', $context)" />
			<SecondaryPrelims>
				<xsl:call-template name="add-fragment-attributes">
					<xsl:with-param name="from" select="preface" />
				</xsl:call-template>
				<xsl:apply-templates select="preface/*">
					<xsl:with-param name="context" select="$child-context" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:apply-templates select="preamble">
					<xsl:with-param name="context" select="$child-context" tunnel="yes" />
				</xsl:apply-templates>
			</SecondaryPrelims>
		</xsl:when>
		<xsl:when test="$head = 'EURetained'">
			<xsl:call-template name="eu-prelims" />
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="preface/block[@name='title']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Title>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Title', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Title>
</xsl:template>

<xsl:template match="coverPage/block[@name='number'] | preface/block[@name='number']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Number>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Number', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</Number>
</xsl:template>

<xsl:template match="preface/block[@name=('dateOfEnactment','DateOfEnactment')] | preface/p[exists(docDate/@class='assentDate')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<DateOfEnactment>
		<DateText>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="('DateText', 'DateOfEnactment', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</DateText>
	</DateOfEnactment>
</xsl:template>

<xsl:template match="longTitle">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="local:get-applicable-doc-class(.) = 'euretained'">
			<MultilineTitle>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('MultilineTitle', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</MultilineTitle>
		</xsl:when>
		<xsl:otherwise>
			<LongTitle>
				<xsl:apply-templates select="*/node()">
					<xsl:with-param name="context" select="('LongTitle', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</LongTitle>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- secondary -->

<xsl:template match="block[@name='banner']" />

<xsl:template match="container[@name=('correction')]">
	<Correction>
		<xsl:call-template name="uncollapse-para" />
	</Correction>
</xsl:template>

<xsl:template match="block[@name=('correctionRubric')]">
	<Correction>
		<Para>
			<Text>
				<xsl:apply-templates />
			</Text>
		</Para>
	</Correction>
</xsl:template>

<!-- <xsl:template match="container[@name='draft']">
	<Draft>
		<xsl:call-template name="uncollapse-para" />
	</Draft>
</xsl:template> -->

<xsl:template match="container[@name='subjects']">
	<SubjectInformation>
		<xsl:apply-templates />
	</SubjectInformation>
</xsl:template>

<xsl:template match="container[@name='subject']">
	<Subject>
		<xsl:apply-templates />
	</Subject>
</xsl:template>

<xsl:template match="container[@name='subject']/block[@name=('title','subject')] | container[@name='subject']/p">
	<Title>
		<xsl:apply-templates />
	</Title>
</xsl:template>

<xsl:template match="container[@name='subject']/block[@name=('subtitle','subsubject')]">
	<Subtitle>
		<xsl:apply-templates />
	</Subtitle>
</xsl:template>

<xsl:template match="container[@name='resolution']">
	<Resolution>
		<Para>
			<xsl:apply-templates />
		</Para>
	</Resolution>
</xsl:template>

<xsl:template match="block[@name=('approved','approval')]">
	<Approved>
		<xsl:apply-templates />
	</Approved>
</xsl:template>

<xsl:template match="concept">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="container[@name='dates']">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="block[@name=('siftedDate','otherDate')]">
	<SiftedDate>
		<xsl:apply-templates />
	</SiftedDate>
</xsl:template>

<xsl:template match="block[@name='madeDate']">
	<MadeDate>
		<xsl:apply-templates />
		<xsl:if test="empty(docDate)">
			<DateText />
		</xsl:if>
	</MadeDate>
</xsl:template>

<xsl:template match="block[@name=('laidDraft','laidInDraft')]">
	<LaidDraft>
		<xsl:apply-templates />
	</LaidDraft>
</xsl:template>

<xsl:template match="block[@name='laidDate']">
	<LaidDate>
		<xsl:apply-templates />
	</LaidDate>
</xsl:template>

<xsl:template match="block[@name=('commenceDate')][empty(preceding-sibling::block[@name=('commenceDate')])]">
	<ComingIntoForce>
		<xsl:choose>
			<xsl:when test="empty(following-sibling::block[@name=('commenceDate')])">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:when test="exists(docDate)"><!-- and exists(following-sibling::block[@name=('commenceDate')]) -->
				<Text />
				<xsl:apply-templates select="." mode="clauses" />
				<xsl:apply-templates select="following-sibling::block[@name=('commenceDate')]" mode="clauses" />
			</xsl:when>
			<xsl:otherwise> <!-- just a heading -->
				<xsl:apply-templates />
				<xsl:apply-templates select="following-sibling::block[@name=('commenceDate')]" mode="clauses" />
			</xsl:otherwise>
		</xsl:choose>
	</ComingIntoForce>
</xsl:template>

<xsl:template match="block[@name=('commenceDate')][exists(preceding-sibling::block[@name=('commenceDate')])]">
</xsl:template>

<xsl:template match="block[@name=('commenceDate')]" mode="clauses">
	<ComingIntoForceClauses>
		<xsl:apply-templates />
	</ComingIntoForceClauses>
</xsl:template>

<xsl:template match="block[@name=('siftedDate','madeDate','laidDraft','laidInDraft','laidDate','commenceDate','otherDate')]/span">
	<Text>
		<xsl:apply-templates />
	</Text>
</xsl:template>

<xsl:template match="block[@name=('siftedDate','madeDate','laidDate','commenceDate','otherDate')]/docDate">
	<DateText>
		<xsl:apply-templates />
	</DateText>
</xsl:template>


<!-- preamble -->

<xsl:template match="preamble">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="context1" as="xs:string" select="$context[1]" />
	<xsl:choose>
		<xsl:when test="$context1 = 'PrimaryPrelims'">
			<PrimaryPreamble>
				<xsl:variable name="enacting-text" as="element()?" select="formula[1]" />
				<xsl:choose>
					<xsl:when test="exists($enacting-text)">
						<xsl:variable name="intro" as="element()*" select="if (exists($enacting-text)) then $enacting-text/preceding-sibling::* else *" />
						<xsl:if test="exists($intro)">
							<IntroductoryText>
								<xsl:apply-templates select="$intro">
									<xsl:with-param name="context" select="('IntroductoryText', 'PrimaryPreamble', $context)" tunnel="yes" />
								</xsl:apply-templates>
							</IntroductoryText>
						</xsl:if>
						<xsl:apply-templates select="$enacting-text">
							<xsl:with-param name="context" select="('PrimaryPreamble', $context)" tunnel="yes" />
						</xsl:apply-templates>
						<xsl:apply-templates select="$enacting-text/following-sibling::*">
							<xsl:with-param name="context" select="('PrimaryPreamble', $context)" tunnel="yes" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<IntroductoryText>
							<xsl:apply-templates>
								<xsl:with-param name="context" select="('IntroductoryText', 'PrimaryPreamble', $context)" tunnel="yes" />
							</xsl:apply-templates>
						</IntroductoryText>
						<EnactingTextOmitted />
					</xsl:otherwise>
				</xsl:choose>
			</PrimaryPreamble>
		</xsl:when>
		<xsl:when test="$context1 = 'SecondaryPrelims'">
			<SecondaryPreamble>
				<xsl:apply-templates select="container[@name=('royalPresence','royal')]" />
				<xsl:variable name="enacting-text" as="element()?" select="formula[1]" />
				<xsl:choose>
					<xsl:when test="empty($enacting-text)">	<!-- resolution only -->
						<xsl:apply-templates>
							<xsl:with-param name="context" select="('SecondaryPreamble', $context)" tunnel="yes" />
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="intro" as="element()*" select="$enacting-text/preceding-sibling::*[not(self::container[@name=('royalPresence','royal')])]" />
						<xsl:if test="exists($intro)">
							<IntroductoryText>
								<xsl:apply-templates select="$intro">
									<xsl:with-param name="context" select="('IntroductoryText', 'SecondaryPreamble', $context)" tunnel="yes" />
								</xsl:apply-templates>
							</IntroductoryText>
						</xsl:if>
						<xsl:apply-templates select="$enacting-text">
							<xsl:with-param name="context" select="('SecondaryPreamble', $context)" tunnel="yes" />
						</xsl:apply-templates>
						<xsl:apply-templates select="$enacting-text/following-sibling::*">
							<xsl:with-param name="context" select="('SecondaryPreamble', $context)" tunnel="yes" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</SecondaryPreamble>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="uncollapse-para">
	<xsl:choose>
		<xsl:when test="every $child in * satisfies $child/self::p">
			<Para>
				<xsl:apply-templates />
			</Para>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="container[@name=('royalPresence','royal')]">
	<RoyalPresence>
		<xsl:call-template name="uncollapse-para" />
	</RoyalPresence>
</xsl:template>

<xsl:template match="block[@name='proceduralRubric']">
	<Draft>
		<Para>
			<Text>
				<xsl:apply-templates />
			</Text>
		</Para>
	</Draft>
</xsl:template>

<xsl:template match="preamble/blockContainer[empty(child::num)]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<P>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('P', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</P>
</xsl:template>

<xsl:template match="formula[@name=('enactingText','EnactingText','enactingWords')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<EnactingText>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EnactingText', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EnactingText>
</xsl:template>

</xsl:transform>
