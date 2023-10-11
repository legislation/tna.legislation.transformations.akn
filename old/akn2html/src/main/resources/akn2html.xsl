<?xml version="1.0" encoding="utf-8"?>

<!-- v3.5, written by Jim Mangiafico -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:local="http://jurisdatum.com/tna/akn2html"
	xmlns:ldapp="#ldapp"
	exclude-result-prefixes="xs math ukl ukm uk html fo local ldapp">

<xsl:param name="css-path" as="xs:string" select="'/'" />
<xsl:param name="ldapp" as="xs:boolean" select="ldapp:is-ldapp(.)" />

<xsl:include href="ldapp.xsl" />
<xsl:include href="annotations.xsl" />

<xsl:output method="html" version="5" include-content-type="no" encoding="utf-8" indent="yes" />

<xsl:strip-space elements="*" />
<xsl:preserve-space elements="block p docTitle docNumber docDate num heading subheading ref def term abbr date inline b i u sup sub span a mod quotedText ins" />

<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="$ldapp">
			<xsl:variable name="fixed" as="document-node()">
				<xsl:document>
					<xsl:apply-templates mode="ldapp" />
				</xsl:document>
			</xsl:variable>
			<xsl:apply-templates select="$fixed/*" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:key name="id" match="*" use="@eId" />
<xsl:key name="note" match="note" use="@eId" />
<xsl:key name="note-ref" match="noteRef" use="substring(@href, 2)" />


<xsl:variable name="doc-short-type" as="xs:string" select="/akomaNtoso/*/@name" />

<xsl:function name="local:doc-category-from-short-type" as="xs:string?">
	<xsl:param name="short-type" as="xs:string" />
	<xsl:variable name="primary-short-types" as="xs:string+" select="( 'ukpga', 'ukla', 'asp', 'anaw', 'asc', 'mwa', 'ukcm', 'nia', 'aosp', 'aep', 'aip', 'apgb', 'mnia', 'apni' )" />
	<xsl:variable name="secondary-short-types" as="xs:string+" select="( 'uksi', 'wsi', 'ssi', 'nisi', 'nisr', 'ukci', 'ukmd', 'ukmo', 'uksro', 'nisro', 'ukdpb', 'ukdsi', 'sdsi', 'nidsr' )" />
	<xsl:variable name="eu-short-types" as="xs:string+" select="( 'eur', 'eudn', 'eudr', 'eut' )" />
	<xsl:choose>
		<xsl:when test="$short-type = $primary-short-types">
			<xsl:sequence select="'primary'" />
		</xsl:when>
		<xsl:when test="$short-type = $secondary-short-types">
			<xsl:sequence select="'secondary'" />
		</xsl:when>
		<xsl:when test="$short-type = $eu-short-types">
			<xsl:sequence select="'euretained'" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:variable name="doc-category" as="xs:string?" select="local:doc-category-from-short-type($doc-short-type)" />

<xsl:template name="add-class-attribute">
	<xsl:param name="classes" as="xs:string*" select="()" />
	<xsl:variable name="classes" as="xs:string*">
		<xsl:if test="empty(self::p)">
			<xsl:sequence select="local-name(.)" />
		</xsl:if>
		<xsl:sequence select="@name" />
		<xsl:sequence select="@uk:name" />
		<xsl:sequence select="@class" />
		<xsl:sequence select="$classes" />
	</xsl:variable>
	<xsl:if test="exists($classes)">
		<xsl:attribute name="class">
			<xsl:value-of select="string-join($classes, ' ')" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:key name="extent-restrictions" match="restriction[starts-with(@refersTo, '#extent-')]" use="substring(@href, 2)" />

<xsl:template name="add-extent-attribute">
	<xsl:if test="exists(self::act) or exists(@eId)">
		<xsl:variable name="id" as="xs:string?" select="@eId" />
		<xsl:variable name="restriction" as="element()?" select="key('extent-restrictions', $id)[1]" />	<!-- [1] protects against duplicate ids -->
		<xsl:if test="exists($restriction)">
			<xsl:variable name="extent" as="element(TLCLocation)" select="key('id', substring($restriction/@refersTo, 2))" />
			<xsl:attribute name="data-x-extent">
				<xsl:value-of select="$extent/@showAs" />
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:key name="temporal-restrictions" match="restriction[starts-with(@refersTo, '#period-')]" use="substring(@href, 2)" />

