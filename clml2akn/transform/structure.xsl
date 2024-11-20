<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl html local">


<xsl:variable name="mapping" as="element()">
	<Legislation xmlns="">
		<primary>
			<P1 akn="section" />
			<P2 akn="subsection" />
		</primary>
		<secondary>
			<order> <!-- use if 'unknown' or 'scheme' -->
				<P1 akn="article" />
				<P2 akn="paragraph" />
			</order>
			<regulation>
				<P1 akn="regulation" />
				<P2 akn="paragraph" />
			</regulation>
			<rule>
				<P1 akn="rule" />
				<P2 akn="paragraph" />
			</rule>
		</secondary>
		<schedule>
			<P1 akn="paragraph" />
			<P2 akn="subparagraph" />
		</schedule>
		<euretained>
			<P1 akn="article" />
			<P2 akn="paragraph" />
		</euretained>
	</Legislation>
</xsl:variable>

<xsl:function name="local:make-hcontainer-name" as="xs:string?">
	<xsl:param name="doc-class" as="xs:string" />
	<xsl:param name="doc-subclass" as="xs:string?" />
	<xsl:param name="schedule" as="xs:boolean" />
	<xsl:param name="clml-element-name" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$clml-element-name = ('P3', 'P4', 'P5', 'P6')">
			<xsl:sequence select="'level'" />
		</xsl:when>
		<xsl:when test="$schedule">
			<xsl:sequence select="$mapping/*:schedule/*[local-name()=$clml-element-name]/@akn" />
		</xsl:when>
		<xsl:when test="$doc-class = 'secondary'">
			<xsl:variable name="doc-subclass" as="xs:string" select="if (empty($doc-subclass) or ($doc-subclass = ('unknown','scheme'))) then 'order' else $doc-subclass" />
			<xsl:sequence select="$mapping/*:secondary/*[local-name()=$doc-subclass]/*[local-name()=$clml-element-name]/@akn" />
		</xsl:when>
		<xsl:when test="$doc-class = 'euretained'">
			<xsl:sequence select="$mapping/*:euretained/*[local-name()=$clml-element-name]/@akn" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$mapping/*:primary/*[local-name()=$clml-element-name]/@akn" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:make-hcontainer-class" as="xs:string?">
	<xsl:param name="clml-element-name" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$clml-element-name = 'P3'">
			<xsl:sequence select="'para1'" />
		</xsl:when>
		<xsl:when test="$clml-element-name = 'P4'">
			<xsl:sequence select="'para2'" />
		</xsl:when>
		<xsl:when test="$clml-element-name = 'P5'">
			<xsl:sequence select="'para3'" />
		</xsl:when>
		<xsl:when test="$clml-element-name = 'P6'">
			<xsl:sequence select="'para4'" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:clml-is-within-schedule" as="xs:boolean">
	<xsl:param name="clml" as="element()" />
	<xsl:choose>
		<xsl:when test="empty($clml/parent::*)">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="$clml/parent::Schedule">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$clml/parent::BlockAmendment">
			<xsl:sequence select="$clml/parent::*/@Context = 'schedule'" />
		</xsl:when>
		<xsl:when test="$clml/parent::html:td">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:clml-is-within-schedule($clml/parent::*)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- better would be to pass this down as a tunnel parameter as in akn2html -->
