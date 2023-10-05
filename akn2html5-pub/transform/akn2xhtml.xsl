<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0/CSD13"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:local="http://jurisdatum.com/tna/akn2html" 
	xmlns:tso="http://tso.co.uk/functions/1.0" 
	xmlns:html = "http://www.w3.org/1999/xhtml"
	
	exclude-result-prefixes="xs math akn ukl ukm local tso html" >
	
	<xsl:import href="akn2html.xsl"/>
	<xsl:output method="xhtml" version="1.0"  encoding="UTF-8"  omit-xml-declaration="yes"  indent="yes"/>
	<xsl:variable name="dateRegExpr" select="'([0-9]?(1st|2nd|3rd|[0-9]th)\s+(Jan|Feb|Mar|Apr|May|June|July|Aug|sep|Oct|Nov|Dec)[^\s]*\s+[0-9]{4})'"/>
	<xsl:strip-space elements="*" />
	
	<!-- extracted the date text if the contaxt conatins a date  
		otherwise return the context string -->
	<xsl:function name="tso:extract-date-text">
		<xsl:param name="context" as="xs:string" />
		<xsl:variable name="replacer" select="concat('.*',$dateRegExpr,'.*')"/>
		<xsl:value-of select="
			if(matches(normalize-space($context), $dateRegExpr)) then (
				replace(normalize-space($context),$replacer,'$1')
			)
			else
			 $context
		"/>
	</xsl:function>
	
	<xsl:template match="/">
		<xsl:variable name="akn2Html">
			<xsl:variable name="fixed" as="document-node()">
				<xsl:document>
					<xsl:apply-templates mode="ldapp" />
				</xsl:document>
			</xsl:variable>
			<xsl:apply-templates select="$fixed/*" />
		</xsl:variable>
		<xsl:apply-templates select="$akn2Html/descendant::*:html" mode="akn2xhtml"/>
	</xsl:template>
	
	<xsl:template match="*:div[@class=('block subject','block subsubject')]" mode="akn2xhtml">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates />
			<a class="note">
				<img alt="
					style = { replace(@class,'block ','') }
					" 
					src="/modules/file/icons/image-x-generic.png"
					title="
					style = { replace(@class,'block ','') }
					"
				/> 
			</a>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*:div[@class='block commenceDate' and *:time]" mode="akn2xhtml">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="node()">
				<xsl:choose>
					<xsl:when test=".[self::*:time and @datetime]">
						<xsl:copy>
							<xsl:copy-of select="@datetime"/>
							<xsl:attribute name="class" select="concat(@class,' ','highlight-yellow')"/>
							<xsl:copy-of select="node()"></xsl:copy-of>
						</xsl:copy>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*:div[@class='body']/*:section[1]" mode="akn2xhtml" priority="10">
		<xsl:variable name="title" select="lower-case(parent::*/preceding-sibling::*[@class='preface']//*:span[@class='docTitle'])" />
		<xsl:call-template name="highlightText">
			<xsl:with-param name="text" select="$title"/>
			<xsl:with-param name="context" select="."/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="highlightText">
		<xsl:param name="text" select="''"/>
		<xsl:param name="context" select="()"/>
		
		<xsl:for-each select="$context">
			<xsl:copy>
				<xsl:copy-of select="@* except (@data-GUID, @id)"/>
				<xsl:choose>
					<xsl:when test="self::*:p[every $i in node() satisfies $i[self::text()] and contains(lower-case(normalize-space(.)), normalize-space($text) )]">
						<xsl:variable name="normalised" select="normalize-space(.)"/>
						<xsl:variable name="lbefore" select="string-length(substring-before(lower-case($normalised), normalize-space($text)))"/>
						<xsl:variable name="lafter" select="string-length(substring-after(lower-case($normalised), normalize-space($text)))"/>
						<xsl:copy>
							<xsl:copy-of select="@*"/>
							<xsl:value-of select="substring($normalised,1,$lbefore)" />
							<xsl:element name="span">
								<xsl:attribute name="class" select="'highlight-yellow'"/>
								<xsl:value-of select="substring($normalised,$lbefore + 1,string-length(normalize-space($text)))"/>
							</xsl:element>
							<xsl:call-template name="highligth-date">
								<xsl:with-param name="context" select="substring($normalised, string-length($normalised) - $lafter +1)"/>
							</xsl:call-template>
						</xsl:copy>
					</xsl:when>
					<xsl:when test="self::text()">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<!-- recurse child elements -->
						<xsl:call-template name="highlightText">
							<xsl:with-param name="text" select="$text"/>
							<xsl:with-param name="context" select="node()"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>	
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	
	<!-- if Citation, commencement and interpretation contains a coming into force date
		adds a span with highlight-yellow class around the date -->
	<xsl:template name="highligth-date">
		<xsl:param name="context" select="''"/>
		<xsl:variable name="extract-date" select="tso:extract-date-text($context)"/>
		
		<xsl:choose>
			<!-- if the context (string) and extracted date are equal no date was found output text -->
			<xsl:when test="$context=$extract-date">
				<xsl:value-of select="$context"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($context, $extract-date)"/>
				<span class="highlight-yellow">
					<xsl:value-of select="$extract-date"/>
				</span>
				<xsl:value-of select="substring-after($context, $extract-date)" />	
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="*:span[matches(@class,'bill\.*')]" mode="akn2xhtml">
		<article>
			<xsl:attribute name="class" select="'act secondary'" />
			<xsl:apply-templates  mode="akn2xhtml"/>
		</article>
	</xsl:template>
	
	<xsl:template match="*:a[@class='fnRef']" mode="akn2xhtml">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="style" select="'font-size:1em;color:#0066CC'"></xsl:attribute>
			<xsl:value-of select="string-join(text(),'')"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*:div[@class='meta']"  mode="akn2xhtml" />
	
	<xsl:template match="*:head" mode="akn2xhtml" />
	
	<!-- add highlight-yellow to class attribute -->
	<xsl:template match="*:span[@class[.='docTitle']]"  mode="akn2xhtml">
		<xsl:copy>
			<xsl:attribute name="class" select="concat(@class, ' ', 'highlight-yellow')"/>
			<xsl:apply-templates select="node()" mode="akn2xhtml"/>			
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*"  mode="akn2xhtml">
		<xsl:copy>
			<xsl:apply-templates select="@* except (@data-GUID, @id)" mode="akn2xhtml"/>
			<xsl:apply-templates  mode="akn2xhtml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@class"  mode="akn2xhtml">
		<xsl:copy>
			<xsl:value-of select=" 
				for $style in tokenize(.,' ') 
				return
				if(not(matches($style,'(hcontainer|blockContainer|prov.+|block)'))) then 
					'true'
				else
					()
			"/>			
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*"  mode="akn2xhtml">
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>