<xsl:template name="add-restrict-date-attributes">
	<xsl:if test="exists(self::act) or exists(@eId)">
		<xsl:variable name="id" as="xs:string?" select="@eId" />
		<xsl:variable name="restriction" as="element()?" select="key('temporal-restrictions', $id)[1]" />	<!-- [1] protects against duplicate ids -->
		<xsl:if test="exists($restriction)">
			<xsl:variable name="group" as="element(temporalGroup)" select="key('id', substring($restriction/@refersTo, 2))" />
			<xsl:variable name="interval" as="element(timeInterval)" select="$group/*" />
			<xsl:if test="exists($interval/@start)">
				<xsl:variable name="event" as="element(eventRef)" select="key('id', substring($interval/@start, 2))" />
				<xsl:attribute name="data-x-restrict-start-date">
					<xsl:value-of select="$event/@date" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="exists($interval/@end)">
				<xsl:variable name="event" as="element(eventRef)" select="key('id', substring($interval/@end, 2))" />
				<xsl:attribute name="data-x-restrict-end-date">
					<xsl:value-of select="$event/@date" />
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="add-restrict-attributes">
	<xsl:call-template name="add-extent-attribute" />
	<xsl:call-template name="add-restrict-date-attributes" />
</xsl:template>

<xsl:template name="add-status-attribute">
</xsl:template>

<xsl:key name="confers-power" match="uk:confersPower" use="substring(@href, 2)" />

<xsl:template name="add-confers-power-attribute">
	<xsl:if test="exists(self::act) or exists(@eId)">
		<xsl:variable name="id" as="xs:string?" select="@eId" />
		<xsl:variable name="restriction" as="element(uk:confersPower)?" select="key('confers-power', $id)[1]" />	<!-- [1] guards against duplicate ids -->
		<xsl:if test="exists($restriction)">
			<xsl:attribute name="data-x-confers-power">
				<xsl:text>true</xsl:text>
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="add-status-attributes">
	<xsl:call-template name="add-status-attribute" />
	<xsl:call-template name="add-confers-power-attribute" />
</xsl:template>

<xsl:template name="add-extra-attributes">
	<xsl:call-template name="add-restrict-attributes" />
	<xsl:call-template name="add-status-attributes" />
</xsl:template>

<xsl:template name="attrs">
	<xsl:param name="classes" as="xs:string*" select="()" />
	<xsl:call-template name="add-class-attribute">
		<xsl:with-param name="classes" select="$classes" />
	</xsl:call-template>
	<xsl:apply-templates select="@* except (@name, @uk:name, @class)" />
	<xsl:call-template name="add-extra-attributes" />
</xsl:template>


<!-- templates -->

<xsl:template match="akomaNtoso">
	<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
</xsl:text>
	<html>
		<head>
			<meta charset="utf-8" />
			<title>
				<xsl:choose>
					<xsl:when test="//shortTitle">
						<xsl:value-of select="(//shortTitle)[1]" />
					</xsl:when>
					<xsl:when test="//docTitle">
						<xsl:value-of select="(//docTitle)[1]" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//FRBRWork/FRBRthis/@value" />
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:choose>
				<xsl:when test="$doc-short-type = 'nia'">
					<link rel="stylesheet" href="{$css-path}nia.css" type="text/css" />
				</xsl:when>
				<xsl:when test="$doc-category = 'secondary'">
					<link rel="stylesheet" href="{$css-path}secondary.css" type="text/css" />
				</xsl:when>
				<xsl:when test="$doc-category = 'euretained'">
					<link rel="stylesheet" href="{$css-path}euretained.css" type="text/css" />
				</xsl:when>
				<xsl:otherwise>
					<link rel="stylesheet" href="{$css-path}primary.css" type="text/css" />
				</xsl:otherwise>
			</xsl:choose>
		</head>
		<body>
			<xsl:apply-templates>
				<xsl:with-param name="effective-document-category" select="$doc-category" tunnel="yes" />
				<xsl:with-param name="within-schedule" select="false()" tunnel="yes" />
			</xsl:apply-templates>
			<xsl:call-template name="footnotes" />
		</body>
	</html>