<xsl:function name="local:effective-document-class" as="xs:string">
	<xsl:param name="clml" as="element()" />
	<xsl:variable name="block-amendment" as="element(BlockAmendment)?" select="$clml/ancestor::BlockAmendment[1]" />
	<xsl:choose>
		<xsl:when test="exists($block-amendment)">
			<xsl:variable name="target-class" as="attribute()?" select="$block-amendment/@TargetClass" />
			<xsl:choose>
				<xsl:when test="empty($target-class)">
					<xsl:sequence select="$doc-category" />
				</xsl:when>
				<xsl:when test="$target-class = 'unknown'">
					<xsl:sequence select="$doc-category" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="string($target-class)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="block-extract" as="element(BlockExtract)?" select="$clml/ancestor::BlockExtract[1]" />
			<xsl:choose>
				<xsl:when test="exists($block-extract)">
					<xsl:variable name="source-class" as="attribute()?" select="$block-extract/@SourceClass" />
					<xsl:choose>
						<xsl:when test="empty($source-class)">
							<xsl:sequence select="$doc-category" />
						</xsl:when>
						<xsl:when test="$source-class = 'unknown'">
							<xsl:sequence select="$doc-category" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="string($source-class)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$doc-category" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:make-hcontainer-name" as="xs:string?">
	<xsl:param name="clml" as="element()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:variable name="block-amendment" as="element()?" select="$clml/ancestor::BlockAmendment[1]" />
	<xsl:variable name="doc-class" as="xs:string" select="local:effective-document-class($clml)" />
	<xsl:variable name="doc-subclass" as="xs:string?">
		<xsl:choose>
			<xsl:when test="exists($block-amendment)">
				<xsl:sequence select="$block-amendment/@TargetSubClass" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$doc-minor-type" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="within-schedule" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="local:clml-is-within-schedule($clml)">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:when test="exists($block-amendment)">
				<xsl:sequence select="$block-amendment/@Context = 'schedule'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="clml-element-name" as="xs:string">
		<xsl:choose>
			<xsl:when test="ends-with(local-name($clml), 'group')">
				<xsl:value-of select="substring-before(local-name($clml), 'group')" />
			</xsl:when>
			<xsl:when test="$clml/self::P/parent::Pblock or $clml/self::P/parent::PsubBlock">
				<xsl:sequence select="'P1'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="local-name($clml)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="local:make-hcontainer-name($doc-class, $doc-subclass, $within-schedule, $clml-element-name)" />
</xsl:function>


<xsl:function name="local:struct-has-structural-children" as="xs:boolean">
	<xsl:param name="parent" as="element()" />
	<xsl:variable name="paras" as="element()*" select="$parent/*[local:element-is-para(.)]" />
	<xsl:value-of select="exists($parent/*[local:element-is-structural(.)]) or exists($paras/*[local:element-is-structural(.)])" />
</xsl:function>

<xsl:function name="local:flatten-children" as="element()*">
	<xsl:param name="parent" as="element()" />
	<xsl:for-each select="$parent/*">
		<xsl:choose>
			<xsl:when test="self::Number or self::Pnumber or self::Title or self::Subtitle" />
			<xsl:when test="self::Reference" /> <!-- for schedule parts -->
			<xsl:when test="local:element-is-para(.)">
				<xsl:sequence select="local:flatten-children(.)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:function>

<xsl:function name="local:get-intro-elements" as="element()*">
	<xsl:param name="children" as="element()*" />
	<xsl:if test="exists($children)">
		<xsl:variable name="first-child" as="element()" select="$children[1]" />
		<xsl:if test="not(local:element-is-structural($first-child))">
			<xsl:sequence select="($first-child, local:get-intro-elements(subsequence($children, 2)))" />
		</xsl:if>
	</xsl:if>
</xsl:function>

<xsl:function name="local:get-wrapup-elements" as="element()*">
	<xsl:param name="children" as="element()*" />
	<xsl:if test="exists($children)">
		<xsl:variable name="last-child" as="element()" select="$children[last()]" />
		<xsl:if test="not(local:element-is-structural($last-child))">
			<xsl:sequence select="(local:get-wrapup-elements($children[position() lt last()]), $last-child)" />
		</xsl:if>
	</xsl:if>
</xsl:function>

<xsl:function name="local:children-must-be-divided" as="xs:boolean">
	<xsl:param name="children" as="element()*" />
	<xsl:param name="found-first-structural-child" as="xs:boolean" />
	<xsl:param name="found-first-wrapup" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="empty($children)">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="head" as="element()" select="$children[1]" />
			<xsl:variable name="tail" as="element()*" select="subsequence($children, 2)" />
			<xsl:choose>
				<xsl:when test="$found-first-wrapup">
					<xsl:choose>
						<xsl:when test="local:element-is-structural($head)">
							<xsl:sequence select="true()" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="local:children-must-be-divided($tail, true(), true())" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$found-first-structural-child">
					<xsl:choose>
						<xsl:when test="local:element-is-structural($head)">
							<xsl:sequence select="local:children-must-be-divided($tail, true(), false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="local:children-must-be-divided($tail, true(), true())" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="local:element-is-structural($head)">
							<xsl:sequence select="local:children-must-be-divided($tail, true(), false())" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="local:children-must-be-divided($tail, false(), false())" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:children-must-be-divided" as="xs:boolean">
	<xsl:param name="children" as="element()*" />
	<xsl:sequence select="local:children-must-be-divided($children, false(), false())" />
