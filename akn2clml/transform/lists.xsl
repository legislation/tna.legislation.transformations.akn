<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/akn2clml"
	exclude-result-prefixes="xs ukl local">


<xsl:function name="local:is-ordered" as="xs:boolean">
	<xsl:param name="list" as="element(blockList)" />
	<xsl:variable name="items" as="element()*" select="$list/*" />
	<xsl:choose>
		<xsl:when test="$list/@ukl:Name = 'OrderedList'">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="$list/@ukl:Name = 'UnorderedList'">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="tokenize($list/@class, ' ') = 'ordered'">
			<xsl:sequence select="true()" />
		</xsl:when>
		<xsl:when test="tokenize($list/@class, ' ') = 'unordered'">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="some $item in $items satisfies empty($item/num)">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="every $item in $items satisfies matches($item/num, '•')">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="every $item in $items satisfies matches($item/num, '—')">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:when test="every $item in $items satisfies matches($item/num, '-')">
			<xsl:sequence select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="true()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-decoration-from-numbered-things" as="xs:string">
	<xsl:param name="items" as="element()*" />
	<xsl:variable name="nums" as="xs:string*" select="$items/num/normalize-space(.)" />
	<xsl:choose>
		<xsl:when test="empty($nums)">
			<xsl:sequence select="'none'" />
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies (starts-with($num, '(') and ends-with($num, ')'))">
			<xsl:text>parens</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies ends-with($num, ')')">
			<xsl:text>parenRight</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies (starts-with($num, '[') and ends-with($num, ']'))">
			<xsl:text>brackets</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies ends-with($num, ']')">
			<xsl:text>bracketRight</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies ends-with($num, '.')">
			<xsl:text>period</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies ends-with($num, ':')">
			<xsl:text>colon</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies $num = '•'">
			<xsl:sequence select="'bullet'" />
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies $num = ('—','-')">
			<xsl:sequence select="'dash'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="'none'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-decoration-from-list" as="xs:string">
	<xsl:param name="list" as="element(blockList)" />
	<xsl:param name="ordered" as="xs:boolean" />
	<xsl:choose>
		<xsl:when test="exists($list/@ukl:Decoration)">
			<xsl:sequence select="string($list/@ukl:Decoration)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:get-decoration-from-numbered-things($list/item)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-ordered-list-type-from-numbered-things" as="xs:string?">
	<xsl:param name="items" as="element()+" />
	<xsl:param name="decor" as="xs:string" />
	<xsl:variable name="nums" as="xs:string+" select="$items/num/translate(., ' ', '')" /><!-- some have spaces within: ukpga/2017/3/enacted -->
	<xsl:variable name="begin-end" as="xs:string+">
		<xsl:choose>
			<xsl:when test="$decor = 'none'">
				<xsl:sequence select="'^', '$'" />
			</xsl:when>
			<xsl:when test="$decor = 'parens'">
				<xsl:sequence select="('^\(', '\)$')" />
			</xsl:when>
			<xsl:when test="$decor = 'parenRight'">
				<xsl:sequence select="('^', '\)$')" />
			</xsl:when>
			<xsl:when test="$decor = 'brackets'">
				<xsl:sequence select="('^\[', '\]$')" />
			</xsl:when>
			<xsl:when test="$decor = 'bracketRight'">
				<xsl:sequence select="('^', '\]$')" />
			</xsl:when>
			<xsl:when test="$decor = 'period'">
				<xsl:sequence select="('^', '\.$')" />
			</xsl:when>
			<xsl:when test="$decor = 'colon'">
				<xsl:sequence select="('^', ':$')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="'^', '$'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="arabic-pattern" as="xs:string">
		<xsl:value-of select="concat($begin-end[1], '\d+', $begin-end[2])" />
	</xsl:variable>
	<xsl:variable name="roman-pattern" as="xs:string">
		<xsl:value-of select="concat($begin-end[1], '[ivx]+', $begin-end[2])" />
	</xsl:variable>
	<xsl:variable name="roman-upper-pattern" as="xs:string">
		<xsl:value-of select="concat($begin-end[1], '[IVX]+', $begin-end[2])" />
	</xsl:variable>
	<xsl:variable name="alpha-pattern" as="xs:string">
		<xsl:value-of select="concat($begin-end[1], '[a-z]+\d*', $begin-end[2])" />
	</xsl:variable>
	<xsl:variable name="alpha-upper-pattern" as="xs:string">
		<xsl:value-of select="concat($begin-end[1], '[A-Z]+\d*', $begin-end[2])" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="every $num in $nums satisfies matches($num, $arabic-pattern)">
			<xsl:text>arabic</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies matches($num, $roman-pattern)">
			<xsl:text>roman</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies matches($num, $roman-upper-pattern)">
			<xsl:text>romanUpper</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies matches($num, $alpha-pattern)">
			<xsl:text>alpha</xsl:text>
		</xsl:when>
		<xsl:when test="every $num in $nums satisfies matches($num, $alpha-upper-pattern)">
			<xsl:text>alphaUpper</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-type-of-ordered-list" as="xs:string?">
	<xsl:param name="list" as="element(blockList)" />
	<xsl:param name="decor" as="xs:string" />
	<xsl:choose>
		<xsl:when test="exists($list/@ukl:Type)">
			<xsl:sequence select="string($list/@ukl:Type)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:get-ordered-list-type-from-numbered-things($list/item, $decor)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="blockList">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="ordered" as="xs:boolean" select="local:is-ordered(.)" />
	<xsl:variable name="name" as="xs:string" select="if ($ordered) then 'OrderedList' else 'UnorderedList'" />
	<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-list(., $ordered)" />
	<xsl:variable name="type" as="xs:string?" select="if ($ordered) then local:get-type-of-ordered-list(., $decor) else ()" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<xsl:element name="{ $name }">
				<xsl:if test="$ordered">
					<xsl:attribute name="Type">
						<xsl:value-of select="$type" />
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="Decoration">
					<xsl:value-of select="$decor" />
				</xsl:attribute>
				<xsl:apply-templates>
					<xsl:with-param name="type" select="$type" />
					<xsl:with-param name="decor" select="$decor" />
					<xsl:with-param name="context" select="($name, local:get-wrapper($name, $context), $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="item">
	<xsl:param name="type" as="xs:string?" />
	<xsl:param name="decor" as="xs:string?" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:if test="exists(num)">
			<xsl:call-template name="add-number-override-if-necessary">
				<xsl:with-param name="type" as="xs:string?" select="$type" />
				<xsl:with-param name="decor" as="xs:string?" select="$decor" />
				<xsl:with-param name="position" as="xs:integer" select="position()" />
				<xsl:with-param name="actual" as="xs:string" select="string(num)" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num)]">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>