</xsl:template>


<!-- document types -->

<xsl:template match="act">
	<article>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="$doc-category" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="@name" />
		</xsl:attribute>
		<xsl:call-template name="add-restrict-attributes" />
		<xsl:apply-templates />
	</article>
</xsl:template>


<!-- metadata -->

<xsl:template match="meta">
	<div class="meta" vocab="{namespace-uri()}/" style="display:none">
		<xsl:apply-templates select="identification" />
	</div>
</xsl:template>

<xsl:template match="meta/*">
	<div resource="#{name()}" typeof="{name()}">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="identification/*">
	<div resource="#{name()}" property="{name()}" typeof="{name()}">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="meta/*//*[not(parent::identification)][not(ancestor-or-self::note)]">
	<xsl:choose>
		<xsl:when test="text()[normalize-space()]">
			<div property="{ name() }">
				<xsl:value-of select="." />
			</div>
		</xsl:when>
		<xsl:otherwise>
			<div>
				<xsl:if test="not(parent::meta) and ((namespace-uri() = namespace-uri(..)) or parent::proprietary)">
					<xsl:attribute name="property">
						<xsl:value-of select="name()" />
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="typeof">
					<xsl:value-of select="name()" />
				</xsl:attribute>
				<xsl:variable name="prefix" select="prefix-from-QName(resolve-QName(name(), .))" as="xs:string?" />
				<xsl:for-each select="@*">
					<meta>
						<xsl:attribute name="property">
							<xsl:if test="$prefix">
								<xsl:value-of select="$prefix" />
								<xsl:text>:</xsl:text>
							</xsl:if>
							<xsl:value-of select="name()" />
						</xsl:attribute>
						<xsl:attribute name="content">
							<xsl:value-of select="translate(., '&#128;&#132;&#149;&#150;&#153;&#157;', '')" />
						</xsl:attribute>
					</meta>
				</xsl:for-each>
				<xsl:apply-templates select="*" />
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- prelims -->

<xsl:template match="coverPage">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="preface">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="preface/block[@name='title']">
	<h1>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</h1>
</xsl:template>

<xsl:template match="preamble">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="body">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="conclusions | attachments | components">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="attachment">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="doc">
	<article>
		<xsl:apply-templates select="@name" />
		<xsl:variable name="category" as="xs:string?" select="meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
		<xsl:if test="exists($category)">
			<xsl:attribute name="class">
				<xsl:value-of select="$category" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</article>
</xsl:template>


<!-- hierarchy -->

<xsl:template match="hcontainer[name = 'groupOfParts']">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="title">	<!-- for EU Titles -->
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="part">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="chapter">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="hcontainer[@name = 'crossheading']">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="hcontainer[@name = 'subheading']">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="hcontainer[@name = 'P1group']">
	<xsl:call-template name="big-level" />
</xsl:template>

<xsl:template match="section">
	<xsl:param name="effective-document-category" as="xs:string" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$effective-document-category = 'primary'">
			<xsl:call-template name="p1" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="big-level" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="article | hcontainer[@name = 'regulation'] | rule">
	<xsl:call-template name="p1" />
</xsl:template>

<xsl:template match="subsection">
	<xsl:param name="effective-document-category" as="xs:string" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$effective-document-category = 'primary'">
			<xsl:call-template name="p2" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="big-level" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="paragraph">
	<xsl:param name="within-schedule" as="xs:boolean" select="false()" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="@class = 'para1'">
			<xsl:call-template name="p3" />
		</xsl:when>
		<xsl:when test="@class = 'schProv1'">
			<xsl:call-template name="p1" />
		</xsl:when>
		<xsl:when test="$within-schedule">
			<xsl:call-template name="p1" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="p2" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="hcontainer[@name = 'SIParagraph']">	<!-- legacy -->
	<xsl:call-template name="p2" />
</xsl:template>

