<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">


<xsl:function name="local:parse-lgu-uri" as="element()?">
	<xsl:param name="uri" as="xs:string" />
	<xsl:analyze-string select="$uri" regex="^https?://www.legislation.gov.uk/(id/)?([a-z]{{3,5}})/(\d{{4}})/(\d+)(/.+)?$">
		<xsl:matching-substring>
			<components xmlns="">
				<xsl:attribute name="Class">
					<xsl:value-of select="local:long-type-from-short(regex-group(2))" />
				</xsl:attribute>
				<xsl:attribute name="Year">
					<xsl:value-of select="regex-group(3)" />
				</xsl:attribute>
				<xsl:attribute name="Number">
					<xsl:value-of select="regex-group(4)" />
				</xsl:attribute>
				<xsl:variable name="section" select="substring(regex-group(5), 2)" />
				<xsl:if test="$section != ''">
					<xsl:attribute name="Section">
						<xsl:value-of select="translate($section, '/', '-')" />
					</xsl:attribute>
				</xsl:if>
			</components>
		</xsl:matching-substring>
	</xsl:analyze-string>
</xsl:function>

<xsl:function name="local:parse-old-eu-uri" as="element()?">
	<xsl:param name="uri" as="xs:string" />
	<xsl:analyze-string select="$uri" regex="^https?://(www.legislation.gov.uk|www.opsi.gov.uk/legislation)/(id/)?european/(regulation|decision|directive)/(\d{{4}})/(\d+)(/.+)?$">
		<xsl:matching-substring>
			<components xmlns="">
				<xsl:attribute name="Class">
					<xsl:choose>
						<xsl:when test="regex-group(3) = 'regulation'">
							<xsl:text>EuropeanUnionRegulation</xsl:text>
						</xsl:when>
						<xsl:when test="regex-group(3) = 'decision'">
							<xsl:text>EuropeanUnionDecision</xsl:text>
						</xsl:when>
						<xsl:when test="regex-group(3) = 'directive'">
							<xsl:text>EuropeanUnionDirective</xsl:text>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="Year">
					<xsl:value-of select="regex-group(4)" />
				</xsl:attribute>
				<xsl:attribute name="Number">
					<xsl:value-of select="regex-group(5)" />
				</xsl:attribute>
				<xsl:if test="normalize-space(regex-group(6))">
					<xsl:attribute name="Section">
						<xsl:value-of select="translate(substring(regex-group(5), 2), '/', '-')" />
					</xsl:attribute>
				</xsl:if>
			</components>
		</xsl:matching-substring>
	</xsl:analyze-string>
</xsl:function>

<xsl:function name="local:parse-uri" as="element()?">
	<xsl:param name="uri" as="xs:string" />
	<xsl:variable name="components" as="element()?" select="local:parse-lgu-uri($uri)" />
	<xsl:sequence select="if (exists($components)) then $components else local:parse-old-eu-uri($uri)" />
</xsl:function>


<xsl:variable name="citations" as="element()*" select="//ref[not(@class='placeholder')] | //rref" />

<xsl:function name="local:make-citation-id" as="xs:string?">
	<xsl:param name="cite" as="element()" />
	<xsl:variable name="index" as="xs:integer?" select="local:get-first-index-of-node($cite, $citations)" />
	<xsl:if test="exists($index)">
		<xsl:value-of select="concat('c', format-number($index, '00000'))" />
	</xsl:if>
</xsl:function>