</xsl:function>

<xsl:function name="local:get-frist-group-of-children" as="element()*">
	<xsl:param name="children" as="element()*" />
	<xsl:param name="found-first-structural-child" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="empty($children)">
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="head" as="element()" select="$children[1]" />
			<xsl:variable name="tail" as="element()*" select="subsequence($children, 2)" />
			<xsl:choose>
				<xsl:when test="local:element-is-structural($head)">
					<xsl:sequence select="($head, local:get-frist-group-of-children($tail, true()))" />
				</xsl:when>
				<xsl:when test="not($found-first-structural-child)">
					<xsl:sequence select="($head, local:get-frist-group-of-children($tail, false()))" />
				</xsl:when>
				<xsl:when test="exists($tail[local:element-is-structural(.)])">
					<xsl:sequence select="()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="$children" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-frist-group-of-children" as="element()*">
	<xsl:param name="children" as="element()*" />
	<xsl:sequence select="local:get-frist-group-of-children($children, false())" />
</xsl:function>

<xsl:template name="divide-children-and-wrap">
	<xsl:param name="children" as="element()+" />
	<xsl:param name="first-group" as="element()+" select="local:get-frist-group-of-children($children)" />
	<xsl:param name="rest" as="element()*" select="$children except $first-group" />
	<hcontainer name="wrapper2">
		<xsl:call-template name="handle-one-group-of-children">
			<xsl:with-param name="children" select="$first-group" />
		</xsl:call-template>
	</hcontainer>
	<xsl:if test="exists($rest)">
		<xsl:call-template name="divide-children-and-wrap">
			<xsl:with-param name="children" select="$rest" />
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template name="handle-one-group-of-children">
	<xsl:param name="children" as="element()+" />
	<xsl:variable name="intro" as="element()*" select="local:get-intro-elements($children)" />
	<xsl:variable name="wrapup" as="element()*" select="local:get-wrapup-elements($children)" />
	<xsl:if test="exists($intro)">
		<intro>
			<xsl:apply-templates select="$intro" />
		</intro>
	</xsl:if>
	<xsl:apply-templates select="$children except $intro except $wrapup" />
	<xsl:if test="exists($wrapup)">
		<wrapUp>
			<xsl:apply-templates select="$wrapup" />
		</wrapUp>
	</xsl:if>
</xsl:template>

<xsl:template name="hcontainer-body">
	<xsl:choose>
		<!-- hcontainer[@name='wrapper1'] maps P?paras where more than one sibling contain structural children -->
		<xsl:when test="count(*[local:element-is-para(.)][exists(*[local:element-is-structural(.)])]) gt 1">
			<xsl:apply-templates select="* except (Number | Pnumber | Title | Subtitle)" mode="wrapper1" />
		</xsl:when>
		<xsl:when test="local:struct-has-structural-children(.)">
			<xsl:variable name="children" as="element()+" select="local:flatten-children(.)" />
			<xsl:choose>
				<!-- hcontainer[@name='wrapper2'] wraps groups of numbered paragraphs that are siblings but separated by content -->
				<xsl:when test="local:children-must-be-divided($children)">
					<xsl:call-template name="divide-children-and-wrap">
						<xsl:with-param name="children" select="$children" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="handle-one-group-of-children">
						<xsl:with-param name="children" select="$children" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="exists(IncludedDocument)">
			<xsl:variable name="headings" as="element()*" select="Number | Pnumber | Title | Subtitle" />
			<xsl:apply-templates select="* except ($headings | Reference)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="headings" as="element()*" select="Number | Pnumber | Title | Subtitle" />
			<content>
				<xsl:apply-templates select="* except ($headings | Reference)" />
			</content>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="wrapper1">
	<hcontainer name="wrapper1">
		<xsl:call-template name="hcontainer-body" />
	</hcontainer>