<xsl:template name="add-number-override-if-necessary">
	<xsl:param name="type" as="xs:string?" />
	<xsl:param name="decor" as="xs:string?" />
	<xsl:param name="position" as="xs:integer" />
	<xsl:param name="actual" as="xs:string" />
	<xsl:variable name="expected" as="xs:string*">
		<xsl:choose>
			<xsl:when test="empty($type)">
				<xsl:choose>
					<xsl:when test="$decor = 'bullet'">
						<xsl:sequence select="('•')" />
					</xsl:when>
					<xsl:when test="$decor = 'dash'">
						<xsl:sequence select="('—','-')" />
					</xsl:when>
					<xsl:when test="$decor = 'arrow'">
						<!-- to do-->
					</xsl:when>
					<xsl:when test="$decor = 'none'">
						<xsl:sequence select="''" />
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="without-punct" as="xs:string">
					<xsl:choose>
						<xsl:when test="$type = 'arabic'">
							<xsl:number value="$position" format="1" />
						</xsl:when>
						<xsl:when test="$type = 'roman'">
							<xsl:number value="$position" format="i" />
						</xsl:when>
						<xsl:when test="$type = 'romanUpper'">
							<xsl:number value="$position" format="I" />
						</xsl:when>
						<xsl:when test="$type = 'alpha'">
							<xsl:number value="$position" format="a" />
						</xsl:when>
						<xsl:when test="$type = 'alphaUpper'">
							<xsl:number value="$position" format="A" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="''" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$decor = 'none'">
						<xsl:sequence select="$without-punct" />
					</xsl:when>
					<xsl:when test="$decor = 'parens'">
						<xsl:sequence select="concat('(', $without-punct, ')')" />
					</xsl:when>
					<xsl:when test="$decor = 'parenRight'">
						<xsl:sequence select="concat($without-punct, ')')" />
					</xsl:when>
					<xsl:when test="$decor = 'brackets'">
						<xsl:sequence select="concat('[', $without-punct, ']')" />
					</xsl:when>
					<xsl:when test="$decor = 'bracketRight'">
						<xsl:sequence select="concat($without-punct, ']')" />
					</xsl:when>
					<xsl:when test="$decor = 'period'">
						<xsl:sequence select="concat($without-punct, '.')" />
					</xsl:when>
					<xsl:when test="$decor = 'colon'">
						<xsl:sequence select="concat($without-punct, ':')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="$without-punct" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:if test="not($actual = $expected)">
		<xsl:attribute name="NumberOverride">
			<xsl:value-of select="$actual" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<!-- definition lists -->

