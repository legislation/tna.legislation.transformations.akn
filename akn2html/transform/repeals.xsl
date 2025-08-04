<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
    xmlns:local="akn2html-local"
    exclude-result-prefixes="xs uk local">

<!-- the templates in this file replace the contents of repealed large structural containers, -->
<!-- such as parts, chapters or schedules, with a single dotted line. -->

<xsl:key name="status-repealed" match="uk:status[@refersTo='#status-repealed']" use="substring(@href, 2)" />

<xsl:key name="match" match="uk:match" use="substring(@href, 2)" />

<xsl:function name="local:is-repealed" as="xs:boolean">
    <xsl:param name="e" as="element()" />
    <xsl:choose>
        <xsl:when test="exists($e/@eId) and exists(key('status-repealed', $e/@eId, root($e)))">
            <xsl:sequence select="true()" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:sequence select="local:is-repealed-2($e)" />
        </xsl:otherwise>
    </xsl:choose>
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
        <xsl:when test="$is-repealed">
            <xsl:apply-templates select="* except (num | heading | subheading)" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="title | part | chapter | hcontainer[@name=('groupOfParts','crossheading','subheading','schedule')]" priority="1" name="big-level-repeal">
    <xsl:param name="within-schedule" as="xs:boolean" select="false()" tunnel="yes" />
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
        <xsl:when test="$is-repealed">
            <xsl:apply-templates select="* except (num | heading | subheading)">
                <xsl:with-param name="within-schedule" select="$within-schedule or @name='schedule'" tunnel="yes" />
            </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:variable name="point-in-time" as="xs:date?" select="/akomaNtoso/*/meta/identification/FRBRExpression/FRBRdate[@name='point-in-time']" />

<xsl:template match="section" priority="1">
    <xsl:param name="effective-document-category" as="xs:string" tunnel="yes" />
    <xsl:choose>
        <xsl:when test="$effective-document-category = 'primary'">
            <xsl:call-template name="p1-repeal" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="big-level-repeal" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- based on tna.legislation.transformations.clml-html-fo/src/legislation/html/legislation_xhtml_consolidation.xslt -->
<xsl:function name="local:is-repealed-2" as="xs:boolean">
    <xsl:param name="e" as="element()" />
    <xsl:variable name="match" as="xs:string?" select="key('match', $e/@eId, root($e))/@value" />
    <xsl:variable name="is-prospective" as="xs:boolean" select="key('status', $e/@eId, root($e))/@refersTo = '#status-prospective'" />
    <xsl:variable name="restrict-end-date" as="xs:date?" select="local:get-restrict-end-date($e)" />
    <xsl:variable name="point-in-time" as="xs:date?" select="if (exists($point-in-time)) then $point-in-time else current-date()" />
    <xsl:sequence select="empty($e/ancestor::quotedStructure) and $match = 'false' and exists($restrict-end-date) and not($is-prospective) and $restrict-end-date &lt;= $point-in-time" />
</xsl:function>

<xsl:template match="article | hcontainer[@name='regulation'] | rule" priority="1" name="p1-repeal">
    <xsl:choose>
        <xsl:when test="local:is-repealed-2(.)">
            <section>
                <xsl:call-template name="attrs" />
                <h2>
                    <xsl:apply-templates select="num | heading" />
                </h2>
                <div class="content">
                    <xsl:call-template name="dotty-line" />
                </div>
                <xsl:call-template name="annotations-from-notes">
                    <xsl:with-param name="notes" as="element(note)*">
                        <xsl:for-each select="key('commentaries', 'act')">
                            <xsl:sequence select="key('id', substring(@refersTo, 2))" />
                        </xsl:for-each>
                    </xsl:with-param>
                </xsl:call-template>
            </section>
        </xsl:when>
        <xsl:otherwise>
            <xsl:next-match />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="paragraph" priority="1">
    <xsl:param name="within-schedule" as="xs:boolean" select="false()" tunnel="yes" />
    <xsl:choose>
        <xsl:when test="$within-schedule">
            <xsl:call-template name="p1-repeal" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="big-level-repeal" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="dotty-line-with-annotation">
    <xsl:call-template name="dotty-line" />
    <xsl:variable name="whole-act-commentaries" as="element(note)*">
        <xsl:for-each select="key('commentaries', 'act')">
            <xsl:sequence select="key('id', substring(@refersTo, 2))" />
        </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
        <xsl:when test="exists($whole-act-commentaries)">
            <xsl:call-template name="annotations-from-notes">
                <xsl:with-param name="notes" as="element(note)*" select="$whole-act-commentaries" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="commentary-anchor" as="element()?" select="descendant-or-self::*[exists(key('commentaries', @eId))][1]" />
            <xsl:apply-templates select="$commentary-anchor" mode="annotations-only" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="dotty-line">
    <p>. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .</p>
</xsl:template>

<xsl:template match="*" mode="annotations-only">
    <xsl:call-template name="annotations" />
</xsl:template>

</xsl:transform>
