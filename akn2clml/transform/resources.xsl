<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl math local">


<xsl:key name="altimg" match="math:math" use="@altimg" />

<xsl:key name="imgsrc" match="img" use="@src" />

<xsl:variable name="versions" as="element()*">
	<xsl:sequence select="//*[@alternativeTo]" />
	<xsl:sequence select="//math:math[@altimg]" />
</xsl:variable>

<xsl:variable name="resources" as="element()*">
	<xsl:for-each-group select="//img" group-by="@src">
		<xsl:sequence select="." />
	</xsl:for-each-group>
	<xsl:sequence select="//math:math[@altimg]" />
	<xsl:sequence select="/akomaNtoso/*/components/component" />
</xsl:variable>

<xsl:function name="local:get-first-index-of-node" as="xs:integer?">
	<xsl:param name="n" as="node()" />
	<xsl:param name="nodes" as="node()*" />
	<xsl:variable name="index" as="xs:integer*">
		<xsl:for-each select="$nodes">
			<xsl:if test=". is $n">
				<xsl:sequence select="position()" />
			</xsl:if>
		</xsl:for-each> 
	</xsl:variable>
	<xsl:sequence select="$index[1]" />
</xsl:function>

<xsl:function name="local:make-version-id">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="index" as="xs:integer?" select="local:get-first-index-of-node($e, $versions)" />
	<xsl:variable name="num" as="xs:integer" select="if (exists($index)) then $index else 0" />
	<xsl:value-of select="concat('v', format-number($num,'00000'))" />
</xsl:function>

<xsl:function name="local:make-resource-id">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="e" as="element()" select="if ($e/self::img) then key('imgsrc', $e/@src, root($e))[1] else $e" />
	<xsl:variable name="index" as="xs:integer?" select="local:get-first-index-of-node($e, $resources)" />
	<xsl:variable name="num" as="xs:integer" select="if (exists($index)) then $index else 0" />
	<xsl:value-of select="concat('r', format-number($num,'00000'))" />
</xsl:function>

<xsl:template name="resources">
	<xsl:if test="exists($resources)">
		<xsl:if test="exists($versions)">
			<Versions>
				<xsl:apply-templates select="$versions" mode="version" />
			</Versions>
		</xsl:if>
		<Resources>
			<xsl:apply-templates select="$resources" mode="resource" />
		</Resources>
	</xsl:if>
</xsl:template>

<xsl:template match="img" mode="resource">
	<Resource id="r{format-number(position(),'00000')}">
		<ExternalVersion URI="{ @src }" />
	</Resource>
</xsl:template>

<xsl:template match="math:math" mode="version">
	<Version id="v{format-number(position(),'00000')}">
		<Figure>
			<Image ResourceRef="{ local:make-resource-id(.) }" Height="auto" Width="auto" />
		</Figure>
	</Version>
</xsl:template>

<xsl:template match="math:math" mode="resource">
	<Resource id="r{format-number(position(),'00000')}">
		<ExternalVersion URI="{ @altimg }" />
	</Resource>
</xsl:template>


<!-- alternative versions -->

<xsl:key name="alternative-to" match="*" use="@alternativeTo" />

<xsl:template name="alt-version-refs">
	<xsl:if test="exists(@eId)">
		<xsl:variable name="alternatives" as="element()*" select="key('alternative-to', @eId)" />
		<xsl:if test="exists($alternatives)">
			<xsl:attribute name="AltVersionRefs">
				<xsl:value-of select="string-join($alternatives/local:make-version-id(.), ' ')" />
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template match="*[exists(@alternativeTo)]" priority="100">
	<xsl:param name="version" as="xs:boolean" select="false()" />
	<xsl:if test="$version">
		<Version id="v{format-number(position(),'00000')}">
			<xsl:if test="exists(@ukl:Description)">
				<xsl:attribute name="Description">
					<xsl:value-of select="@ukl:Description" />
				</xsl:attribute>
			</xsl:if>
			<xsl:next-match />
		</Version>
	</xsl:if>
</xsl:template>

<xsl:template match="*[exists(@alternativeTo)]" mode="version">
	<xsl:param name="version" as="xs:boolean" select="false()" />
	<xsl:apply-templates select=".">
		<xsl:with-param name="version" select="true()" />
	</xsl:apply-templates>
</xsl:template>


<!-- components / IncludedDocuments -->

<xsl:template match="componentRef">
	<xsl:variable name="id" as="xs:string" select="substring(@src, 2)" />
	<xsl:variable name="resource" as="element()" select="key('id', $id)" />
	<IncludedDocument ResourceRef="{ local:make-resource-id($resource) }" />
</xsl:template>

<xsl:template match="component" mode="resource">
	<Resource id="r{format-number(position(),'00000')}">
		<InternalVersion>
			<XMLcontent>
				<xsl:apply-templates mode="component">
					<xsl:with-param name="context" select="('Resource')" tunnel="yes" />
				</xsl:apply-templates>
			</XMLcontent>
		</InternalVersion>
	</Resource>
</xsl:template>

<xsl:template match="toc" mode="component">
	<xsl:apply-templates select="." />
</xsl:template>

<xsl:template match="interstitial | p" mode="component">
	<xsl:apply-templates mode="component" />
</xsl:template>

<xsl:template match="subFlow" mode="component">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