<xsl:template name="definition-list">
	<xsl:param name="intro" as="element()?" select="()" />
	<xsl:param name="definitions" as="element()+" />
	<xsl:param name="wrapUp" as="element()?" select="()" />
	<xsl:param name="decoration" as="xs:string" select="'none'" />
	<xsl:call-template name="make-unordered-list-and-group-with-surrounding-text">
		<xsl:with-param name="class" as="xs:string" select="'Definition'" />
		<xsl:with-param name="intro" as="element()?" select="$intro" />
		<xsl:with-param name="children" as="element()+" select="$definitions" />
		<xsl:with-param name="wrapUp" as="element()?" select="$wrapUp" />
		<xsl:with-param name="decoration" as="xs:string" select="$decoration" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="make-unordered-list-and-group-with-surrounding-text">
	<xsl:param name="class" as="xs:string?" />
	<xsl:param name="intro" as="element()?" />
	<xsl:param name="children" as="element()+" />
	<xsl:param name="wrapUp" as="element()?" />
	<xsl:param name="decoration" as="xs:string" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="list" as="element()">
		<UnorderedList>
			<xsl:if test="exists($class)">
				<xsl:attribute name="Class">
					<xsl:value-of select="$class" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="Decoration">
				<xsl:value-of select="$decoration" />
			</xsl:attribute>
			<xsl:apply-templates select="$children">
				<xsl:with-param name="context" select="('UnorderedList', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</UnorderedList>
	</xsl:variable>
	<xsl:call-template name="group-list-with-surrounding-text">
		<xsl:with-param name="intro" select="$intro" />
		<xsl:with-param name="list" select="$list" />
		<xsl:with-param name="wrapUp" select="$wrapUp" />
	</xsl:call-template>
</xsl:template>

<xsl:template name="make-ordered-list-and-group-with-surrounding-text">
	<xsl:param name="intro" as="element()?" />
	<xsl:param name="children" as="element()+" />
	<xsl:param name="wrapUp" as="element()?" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-numbered-things($children)" />
	<xsl:variable name="type" as="xs:string" select="local:get-ordered-list-type-from-numbered-things($children, $decor)" />
	<xsl:variable name="list" as="element()">
		<OrderedList>
			<xsl:attribute name="Type">
				<xsl:value-of select="$type" />
			</xsl:attribute>
			<xsl:attribute name="Decoration">
				<xsl:value-of select="$decor" />
			</xsl:attribute>
			<xsl:apply-templates select="$children" mode="list">
				<xsl:with-param name="context" select="('OrderedList', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</OrderedList>
	</xsl:variable>
	<xsl:call-template name="group-list-with-surrounding-text">
		<xsl:with-param name="intro" select="$intro" />
		<xsl:with-param name="list" select="$list" />
		<xsl:with-param name="wrapUp" select="$wrapUp" />
	</xsl:call-template>
</xsl:template>

