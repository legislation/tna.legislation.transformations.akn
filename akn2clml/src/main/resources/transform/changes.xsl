<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs uk ukl local">


<xsl:template match="ins">
	<Addition>
		<xsl:attribute name="ChangeId">
			<xsl:value-of select="if (exists(@ukl:ChangeId)) then @ukl:ChangeId else generate-id(.)" />
		</xsl:attribute>
		<xsl:apply-templates select="@ukl:CommentaryRef" />
		<xsl:apply-templates />
	</Addition>
</xsl:template>

<xsl:template match="ins[starts-with(@class, 'substitution')]">
	<Substitution>
		<xsl:attribute name="ChangeId">
			<xsl:value-of select="if (exists(@ukl:ChangeId)) then @ukl:ChangeId else generate-id(.)" />
		</xsl:attribute>
		<xsl:apply-templates select="@ukl:CommentaryRef" />
		<xsl:apply-templates />
	</Substitution>
</xsl:template>

<xsl:template match="del">
	<Repeal>
		<xsl:attribute name="ChangeId">
			<xsl:value-of select="if (exists(@ukl:ChangeId)) then @ukl:ChangeId else generate-id(.)" />
		</xsl:attribute>
		<xsl:apply-templates select="@ukl:CommentaryRef" />
		<xsl:apply-templates />
	</Repeal>
</xsl:template>

<xsl:template match="@ukl:CommentaryRef">
	<xsl:attribute name="CommentaryRef">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="noteRef[starts-with(@class, 'commentary') and not(@ukl:Name='MarginNoteRef')]">
	<xsl:variable name="ref" as="xs:string" select="substring(@href, 2)" />
	<!-- this is necessary because I add noteRefs for f-notes even though there is no CommentaryRef in the source CLML -->
	<!-- it works only because I include @ukl:CommentaryRef attributes on <ins> and <del> elements -->
	<xsl:if test="not(parent::*/@ukl:CommentaryRef = $ref)">
		<CommentaryRef Ref="{ $ref }">
			<xsl:apply-templates />
		</CommentaryRef>
	</xsl:if>
</xsl:template>

<xsl:template name="commentaries">
	<xsl:variable name="commentaries" as="element(note)*" select="/akomaNtoso/*/meta/notes/note[@ukl:Name='Commentary' or (starts-with(@class,'commentary') and not(@ukl:Name='MarginNote'))]" />
	<xsl:if test="exists($commentaries)">
		<Commentaries>
			<xsl:apply-templates select="$commentaries" />
		</Commentaries>
	</xsl:if> 
</xsl:template>

<xsl:template match="note[@ukl:Name='Commentary' or (starts-with(@class,'commentary') and not(@ukl:Name='MarginNote'))]">
	<Commentary id="{ @eId }" Type="{ if (exists(@ukl:Type)) then @ukl:Type else tokenize(@class, ' ')[2] }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('Commentary')" tunnel="yes" />
		</xsl:apply-templates>
	</Commentary>
</xsl:template>

<xsl:key name="commentary-references" match="otherAnalysis/uk:commentary" use="substring(@href, 2)" />

<xsl:template name="add-commentary-refs-to-number">
	<xsl:variable name="id" as="xs:string?" select="parent::*/@eId" />
	<xsl:variable name="links" as="element(uk:commentary)*" select="key('commentary-references', $id)" />
	<xsl:variable name="notes" as="element(note)*" select="$links/key('id', substring(@refersTo, 2))" />
	<xsl:variable name="notes-without-reference-markers" as="element(note)*" select="$notes[not(@ukl:Type=('F','M','X'))]" />
	<xsl:apply-templates select="$notes-without-reference-markers" mode="commentary-ref" />
</xsl:template>

<xsl:template match="note" mode="commentary-ref">
	<CommentaryRef Ref="{ @eId }" />
</xsl:template>


<!-- margin notes -->

<xsl:variable name="all-margin-notes" as="element(note)*">
	<xsl:sequence select="/akomaNtoso/*/meta/notes/note[@ukl:Name='MarginNote']" />
</xsl:variable>

<xsl:function name="local:make-margin-note-id" as="xs:string">
	<xsl:param name="e" as="element(note)" />
	<xsl:variable name="index" as="xs:integer?" select="local:get-first-index-of-node($e, $all-margin-notes)" />
	<xsl:variable name="num" as="xs:integer" select="if (exists($index)) then $index else 0" />
	<xsl:sequence select="concat('m', format-number($num,'00000'))" />
</xsl:function>

<xsl:template match="noteRef[@ukl:Name='MarginNoteRef']">
	<xsl:variable name="ref" as="xs:string" select="substring(@href, 2)" />
	<xsl:variable name="margin-note" as="element()" select="key('id', $ref)" />
	<MarginNoteRef Ref="{ local:make-margin-note-id($margin-note) }" />
</xsl:template>

<xsl:template name="margin-notes">
	<xsl:if test="exists($all-margin-notes)">
		<MarginNotes>
			<xsl:apply-templates select="$all-margin-notes" mode="margin-note" />
		</MarginNotes>
	</xsl:if>
</xsl:template>

<xsl:template match="note" mode="margin-note">
	<MarginNote id="{ local:make-margin-note-id(.) }">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('MarginNote')" tunnel="yes" />
		</xsl:apply-templates>
	</MarginNote>
</xsl:template>

</xsl:transform>
