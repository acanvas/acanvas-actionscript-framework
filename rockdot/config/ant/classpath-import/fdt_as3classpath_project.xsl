<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<xsl:output method="text" indent="no" />
	<xsl:key name="valrestriction" match="//AS3Classpath" use="." />
	<xsl:template match="/">
		<!-- collect SWCs -->
		<xsl:text>flash.swc.project = </xsl:text>
		<xsl:for-each
			select="//AS3Classpath[count(.|key('valrestriction',.)[1]) = 1]">
			<xsl:sort select="." />
			<xsl:if test="@type='lib' and substring(. , 1, 22)!='frameworks/libs/player'">
				<xsl:if test="substring(. , 1, 10)='frameworks'">
					<xsl:text>${global.dir.air}/</xsl:text>
				</xsl:if>
				<xsl:value-of select="." /> 
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:text>

		</xsl:text>
		<!-- collect src path(s) -->
		<xsl:text>flash.src.project = </xsl:text>
		<xsl:for-each
			select="//AS3Classpath[count(.|key('valrestriction',.)[1]) = 1]">
			<xsl:sort select="." />
			<xsl:if test="@type='source'">
				<xsl:text>'</xsl:text>
				<xsl:value-of select="." />
				<xsl:text>' </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>