<xsl:template match="subparagraph">
	<xsl:choose>
		<xsl:when test="@class = 'para2'">	<!-- legacy -->
			<xsl:call-template name="p3" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="p2" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="level">
	<xsl:call-template name="p3" />
</xsl:template>

<xsl:template match="hcontainer[@name = 'step']">
	<xsl:call-template name="p3" />
</xsl:template>

<xsl:template match="point">	<!-- legacy -->
	<xsl:call-template name="p3" />
</xsl:template>

<xsl:template match="hcontainer[@name='subsubparagraph']">	<!-- legacy -->
	<xsl:call-template name="p3" />
</xsl:template>

<xsl:template match="hcontainer">	<!-- e.g., division -->
	<xsl:call-template name="p3">
		<xsl:with-param name="class" select="if (empty(num)) then 'no-num' else ()" />
	</xsl:call-template>
</xsl:template>


<!-- named templates -->

<xsl:template name="big-level">
	<section>
		<xsl:call-template name="attrs" />
		<xsl:if test="exists(num | heading | subheading)">
			<h2>
				<xsl:apply-templates select="num | heading | subheading" />
			</h2>
		</xsl:if>
		<xsl:apply-templates select="num/authorialNote[@class='referenceNote']" />	<!-- for schedule -->
		<xsl:apply-templates select="*[not(self::num) and not(self::heading) and not(self::subheading)]" />
		<xsl:call-template name="annotations" />
	</section>
</xsl:template>


<!-- P1 -->

<xsl:template name="p1">
	<section>
		<xsl:call-template name="attrs" />
		<h2>
			<xsl:apply-templates select="num | heading | subheading" />			
		</h2>
		<xsl:apply-templates select="*[not(self::num) and not(self::heading) and not(self::subheading)]">
			<xsl:with-param name="indent" select="1" tunnel="yes" />	<!-- this isn't correct for secondary uk legislation -->
		</xsl:apply-templates>
		<xsl:call-template name="annotations" />
	</section>
</xsl:template>


<!-- P2 -->

<xsl:template name="p2">
	<section>
		<xsl:call-template name="attrs" />
		<h2>
			<xsl:apply-templates select="num | heading | subheading" />			
		</h2>
		<xsl:apply-templates select="*[not(self::num) and not(self::heading) and not(self::subheading)]">
			<xsl:with-param name="indent" select="2" tunnel="yes" />
		</xsl:apply-templates>
	</section>
</xsl:template>


<!-- P3 -->

<xsl:template name="p3">
	<xsl:param name="class" as="xs:string?" select="()" />
	<xsl:param name="indent" as="xs:integer" select="3" tunnel="yes" />
	<xsl:param name="plevel" as="xs:integer" select="3" tunnel="no" />
	<div>
		<xsl:call-template name="attrs">
			<xsl:with-param name="classes" select="$class" />
		</xsl:call-template>
		<xsl:if test="num | heading | subheading">	<!-- needed b/c this template is now used as default for hcontainer -->
			<xsl:element name="h{$plevel}">
				<xsl:apply-templates select="num | heading | subheading" />			
			</xsl:element>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num) and not(self::heading) and not(self::subheading)]">
			<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
			<xsl:with-param name="plevel" select="$plevel + 1" tunnel="no" />
		</xsl:apply-templates>
	</div>
</xsl:template>

<xsl:template match="num | heading | subheading">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="intro | content | wrapUp">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>


<!-- schedules and explanatory notes -->

<xsl:template match="hcontainer[@name='schedules']">
	<section>
		<xsl:call-template name="attrs" />
		<xsl:if test="exists(num | heading | subheading)">
			<h2>
				<xsl:apply-templates select="num | heading | subheading" />
			</h2>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num) and not(self::heading) and not(self::subheading)]" />
	</section>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']">
	<xsl:call-template name="big-level">
		<xsl:with-param name="within-schedule" select="true()" tunnel="yes" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']/num | hcontainer[@name='schedule']/part/num">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates select="node()[not(self::authorialNote[@class='referenceNote'])]" />
	</span>
</xsl:template>

