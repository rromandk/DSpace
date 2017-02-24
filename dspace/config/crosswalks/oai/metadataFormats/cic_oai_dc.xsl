<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	> http://www.openarchives.org/OAI/2.0/oai_dc.xsd

 -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	<xsl:template match="/">
		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
			xmlns:dc="http://purl.org/dc/elements/1.1/" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			<!-- dc.type -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='driver']/doc:field[@name='value']">
				<dc:type><xsl:value-of select="concat('info:eu-repo/semantics/',.)" /></dc:type>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='snrd']/doc:field[@name='value']">
				<dc:type><xsl:value-of select="concat('info:ar-repo/semantics/',.)" /></dc:type>
			</xsl:for-each>
			<!-- dc.type.version -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type-version']/doc:element[@name='driver']/doc:field[@name='value']">
				<dc:type><xsl:value-of select="." /></dc:type>
			</xsl:for-each>
			<!-- dc.title -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>
			<!-- dcterms.alternative -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>
			<!-- dcterms.creator.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='creator']/doc:element/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>

			<!-- dc.contributor.director-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='contributor']/doc:element[@name='director']/doc:element/doc:field[@name='value'][contains(., 'tesis')]">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='contributor']/doc:element[@name='director']/doc:element/doc:field[@name='value'][not(contains(., 'tesis'))]">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>
			
			<!-- dcterms.subject.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<dc:subject><xsl:value-of select="." /></dc:subject>
			</xsl:for-each>
			<!-- dcterms.abstract -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			<!-- dcterms.description-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			<!-- thesis.degree.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='thesis']/doc:element[@name='degree']/doc:element[@name='name']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>

			<!-- dcterms.issued -->
			<xsl:choose>
				<xsl:when test="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='issued']/doc:element/doc:field[@name='value'] &gt; 0">
					<dc:date><xsl:value-of select="substring(doc:metadata/doc:element[@name='dcterms']/doc:element[@name='issued']/doc:element/doc:field[@name='value'],1,10)" /></dc:date>
				</xsl:when>
				<xsl:otherwise>
				<!-- dc.date.available -->
					<dc:date><xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value'],1,10)" /></dc:date>					
				</xsl:otherwise>
			</xsl:choose>		

			<!-- mimetype -->
			<xsl:variable name="formats" select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle' and doc:field[@name='name' and text()='ORIGINAL']]/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']"/>
            
            <xsl:for-each select="$formats">
				<xsl:if test="not(. = ../preceding-sibling::*/doc:field[@name='format'])">
					<dc:format><xsl:value-of select="." /></dc:format>
				</xsl:if>
            </xsl:for-each>
			
			<!-- dcterms.extent -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='extent']/doc:element/doc:field[@name='value']">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each>
			<!-- dcterms.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<dc:publisher><xsl:value-of select="." /></dc:publisher>
			</xsl:for-each>			
			<!-- dc.identifier.uri -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
			<!-- dcterms.identifier.url -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='identifier']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
			<!-- dc:source -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<dc:source><xsl:value-of select="." /></dc:source>
			</xsl:for-each>
			<!-- dcterms.language -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='language']/doc:element/doc:field[@name='value']">
				<dc:language><xsl:value-of select="." /></dc:language>
			</xsl:for-each>

			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='item']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<xsl:variable name="series" select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='series']/doc:element/doc:field[@name='value']"/>
			<xsl:variable name="issue" select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='issue']/doc:element/doc:field[@name='value']"/>
			
			<xsl:if test="$series != '' and $issue != ''">
				<dc:relation><xsl:value-of select="$series" />:<xsl:value-of select="$issue" /></dc:relation>
			</xsl:if>
			<xsl:if test="$series != '' and $issue = ''">
				<dc:relation><xsl:value-of select="$series" /></dc:relation>
			</xsl:if>
			<xsl:if test="$series = '' and $issue != ''">
				<dc:relation><xsl:value-of select="$issue" /></dc:relation>
			</xsl:if>

			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='project']/doc:element/doc:field[@name='value']">
				<dc:relation>info:eu-repo/grantAgreement/<xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='relation']/doc:element[@name='dataset']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- Formatting dc.date and dc.rigths -->
			<xsl:variable name="bitstreams" select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle'][./doc:field/text()='ORIGINAL']/doc:element[@name='bitstreams']/doc:element[@name='bitstream']"/>
			<xsl:variable name="embargoed" select="$bitstreams/doc:field[@name='embargo']"/>

			<xsl:choose>
				<xsl:when test="count($bitstreams) = 0 or count($embargoed[text() = 'forever']) = count($bitstreams) ">
					<dc:rights>info:eu-repo/semantics/closedAccess</dc:rights>
				</xsl:when>
				<xsl:when test="count($embargoed) = 0">
					<dc:rights>info:eu-repo/semantics/openAccess</dc:rights>
				</xsl:when>
				<xsl:when test="count($embargoed[text() = 'forever']) &gt; 0">
					<dc:rights>info:eu-repo/semantics/restrictedAccess</dc:rights>
				</xsl:when>
				<xsl:otherwise>
<!-- 			es un embargoedAccess si o si -->
					<xsl:for-each select="$embargoed">
						<xsl:sort select="text()" />
						<xsl:if test="position() = 1">
							<dc:date><xsl:value-of select="concat('info:eu-repo/date/embargoEnd/',text())"/></dc:date>
							<dc:rigths>info:eu-repo/semantics/embargoedAccess</dc:rigths>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

			<!-- dcterms.license -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='license']/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
		</oai_dc:dc>
	</xsl:template>
</xsl:stylesheet>
