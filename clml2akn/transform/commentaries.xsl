<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk ukl local">


<xsl:template name="notes">
	<xsl:variable name="all-unique-commentary-ids-in-reference-order" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="( //CommentaryRef | //*[exists(@CommentaryRef)] )" />
		<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
			<xsl:for-each select="$all-elements">
				<xsl:choose>
					<xsl:when test="self::CommentaryRef">
						<xsl:sequence select="string(@Ref)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="string(@CommentaryRef)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
			<xsl:sequence select="." />
		</xsl:for-each-group>
	</xsl:variable>
	
	<xsl:variable name="all-commentaries-in-reference-order" as="element(Commentary)*">
		<xsl:variable name="root" as="document-node()" select="root()" />
		<xsl:for-each select="$all-unique-commentary-ids-in-reference-order">
			<xsl:sequence select="key('id', ., $root)[self::Commentary]" />	<!-- self::Commentary only b/c of errors, e.g., in ukpga/1974/7 -->
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="all-unique-margin-note-ids-in-reference-order" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="//MarginNoteRef" />
		<xsl:variable name="all-margin-note-ids-with-duplicates" as="xs:string*">
			<xsl:for-each select="$all-elements">
				<xsl:sequence select="string(@Ref)" />
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each-group select="$all-margin-note-ids-with-duplicates" group-by=".">
			<xsl:sequence select="." />
		</xsl:for-each-group>
	</xsl:variable>

	<xsl:variable name="all-margin-notes-in-reference-order" as="element(MarginNote)*">
		<xsl:variable name="root" as="document-node()" select="root()" />
		<xsl:for-each select="$all-unique-margin-note-ids-in-reference-order">
			<xsl:sequence select="key('id', ., $root)" />
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:if test="exists($all-commentaries-in-reference-order) or exists($all-margin-notes-in-reference-order)">
		<notes source="#">
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='I']" />
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='X']" />
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='E']" />
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='F']" />
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='C']" />
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='M']" />
			<xsl:apply-templates select="$all-margin-notes-in-reference-order" />
			<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='P']" />
		</notes>
	</xsl:if>
</xsl:template>

<xsl:template match="Commentaries" />

<xsl:template match="Commentary">
	<note ukl:Name="Commentary" ukl:Type="{ @Type }">
		<xsl:attribute name="class">
			<xsl:text>commentary </xsl:text>
			<xsl:value-of select="@Type" />
		</xsl:attribute>
		<xsl:attribute name="eId">
			<xsl:value-of select="@id" />
		</xsl:attribute>
		<xsl:attribute name="marker">
			<xsl:value-of select="@Type" />
			<xsl:value-of select="position()" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'note'" tunnel="yes" />
		</xsl:apply-templates>
	</note>
</xsl:template>

<xsl:template match="Group | Part | Chapter | Pblock | PsubBlock | EUPart | EUTitle | EUChapter | EUSection | EUSubsection" mode="other-analysis">
	<xsl:variable name="id" as="xs:string" select="if (exists(@id)) then @id else generate-id()" />
	<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="( self::*[exists(@CommentaryRef)] | child::CommentaryRef | Number/descendant-or-self::*[exists(@CommentaryRef)] | Number/descendant::CommentaryRef | Title/descendant-or-self::*[exists(@CommentaryRef)] | Title/descendant::CommentaryRef )" />
		<xsl:for-each select="$all-elements">
			<xsl:choose>
				<xsl:when test="self::CommentaryRef">
					<xsl:sequence select="string(@Ref)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="string(@CommentaryRef)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
		<uk:commentary href="#{ $id }" refersTo="#{ . }" />
	</xsl:for-each-group>
	<xsl:apply-templates mode="other-analysis" />
</xsl:template>

<xsl:template match="P1" mode="other-analysis">
	<xsl:variable name="id" as="xs:string" select="if (exists(@id)) then @id else generate-id()" />
	<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="( descendant-or-self::*[exists(@CommentaryRef)] | descendant::CommentaryRef )" />
		<xsl:for-each select="$all-elements">
			<xsl:choose>
				<xsl:when test="self::CommentaryRef">
					<xsl:sequence select="string(@Ref)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="string(@CommentaryRef)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
		<uk:commentary href="#{ $id }" refersTo="#{ . }" />
	</xsl:for-each-group>
	<xsl:for-each-group select="descendant::MarginNoteRef" group-by="@Ref">
		<uk:commentary href="#{ $id }" refersTo="#{ @Ref }" />
	</xsl:for-each-group>
</xsl:template>

<xsl:template match="BlockAmendment | EmbeddedStructure" mode="other-analysis" />

<xsl:template match="node()" mode="other-analysis">
	<xsl:apply-templates mode="other-analysis" />
</xsl:template>

<xsl:template match="CommentaryRef">
	<xsl:variable name="commentary" as="element(Commentary)?" select="key('id', @Ref)[self::Commentary]" />	<!-- self::Commentary b/c of errors in ukpga/1974/7 -->
	<xsl:if test="exists($commentary) and $commentary/@Type = ('F', 'M', 'X')">
		<noteRef href="#{ @Ref }" uk:name="commentary" ukl:Name="CommentaryRef" class="commentary" />
	</xsl:if>
</xsl:template>


<!-- margin notes -->

<xsl:template match="MarginNoteRef">
	<xsl:variable name="margin-note" as="element(MarginNote)?" select="key('id', @Ref)" />
	<xsl:if test="exists($margin-note)">
		<noteRef href="#{ @Ref }" uk:name="commentary" ukl:Name="MarginNoteRef" class="commentary" />
	</xsl:if>
</xsl:template>

<xsl:template match="MarginNotes" />

<xsl:variable name="number-of-proper-m-notes" as="xs:integer" select="count(/Legislation/Commentaries/Commentary[@Type='M'])" />

<xsl:template match="MarginNote">
	<note ukl:Name="MarginNote" ukl:Type="M">
		<xsl:attribute name="class">
			<xsl:text>commentary M</xsl:text>
		</xsl:attribute>
		<xsl:attribute name="eId">
			<xsl:value-of select="@id" />
		</xsl:attribute>
		<xsl:attribute name="marker">
			<xsl:text>M</xsl:text>
			<xsl:value-of select="$number-of-proper-m-notes + position()" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'note'" tunnel="yes" />
		</xsl:apply-templates>
	</note>
</xsl:template>

</xsl:transform>