<xsl:template match="blockContainer[@class=('explanatoryNote','explanatoryNotes','earlierOrders','commencementHistory')]/heading">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>
<xsl:template match="blockContainer[@class=('explanatoryNote','explanatoryNotes','earlierOrders','commencementHistory')]/subheading">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>



<!-- LISTS (ordered, unordered, and key) -->

<xsl:template match="item">
	<li>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<xsl:template match="listIntroduction | listWrapUp">
	<li>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<!-- ordered lists -->

<xsl:template match="blockList[item/num]">
	<ol><xsl:apply-templates select="@*|node()"/></ol>
</xsl:template>

<xsl:template match="item/num">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:choose>
			<xsl:when test="@title">
				<xsl:attribute name="data-raw"><xsl:value-of select="." /></xsl:attribute>
				<xsl:value-of select="@title" />
				<xsl:apply-templates select="*" /><!-- for notes, etc -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<!-- unordered lists -->

<xsl:template match="blockList"><!-- [not(item/num)] -->
	<ul>
		<xsl:apply-templates select="@*|node()" />
	</ul>
</xsl:template>

<!-- key lists -->

<xsl:template match="blockList[@class='key']">
	<dl>
		<xsl:if test="@ukl:separator = '='">
			<xsl:attribute name="class">equals</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@*[name()!='class'][local-name()!='separator']" />
		<xsl:apply-templates />
	</dl>
</xsl:template>

<xsl:template match="blockList[@class='key']/item">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="blockList[@class='key']/item/heading">
	<dt><xsl:apply-templates select="@*|node()" /></dt>
</xsl:template>

<xsl:template match="blockList[@class='key']/item/*[not(self::heading)]" priority="1"><!-- could be another blockList -->
	<dd>
		<xsl:next-match />
	</dd>
</xsl:template>


<!-- blocks -->

<xsl:template match="p[docTitle] | p[shortTitle] | p[mod[quotedStructure]] | p[embeddedStructure] | p[subFlow] | p[authorialNote]">
	<div>
		<xsl:call-template name="attrs">
			<xsl:with-param name="classes" select="local-name()" />
		</xsl:call-template>
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="p">
	<p>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="block[@name='figure']">
	<figure>
		<xsl:apply-templates select="@*[name() != 'name']" />
		<xsl:apply-templates />
	</figure>
</xsl:template>
<xsl:template match="tblock[@class='figure']">
	<figure>
		<xsl:apply-templates select="@*[name() != 'class']" />
		<xsl:apply-templates />
	</figure>
</xsl:template>
<xsl:template match="tblock[@class='figure']/heading">
	<figcaption>
		<xsl:apply-templates select="@*|node()" />
	</figcaption>
</xsl:template>

<xsl:template match="block | container | tblock | blockContainer | formula | longTitle | authorialNote | signatures | signature">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>