</xsl:template>

<xsl:function name="local:heading-before-number" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::P1 and local:effective-document-class($e) = 'secondary'">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::P1 and local:clml-is-within-schedule($e)">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="hcontainer">
	<xsl:param name="skipped-pgroup-title" as="xs:boolean" select="false()" />
	<xsl:call-template name="add-structure-attributes" />
	<xsl:choose>
		<xsl:when test="local:heading-before-number(.)">
			<xsl:if test="$skipped-pgroup-title">
				<xsl:apply-templates select="parent::*/Title" />
			</xsl:if>
			<xsl:apply-templates select="Title | Subtitle" />
			<xsl:apply-templates select="Number | Pnumber" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="Number | Pnumber" />
			<xsl:if test="$skipped-pgroup-title">
				<xsl:apply-templates select="parent::*/Title" />
			</xsl:if>
			<xsl:apply-templates select="Title | Subtitle" />
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="hcontainer-body" />
</xsl:template>


<!-- attributes -->

<xsl:template name="add-structure-attributes">
	<xsl:call-template name="add-internal-id" />
	<xsl:call-template name="add-alt-attr" />
</xsl:template>


<!-- matching templates -->

<xsl:template match="Group">
	<hcontainer name="groupOfParts">
		<xsl:call-template name="hcontainer" />
	</hcontainer>
</xsl:template>

<xsl:template match="Part">
	<part>
		<xsl:call-template name="hcontainer" />
	</part>
</xsl:template>

<xsl:template match="Chapter">
	<chapter>
		<xsl:call-template name="hcontainer" />
	</chapter>
</xsl:template>

<xsl:template match="Pblock">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(Number) and (local:effective-document-class(.) = 'secondary' or local:clml-is-within-schedule(.))">
			<section ukl:Name="Pblock">
				<xsl:call-template name="hcontainer">
					<xsl:with-param name="context" select="('section', $context)" tunnel="yes" />
				</xsl:call-template>
			</section>
		</xsl:when>
		<!-- consider treating as P1group in certain cases, e.g., asp/2018/9/2018-06-02 -->
		<!-- exists(previous-sibling::P1) and exists(Title) and exists(P1) and (every $child in * satisfies $child]) and (count(P1) eq 1) -->
		<xsl:otherwise>
			<hcontainer name="crossheading" ukl:Name="Pblock">
				<xsl:call-template name="hcontainer">
					<xsl:with-param name="context" select="('crossheading', $context)" tunnel="yes" />
				</xsl:call-template>
			</hcontainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="PsubBlock">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(Number) and (local:effective-document-class(.) = 'secondary' or local:clml-is-within-schedule(.))">
			<subsection ukl:Name="PsubBlock">
				<xsl:call-template name="hcontainer">
					<xsl:with-param name="context" select="('subsection', $context)" tunnel="yes" />
				</xsl:call-template>
			</subsection>
		</xsl:when>
		<xsl:otherwise>
			<hcontainer name="subheading" ukl:Name="PsubBlock">
				<xsl:call-template name="hcontainer">
					<xsl:with-param name="context" select="('subheading', $context)" tunnel="yes" />
				</xsl:call-template>
			</hcontainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Group/Number | Part/Number | Chapter/Number | Pblock/Number | PsubBlock/Number">
	<num>
		<xsl:apply-templates />
		<xsl:apply-templates select="../Reference" />
	</num>
</xsl:template>

<xsl:template match="Group/Title | Part/Title | Chapter/Title | Pblock/Title | PsubBlock/Title">
	<xsl:choose>
		<xsl:when test="exists(preceding-sibling::Number)">
			<xsl:next-match />
		</xsl:when>
		<xsl:otherwise>
			<heading>
				<xsl:apply-templates />
				<xsl:apply-templates select="../Reference" />
			</heading>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!--  -->

