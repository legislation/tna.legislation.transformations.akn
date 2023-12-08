<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl html local">

<xsl:template match="tblock[@class=('table','tabular')] | tblock[foreign/html:table]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="wrapper" as="xs:string?" select="local:get-wrapper('Tabular', $context)" />
	<xsl:variable name="clml" as="element()">
		<Tabular Orientation="{ if (exists(@ukl:Orientation)) then @ukl:Orientation else 'portrait' }">
			<xsl:apply-templates select="num | heading | subheading">
				<xsl:with-param name="context" select="('Tabular', $wrapper, $context)" tunnel="yes" />
			</xsl:apply-templates>
			<xsl:variable name="table-text" as="element()*" select="foreign[1]/preceding-sibling::* except (num, heading, subheading)" />
			<xsl:if test="exists($table-text)">
				<TableText>
					<xsl:apply-templates select="$table-text">
						<xsl:with-param name="context" select="('TableText', 'Tabular', $wrapper, $context)" tunnel="yes" />
					</xsl:apply-templates>
				</TableText>
			</xsl:if>
			<xsl:apply-templates select="* except (num, heading, subheading, $table-text)">
				<xsl:with-param name="context" select="('Tabular', $wrapper, $context)" tunnel="yes" />
			</xsl:apply-templates>
		</Tabular>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="exists($wrapper)">
			<xsl:element name="{ $wrapper }">
				<xsl:copy-of select="$clml" />
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$clml" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="foreign">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:*">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:copy copy-namespaces="no">
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="(local-name(.), $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template match="html:tbody[1]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:if test="empty(preceding-sibling::html:tfoot)">
		<xsl:call-template name="table-footnotes">
			<xsl:with-param name="table" select="ancestor::html:table[1]" />
		</xsl:call-template>
	</xsl:if>
	<xsl:copy copy-namespaces="no">
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="(local-name(.), $context)" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template match="html:tfoot">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:copy copy-namespaces="no">
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates>
			<xsl:with-param name="context" select="(local-name(.), $context)" tunnel="yes" />
		</xsl:apply-templates>

		<xsl:variable name="table" as="element(html:table)" select="parent::*" />
		<xsl:variable name="table-notes" as="element(authorialNote)*" select="$table/descendant::authorialNote[tokenize(@class,' ')='tablenote']" />
		<xsl:if test="exists($table-notes)">
			<xsl:variable name="colspan" as="xs:integer" select="if (exists($table/html:colgroup)) then count($table/html:colgroup/html:col) else max($table/descendant::html:tr/count(html:td))" />
			<xsl:call-template name="add-rows-for-table-footnotes">
				<xsl:with-param name="table-notes" select="$table-notes" />
				<xsl:with-param name="colspan" select="$colspan" />
			</xsl:call-template>
		</xsl:if>
	</xsl:copy>
</xsl:template>

<xsl:template name="table-footnotes">
	<xsl:param name="table" as="element(html:table)" />
	<xsl:variable name="table-notes" as="element(authorialNote)*" select="$table/descendant::authorialNote[tokenize(@class,' ')='tablenote']" />
	<xsl:if test="exists($table-notes)">
		<xsl:variable name="colspan" as="xs:integer" select="if (exists($table/html:colgroup)) then count($table/html:colgroup/html:col) else max($table/descendant::html:tr/count(html:td))" />
		<tfoot xmlns="http://www.w3.org/1999/xhtml">
			<xsl:call-template name="add-rows-for-table-footnotes">
				<xsl:with-param name="table-notes" select="$table-notes" />
				<xsl:with-param name="colspan" select="$colspan" />
			</xsl:call-template>
		</tfoot>
	</xsl:if>
</xsl:template>

<xsl:template name="add-rows-for-table-footnotes">
	<xsl:param name="table-notes" as="element(authorialNote)*" />
	<xsl:param name="colspan" as="xs:integer" />
	<xsl:for-each select="$table-notes" >
		<tr>
			<td colspan="{ $colspan }">
				<xsl:apply-templates select="." mode="footnote" />
			</td>
		</tr>
	</xsl:for-each>
</xsl:template>

<!-- orphan table footnotes -->
<xsl:template match="html:tfoot//authorialNote[@placement='inline']">
	<xsl:apply-templates select="." mode="footnote" />
</xsl:template>


<!--  -->

<xsl:template match="html:p">
	<Para>
		<Text>
			<xsl:apply-templates />
		</Text>
	</Para>
</xsl:template>

<xsl:template match="html:i">
	<Emphasis>
		<xsl:apply-templates />
	</Emphasis>
</xsl:template>


<!-- attributes -->

<xsl:template match="html:*/@class" priority="1" /> <!-- "HTML" elements in CLML can't have a @class attribute -->

<xsl:template match="html:*/@*:eId | html:*/@*:GUID" priority="1" /> <!-- LDAPP uses these -->

<xsl:template match="html:th/@width | html:th/@height | html:td/@width | html:td/@height" priority="1">
	<xsl:attribute name="{ name() }">
		<xsl:choose>
			<xsl:when test="matches(., '^\d+$')">
				<xsl:value-of select="." />
				<xsl:text>px</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template match="html:*/@*">
	<xsl:copy-of select="." />
</xsl:template>

</xsl:transform>