<xsl:template match="mod">
	<xsl:if test="preceding-sibling::node()[1][self::text()][normalize-space()]">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="exists(child::quotedStructure)">
			<div class="mod">
				<xsl:apply-templates />
			</div>
		</xsl:when>
		<xsl:otherwise>
			<span class="mod">
				<xsl:apply-templates />
			</span>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="quotedStructure | embeddedStructure">
	<xsl:param name="indent" as="xs:integer" select="1" tunnel="yes" />
	<xsl:variable name="effective-document-category" as="xs:string">
		<xsl:choose>
			<xsl:when test="@ukl:TargetClass">
				<xsl:sequence select="string(@ukl:TargetClass)" />
			</xsl:when>
			<xsl:when test="@ukl:SourceClass">
				<xsl:sequence select="string(@ukl:SourceClass)" />
			</xsl:when>
			<xsl:when test="exists(@uk:docName)">
				<xsl:sequence select="local:doc-category-from-short-type(string(@uk:docName))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$doc-category" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<blockquote class="{ local-name() }">
		<xsl:apply-templates select="@* except (@class, @startQuote, @endQuote)" />
		<xsl:attribute name="class">
			<xsl:value-of select="$effective-document-category" />
			<xsl:choose>
				<xsl:when test="exists(@ukl:Context)">
					<xsl:text> context-</xsl:text>
					<xsl:value-of select="@ukl:Context" />
				</xsl:when>
				<xsl:when test="exists(descendant::*[@class = ('schProv1', 'schProv2')])">
					<xsl:text> context-schedule</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="exists(@class)">
				<xsl:text> </xsl:text>
				<xsl:value-of select="@class" />
			</xsl:if>
		</xsl:attribute>
		<xsl:variable name="text-nodes" as="text()*" select="descendant::text()[normalize-space()]" />
		<xsl:apply-templates>
			<xsl:with-param name="within-quoted-structure" as="xs:boolean" select="true()" tunnel="yes" />
			<xsl:with-param name="start-quote-attr" as="attribute()?" select="@startQuote" tunnel="yes" />
			<xsl:with-param name="end-quote-attr" as="attribute()?" select="@endQuote" tunnel="yes" />
			<xsl:with-param name="first-text-node-of-quote" select="$text-nodes[1]" tunnel="yes" />
			<xsl:with-param name="last-text-node-of-quote" select="$text-nodes[last()]" tunnel="yes" />
			<xsl:with-param name="append-text" select="following-sibling::*[1][@name=('appendText','AppendText')]" tunnel="yes" />
			<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
			<xsl:with-param name="effective-document-category" as="xs:string" select="$effective-document-category" tunnel="yes" />
			<xsl:with-param name="within-schedule" as="xs:boolean" tunnel="yes">
				<xsl:choose>
					<xsl:when test="@ukl:Context = 'schedule'">
						<xsl:sequence select="true()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="false()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:apply-templates>
	</blockquote>
</xsl:template>

<xsl:template match="inline[@name=('appendText','AppendText')]" />


<!-- attachments -->

<xsl:template match="hcontainer[@name='attachments']">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="hcontainer[@name='attachment']">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates mode="attachment" />
	</div>
</xsl:template>

<xsl:template match="content | p" mode="attachment">
	<xsl:apply-templates mode="attachment" />
</xsl:template>

<xsl:template match="subFlow" mode="attachment">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="subFlow/hcontainer[@name='body']">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>


<!-- tables of contents -->

<xsl:template match="toc">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="tocItem">
	<div class="{string-join((name(), @class), ' ')}">
		<xsl:apply-templates select="@*[not(name() = 'class')][not(name() = 'href')]" />
		<a>
			<xsl:apply-templates select="@href" />
			<xsl:apply-templates />
		</a>
	</div>
</xsl:template>


<!-- same -->

<xsl:template match="img">
	<xsl:element name="{ local-name() }">
		<xsl:apply-templates select="@*" />
		<xsl:if test="empty(@alt)">
			<xsl:attribute name="alt" />
		</xsl:if>
		<xsl:apply-templates select="node()" />
	</xsl:element>
</xsl:template>

<xsl:template match="i | b | u | br | caption | tr | th | td | abbr | sup | sub | a | ol | ul | li | ins | del">
	<xsl:element name="{ local-name() }">
		<xsl:apply-templates select="@*|node()" />
	</xsl:element>
</xsl:template>


<!-- foreign: tables and math -->

<xsl:template match="foreign">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:table">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:element name="{ local-name() }">
		<xsl:apply-templates select="@* except (@cols, @summary)" />
		<xsl:if test="$indent gt 0">
			<xsl:attribute name="class">
				<xsl:if test="exists(@class)">
					<xsl:value-of select="@class" />
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>level-</xsl:text>
				<xsl:value-of select="$indent" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::html:tfoot)]" />
		<xsl:apply-templates select="html:tfoot" />
	</xsl:element>
</xsl:template>

