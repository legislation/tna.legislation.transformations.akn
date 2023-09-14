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

	<xsl:function name="tso:headingNumbers">
		<xsl:param name="node" as="node()"/>

		<xsl:sequence select="$node/ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		
	</xsl:function>
	
	

	<!-- top level section -->
	<xsl:template match="*:section[(parent::*:div/@class='body' or parent::*:blockquote) and *:h2]" mode="content" priority="100">
		<h3 class="LegP1GroupTitle" data="top"><xsl:value-of select="normalize-space(*/*[@class='heading']/text())"/></h3>
		
		<xsl:choose>
			<xsl:when test="*[@class='content']">
				<xsl:apply-templates select="*[@class='content']" mode="content">
					<xsl:with-param name="pnum" select="*:h2/*:span[@class='num']"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*:section" mode="content">
					<xsl:with-param name="pnum" select="*:h2/*:span[@class='num']"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*:section[parent::*:blockquote and *[1]/*[@class='num'] and *[2][@class=('heading','intro')] and exists(*[2]/following-sibling::*)]" mode="content" priority="100">
		<xsl:variable name="pnum" select="tso:headingNumbers(.)"/>
		<p class="{count($pnum)}" data="''">
			<span class="{count($pnum)}"><xsl:value-of select="*[1]/*[@class='num']"/></span>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="*[@class=('heading','intro')]" mode="content"/>
		</p>
		<xsl:apply-templates select="*[not(@class=('heading','intro'))]" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:section[parent::*:blockquote and *[1]/*[@class='num'] and not(*[2][@class=('heading','intro')])]" mode="content" priority="100">
		<xsl:variable name="pnum" select="tso:headingNumbers(.)"/>
		<p class="{count($pnum)}">
			<span class="{count($pnum)}"><xsl:value-of select="*[1]/*[@class='num']"/></span>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="*[2]" mode="markup"/>
		</p>
		<xsl:apply-templates select="*[2]/following-sibling::*" mode="content"/>
	</xsl:template>

	<!-- first child section -->
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='content'] and ancestor::*/*[1]/*[@class='num'] and not(preceding-sibling::*:section)]" mode="content" priority="10">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<p class="{tso:LegParaText(count($pnum) - 1)}">
			<span class="{tso:LegNo(count($pnum) - 1)}"><xsl:value-of select="$pnum[1]"/></span>
			<xsl:value-of select="concat('&#x2014;',$pnum[2],' ')"/>
			<xsl:apply-templates select="*[@class='content']" mode="markup"/>
		</p>
	</xsl:template>
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='intro'] and ancestor::*/*[1]/*[@class='num'] and not(preceding-sibling::*:section)]" mode="content" priority="10">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<p class="{tso:LegParaText(count($pnum) - 1)}">
			<span class="{tso:LegNo(count($pnum) - 1)}"><xsl:value-of select="$pnum[1]"/></span>
			<xsl:value-of select="concat('&#x2014;',$pnum[2],' ')"/>
			<xsl:apply-templates select="*[@class='intro']" mode="markup"/>
		</p>
		<xsl:apply-templates select="*[@class='intro']/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*[@class='content']" mode="content">
		<xsl:param name="pnum" select="()"/>
		<p class="LegP1ParaText">
			<xsl:if test="$pnum">
				<span class="LegP1No"><xsl:copy-of select="$pnum/text()"/></span><xsl:text> </xsl:text>
			</xsl:if>
			<xsl:apply-templates mode="markup" />
		</p>
	</xsl:template>	
	
	<xsl:template match="*[@class='content']" mode="content">
		<xsl:param name="pnum" select="()"/>
		<p class="LegP1ParaText">
			<xsl:if test="$pnum">
				<span class="LegP1No"><xsl:copy-of select="$pnum/text()"/></span><xsl:text> </xsl:text>
			</xsl:if>
			<xsl:apply-templates mode="markup" />
		</p>
	</xsl:template>	
	
	<xsl:template match="*:p[@class='p' and parent::*[@class='content']]" mode="content">
		<xsl:apply-templates select="node()" mode="markup"/>
	</xsl:template>	
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='content'] and ancestor::*/*[1]/*[@class='num'] and preceding-sibling::*:section]"  mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<xsl:variable name="pnum_count" select="xs:string(count($pnum))"/>
		<p class="{tso:LegParaText(count($pnum))}">
			<span class="{tso:LegNo(count($pnum))}"><xsl:value-of select="$pnum[last()]"/></span>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="*[@class='content']/*[1]" mode="content"/>
		</p>
		<xsl:apply-templates select="*[@class='content']/*[1]/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='content'] and ancestor::*/*[1]/*[@class='num'] and not(preceding-sibling::*:section)]" mode="content" priority="10">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<p class="{tso:LegParaText(count($pnum) - 1)}">
			<span class="{tso:LegNo(count($pnum) - 1)}"><xsl:value-of select="$pnum[1]"/></span>
			<xsl:value-of select="concat('&#x2014;',$pnum[2],' ')"/>
			<xsl:apply-templates select="*[@class='content']" mode="markup"/>
		</p>
	</xsl:template>
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='intro'] and ancestor::*/*[1]/*[@class='num'] and not(preceding-sibling::*:section)]" mode="content" priority="10">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<p class="{tso:LegParaText(count($pnum) - 1)}">
			<span class="{tso:LegNo(count($pnum) - 1)}"><xsl:value-of select="$pnum[1]"/></span>
			<xsl:value-of select="concat('&#x2014;',$pnum[2],' ')"/>
			<xsl:apply-templates select="*[@class='intro']" mode="markup"/>
		</p>
		<xsl:apply-templates select="*[@class='intro']/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*[@class='content'][preceding-sibling::*[1]/*/@class='num']" mode="content">
		<xsl:param name="depth" select="()"/>
		<p class="LegP1ParaText">
			<span class="LegP1No"><xsl:copy-of select="$depth/text()"/></span><xsl:text> </xsl:text>
			<xsl:apply-templates mode="markup" />
		</p>
	</xsl:template>
	
	<xsl:template match="*[@class='content'][not(preceding-sibling::*[1]/*/@class='num') and count(*) gt 1]"  priority="10" mode="content">
		<xsl:param name="depth" select="tso:headingNumbers(.)"/>
		<xsl:for-each select="*">
			<p class="{count($depth)}">
				<xsl:apply-templates mode="markup" />
			</p>
		</xsl:for-each>

	</xsl:template>
	
	<xsl:template match="*[@class='content'][not(preceding-sibling::*[1]/*/@class='num')]" mode="content">
		<xsl:param name="depth" select="tso:headingNumbers(.)"/>
		<p class="{count($depth)}">
			<xsl:apply-templates mode="markup" />
		</p>
	</xsl:template>
	
	<xsl:template match="*:p[@class='p' and parent::*[@class='content']]" mode="content">
		<xsl:apply-templates select="node()" mode="markup"/>
	</xsl:template>	
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='content']/*/*[@class='mod']/*:blockquote and ancestor::*/*[1]/*[@class='num'] and preceding-sibling::*:section]" priority="10"  mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<xsl:variable name="pnum_count" select="xs:string(count($pnum))"/>
		<p class="{tso:LegParaText(count($pnum))}" here="1'">
			<span class="{tso:LegNo(count($pnum))}"><xsl:value-of select="$pnum[last()]"/></span>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="*[@class='content']/*/*[@class='mod']/*:blockquote/preceding-sibling::node()" mode="content"/>
		</p>
		<xsl:apply-templates select="*[@class='content']/*/*[@class='mod']/*:blockquote/*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='content'] and ancestor::*/*[1]/*[@class='num'] and preceding-sibling::*:section]"  mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<xsl:variable name="pnum_count" select="xs:string(count($pnum))"/>
		<p class="{tso:LegParaText(count($pnum))}" here="'2'">
			<span class="{tso:LegNo(count($pnum))}"><xsl:value-of select="$pnum[last()]"/></span>
			<xsl:text> </xsl:text>
			<xsl:apply-templates select="*[@class='content']/*[1]" mode="content"/>
		</p>
		<xsl:apply-templates select="*[@class='content']/*[1]/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='intro'] and ancestor::*/*[1]/*[@class='num']]" mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<p class="{tso:LegParaText(count($pnum))}">
			<span class="{tso:LegNo(count($pnum))}"><xsl:value-of select="$pnum[last()]"/></span>
			<xsl:value-of select="concat(' ',string-join(*[@class='intro']/descendant-or-self::text(),' '))"/>
		</p>
		<!-- processes the node after the intro -->
		<xsl:apply-templates select="*[@class='intro']/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:section[not(parent::*:blockquote)][*[2][@class='intro'] and ancestor::*/*[1]/*[@class='num']]" mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<p class="{tso:LegParaText(count($pnum))}">
			<span class="{tso:LegParaText(count($pnum))}"><xsl:value-of select="$pnum[last()]"/></span>
			<xsl:value-of select="concat(' ',string-join(*[@class='intro']/descendant-or-self::text(),' '))"/>
		</p>
		<xsl:apply-templates select="*[@class='intro']/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:div[not(@class='content')][not(parent::*:blockquote)][preceding-sibling::*[@class='intro'] and *:div[@class='content']/*:p]" mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<xsl:variable name="depth" select="xs:string(count($pnum))"/>
		
		<p class="LegClearFix {concat('LegP',$depth,'Container')}">
			<span class="{concat('LegDS LegLHS LegP',$depth,'No')}"><xsl:value-of select="$pnum[last()]"/></span>
			<span class="{concat('LegDS LegRHS LegP',$depth,'Text')}">
				<xsl:apply-templates select="*:div[@class='content']/*:p/node()" mode="markup"/>
			</span>
		</p>
		<xsl:apply-templates select="*:div[@class='content']/*[1]/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:div[not(@class='content')][not(parent::*:blockquote)][preceding-sibling::*[@class='intro'] and *:div[@class='content']/*:div[@class='p']/*:div[@class='mod']]" mode="content">
		<xsl:variable name="pnum" select="ancestor-or-self::*/*[1]/*[@class='num']/text()"/>
		<xsl:variable name="depth" select="xs:string(count($pnum))"/>
		
		<xsl:variable name="content" select="*:div[@class='content']/*:div[@class='p']/*:div[@class='mod']"/>
		<p class="LegClearFix LegP3Container">
			<span class="{concat('LegDS LegLHS LegP',$depth,'No')}"><xsl:value-of select="$pnum[last()]"/></span>
			<span class="{concat('LegDS LegRHS LegP',$depth,'Text')}">
				<xsl:apply-templates select="$content/node()[1]" mode="markup"/>
			</span>
		</p>
		<xsl:apply-templates select="$content/node()[1]/following-sibling::*" mode="content"/>
	</xsl:template>
	
	<xsl:template match="*:div[@class='tblock table']" mode="content">
		<xsl:if test="*:span[@class[contains(.,'heading')]]">
			<h4 class="LegTableNo LegAmend">
				<span class="LegAmendingText"><xsl:value-of select="*:span[@class[contains(.,'heading')]]/text()"/></span>
			</h4>			
		</xsl:if>
		<xsl:apply-templates select="*:table" mode="content"/>
	</xsl:template>
	
	<xsl:template name="create-col-group">
		<xsl:param name="tableRow" as="element()*" select="()"/>
		<xsl:variable name="mod" select="100 mod count($tableRow[1]/*:td)"/>
		<xsl:variable name="columnWidth" select="xs:string((100 - $mod)  div count($tableRow[1]/*:td))"/>
		<colgroup>
			<xsl:for-each select="$tableRow[1]/*:td">
				<col width="{concat($columnWidth,'%')}"/>
			</xsl:for-each>
		</colgroup>
	</xsl:template>
	
	<xsl:template match="*:table[*:thead]" mode="content">
		<div class="LegTabular">
			<div class="LegClearFix LegTableContainer LegAmend" style="margin-left:5%">
				<table class="LegTable" cellpadding="5">
					<xsl:call-template name="create-col-group">
						<xsl:with-param name="tableRow" select="(*:thead/*:tr[1], *:tbody/*:tr[1])" />
					</xsl:call-template>
					<xsl:apply-templates mode="content"/>
				</table>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="*:table[not(*:thead)]" mode="content">
		<div class="LegTabular">
			<div class="LegClearFix LegTableContainer LegAmend" style="margin-left:5%">
				<table class="LegTable" cellpadding="5">
					<xsl:apply-templates mode="content"/>
				</table>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="*:thead" mode="content">
		<thead>
			<xsl:apply-templates mode="content"/>
		</thead>
	</xsl:template>
	
	<xsl:template match="*:tr[parent::*:thead]" mode="content">
		<tr>
			<xsl:apply-templates mode="content"/>
		</tr>
	</xsl:template>
	
	<xsl:template match="*:div[@class='mod']" mode="content">
		
	</xsl:template>
	
	<xsl:template match="section[parent::*:blockquote]" mode="content" priority="150">
		<xsl:variable name="depth" select="ancestor::*[*[1]/*[@class='num']]/text()"/>
		<xsl:for-each select="*:div[preceding-sibling::*/*[@class='num']]">
			<p class="{$depth}">
				<span><xsl:value-of select="preceding-sibling::*/*[@class='num']"/></span>
				<xsl:text> </xsl:text>
				<xsl:apply-templates select="."/>
			</p>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="*:blockquote" mode="content">
		<blockquote>
			
			<xsl:apply-templates mode="content"/>
		</blockquote>
	</xsl:template>
	
	<xsl:template match="*:td[ancestor::*:thead]" mode="content">
		<th class="LegTHplain {if(not(following-sibling::*)) then 'RightNBottom' else 'NRightNBottom'}">
			<xsl:apply-templates mode="content"/>
		</th>
	</xsl:template>
	
	<xsl:template match="*:td[ancestor::*:tbody]" mode="content">
		<td class="LegTd {if(not(following-sibling::*)) then 'RightNBottom' else 'NRightNBottom'}">
			<xsl:apply-templates mode="content"/>
		</td>
	</xsl:template>
	
	<xsl:template match="*:tbody" mode="content">
		<tbody class="LegTabular">
			<xsl:apply-templates mode="content"/>
		</tbody>
	</xsl:template>
	
	<xsl:template match="*:div[@class='p']" mode="content">
		<xsl:apply-templates select="node()" mode="markup"/>
	</xsl:template>
	
	<xsl:template match="*:p[ancestor::*:tbody]" mode="content">
		<p class="LegText">
			<xsl:apply-templates select="node()" mode="markup"/>
		</p>
	</xsl:template>
	
</xsl:stylesheet>
