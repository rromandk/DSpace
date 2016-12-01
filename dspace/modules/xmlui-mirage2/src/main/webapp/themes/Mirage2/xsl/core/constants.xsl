<!-- The contents of this file are subject to the license and copyright detailed 
	in the LICENSE and NOTICE files at the root of the source tree and available 
	online at http://www.dspace.org/license/ -->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

	<xsl:output indent="yes" />
	<!-- Requested Page URI. Some functions may alter behavior of processing 
		depending if URI matches a pattern. Specifically, adding a static page will 
		need to override the DRI, to directly add content. -->
	<xsl:variable name="request-uri"
		select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']" />
	<xsl:variable name="search-url"
		select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']" />
	
	<xsl:variable name="is-error-page">
		<xsl:choose>
		<xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']) = 0">
			<xsl:text>true</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>false</xsl:text>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>	
	
	<xsl:variable name="theme-path">
		<xsl:text>/themes/</xsl:text>
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']" />
		<xsl:text>/</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="home-path">
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]" />
		<xsl:text>/</xsl:text>
	</xsl:variable>
	
	
	<!-- Esta variable sirve para obtener desde cualquier parte del sistema el metadato que contiene los parametros que van por URL  -->
	<xsl:variable name="query-string">
		<xsl:value-of
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='queryString']/text()"	>		
		</xsl:value-of>
	</xsl:variable>
	
	<xsl:variable name="global-theme-path">
		<xsl:value-of 
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme' and @qualifier='path']">
		</xsl:value-of>
	</xsl:variable>
	
	<xsl:variable name="global-context-path">
		<xsl:value-of 
			select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']">
		</xsl:value-of>
	</xsl:variable>
	
	<xsl:variable name="handle-autoarchive">
		<xsl:value-of select="/dri:document/dri:meta/dri:repositoryMeta/dri:repository/@repositoryID"/>
		<xsl:text>/12</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="url-autoarchive">
		<xsl:text>/metadata/handle/</xsl:text>
		<xsl:value-of select="$handle-autoarchive"/>
		<xsl:text>/mets.xml</xsl:text>
	</xsl:variable>
	
</xsl:stylesheet>