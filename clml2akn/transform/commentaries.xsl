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
		<xsl:variable name="anchor" as="element()*" select="//*[not(self::InternalLink)][@DocumentURI = $dc-identifier]" />
		<xsl:variable name="anchor" as="element()*" select="if ($anchor/self::P1/parent::P1group) then ($anchor[self::P1/parent::P1group])[1]/parent::* else $anchor[1]" />
		<xsl:variable name="anchor" as="element()" select="if (exists($anchor)) then $anchor else /*" />
		<xsl:variable name="all-elements" as="element()*" select="( $anchor/descendant::CommentaryRef | $anchor/descendant-or-self::*[exists(@CommentaryRef)] )" />
		<xsl:sequence select="local:get-unique-commentary-ids($all-elements)" />
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

<xsl:function name="local:get-unique-commentary-ids">
	<xsl:param name="elements" as="element()*" />
	<xsl:variable name="ids-with-duplicates" as="xs:string*">
		<xsl:for-each select="$elements">
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
	<xsl:for-each-group select="$ids-with-duplicates" group-by=".">
		<xsl:sequence select="." />
	</xsl:for-each-group>
</xsl:function>

<xsl:template match="PrimaryPrelims | SecondaryPrelims | EUPrelims" mode="other-analysis">
	<xsl:variable name="elements" as="element()*" select="( descendant::*[exists(@CommentaryRef)] | descendant::CommentaryRef )" />
	<xsl:variable name="commentary-ids" as="xs:string*" select="local:get-unique-commentary-ids($elements)" />
	<xsl:for-each select="$commentary-ids">
		<uk:commentary href="#preface" refersTo="#{ . }" />
	</xsl:for-each>
</xsl:template>

<xsl:template match="Group | Part | Chapter | Pblock | PsubBlock | Schedule | EUPart | EUTitle | EUChapter | EUSection | EUSubsection" mode="other-analysis">

	<xsl:param name="already-handled-commentary-ids" as="xs:string*" select="()" />
	<xsl:variable name="id" as="xs:string" select="if (exists(@id)) then @id else generate-id()" />

	<xsl:variable name="this-elements" as="element()*" select="( self::*[exists(@CommentaryRef)] | child::CommentaryRef | Number/descendant-or-self::*[exists(@CommentaryRef)] | Number/descendant::CommentaryRef | Title/descendant-or-self::*[exists(@CommentaryRef)] | Title/descendant::CommentaryRef )" />
	<xsl:variable name="this-commentary-ids" as="xs:string*" select="local:get-unique-commentary-ids($this-elements)" />

	<!-- could be optimized -->
	<xsl:variable name="is-requested" as="xs:boolean" select="empty(descendant::*[not(self::InternalLink)][@DocumentURI = $dc-identifier])" />

	<xsl:choose>
		<xsl:when test="$is-requested">
			<xsl:variable name="new-commentary-ids" as="xs:string*">
				<xsl:for-each select="$this-commentary-ids">
					<xsl:if test="not(. = $already-handled-commentary-ids)">
						<xsl:sequence select="." />
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each select="$new-commentary-ids">
				<uk:commentary href="#{ $id }" refersTo="#{ . }" />
			</xsl:for-each>
			<xsl:apply-templates mode="other-analysis">
				<xsl:with-param name="already-handled-commentary-ids" select="( $already-handled-commentary-ids, $new-commentary-ids )" />
			</xsl:apply-templates>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="other-analysis" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ScheduleBody" mode="other-analysis">
	<xsl:param name="already-handled-commentary-ids" as="xs:string*" select="()" />
	<xsl:apply-templates mode="other-analysis">
		<xsl:with-param name="already-handled-commentary-ids" select="$already-handled-commentary-ids" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="P1group" mode="other-analysis">
	<xsl:param name="already-handled-commentary-ids" as="xs:string*" select="()" />
	<xsl:variable name="id" as="xs:string" select="if (exists(@id)) then @id else generate-id()" />
	<xsl:choose>
		<xsl:when test="empty(P1)">
			<xsl:variable name="this-commentary-ids" as="xs:string*">
				<xsl:variable name="desc-elements" as="element()*" select="( descendant-or-self::*[exists(@CommentaryRef)] | descendant::CommentaryRef )" />
				<xsl:sequence select="local:get-unique-commentary-ids($desc-elements)" />
			</xsl:variable>
			<xsl:variable name="new-commentary-ids" as="xs:string*">
				<xsl:for-each select="$this-commentary-ids">
					<xsl:if test="not(. = $already-handled-commentary-ids)">
						<xsl:sequence select="." />
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:for-each select="$new-commentary-ids">
				<uk:commentary href="#{ $id }" refersTo="#{ . }" />
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates mode="other-analysis">
				<xsl:with-param name="already-handled-commentary-ids" select="$already-handled-commentary-ids" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P1" mode="other-analysis">
	<xsl:param name="already-handled-commentary-ids" as="xs:string*" select="()" />
	<xsl:variable name="id" as="xs:string" select="if (exists(@id)) then @id else generate-id()" />
	<xsl:variable name="this-commentary-ids" as="xs:string*">
		<xsl:variable name="desc-elements" as="element()*">
			<xsl:choose>
				<xsl:when test="exists(parent::P1group) and empty(preceding-sibling::P1)">
					<xsl:sequence select="( ../CommentaryRef | ../Title/descendant-or-self::*[exists(@CommentaryRef)] | ../Title/descendant::CommentaryRef | descendant-or-self::*[exists(@CommentaryRef)] | descendant::CommentaryRef )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="( descendant-or-self::*[exists(@CommentaryRef)] | descendant::CommentaryRef )" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="local:get-unique-commentary-ids($desc-elements)" />
	</xsl:variable>

	<xsl:variable name="preceding-sibling-commentary-ids" as="xs:string*">
		<xsl:variable name="preceding-sibling-elements" as="element()*">
			<xsl:sequence select="parent::P1group/preceding-sibling::P1group/Title/(descendant-or-self::*[exists(@CommentaryRef)] | descendant::CommentaryRef)" />
		</xsl:variable>
		<xsl:sequence select="local:get-unique-commentary-ids($preceding-sibling-elements)" />
	</xsl:variable>

	<xsl:variable name="new-commentary-ids" as="xs:string*">
		<xsl:for-each select="$this-commentary-ids">
			<xsl:if test="not(. = $already-handled-commentary-ids) and not(. = $preceding-sibling-commentary-ids)">
				<xsl:sequence select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:for-each select="$new-commentary-ids">
		<uk:commentary href="#{ $id }" refersTo="#{ . }" />
	</xsl:for-each>
</xsl:template>

<xsl:template match="BlockAmendment | EmbeddedStructure" mode="other-analysis" />

<xsl:template match="node()" mode="other-analysis">
	<xsl:apply-templates mode="other-analysis" />
</xsl:template>

<xsl:template match="CommentaryRef">
	<xsl:variable name="commentary" as="element(Commentary)*" select="key('id', @Ref)[self::Commentary]" />	<!-- self::Commentary b/c of errors in ukpga/1974/7 -->
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