<xsl:template match="P1group">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="local:clml-is-within-schedule(.)">
			<xsl:variable name="name" as="xs:string" select="if ($context[1] = 'crossheading') then 'subheading' else 'crossheading'" />
			<hcontainer name="{ $name }" class="schGroup7">
				<xsl:call-template name="hcontainer">
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:call-template>
			</hcontainer>
			<xsl:call-template name="insert-alt-versions" />
		</xsl:when>
		<xsl:when test="exists(parent::*/P1group[count(P1) gt 1])">
			<xsl:variable name="name" as="xs:string" select="if ($context[1] = 'crossheading') then 'subheading' else 'crossheading'" />
			<hcontainer name="{ $name }" ukl:Name="P1group">
				<xsl:call-template name="hcontainer">
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:call-template>
			</hcontainer>
			<xsl:call-template name="insert-alt-versions" />
		</xsl:when>
		<xsl:when test="empty(P1)">
			<xsl:if test="exists(*[local:element-is-structural(.)])">
				<xsl:message terminate="yes">
					<xsl:sequence select="." />
				</xsl:message>
			</xsl:if>
			<xsl:variable name="name" as="xs:string" select="local:make-hcontainer-name(., $context)" />
			<xsl:element name="{ if ($name = $unsupported) then 'hcontainer' else $name }">
				<xsl:if test="$name = $unsupported">
					<xsl:attribute name="name">
						<xsl:value-of select="$name" />
					</xsl:attribute>
				</xsl:if>
				<xsl:call-template name="add-structure-attributes" />
				<!-- add the LDAPP class attributes where necessary -->
				<xsl:if test="local:clml-is-within-schedule(.)">
					<xsl:attribute name="class">
						<xsl:text>schProv1</xsl:text>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="normalize-space(Title)">
					<xsl:apply-templates select="Title">
						<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:if>
				<xsl:call-template name="hcontainer-body">
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:call-template>
			</xsl:element>
			<xsl:call-template name="insert-alt-versions" />
		</xsl:when>
		<xsl:otherwise> <!-- there is only one P1 -->
			<xsl:apply-templates select="*[not(self::Title)]">
				<xsl:with-param name="inherit-from-p1group" select="true()" />
				<xsl:with-param name="skipped-pgroup-title" select="true()" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:variable name="unsupported" as="xs:string*" select="('regulation')" />

<xsl:template match="P1">
	<xsl:param name="inherit-from-p1group" as="xs:boolean" select="false()" />
	<xsl:param name="skipped-pgroup-title" as="xs:boolean" select="false()" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="local:make-hcontainer-name(., $context)" />
	<xsl:variable name="alt-version-anchor" as="element()" select="if (empty(@AltVersionRefs) and $inherit-from-p1group) then .. else ." />
	<xsl:element name="{ if ($name = $unsupported) then 'hcontainer' else $name }">
		<xsl:if test="$name = $unsupported">
			<xsl:attribute name="name">
				<xsl:value-of select="$name" />
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="add-internal-id" />
		<xsl:call-template name="add-alt-attr">
			<xsl:with-param name="e" select="$alt-version-anchor" />
		</xsl:call-template>
		<!-- add the LDAPP class attributes where necessary -->
		<xsl:if test="local:clml-is-within-schedule(.)">
			<xsl:attribute name="class">
				<xsl:text>schProv1</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="hcontainer">
			<xsl:with-param name="skipped-pgroup-title" select="$skipped-pgroup-title" />
			<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:call-template>
	</xsl:element>
	<xsl:call-template name="insert-alt-versions">
		<xsl:with-param name="alt-version-refs" select="$alt-version-anchor/@AltVersionRefs" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="P2group">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="every $sibling in parent::*/P2group satisfies count($sibling/child::P2) eq 1">
			<xsl:apply-templates select="*[not(self::Title)]">
				<xsl:with-param name="skipped-pgroup-title" select="true()" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<hcontainer name="P2group">
				<xsl:call-template name="hcontainer" />
			</hcontainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P3group">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="every $sibling in parent::*/P3group satisfies count($sibling/child::P3) eq 1">
			<xsl:apply-templates select="*[not(self::Title)]">
				<xsl:with-param name="skipped-pgroup-title" select="true()" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<hcontainer name="P3group">
				<xsl:call-template name="hcontainer" />
			</hcontainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P2 | P3 | P4 | P5 | P6 | Pblock/P | PsubBlock/P">
	<xsl:param name="skipped-pgroup-title" as="xs:boolean" select="false()" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string" select="local:make-hcontainer-name(., $context)" />
	<xsl:element name="{ if ($name = $unsupported) then 'hcontainer' else $name }">
		<xsl:if test="$name = $unsupported">
			<xsl:attribute name="name">
				<xsl:value-of select="$name" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="$name = 'level'">
			<xsl:attribute name="class">
				<xsl:value-of select="local:make-hcontainer-class(local-name(.))" />
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="hcontainer">
			<xsl:with-param name="skipped-pgroup-title" select="$skipped-pgroup-title" />
		</xsl:call-template>
	</xsl:element>
