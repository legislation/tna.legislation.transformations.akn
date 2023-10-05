<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">


<xsl:template name="para-with-amendment">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="children" as="node()*" select="node()" />
	<xsl:choose>
		<xsl:when test="exists($children[1][self::Text]) and exists($children[2][self::BlockAmendment])">
			<p>
				<mod>
					<xsl:apply-templates select="$children[1]/node()">
						<xsl:with-param name="context" select="('mod', 'p', $context)" tunnel="yes" />
					</xsl:apply-templates>
					<xsl:apply-templates select="$children[2]">
						<xsl:with-param name="context" select="('mod', 'p', $context)" tunnel="yes" />
					</xsl:apply-templates>
				</mod>
			</p>
			<xsl:apply-templates select="$children[position() gt 2]" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="add-start-quote-attribute">
	<xsl:choose>
		<xsl:when test="@Format = ('double', 'default')">
			<xsl:attribute name="startQuote">
				<xsl:text>“</xsl:text>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="@Format = 'single'">
			<xsl:attribute name="startQuote">
				<xsl:text>‘</xsl:text>
			</xsl:attribute>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="add-end-quote-attribute">
	<xsl:choose>
		<xsl:when test="@Format = ('double', 'default')">
			<xsl:attribute name="endQuote">
				<xsl:text>”</xsl:text>
			</xsl:attribute>
		</xsl:when>
		<xsl:when test="@Format = 'single'">
			<xsl:attribute name="endQuote">
				<xsl:text>’</xsl:text>
			</xsl:attribute>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="add-quote-attributes">
	<xsl:call-template name="add-start-quote-attribute" />
	<xsl:call-template name="add-end-quote-attribute" />
</xsl:template>

<xsl:template name="add-lawmaker-context-attributes">
	<xsl:attribute name="uk:context">
		<xsl:choose>
			<xsl:when test="@Context = 'main'">
				<xsl:sequence select="'body'" />
			</xsl:when>
			<xsl:when test="@Context = 'schedule'">
				<xsl:sequence select="'schedule'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="'unknown'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="uk:docName">
		<xsl:variable name="main-class" as="xs:string?" select="if (exists(@TargetClass)) then @TargetClass else @SourceClass" />
		<xsl:choose>
			<xsl:when test="$main-class = 'primary'">
				<xsl:choose>
					<xsl:when test="$doc-category = 'primary'">
						<xsl:sequence select="$doc-short-type" />
					</xsl:when>
					<xsl:when test="$doc-is-scottish">
						<xsl:sequence select="local:get-primary-scottish-type($doc-year)" />
					</xsl:when>
					<xsl:when test="$doc-is-welsh">
						<xsl:sequence select="local:get-primary-welsh-type($doc-year)" />
					</xsl:when>
					<xsl:when test="$doc-is-northern-irish">
						<xsl:sequence select="local:get-primary-northern-irish-type($doc-year)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="local:get-primary-uk-type($doc-year)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$main-class = 'secondary'">
				<xsl:choose>
					<xsl:when test="$doc-category = 'secondary'">
						<xsl:sequence select="$doc-short-type" />
					</xsl:when>
					<xsl:when test="$doc-is-scottish">
						<xsl:sequence select="local:get-secondary-scottish-type($doc-year)" />
					</xsl:when>
					<xsl:when test="$doc-is-welsh">
						<xsl:sequence select="local:get-secondary-welsh-type($doc-year)" />
					</xsl:when>
					<xsl:when test="$doc-is-northern-irish">
						<xsl:sequence select="local:get-secondary-northern-irish-type($doc-year)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="local:get-secondary-uk-type($doc-year)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$main-class = 'euretained'">
				<xsl:choose>
					<xsl:when test="$doc-category = 'euretained'">
						<xsl:sequence select="$doc-short-type" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="'eur'" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="'unknown'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:template>

<xsl:template name="add-uk-amendment-attributes">
	<xsl:attribute name="ukl:TargetClass">
		<xsl:value-of select="@TargetClass" />
	</xsl:attribute>
	<xsl:attribute name="ukl:TargetSubClass">
		<xsl:value-of select="@TargetSubClass" />
	</xsl:attribute>
	<xsl:attribute name="ukl:Context">
		<xsl:value-of select="@Context" />
	</xsl:attribute>
	<xsl:attribute name="ukl:Format">
		<xsl:value-of select="@Format" />
	</xsl:attribute>
</xsl:template>

<xsl:template match="BlockAmendment" mode="wrapped">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="lead-in" as="element(Text)?" select="*[1][self::Text][exists(following-sibling::*)]" />
	<xsl:choose>
		<xsl:when test="exists($lead-in)">
			<quotedText>
				<xsl:call-template name="add-start-quote-attribute" />
				<xsl:apply-templates select="$lead-in/node()">
					<xsl:with-param name="context" select="('quotedText', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</quotedText>
			<quotedStructure>
				<xsl:call-template name="add-end-quote-attribute" />
				<xsl:call-template name="add-lawmaker-context-attributes" />
				<xsl:call-template name="add-uk-amendment-attributes" />
				<xsl:apply-templates select="* except $lead-in">
					<xsl:with-param name="context" select="('quotedStructure', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</quotedStructure>
		</xsl:when>
		<xsl:otherwise>
			<quotedStructure>
				<xsl:call-template name="add-quote-attributes" />
				<xsl:call-template name="add-lawmaker-context-attributes" />
				<xsl:call-template name="add-uk-amendment-attributes" />
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('quotedStructure', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</quotedStructure>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="BlockAmendment">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="$context[1] = 'mod'">
			<xsl:apply-templates select="." mode="wrapped" />
			<xsl:apply-templates select="following-sibling::*[1][self::AppendText]" mode="force" />
		</xsl:when>
		<xsl:when test="$context[1] = 'p'">
			<mod>
				<xsl:apply-templates select=".">
					<xsl:with-param name="context" select="('mod', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</mod>
		</xsl:when>
		<xsl:otherwise>
			<p>
				<xsl:apply-templates select=".">
					<xsl:with-param name="context" select="('p', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</p>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="AppendText" />

<xsl:template match="AppendText" mode="force">
	<inline name="appendText">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Text[exists(InlineAmendment)]">
	<p>
		<mod>
			<xsl:apply-templates />
		</mod>
	</p>
</xsl:template>

<xsl:template match="InlineAmendment">
	<quotedText>
		<xsl:apply-templates />
	</quotedText>
</xsl:template>

<xsl:template match="FragmentNumber | FragmentTitle">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="BlockExtract">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<p>
		<embeddedStructure>
			<xsl:call-template name="add-quote-attributes" />
			<xsl:attribute name="ukl:SourceClass">
				<xsl:value-of select="@SourceClass" />
			</xsl:attribute>
			<xsl:if test="exists(@SourceSubClass)">
				<xsl:attribute name="ukl:SourceSubClass">
					<xsl:value-of select="@SourceSubClass" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="ukl:Context">
				<xsl:value-of select="@Context" />
			</xsl:attribute>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="('embeddedStructure', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</embeddedStructure>
		<xsl:apply-templates select="following-sibling::*[1][self::AppendText]" mode="force" />
	</p>
</xsl:template>

</xsl:transform>
