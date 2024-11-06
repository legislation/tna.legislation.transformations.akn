<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
    xmlns:local="akn2html"
    exclude-result-prefixes="xs uk local">

<!-- the templates in this file replace the contents of repealed large structural containers, -->
<!-- such as parts, chapters or schedules, with a single dotted line. -->

<xsl:key name="status-repealed" match="uk:status[@refersTo='#status-repealed']" use="substring(@href, 2)" />

<xsl:function name="local:is-repealed" as="xs:boolean">
    <xsl:param name="e" as="element()" />
    <xsl:sequence select="if (exists($e/@eId)) then exists(key('status-repealed', $e/@eId, root($e))) else false()" />
</xsl:function>

<!-- at most one element in the document will have a @uk:target attribute, signifying that it was -->
<!-- the level requested by the API. For example, if the document was generated in response to -->
<!-- a request for .../section/1, the Section 1 will have @uk:target="true" -->
<xsl:variable name="target" as="element()?" select="//*[@uk:target='true']" />

<xsl:template match="act" priority="1">
    <xsl:variable name="preface-is-repealed" as="xs:boolean" select="exists(preface) and local:is-repealed(preface)" />
    <xsl:variable name="body-is-repealed" as="xs:boolean" select="exists(body) and local:is-repealed(body)" />
    <xsl:variable name="whole-act-is-requested" as="xs:boolean" select="empty($target)" />
    <xsl:choose>
        <xsl:when test="$preface-is-repealed and $body-is-repealed and $whole-act-is-requested">
            <article class="{ string-join((local-name(), $doc-category, @name), ' ') }">
                <xsl:call-template name="add-restrict-attributes" />
                <xsl:apply-templates select="coverPage | preface | preamble" />
            </article>
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="body | hcontainer[@name='schedules']" priority="1">
    <xsl:variable name="is-repealed" as="xs:boolean" select="local:is-repealed(.)" />
    <xsl:variable name="is-requested" as="xs:boolean" select="empty($target) or . is $target" />
    <xsl:choose>
        <xsl:when test="$is-repealed and $is-requested">
            <div>
                <xsl:call-template name="attrs" />
                <xsl:call-template name="dotty-line-with-annotation" />
            </div>
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="title | part | chapter | hcontainer[@name=('groupOfParts','crossheading','subheading','schedule')]" priority="1" name="big-level-repeal">
    <xsl:variable name="is-repealed" as="xs:boolean" select="local:is-repealed(.)" />
    <xsl:variable name="is-requested" as="xs:boolean" select="empty($target) or . is $target" />
    <xsl:choose>
        <xsl:when test="$is-repealed and $is-requested">
            <section>
                <xsl:call-template name="attrs" />
                <xsl:if test="exists(num | heading | subheading)">
                    <h2>
                        <xsl:apply-templates select="num | heading | subheading" />
                    </h2>
                </xsl:if>
                <xsl:call-template name="dotty-line-with-annotation" />
            </section>
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="section" priority="1">
    <xsl:param name="effective-document-category" as="xs:string" tunnel="yes" />
    <xsl:choose>
        <xsl:when test="$effective-document-category = 'primary'">
            <xsl:next-match />
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="big-level-repeal" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="dotty-line-with-annotation">
    <xsl:call-template name="dotty-line" />
    <xsl:variable name="commentary-anchor" as="element()?" select="descendant-or-self::*[exists(key('commentaries', @eId))][1]" />
    <xsl:apply-templates select="$commentary-anchor" mode="annotations-only" />
</xsl:template>

<xsl:template name="dotty-line">
    <p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
</xsl:template>

<xsl:template match="*" mode="annotations-only">
    <xsl:call-template name="annotations" />
</xsl:template>

</xsl:transform>
