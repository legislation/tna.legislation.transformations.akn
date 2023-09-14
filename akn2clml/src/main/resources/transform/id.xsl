<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk ukl html local">

<xsl:key name="internal-refs" match="ref[starts-with(@href,'#')]" use="substring(@href, 2)" />
<xsl:key name="internal-refs-by-guid" match="ref[exists(@uk:targetGuid)]" use="@uk:targetGuid" />

<xsl:function name="local:element-id-is-necessary" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="ref-to-id-exists" as="xs:boolean" select="exists($e/@eId) and exists(key('internal-refs', $e/@eId, root($e)))" />
	<xsl:variable name="ref-to-guid-exists" as="xs:boolean" select="exists($e/@GUID) and exists(key('internal-refs-by-guid', $e/@GUID, root($e)))" />
	<xsl:sequence select="$ref-to-id-exists or $ref-to-guid-exists" />
</xsl:function>

<xsl:function name="local:make-necessary-id" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="num" as="xs:integer" select="count($e/preceding::*)" />
	<xsl:sequence select="concat('p', format-number($num,'00000'))" />
</xsl:function>

<xsl:template match="authorialNote[@class='referenceNote']" mode="remove-schedule-reference" />
<xsl:template match="@*|*|processing-instruction()|comment()" mode="remove-schedule-reference">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="remove-schedule-reference" />
	</xsl:copy>
</xsl:template>

<xsl:function name="local:make-id-from-number-1" as="xs:string">
	<xsl:param name="num" as="element(num)" />
	<xsl:variable name="num" as="element(num)">
		<xsl:apply-templates select="$num" mode="remove-schedule-reference" />
	</xsl:variable>
	<xsl:sequence select="translate(lower-case(normalize-space(string($num))), ' &#160;&#8239;', '---')" />
</xsl:function>

<xsl:function name="local:make-id-from-number-2" as="xs:string">
	<xsl:param name="prefix" as="xs:string" />
	<xsl:param name="num" as="element(num)" />
	<xsl:sequence select="concat($prefix, '-', local:strip-punctuation-from-number(string($num)))" />
</xsl:function>

<xsl:function name="local:make-id-from-p1-number" as="xs:string">
	<xsl:param name="prefix" as="xs:string" />
	<xsl:param name="num" as="element(num)" />
	<xsl:variable name="stripped" as="xs:string" select="local:strip-punctuation-from-number(string($num))" />
	<xsl:variable name="stripped" as="xs:string" select="translate($stripped, '&#160;&#8239;—', '  -')" />	<!-- eudn/2019/15, eur/2019/2176, ukpga/Vict/58-59/16 -->
	<xsl:variable name="stripped" as="xs:string" select="if (contains($stripped, ' ')) then substring-after($stripped, ' ') else $stripped" />
	<xsl:sequence select="concat($prefix, '-', $stripped)" />
</xsl:function>

<xsl:function name="local:make-id-from-heading" as="xs:string">
	<xsl:param name="prefix" as="xs:string" />
	<xsl:param name="heading" as="element(heading)" />
	<xsl:variable name="fixed" as="xs:string" select="translate($heading, '&#8199;', ' ')" />
	<xsl:sequence select="concat($prefix, '-', translate(lower-case(normalize-space($fixed)), '/ ():.,‘’“”''&quot;', '--'))" />
</xsl:function>