<!-- this template wraps the last p of the intro and the first p of the wrapUp together with the list in the same "para" -->
<!-- intro p's before the last, and wrapUp p's after the first, are put in separate paras -->
<xsl:template name="group-list-with-surrounding-text">
	<xsl:param name="intro" as="element()?" />
	<xsl:param name="list" as="element()" />
	<xsl:param name="wrapUp" as="element()?" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />

	<!-- first, handle any intro p's before the last one -->
	<xsl:apply-templates select="$intro/*[position() lt last()]" />

	<!-- then, group together the last intro p, the children, and the first wrapUp p -->
	<xsl:variable name="wrapper" as="xs:string?" select="local:get-block-wrapper($context)" />
	<xsl:choose>
		<xsl:when test="empty($wrapper)">
			<xsl:apply-templates select="$intro/*[position() = last()]" />
			<xsl:copy-of select="$list" />
			<xsl:apply-templates select="$wrapUp/*[position() = 1]" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="{ $wrapper }">
				<xsl:apply-templates select="$intro/*[position() = last()]">
					<xsl:with-param name="context" select="($wrapper, $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:copy-of select="$list" />
				<xsl:apply-templates select="$wrapUp/*[position() = 1]">
					<xsl:with-param name="context" select="($wrapper, $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>

	<!-- finally, handle any wrapUp p's after the first -->
	<xsl:apply-templates select="$wrapUp/*[position() gt 1]" />

</xsl:template>


<!--  -->

<xsl:function name="local:get-contiguous-definitions" as="element()*">
	<xsl:param name="elements" as="element()*" />
	<xsl:choose>
		<xsl:when test="empty($elements)">
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:when test="$elements[1]/self::hcontainer[@name='definition']">
			<xsl:sequence select="($elements[1], local:get-contiguous-definitions(subsequence($elements, 2)))" />
		</xsl:when>
		<xsl:when test="$elements[1]/self::tblock[@class='definition']">
			<xsl:sequence select="($elements[1], local:get-contiguous-definitions(subsequence($elements, 2)))" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:get-elements-following-contiguous-definitions" as="element()*">
	<xsl:param name="elements" as="element()*" />
	<xsl:choose>
		<xsl:when test="empty($elements)">
			<xsl:sequence select="()" />
		</xsl:when>
		<xsl:when test="$elements[1]/self::hcontainer[@name='definition']">
			<xsl:sequence select="local:get-elements-following-contiguous-definitions(subsequence($elements, 2))" />
		</xsl:when>
		<xsl:when test="$elements[1]/self::tblock[@class='definition']">
			<xsl:sequence select="local:get-elements-following-contiguous-definitions(subsequence($elements, 2))" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$elements" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="group-definitions-for-block-amendment">
	<xsl:param name="elements" as="element()*" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:param name="decoration" as="xs:string" select="'none'" />
	<xsl:if test="exists($elements)">
		<xsl:variable name="first" as="element()" select="$elements[1]" />
		<xsl:choose>
			<xsl:when test="$first/self::hcontainer[@name='definition'] or $first/self::tblock[@class='definition']">
				<xsl:call-template name="definition-list">
					<xsl:with-param name="definitions" select="local:get-contiguous-definitions($elements)" />
				</xsl:call-template>
				<xsl:call-template name="group-definitions-for-block-amendment">
					<xsl:with-param name="elements" select="local:get-elements-following-contiguous-definitions($elements)" />
					<xsl:with-param name="decoration" select="$decoration" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$first" />
				<xsl:call-template name="group-definitions-for-block-amendment">
					<xsl:with-param name="elements" select="subsequence($elements, 2)" />
					<xsl:with-param name="decoration" select="$decoration" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template match="hcontainer[@name=('definition','step')][exists(content)] | tblock[@class='definition']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>

<xsl:template match="hcontainer[@name=('definition','step')][empty(content)]">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:apply-templates select="num | heading | subheading">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:variable name="children" as="element()+" select="* except (num | heading | subheading | intro | wrapUp)" />
		<xsl:variable name="sublist" as="element()">
			<OrderedList>
				<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-numbered-things($children)" />
				<xsl:variable name="type" as="xs:string" select="local:get-ordered-list-type-from-numbered-things($children, $decor)" />
				<xsl:attribute name="Type">
					<xsl:value-of select="$type" />
				</xsl:attribute>
				<xsl:attribute name="Decoration">
					<xsl:value-of select="$decor" />
				</xsl:attribute>
				<xsl:apply-templates select="$children" mode="list">
					<xsl:with-param name="context" select="('OrderedList', 'ListItem', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</OrderedList>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="exists(intro/p) or exists(wrapUp/p)">
				<xsl:variable name="wrapper" as="xs:string?" select="local:get-block-wrapper(('ListItem', $context))" />
				<xsl:apply-templates select="intro/*[position() lt last()]">
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:element name="{ $wrapper }">
					<xsl:apply-templates select="intro/*[position() = last()]">
						<xsl:with-param name="context" select="($wrapper, 'ListItem', $context)" tunnel="yes" />
					</xsl:apply-templates>
					<xsl:copy-of select="$sublist" />
					<xsl:apply-templates select="wrapUp/*[position() = 1]">
						<xsl:with-param name="context" select="($wrapper, 'ListItem', $context)" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
				<xsl:apply-templates select="wrapUp/*[position() gt 1]">
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="intro">
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:copy-of select="$sublist" />
				<xsl:apply-templates select="wrapUp">
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</ListItem>
</xsl:template>