</xsl:template>

<xsl:template match="P">
	<xsl:apply-templates />
</xsl:template>


<!-- schedules -->

<xsl:template match="Schedules">
	<hcontainer name="schedules">
		<xsl:call-template name="add-internal-id-if-necessary" />
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="Abstract">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<hcontainer name="abstract">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('abstract', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</hcontainer>
</xsl:template>

<xsl:template match="AbstractBody">
	<content>
		<xsl:apply-templates />
	</content>
</xsl:template>

<xsl:template match="Schedule">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<hcontainer name="schedule">
		<xsl:call-template name="add-structure-attributes" />
		<xsl:apply-templates select="*[not(self::Reference)]">
			<xsl:with-param name="context" select="('schedule', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</hcontainer>
</xsl:template>

<xsl:template match="Schedule/Number">
	<num>
		<xsl:apply-templates />
		<xsl:apply-templates select="../Reference" />
	</num>
</xsl:template>

<xsl:template match="Reference">
	<authorialNote class="referenceNote">
		<p>
			<xsl:apply-templates />
		</p>
	</authorialNote>
</xsl:template>

<xsl:template match="ScheduleBody">
	<xsl:choose>
		<xsl:when test="exists(following-sibling::Appendix)">
			<hcontainer name="scheduleBody">
				<xsl:call-template name="hcontainer-body" />
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="hcontainer-body" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- appendices -->

<xsl:template match="Appendix">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<hcontainer name="appendix">
		<xsl:call-template name="add-structure-attributes" />
		<xsl:apply-templates select="*[not(self::Reference)]">
			<xsl:with-param name="context" select="('appendix', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</hcontainer>
</xsl:template>

<xsl:template match="Appendix/Number">
	<num>
		<xsl:apply-templates />
		<xsl:apply-templates select="../Reference" />
	</num>
</xsl:template>

<xsl:template match="Appendix[exists(Reference)][empty(Number)]/TitleBlock/Title[1]">
	<heading>
		<xsl:apply-templates />
		<xsl:apply-templates select="../Reference" />
	</heading>
</xsl:template>

<xsl:template match="AppendixBody">
	<xsl:choose>
		<xsl:when test="exists(following-sibling::Appendix)">
			<hcontainer name="appendixBody">
				<xsl:call-template name="hcontainer-body" />
			</hcontainer>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="hcontainer-body" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- numbers and headings -->

<xsl:template match="Number | Pnumber">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<num>
		<xsl:if test="parent::FragmentNumber">
			<xsl:attribute name="ukl:Context">
				<xsl:value-of select="parent::*/@Context" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists(parent::BlockAmendment) or exists(parent::BlockExtract)">
			<xsl:attribute name="ukl:Name">
				<xsl:value-of select="local-name(.)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('num', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</num>
</xsl:template>

<xsl:template match="TitleBlock">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Title">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<heading>
		<xsl:if test="parent::FragmentTitle">
			<xsl:attribute name="ukl:Context">
				<xsl:value-of select="parent::*/@Context" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('heading', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</heading>
</xsl:template>

<xsl:template match="Subtitle">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<subheading>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('heading', $context)" tunnel="yes" /> <!-- didn't use 'subheading' to distinguish from hcontainer[@name='subheading'] -->
		</xsl:apply-templates>
	</subheading>
</xsl:template>

</xsl:transform>