<xsl:template match="html:colgroup">
	<xsl:element name="{ local-name() }">
		<xsl:choose>
			<xsl:when test="exists(child::html:col)">
				<xsl:apply-templates select="@* except @span" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="@*" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="html:th | html:td | html:col">
	<xsl:element name="{ local-name() }">
		<xsl:apply-templates select="@* except (@width, @height, @align, @valign, @fo:*)" />
		<xsl:if test="exists(@width) or exists(@height) or exists(@align) or exists(@valign) or exists(@fo:*)">
			<xsl:attribute name="style">
				<xsl:if test="exists(@style)">
					<xsl:value-of select="@style" />
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@width)">
					<xsl:text>width:</xsl:text>
					<xsl:value-of select="@width"/>
					<xsl:if test="@width castable as xs:integer">
						<xsl:text>px</xsl:text>
					</xsl:if>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@height)">
					<xsl:text>height:</xsl:text>
					<xsl:value-of select="@height"/>
					<xsl:if test="@height castable as xs:integer">
						<xsl:text>px</xsl:text>
					</xsl:if>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@align)">
					<xsl:text>text-align:</xsl:text>
					<xsl:value-of select="@align"/>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@valign)">
					<xsl:text>vertical-align:</xsl:text>
					<xsl:value-of select="@valign"/>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:for-each select="@fo:*">
					<xsl:value-of select="local-name()"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>;</xsl:text>
				</xsl:for-each>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="html:*">
	<xsl:element name="{ local-name() }">
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="math:math">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*"/>
		<xsl:choose>
			<xsl:when test="@altimg and not(math:semantics)">
				<semantics>
					<xsl:choose>
						<xsl:when test="every $child in * satisfies $child/self::math:mrow">
							<xsl:apply-templates />
						</xsl:when>
						<xsl:otherwise>
							<mrow>
								<xsl:apply-templates />
							</mrow>
						</xsl:otherwise>
					</xsl:choose>
					<annotation-xml encoding="MathML-Presentation">
						<mtext><img src="{ @altimg }" alt="math" /></mtext>
					</annotation-xml>
				</semantics>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose> 
	</xsl:element>
</xsl:template>

<xsl:template match="math:semantics">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*"/> 
		<xsl:apply-templates />
		<xsl:if test="../@altimg">
			<annotation-xml encoding="MathML-Presentation">
				<mtext><img src="{../@altimg}" alt="math" /></mtext>
			</annotation-xml>
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="math:*">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*" /> 
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>


<!-- forms -->

<xsl:template match="tblock[@class='form']/num">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates select="node()[not(self::authorialNote[@class='referenceNote'])]" />
	</span>
	<xsl:apply-templates select="authorialNote[@class='referenceNote']" />
</xsl:template>


<!-- inline -->

<xsl:template match="quotedText">
	<q>
		<xsl:apply-templates select="@*" />
		<xsl:value-of select="@startQuote" />
		<xsl:apply-templates />
		<xsl:value-of select="@endQuote" />
	</q>
</xsl:template>

<xsl:template match="noteRef">
	<xsl:choose>
		<xsl:when test="@uk:name = 'commentary' or tokenize(@class, ' ') = 'commentary'">
			<xsl:variable name="test" select="key('id', substring(@href, 2))" />
			<xsl:if test="$test[not(self::note)]">
				<xsl:message terminate="yes">
					<xsl:sequence select="." />
				</xsl:message>
			</xsl:if>
			<xsl:variable name="commentary" as="element(note)?" select="key('id', substring(@href, 2))" />
			<span>
				<xsl:call-template name="add-class-attribute" />
				<xsl:apply-templates select="@* except (@href, @class)" />
				<xsl:value-of select="$commentary/@marker" />
			</span>
		</xsl:when>
		<xsl:when test="exists(ancestor::ref)">
			<span>
				<xsl:call-template name="add-class-attribute" />
				<xsl:apply-templates select="@* except (@href, @class)" />
				<xsl:value-of select="@marker" />
			</span>
			<xsl:text> </xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:call-template name="attrs" />
				<xsl:value-of select="@marker" />
			</a>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ref">
	<cite>
		<xsl:apply-templates select="@* except ( @eId, @href )" />	<!-- copying @eId would lead to duplicate ids within notes/commentaries -->
		<xsl:choose>
			<xsl:when test="exists(descendant::ref) or exists(ancestor::a) or exists(ancestor::tocItem)">
				<xsl:attribute name="data-href">
					<xsl:value-of select="@href" />
				</xsl:attribute>
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:apply-templates select="@href" />
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</cite>
</xsl:template>