<xsl:function name="local:make-internal-id-for-ref" as="xs:string?">
	<xsl:param name="ref" as="element(ref)" />
	<xsl:variable name="id" as="xs:string?" select="local:make-internal-id-for-href($ref/@href)" />
	<xsl:choose>
		<xsl:when test="exists($id)">
			<xsl:sequence select="$id" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:make-internal-id-for-ldapp-ref($ref)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="ref[@class='ignore']">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="ref">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element()?" select="local:parse-uri(@href)" />
	<xsl:choose>
		<xsl:when test="exists($components) or (exists(@ukl:Class) and exists(@ukl:Year))">
			<Citation>
				<xsl:attribute name="id">
					<xsl:value-of select="local:make-citation-id(.)" />
				</xsl:attribute>
				<xsl:attribute name="Class">
					<xsl:choose>
						<xsl:when test="exists($components)">
							<xsl:value-of select="$components/@Class" />
						</xsl:when>
						<xsl:when test="exists(@ukl:Class)">
							<xsl:value-of select="@ukl:Class" />
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="Year">
					<xsl:choose>
						<xsl:when test="exists($components)">
							<xsl:value-of select="$components/@Year" />
						</xsl:when>
						<xsl:when test="exists(@ukl:Year)">
							<xsl:value-of select="@ukl:Year" />
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="exists($components) or exists(@ukl:Number)">
					<xsl:attribute name="Number">
						<xsl:choose>
							<xsl:when test="exists($components)">
								<xsl:value-of select="$components/@Number" />
							</xsl:when>
							<xsl:when test="exists(exists(@ukl:Number))">
								<xsl:value-of select="@ukl:Number" />
							</xsl:when>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="exists($components/@Section)">
					<xsl:attribute name="SectionRef">
						<xsl:value-of select="$components/@Section" />
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="URI">
					<xsl:value-of select="@href" />
				</xsl:attribute>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('Citation', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</Citation>
		</xsl:when>
		<xsl:when test="starts-with(@href, '#')">
			<InternalLink>
				<xsl:attribute name="Ref">
					<xsl:sequence select="local:make-internal-id-for-ref(.)" />
				</xsl:attribute>
				<xsl:apply-templates />
			</InternalLink>
		</xsl:when>
		<xsl:otherwise>
			<ExternalLink URI="{ @href }">
				<xsl:apply-templates />
			</ExternalLink>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ref[@class='subref']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element()?" select="local:parse-uri(@href)" />
	<CitationSubRef>
		<xsl:attribute name="id">
			<xsl:value-of select="local:make-citation-id(.)" />
		</xsl:attribute>
		<xsl:if test="exists(@ukl:CitationRef) and exists(key('id', @ukl:CitationRef))">
			<xsl:attribute name="CitationRef">
				<xsl:value-of select="local:make-citation-id(key('id', @ukl:CitationRef)[1])" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists($components/@Section)">
			<xsl:attribute name="SectionRef">
				<xsl:value-of select="$components/@Section" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="URI">
			<xsl:value-of select="@href" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('CitationSubRef', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</CitationSubRef>
</xsl:template>

<xsl:template match="rref">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element()?" select="local:parse-uri(@from)" />
	<xsl:variable name="components2" as="element()?" select="local:parse-uri(@upTo)" />
	<xsl:choose>
		<xsl:when test="exists($components)">
			<Citation>
				<xsl:attribute name="id">
					<xsl:value-of select="local:make-citation-id(.)" />
				</xsl:attribute>
				<xsl:attribute name="Class">
					<xsl:value-of select="$components/@Class" />
				</xsl:attribute>
				<xsl:attribute name="Year">
					<xsl:value-of select="$components/@Year" />
				</xsl:attribute>
				<xsl:attribute name="Number">
					<xsl:value-of select="$components/Number" />
				</xsl:attribute>
				<xsl:attribute name="StartSectionRef">
					<xsl:value-of select="$components/@Section" />
				</xsl:attribute>
				<xsl:attribute name="EndSectionRef">
					<xsl:value-of select="$components2/@Section" />
				</xsl:attribute>
				<xsl:attribute name="URI">
					<xsl:value-of select="@from" />
				</xsl:attribute>
				<xsl:attribute name="UpTo">
					<xsl:value-of select="@upTo" />
				</xsl:attribute>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('Citation', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</Citation>
		</xsl:when>
		<xsl:when test="exists(ref[@href=current()/@from]) and exists(ref[@href=current()/@upTo])">
			<Span>
				<xsl:apply-templates />
			</Span>
		</xsl:when>
		<xsl:when test="starts-with(@from, '#') and exists(ref)">
			<Span>
				<xsl:apply-templates />
			</Span>
		</xsl:when>
		<xsl:when test="starts-with(@from, '#')">
			<InternalLink Ref="{ substring(@from, 2) }" EndRef="{ if (starts-with(@upTo, '#')) then substring(@upTo, 2) else @upTo }">
				<xsl:apply-templates />
			</InternalLink>
		</xsl:when>
		<xsl:otherwise>
			<ExternalLink URI="{ @from }">
				<xsl:apply-templates />
			</ExternalLink>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="rref[@class='subref']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="components" as="element()?" select="local:parse-uri(@from)" />
	<xsl:variable name="components2" as="element()?" select="local:parse-uri(@upTo)" />
	<CitationSubRef>
		<xsl:attribute name="id">
			<xsl:value-of select="local:make-citation-id(.)" />
		</xsl:attribute>
		<xsl:if test="exists(@ukl:CitationRef) and exists(key('id', @ukl:CitationRef))">
			<xsl:attribute name="CitationRef">
				<xsl:value-of select="local:make-citation-id(key('id', @ukl:CitationRef)[1])" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="StartSectionRef">
			<xsl:value-of select="$components/@Section" />
		</xsl:attribute>
		<xsl:attribute name="EndSectionRef">
			<xsl:value-of select="$components2/@Section" />
		</xsl:attribute>
		<xsl:attribute name="URI">
			<xsl:value-of select="@from" />
		</xsl:attribute>
		<xsl:attribute name="UpTo">
			<xsl:value-of select="@upTo" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Citation', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</CitationSubRef>
</xsl:template>

<xsl:template match="a[not(starts-with(@href, '#'))]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ExternalLink URI="{ @href }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ExternalLink', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ExternalLink>
</xsl:template>

</xsl:transform>