<xsl:template match="level[exists(content)] | paragraph[exists(content)] | subparagraph[exists(content)]" mode="list">	<!-- paragraph and subparagraph are legacy -->
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:apply-templates select="*[not(self::num)]" mode="list">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>

<xsl:template match="level[empty(content)] | paragraph[empty(content)] | subparagraph[empty(content)]" mode="list"><!-- similar to above but skips <num> -->	<!-- paragraph and subparagraph are legacy -->
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:apply-templates select="heading | subheading">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:variable name="children" as="element()+" select="* except (num | heading | subheading | intro | wrapUp)" />
		<xsl:choose>
			<xsl:when test="exists($children/num)">
				<xsl:call-template name="make-ordered-list-and-group-with-surrounding-text">
					<xsl:with-param name="intro" as="element()?" select="intro" />
					<xsl:with-param name="children" as="element()+" select="$children" />
					<xsl:with-param name="wrapUp" as="element()?" select="wrapUp" />
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="make-unordered-list-and-group-with-surrounding-text">
					<xsl:with-param name="class" as="xs:string?">
						<xsl:if test="exists($children/@name='definition')">
							<xsl:sequence select="'Definition'" />
						</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="intro" as="element()?" select="intro" />
					<xsl:with-param name="children" as="element()+" select="$children" />
					<xsl:with-param name="wrapUp" as="element()?" select="wrapUp" />
					<xsl:with-param name="decoration" as="xs:string">
						<xsl:sequence select="local:get-decoration-from-numbered-things($children)" />
					</xsl:with-param>
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</ListItem>
</xsl:template>

<xsl:template match="*" mode="list">
	<xsl:apply-templates select="." />
</xsl:template>


<!-- CLML KeyLists -->

<xsl:template match="blockList[@ukl:Name='KeyList']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<KeyList>
				<xsl:if test="exists(@ukl:Separator)">
					<xsl:attribute name="Separator">
						<xsl:value-of select="@ukl:Separator" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates mode="key-list">
					<xsl:with-param name="context" select="('KeyList', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</KeyList>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="item" mode="key-list">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<KeyListItem>
		<xsl:apply-templates select="heading" mode="key-list" />
		<ListItem>
			<xsl:apply-templates select="* except heading">
			<xsl:with-param name="context" select="('ListItem', 'KeyListItem', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</ListItem>
	</KeyListItem>
</xsl:template>

<xsl:template match="heading" mode="key-list">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<Key>
		<xsl:apply-templates>
		</xsl:apply-templates>
	</Key>
</xsl:template>


<!-- steps -->

<xsl:template name="step-list">
	<xsl:param name="intro" as="element()?" select="()" />
	<xsl:param name="steps" as="element()+" />
	<xsl:param name="wrapUp" as="element()?" select="()" />
	<xsl:param name="decoration" as="xs:string" select="'none'" />
	<xsl:call-template name="make-unordered-list-and-group-with-surrounding-text">
		<xsl:with-param name="class" as="xs:string" select="'Step'" />
		<xsl:with-param name="intro" as="element()?" select="$intro" />
		<xsl:with-param name="children" as="element()+" select="$steps" />
		<xsl:with-param name="wrapUp" as="element()?" select="$wrapUp" />
		<xsl:with-param name="decoration" as="xs:string" select="$decoration" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="hcontainer[@name='step']/num">
	<xsl:call-template name="create-element-and-wrap-as-necessary">
		<xsl:with-param name="name" select="'Text'" />
	</xsl:call-template>
</xsl:template>

</xsl:transform>