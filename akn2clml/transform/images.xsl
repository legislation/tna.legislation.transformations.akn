<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	xmlns:ldapp="ldapp"
	exclude-result-prefixes="xs ukl local ldapp">

<xsl:template match="tblock[child::tblock]" priority="3">
	<xsl:message><xsl:text>Pass through tblock with child tblock element</xsl:text></xsl:message>
	<xsl:apply-templates/>
</xsl:template>

<!-- MR 20230703: aims to rule out all scenarios where there is no text node and no p elements containing no nodes.
	Can't exclude ALL empty elements as some could be legitimate, such as <img/> -->
<xsl:template match="tblock[not(text()) and not(p/node()) and not(child::*[local-name() != 'p'])]" priority="2">
	<xsl:message><xsl:text>Suppress tblock with no text node or only p elements that contains no nodes</xsl:text></xsl:message>
</xsl:template>

<xsl:template match="tblock[tokenize(@class,' ')=('figure','image')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<Figure>
				<xsl:if test="exists(@ukl:Orientation)">
					<xsl:attribute name="Orientation">
						<xsl:value-of select="@ukl:Orientation" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="exists(@ukl:ImageLayout)">
					<xsl:attribute name="ImageLayout">
						<xsl:value-of select="@ukl:ImageLayout" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('Figure', local:get-block-wrapper($context), $context)" tunnel="yes" />
				</xsl:apply-templates>
			</Figure>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="tblock[tokenize(@class,' ')=('figure','image')]/p[exists(img) and count(node()) eq 1]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="img">
	<xsl:variable name="res-id" as="xs:string" select="local:make-resource-id(.)" />
	<xsl:variable name="style" as="attribute()?" select="@style" />
	<xsl:variable name="style-width" as="xs:string?">
		<xsl:if test="exists(@style)">
			<xsl:analyze-string select="$style" regex="width:([0-9\.A-Za-z]+)">
				<xsl:matching-substring>
					<xsl:sequence select="regex-group(1)" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:if>
	</xsl:variable>	
	<Image ResourceRef="{ $res-id }">
		<xsl:attribute name="Width">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Width)">
					<xsl:value-of select="@ukl:Width" />
				</xsl:when>
				<xsl:when test="exists(@width) and exists(@height) and ldapp:is-ldapp(root(.))">
					<xsl:value-of select="ldapp:scale-image-dimension(@width)" />
				</xsl:when>
				<xsl:when test="exists(@width)">
					<xsl:value-of select="@width" />
					<xsl:text>pt</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>auto</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="Height">
			<xsl:choose>
				<xsl:when test="exists(@ukl:Height)">
					<xsl:value-of select="@ukl:Height" />
				</xsl:when>
				<xsl:when test="exists(@height) and exists(@width) and ldapp:is-ldapp(root(.))">
					<xsl:value-of select="ldapp:scale-image-dimension(@height)" />
				</xsl:when>
				<xsl:when test="exists(@height)">
					<xsl:value-of select="@height" />
					<xsl:text>pt</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>auto</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="exists(@alt)">
			<xsl:attribute name="Description">
				<xsl:value-of select="@alt" />
			</xsl:attribute>
		</xsl:if>
	</Image>
</xsl:template>

<xsl:template match="tblock[tokenize(@class,' ')=('figure','image')]/container[@name='notes']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Notes>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Notes', $context)" />
		</xsl:apply-templates>
	</Notes>
</xsl:template>

<xsl:template match="tblock[tokenize(@class,' ')=('figure','image')]/container[@name='notes']/tblock[@class='note']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Footnote id="{ @eId }">
		<FootnoteText>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="('FootnoteText', 'Footnote', $context)" />
			</xsl:apply-templates>
		</FootnoteText>
	</Footnote>
</xsl:template>

</xsl:transform>
