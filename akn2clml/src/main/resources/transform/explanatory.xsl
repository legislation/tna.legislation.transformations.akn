<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">


<xsl:template match="conclusions">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ExplanatoryNotes>
		<xsl:choose>
			<xsl:when test="exists(tblock[@class='para1']) and (every $child in * satisfies $child[self::heading or self::subheading or self::p or self::tblock[@class='para1']])">
				<xsl:call-template name="fix-explanatory-note" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('ExplanatoryNotes', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</ExplanatoryNotes>
</xsl:template>

<xsl:template name="fix-explanatory-note">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:apply-templates select="heading | subheading">
		<xsl:with-param name="context" select="('ExplanatoryNotes', $context)" tunnel="yes" />
	</xsl:apply-templates>
	<xsl:for-each-group select="* except (heading, subheading)" group-starting-with="p">
		<P>
			<xsl:apply-templates select="current-group()[1]">
				<xsl:with-param name="context" select="('P', 'ExplanatoryNotes', $context)" tunnel="yes" />
			</xsl:apply-templates>
			<xsl:apply-templates select="subsequence(current-group(), 2)">
				<xsl:with-param name="context" select="('P', 'ExplanatoryNotes', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</P>
	</xsl:for-each-group>
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes')]/subheading" name="en-comment">
	<Comment>
		<Para>
			<Text>
				<xsl:apply-templates />
			</Text>
		</Para>
	</Comment>
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes','earlierOrders','commencementHistory')]//tblock[not(@class=('figure','image','table','tabular'))]" priority="1">
	<xsl:call-template name="en-structure" />
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('explanatoryNote','explanatoryNotes','earlierOrders','commencementHistory')]//blockContainer" name="en-structure" priority="1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" as="xs:string">
		<xsl:variable name="classes" as="xs:string*" select="tokenize(@class, ' ')" />
		<xsl:choose>
			<xsl:when test="exists(@ukl:Name)">
				<xsl:sequence select="@ukl:Name" />
			</xsl:when>
			<xsl:when test="$classes = 'prov1'">
				<xsl:sequence select="'P1'" />
			</xsl:when>
			<xsl:when test="$classes = 'prov2'">
				<xsl:sequence select="'P2'" />
			</xsl:when>
			<xsl:when test="$classes = 'para1'">
				<xsl:sequence select="'P3'" />
			</xsl:when>
			<xsl:when test="$classes = 'para2'">
				<xsl:sequence select="'P4'" />
			</xsl:when>
			<xsl:when test="$classes = 'para3'">
				<xsl:sequence select="'P5'" />
			</xsl:when>
			<xsl:when test="$classes = 'para4'">
				<xsl:sequence select="'P6'" />
			</xsl:when>
			<xsl:when test="$classes = 'group1'">
				<xsl:sequence select="'P1group'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="'P'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:element name="{ $name }">
		<xsl:choose>
			<xsl:when test="$name = ('P1','P2','P3','P4','P5','P6') and exists(blockContainer)">
				<xsl:apply-templates select="num | heading | subheading">
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:variable name="para-name" select="concat($name, 'para')" />
				<xsl:element name="{ $para-name }">
					<xsl:apply-templates select="* except (num | heading | subheading)">
						<xsl:with-param name="context" select="($para-name, $name, $context)" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates>
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
</xsl:template>


<xsl:template match="blockList[@class='definition']">
	<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-list(., false())" />
	<UnorderedList Decoration="{ $decor }" Class="Definition">
		<xsl:apply-templates>
			<xsl:with-param name="decor" select="$decor" />
		</xsl:apply-templates>
	</UnorderedList>
</xsl:template>


<!-- earlier orders -->

<xsl:template match="blockContainer[tokenize(@class, ' ')=('earlierOrders','commencementHistory')]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<EarlierOrders>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('EarlierOrders', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</EarlierOrders>
</xsl:template>

<xsl:template match="blockContainer[tokenize(@class, ' ')=('earlierOrders','commencementHistory')]/subheading">
	<xsl:call-template name="en-comment" />
</xsl:template>

</xsl:transform>
