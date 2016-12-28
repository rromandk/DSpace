<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    This stylesheet contains helper templates for things like i18n and standard attributes.


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


    <xsl:template match="dri:div[@id='aspect.eperson.PasswordLogin.div.register']">
            <div class="col-md-6 register-wrapper">
                <h3 class="div-head">
                	<i18n:text><xsl:value-of select="./dri:head"></xsl:value-of></i18n:text>
                </h3>
                <p><i18n:text><xsl:value-of select="./dri:p"></xsl:value-of></i18n:text></p>
				<a class="btn btn-default" role="button">
					<xsl:attribute name="href">
	                    <xsl:value-of select="./dri:p/dri:xref/@target"/>
	                </xsl:attribute>
					<i18n:text><xsl:value-of select="./dri:p/dri:xref//i18n:text"></xsl:value-of></i18n:text>
				</a>
            </div> 
    </xsl:template>

</xsl:stylesheet>
