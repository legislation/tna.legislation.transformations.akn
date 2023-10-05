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
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()">
			<xsl:element name="{ $name }">
				<xsl:if test="$ordered">
					<xsl:attribute name="Type">
						<xsl:value-of select="local:get-type-of-ordered-list(., $decor)" />
					</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="Decoration">
					<xsl:value-of select="$decor" />
				</xsl:attribute>
				<xsl:apply-templates>
					<xsl:with-param name="decor" select="$decor" />
					<xsl:with-param name="context" select="($name, local:get-wrapper($name, $context), $context)" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="item">
	<xsl:param name="decor" as="xs:string" select="local:get-decoration-from-numbered-things(.)" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:if test="exists(num)">
			<xsl:attribute name="NumberOverride">
				<xsl:value-of select="local:strip-punctuation-for-number-override(num, $decor)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num)]">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>


<!-- definition lists -->

<xsl:function name="local:should-merge-intro-and-definitions">
	<xsl:param name="parent" as="element()" />
	<xsl:sequence select="exists($parent/intro) and exists($parent/hcontainer[@name='definition']) and exists($parent/intro/p) and (count($parent/intro/*) eq 1) and (every $child in $parent/* satisfies ($child/self::num or $child/self::heading or $child/self::subheading or $child/self::intro or $child/self::hcontainer[@name='definition'] or $child/self::wrapUp))" />
</xsl:function>

<xsl:template name="merge-intro-and-definitions">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="wrapper" as="xs:string?" select="local:get-block-wrapper($context)" />
	<xsl:choose>
		<xsl:when test="empty($wrapper)">
			<xsl:apply-templates select="intro/*">
				<xsl:with-param name="context" select="($wrapper, $context)" tunnel="yes" />
			</xsl:apply-templates>
			<xsl:call-template name="definition-list">
				<xsl:with-param name="definitions" select="hcontainer[@name='definition']" />
				<xsl:with-param name="context" select="($wrapper, $context)" tunnel="yes" />
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:element name="{ $wrapper }">
				<xsl:apply-templates select="intro/*">
					<xsl:with-param name="context" select="($wrapper, $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:call-template name="definition-list">
					<xsl:with-param name="definitions" select="hcontainer[@name='definition']" />
					<xsl:with-param name="context" select="($wrapper, $context)" tunnel="yes" />
				</xsl:call-template>
			</xsl:element>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="definition-list">
	<xsl:param name="definitions" as="element()+" />
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:param name="decoration" as="xs:string" select="'none'" />
	<xsl:call-template name="wrap-as-necessary">
		<xsl:with-param name="clml" as="element()+">
			<UnorderedList Class="Definition" Decoration="{ $decoration }">
				<xsl:apply-templates select="$definitions">
					<xsl:with-param name="context" select="('UnorderedList', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</UnorderedList>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

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

<xsl:template match="hcontainer[@name='definition'][exists(content)] | tblock[@class='definition']">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<ListItem>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</ListItem>
</xsl:template>

<xsl:template match="hcontainer[@name='definition'][empty(content)]">
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
			<xsl:when test="exists(intro/p) and (count(intro/*) eq 1)">
				<xsl:variable name="wrapper" as="xs:string?" select="local:get-block-wrapper(('ListItem', $context))" />
				<xsl:element name="{ $wrapper }">
					<xsl:apply-templates select="intro/*">
						<xsl:with-param name="context" select="($wrapper, 'ListItem', $context)" tunnel="yes" />
					</xsl:apply-templates>
					<xsl:copy-of select="$sublist" />
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="intro">
					<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
				</xsl:apply-templates>
				<xsl:copy-of select="$sublist" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="wrapUp">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
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
		<xsl:apply-templates select="heading | subheading | intro">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:variable name="children" as="element()+" select="* except (num | heading | subheading | intro | wrapUp)" />
		<xsl:choose>
			<xsl:when test="exists($children/num)">
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
			</xsl:when>
			<xsl:otherwise>
				<UnorderedList>
					<xsl:if test="exists($children/@name='definition')">
						<xsl:attribute name="Class">
							<xsl:text>Definition</xsl:text>
						</xsl:attribute>
					</xsl:if>
					<xsl:variable name="decor" as="xs:string" select="local:get-decoration-from-numbered-things($children)" />
					<xsl:attribute name="Decoration">
						<xsl:value-of select="$decor" />
					</xsl:attribute>
					<xsl:apply-templates select="$children" mode="list">
						<xsl:with-param name="context" select="('UnorderedList', 'ListItem', $context)" tunnel="yes" />
					</xsl:apply-templates>
				</UnorderedList>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="wrapUp">
			<xsl:with-param name="context" select="('ListItem', $context)" tunnel="yes" />
		</xsl:apply-templates>
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

</xsl:transform>