<xsl:template match="rref">
	<cite>
		<xsl:apply-templates select="@* except @eId" />	<!-- copying @eId would lead to duplicate ids within notes/commentaries -->
		<xsl:choose>
			<xsl:when test="exists(descendant::ref) or exists(ancestor::a) or exists(ancestor::tocItem)">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="@from" />
					</xsl:attribute>
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</cite>
</xsl:template>

<xsl:template match="date | docDate">
	<time>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</time>
</xsl:template>

<xsl:template match="*">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>


<!-- markers -->

<!-- eol -> <wbr> -->


<!-- attributes -->

<xsl:template match="@eId">
	<xsl:attribute name="id">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@class | @title | @style | @src | @alt | @width | @height | @colspan | @rowspan">
	<xsl:copy />
</xsl:template>

<xsl:template match="@href">
	<xsl:attribute name="href">
		<xsl:value-of select="replace(., ' ', '%20')" />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@date">
	<xsl:attribute name="datetime">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@xml:lang">
	<xsl:attribute name="{ local-name() }">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@uk:*">	<!-- ldapp uses ukl: prefix for uk-akn namespace -->
	<xsl:attribute name="data-uk-{ local-name() }">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@*">
	<xsl:attribute name="data-{ translate(name(), ':', '-') }">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>


<!-- footnotes -->

<xsl:template name="footnotes">
	<xsl:variable name="footnotes" as="element(authorialNote)*" select="//authorialNote[@class='footnote']" />
	<xsl:if test="exists($footnotes)">
		<footer class="footnotes">
			<xsl:apply-templates select="$footnotes" mode="footnote" />
		</footer>
	</xsl:if>
</xsl:template>

<xsl:template match="authorialNote[@class='footnote']">
	<xsl:variable name="id" as="xs:string" select="if (@id) then @id else generate-id()" />
	<a class="fnRef" id="ref-{ $id }" href="#{ $id }">
		<xsl:choose>
			<xsl:when test="exists(@marker)">
				<xsl:value-of select="@marker" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="position()" />
			</xsl:otherwise>
		</xsl:choose>
	</a>
</xsl:template>

<xsl:template match="authorialNote" mode="footnote">
	<xsl:variable name="id" as="xs:string" select="if (@id) then @id else generate-id()" />
	<div>
		<xsl:call-template name="attrs" />
		<a class="marker" id="{ $id }" href="#ref-{ $id }">
			<xsl:choose>
				<xsl:when test="exists(@marker)">
					<xsl:value-of select="@marker" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="position()" />
				</xsl:otherwise>
			</xsl:choose>
		</a>
		<xsl:apply-templates />
	</div>
</xsl:template>

<!-- margin notes -->

<xsl:template match="authorialNote[@placement='side']">
	<div>
		<xsl:call-template name="attrs">
			<xsl:with-param name="classes" select="'marginalNote'" />
		</xsl:call-template>
		<xsl:apply-templates />
	</div>
</xsl:template>


<!-- text nodes -->

<xsl:template match="text()">
	<xsl:param name="start-quote-attr" as="attribute()?" tunnel="yes" />
	<xsl:param name="end-quote-attr" as="attribute()?" tunnel="yes" />
	<xsl:param name="first-text-node-of-quote" as="text()?" tunnel="yes" />
	<xsl:param name="last-text-node-of-quote" as="text()?"  tunnel="yes" />
	<xsl:param name="append-text" as="element()?" tunnel="yes" />
	<xsl:if test="exists($start-quote-attr) and . is $first-text-node-of-quote">
		<xsl:value-of select="$start-quote-attr" />
	</xsl:if>
	<xsl:variable name="value" as="xs:string" select="string(.)" />
	<xsl:variable name="value" as="xs:string" select="replace($value, '&#132;', '&#8222;')" />
	<xsl:variable name="value" as="xs:string" select="replace($value, '&#150;', '')" />	<!-- ukpga/2014/25/enacted -->
	<xsl:variable name="value" as="xs:string" select="replace($value, '&#157;', '')" />
	<xsl:value-of select="$value" />
	<!-- <xsl:value-of select="translate(., '&#157;', '')" /> -->
	<xsl:if test=". is $last-text-node-of-quote">
		<xsl:value-of select="$end-quote-attr" />
		<xsl:apply-templates select="$append-text/node()" />
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