<xsl:function name="local:make-id-for-crossheading" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:param name="name" as="xs:string" />
	<xsl:choose>
		<xsl:when test="exists($e/heading)">
			<xsl:sequence select="local:make-id-from-heading($name, $e/heading[1])" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="number" as="xs:integer" select="count($e/preceding-sibling::*[not(self::num) and not(self::heading) and not(self::subheading)]) + 1" />
			<xsl:sequence select="concat(local:make-internal-id($e/parent::*), '-', $name, '-', string($number))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:make-schedule-id-from-number" as="xs:string">
	<xsl:param name="num" as="element(num)" />
	<xsl:variable name="id" as="xs:string" select="local:make-id-from-number-1($num)" />
	<xsl:choose>
		<xsl:when test="starts-with($id, 'schedule')">
			<xsl:sequence select="$id" />
		</xsl:when>
		<xsl:when test="starts-with($id, 'annex')">
			<xsl:sequence select="$id" />
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:sequence select="concat('annex-', $id)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="concat('schedule-', $id)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:make-internal-id" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="exists($e/ancestor::quotedStructure)">
			<xsl:sequence select="local:make-necessary-id($e)" />
		</xsl:when>
		<xsl:when test="exists($e/ancestor::hcontainer[@name='attachment'])">
			<xsl:sequence select="local:make-necessary-id($e)" />
		</xsl:when>
		<xsl:when test="$e/self::part">
			<xsl:variable name="id" as="xs:string">
				<xsl:choose>
					<xsl:when test="exists($e/num)">
						<xsl:sequence select="local:make-id-from-number-1($e/num)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="concat('part-', string(count($e/preceding-sibling::part) + 1))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="local:akn-is-within-schedule($e)">
					<xsl:variable name="parent" as="element()" select="$e/parent::*" />
					<xsl:variable name="parent-id" as="xs:string" select="local:make-internal-id($parent)" />
					<xsl:sequence select="concat($parent-id, '-', $id)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$e/self::chapter">
			<xsl:variable name="id" as="xs:string">
				<xsl:choose>
					<xsl:when test="exists($e/num)">
						<xsl:sequence select="local:make-id-from-number-1($e/num)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="concat('chapter-', string(count($e/preceding-sibling::chapter) + 1))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="exists($e/parent::part) or local:akn-is-within-schedule($e)">
					<xsl:variable name="parent" as="element()" select="$e/parent::*" />
					<xsl:variable name="parent-id" as="xs:string" select="local:make-internal-id($parent)" />
					<xsl:sequence select="concat($parent-id, '-', $id)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$id" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name=('crossheading','subheading')]">
			<xsl:sequence select="local:make-id-for-crossheading($e, $e/@name)" />
		</xsl:when>
		<xsl:when test="$e[self::section or self::subsection][local:get-applicable-doc-class(.)=('secondary','euretained')]">
			<xsl:choose>
				<xsl:when test="exists($e/num)">
					<xsl:sequence select="local:make-id-from-number-2(local-name($e), $e/num)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="local:make-id-for-crossheading($e, local-name($e))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$e/self::section or $e/self::article or $e/self::rule">
			<xsl:choose>
				<xsl:when test="starts-with($e/@eId, 'section-') or starts-with($e/@eId, 'article-') or starts-with($e/@eId, 'rule-')">
					<xsl:sequence select="string($e/@eId)" />
				</xsl:when>
				<xsl:when test="exists($e/num)">
					<xsl:sequence select="local:make-id-from-p1-number(local-name($e), $e/num)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="preceding" as="element()?" select="$e/preceding-sibling::*[1]" />
					<xsl:choose>
						<xsl:when test="exists($preceding)">
							<xsl:variable name="preceding-id" as="xs:string" select="local:make-internal-id($preceding)" />
							<xsl:sequence select="concat($preceding-id, '-bis')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="concat(local-name($e), '-1')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='regulation']">
			<xsl:choose>
				<xsl:when test="starts-with($e/@eId, 'regulation-')">
					<xsl:sequence select="string($e/@eId)" />
				</xsl:when>
				<xsl:when test="exists($e/num)">
					<xsl:sequence select="local:make-id-from-p1-number($e/@name, $e/num)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="preceding" as="element()?" select="$e/preceding-sibling::*[1]" />
					<xsl:choose>
						<xsl:when test="exists($preceding)">
							<xsl:variable name="preceding-id" as="xs:string" select="local:make-internal-id($preceding)" />
							<xsl:sequence select="concat($preceding-id, '-bis')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="'regulation-1'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$e/self::paragraph[local:akn-is-within-schedule(.)] or $e/self::hcontainer[@name='scheduleParagraph'] or $e/self::paragraph[@class='schProv1']">
			<xsl:sequence select="concat(local:make-internal-id($e/ancestor::hcontainer[@name='schedule']), '-paragraph-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<xsl:when test="$e/self::subsection or $e/self::paragraph or $e/self::subparagraph or $e/self::level">
			<xsl:variable name="parent" as="element()">
				<xsl:choose>
					<xsl:when test="$e/parent::*/self::hcontainer[@name=('wrapper1', 'wrapper2', 'P2group')]">
						<xsl:sequence select="$e/parent::*/parent::*" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$e/parent::*" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:sequence select="concat(local:make-internal-id($parent), '-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<!-- legacy -->
		<xsl:when test="$e/self::hcontainer[@name='SIParagraph'] or $e/self::hcontainer[@name='subsubparagraph'] or $e/self::hcontainer[@name='subsubsubparagraph'] or $e/self::clause or $e/self::subclause">
			<xsl:variable name="parent" as="element()">
				<xsl:choose>
					<xsl:when test="$e/parent::*/self::hcontainer[@name=('wrapper1', 'wrapper2', 'P2group')]">
						<xsl:sequence select="$e/parent::*/parent::*" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$e/parent::*" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:sequence select="concat(local:make-internal-id($parent), '-', local:strip-punctuation-from-number(string($e/num)))" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='step']">
			<xsl:variable name="number" as="xs:string">
				<xsl:choose>
					<xsl:when test="starts-with($e/num, 'step ')">
						<xsl:sequence select="normalize-space(substring-after($e/num, ' '))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="string(count($e/preceding-sibling::hcontainer) + 1)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="parent" as="element()" select="$e/parent::*" />
			<xsl:variable name="parent-id" as="xs:string" select="local:make-internal-id($parent)" />
			<xsl:sequence select="concat($parent-id, '-', $number)" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='schedule']">
			<xsl:sequence select="local:make-schedule-id-from-number($e/num)" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='appendix']">
			<xsl:variable name="number" as="xs:string">
				<xsl:sequence select="string(count($e/preceding-sibling::hcontainer[@name='appendix']) + 1)" />
			</xsl:variable>
			<xsl:variable name="parent" as="element()" select="$e/parent::*" />
			<xsl:variable name="parent-id" as="xs:string" select="local:make-internal-id($parent)" />
			<xsl:sequence select="concat($parent-id, '-appendix-', $number)" />
		</xsl:when>
		<xsl:when test="$e/self::hcontainer[@name='division']">
			<xsl:variable name="parent" as="element()" select="$e/parent::*" />
			<xsl:variable name="parent" as="element()">
				<xsl:choose>
					<xsl:when test="$parent/self::hcontainer[@name=('wrapper1','wrapper2','scheduleBody','appendixBody')]">
						<xsl:sequence select="$parent/parent::*" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$parent" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="parent-id" as="xs:string" select="local:make-internal-id($parent)" />
			<xsl:variable name="position" as="xs:integer" select="count($e/preceding-sibling::*) + 1" />
			<xsl:choose>
				<xsl:when test="$parent/self::hcontainer[@name='division']">
					<xsl:sequence select="concat($parent-id, '-', string($position))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat($parent-id, '-division-', string($position))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		
		<xsl:when test="$e/self::title">
			<xsl:choose>
				<xsl:when test="exists($e/ancestor::hcontainer[@name='schedule'])">
					<xsl:variable name="id" as="xs:string" select="local:make-id-from-number-1($e/num)" />
					<xsl:variable name="parent" as="element()" select="$e/parent::*" />
					<xsl:variable name="parent-id" as="xs:string" select="local:make-internal-id($parent)" />
					<xsl:sequence select="concat($parent-id, '-', $id)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="local:make-id-from-number-1($e/num)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:sequence select="generate-id($e)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="add-id-if-necessary">
	<xsl:param name="e" as="element()" select="." />
	<xsl:variable name="should-add" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$e/self::akomaNtoso">
				<xsl:sequence select="false()" />
			</xsl:when>
			<xsl:when test="$e/parent::akomaNtoso">
				<xsl:sequence select="false()" />
			</xsl:when>
			<xsl:when test="$e/self::act">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="$e/self::body">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="$e/self::preface">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="exists($e/ancestor::quotedStructure) or exists($e/ancestor::embeddedStructure)">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="$e/self::hcontainer/@name='crossheading'">
				<xsl:choose>
					<xsl:when test="local:crossheading-is-p1group(.)">
						<xsl:sequence select="true()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="local:element-id-is-necessary($e)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$e/self::hcontainer[@name='schedules']">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="exists($e/self::hcontainer[@name='attachments'])">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="exists($e/ancestor-or-self::hcontainer[@name='attachment'])">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:when test="exists($e/ancestor::html:*)">
				<xsl:sequence select="local:element-id-is-necessary($e)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="true()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="$should-add">
		<xsl:attribute name="id">
			<xsl:sequence select="local:make-internal-id($e)" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:function name="local:make-internal-id-for-href" as="xs:string?">
	<xsl:param name="href" as="attribute()" />
	<xsl:if test="starts-with($href, '#')">
		<xsl:variable name="ref-id" as="xs:string" select="substring($href, 2)" />
		<xsl:variable name="e" as="element()?" select="key('id', $ref-id, root($href))[1]" />
		<xsl:if test="exists($e)">
			<xsl:sequence select="local:make-internal-id($e)" />
		</xsl:if>
	</xsl:if>
</xsl:function>

</xsl:transform>
