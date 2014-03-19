<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:springas="http://www.springactionscript.org/schema/objects"
		 xmlns:rockdot="http://www.sounddesignz.com/schema/rockdot"
		 xmlns:mad="http://www.sounddesignz.com/schema/mad"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.springactionscript.org/schema/objects 
					http://www.sounddesignz.com/schema/spring/spring-actionscript-objects-2.0.xsd 
					http://www.sounddesignz.com/schema/mad/madcomponents-rockdot-1.0.xsd 
					http://www.sounddesignz.com/schema/rockdot/spring-actionscript-rockdot-2.0.xsd"
	exclude-result-prefixes="xsi springas rockdot mad">
					
	<xsl:output method="xml" indent="yes" />
	
	<xsl:key name="restriction" match="//springas:object" use="@class" />
	<xsl:key name="proprestriction" match="//springas:property"
		use="@value" />
	<xsl:key name="valrestriction" match="//springas:value" use="." />
	
	<xsl:key name="tjrestriction" match="//rockdot:screen" use="@class" />
	<xsl:key name="tjtrrestriction" match="//rockdot:transition" use="@class" />
	
	<xsl:template match="/">
		<flex-config>
			<frames append="true">
				<frame>
				<label>two</label>
				<xsl:for-each
					select="//springas:object[count(.|key('restriction',@class)[1]) = 1]">
					<xsl:sort select="@class" />
					<xsl:if test="@class!=''">
						<classname>
							<xsl:value-of select="@class" />
						</classname>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each
					select="//springas:property[count(.|key('proprestriction',@value)[1]) = 1]">
					<xsl:sort select="@value" />
					<xsl:if test="@type='Class'">
						<classname>
							<xsl:value-of select="@value" />
						</classname>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each
					select="//springas:value[count(.|key('valrestriction',.)[1]) = 1]">
					<xsl:sort select="." />
					<xsl:if test="@type='Class'">
						<classname>
							<xsl:value-of select="." />
						</classname>
					</xsl:if>
				</xsl:for-each>
				
				
				
				
				<xsl:for-each
					select="//rockdot:screen[count(.|key('tjrestriction',@class)[1]) = 1]">
					<xsl:sort select="@class" />
					<xsl:if test="@class!=''">
						<classname>
							<xsl:value-of select="@class" />
						</classname>
					</xsl:if>
				</xsl:for-each>
				
				
				<xsl:for-each
					select="//rockdot:transition[count(.|key('tjtrrestriction',@class)[1]) = 1]">
					<xsl:sort select="@class" />
					<xsl:if test="@class!=''">
						<classname>
							<xsl:value-of select="@class" />
						</classname>
					</xsl:if>
				</xsl:for-each>
				</frame>
			</frames>
		</flex-config>
	</xsl:template>
	
	
	
</xsl:stylesheet>