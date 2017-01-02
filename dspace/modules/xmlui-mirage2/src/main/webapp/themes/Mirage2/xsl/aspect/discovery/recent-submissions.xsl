<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:output indent="yes"/>
    
    <!-- Silenciamos salida de este elemento para mostrarlo bajo el input de búsqueda -->
    <xsl:template match="dri:div[@n='total-items' or @n='total-items-message']"/>
    
    <xsl:template name="show-total-items">
    	<div>
        	<xsl:attribute name="id">
            	<xsl:value-of select="/dri:document/dri:body/dri:div[@n='site-home']/dri:div[@n='total-items']/@id"/>
           	</xsl:attribute>
            <span>
            	<xsl:attribute name="id">
            		<xsl:value-of select="/dri:document/dri:body/dri:div[@n='site-home']/dri:div[@n='total-items']/@rend"/>
                </xsl:attribute>
            	<xsl:value-of select="/dri:document/dri:body/dri:div[@n='site-home']/dri:div[@n='total-items']/dri:p"/>
            </span>
            <i18n:text>
            	<xsl:value-of select="/dri:document/dri:body/dri:div[@n='site-home']/dri:div[@n='total-items-message']/dri:p"/>
            </i18n:text>
        </div>
    </xsl:template>
    
</xsl:stylesheet>