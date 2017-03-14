<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    xmlns:str="http://exslt.org/strings"
    xmlns:xmlui="xalan://ar.edu.unlp.sedici.dspace.xmlui.util.XSLTHelper"
    xmlns:date="http://exslt.org/dates-and-times"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:if test="mets:fileSec/mets:fileGrp[@USE='CONTENT']//mets:file/mets:FLocat[contains(./@xlink:href,'isAllowed=n')]">
        	<xsl:call-template name="add-warning-bitstream-with-embargo"/>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata inline-div">
	        <div class="metadata-header inline-div">
	            <xsl:call-template name="itemSummaryView-DIM-title"/>
	<!--             <xsl:call-template name="itemSummaryView-DIM-authors"/> -->
				 <xsl:call-template name="render-metadata">
					<xsl:with-param name="field" select="'dcterms.creator.*'" />
					<xsl:with-param name="show_label" select="'false'" />
					<xsl:with-param name="container" select="'span'" />
					<xsl:with-param name="is_linked_authority" select="'true'" />
				</xsl:call-template>
				 - <xsl:call-template name="render-metadata">
					<xsl:with-param name="field" select="'dcterms.issued'" />
					<xsl:with-param name="show_label" select="'false'" />
					<xsl:with-param name="isDate" select="'true'" />
					<xsl:with-param name="container" select="'span'" />
				</xsl:call-template>
			</div>
			
			<xsl:if test="../../../../mets:fileSec/mets:fileGrp[@USE='CONTENT']//mets:file/mets:FLocat[contains(./@xlink:href,'isAllowed=n')]">
        		<xsl:call-template name="add-warning-bitstream-with-embargo"/>
        	</xsl:if>
			
            <div class="row">
                <div class="col-sm-4">
                    <div class="row">
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>

				    <xsl:call-template name="render-metadata">
                        <xsl:with-param name="field" select="'dcterms.source'" />
                        <xsl:with-param name="show_label" select="'true'" />
                        <xsl:with-param name="container" select="'span'" />
				    </xsl:call-template>

				    <div class="inline-div">
	                    <xsl:call-template name="render-metadata">
	                        <xsl:with-param name="field" select="'dcterms.license'" />
	                        <xsl:with-param name="show_label" select="'true'" />
	                        <xsl:with-param name="container" select="'span'" />
					    </xsl:call-template>
	                    <span id="item-view-CC">
	                        <xsl:variable name="cc-uri">
	                            <xsl:value-of select="./dim:field[@mdschema='dcterms' and @element='license']/@authority"/>
	                        </xsl:variable>
	                            <xsl:call-template name="generate-CC-Anchor-Logo">
	                                <xsl:with-param name="cc-uri" select="$cc-uri"/>
	                            </xsl:call-template>
	                    </span>
                    </div>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
                <div class="col-sm-8">
                    <div class="inline-label">
                    <xsl:call-template name="render-metadata">
                        <xsl:with-param name="field" select="'dcterms.contributor.director'" />
                        <xsl:with-param name="show_label" select="'true'" />
                        <xsl:with-param name="container" select="'span'" />
				    </xsl:call-template>
	                    <xsl:call-template name="render-metadata">
	                        <xsl:with-param name="field" select="'thesis.degree.name'" />
	                        <xsl:with-param name="show_label" select="'true'" />
	                        <xsl:with-param name="container" select="'span'" />
					    </xsl:call-template>
	                    <xsl:call-template name="render-metadata">
	                        <xsl:with-param name="field" select="'thesis.degree.grantor'" />
	                        <xsl:with-param name="show_label" select="'true'" />
	                        <xsl:with-param name="container" select="'span'" />
					    </xsl:call-template>
				    </div>
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="render-metadata">
                        <xsl:with-param name="field" select="'dcterms.description'" />
                        <xsl:with-param name="show_label" select="'true'" />
                        <xsl:with-param name="container" select="'span'" />
				    </xsl:call-template>
				    <xsl:call-template name="render-metadata">
						<xsl:with-param name="field" select="'dcterms.isPartOf.item'" />
						<xsl:with-param name="show_label" select="'true'" />
						<xsl:with-param name="container" select="'span'" />
					</xsl:call-template>				    
				    <xsl:call-template name="render-metadata">
						<xsl:with-param name="field" select="'dcterms.isPartOf.issue'" />
						<xsl:with-param name="show_label" select="'true'" />
						<xsl:with-param name="container" select="'span'" />
					</xsl:call-template>				    
				    <xsl:call-template name="render-metadata">
						<xsl:with-param name="field" select="'dcterms.isPartOf.series'" />
						<xsl:with-param name="show_label" select="'true'" />
						<xsl:with-param name="container" select="'span'" />
					</xsl:call-template>				    
				    <xsl:call-template name="render-metadata">
						<xsl:with-param name="field" select="'dcterms.isPartOf.project'" />
						<xsl:with-param name="show_label" select="'true'" />
						<xsl:with-param name="container" select="'span'" />
					</xsl:call-template>				    
				    <xsl:call-template name="render-metadata">
						<xsl:with-param name="field" select="'dcterms.relation.dataset'" />
						<xsl:with-param name="show_label" select="'true'" />
						<xsl:with-param name="container" select="'span'" />
					</xsl:call-template>
                    <xsl:call-template name="render-metadata">
                        <xsl:with-param name="field" select="'dcterms.subject.materia'" />
                        <xsl:with-param name="show_label" select="'true'" />
                        <xsl:with-param name="container" select="'span'" />
                        <xsl:with-param name="is_linked_authority" select="'true'" />
				    </xsl:call-template>
                    <xsl:call-template name="render-metadata">
                        <xsl:with-param name="field" select="'dcterms.subject'" />
                        <xsl:with-param name="show_label" select="'true'" />
                        <xsl:with-param name="container" select="'span'" />
                        <xsl:with-param name="is_linked_authority" select="'true'" />
				    </xsl:call-template>
				    <xsl:call-template name="render-metadata">
						<xsl:with-param name="field" select="'dcterms.relation'" />
						<xsl:with-param name="show_label" select="'true'" />
						<xsl:with-param name="container" select="'span'" />
					</xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template name="add-warning-bitstream-with-embargo">
    	<div class="col-xs-12 glyphicon glyphicon-exclamation-sign alert alert-warning">   
    		<i18n:text>xmlui.ArtifactBrowser.ItemViewer.embargo-alert</i18n:text>
    	</div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <img class="img-thumbnail" alt="Thumbnail">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$src"/>
                        </xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <img class="img-thumbnail" alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5 class="metadata-label"><i18n:text>xmlui.mirage2.itemSummaryView.Abstract</i18n:text></h5>
                <div>
                    <xsl:choose>
	                    <xsl:when test="dim:field[@element='abstract' and @language='es']">
	                    	<xsl:call-template name="render-abstract">
                            	<xsl:with-param name="abstract" select="dim:field[@element='abstract' and @language='es']"/>
                            </xsl:call-template>
	                    </xsl:when>
	                    <xsl:otherwise>
	                    	<xsl:call-template name="render-abstract">
                            	<xsl:with-param name="abstract" select="dim:field[@element='abstract']"/>
                            </xsl:call-template>
	                    </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="count(dim:field[@element='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

<xsl:template name="render-abstract">
	<xsl:param name="abstract"></xsl:param>
	<div class="simple-item-view-description item-page-field-wrapper table">
	<xsl:for-each select="$abstract">
		<xsl:choose>
			<xsl:when test="node()">
				<xsl:variable name="language" select="concat('xmlui.dri2xhtml.METS-1.0.locale.',./@language)"/>
				<h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-dcterms_abstract</i18n:text><xsl:text>&#160;</xsl:text>(<i18n:text><xsl:value-of select="$language" /> </i18n:text>):</h5>
				<p><xsl:value-of select="." disable-output-escaping="yes"/></p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>&#160;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
			<div class="spacer">&#160;</div>
		</xsl:if>
	</xsl:for-each>
	</div>
</xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor'][@qualifier='director' and descendant::text()]">
            <div class="simple-item-view-authors">
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='director']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='director']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
<!--         <div> -->
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="node()"/>
<!--         </div> -->
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title" disable-output-escaping="yes"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label" disable-output-escaping="yes"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title" disable-output-escaping="yes"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <!-- Display 'embargo label' if bitstream is embargoed -->
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
		            	<i aria-hidden="true" class="glyphicon glyphicon-lock"/>
		            	<xsl:text> </xsl:text>
		            	<span class="text-danger bg-danger">
							<i18n:text>xmlui.ArtifactBrowser.ItemViewer.embargo-label</i18n:text>
						</span>
		            </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
            
            <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
            	<span class="text-danger bg-danger">
					<i18n:text>xmlui.ArtifactBrowser.ItemViewer.embargo-label</i18n:text>
				</span>
            </xsl:if>
            
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>

    <xsl:template name="render-metadata">
        <xsl:param name="field"></xsl:param>
        <xsl:param name="context" select="." />
        <xsl:param name="separator">; </xsl:param>
        <xsl:param name="is_linked_authority"></xsl:param><!-- Si viene en true, es un link, sino no -->
        <xsl:param name="show_label">true</xsl:param>
        <xsl:param name="in_div">true</xsl:param>
        <xsl:param name="container">div</xsl:param>
        <xsl:param name="null_message"></xsl:param>
        <xsl:param name="isDate"></xsl:param>
        <xsl:param name="disableOutputEscaping">False</xsl:param>
        <xsl:param name="reduced"></xsl:param>
        <xsl:param name="local_browse_type"></xsl:param>
        <xsl:param name="isList"></xsl:param>
                
        <xsl:variable name="mp" select="str:split($field,'.')" />
        <xsl:variable name="schema" select="$mp[1]"/>
        <xsl:variable name="element" select="$mp[position()=2]"/>
        <xsl:variable name="qualifier" >
            <xsl:if test="$mp[last()=3]">
                    <xsl:value-of select="$mp[position()=3]/text()"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="fqmn" select="xmlui:replaceAll(string($field), '[\.\*]', '_')"/>
        
        <xsl:variable name="nodes" select="$context/dim:field[@mdschema=$schema and @element=$element and (($qualifier='' and not(@qualifier)) or ($qualifier!='' and (@qualifier=$qualifier or $qualifier='*')) ) ]"/>
        
        <xsl:if test="$nodes or $null_message">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <xsl:if test="$show_label ='true'">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-<xsl:value-of select="$fqmn" /></i18n:text>: 
                </h5>
                </xsl:if>
            
                <span class="metadata-values" >
                    <xsl:choose>
                        <xsl:when test="$nodes">
                            <xsl:call-template name="render-metadata-values">
                                <xsl:with-param name="separator" select="$separator"/>
                                <xsl:with-param name="nodes" select="$nodes"/>
                                <xsl:with-param name="isDate" select="$isDate"/>
                                <xsl:with-param name="anchor" select="$is_linked_authority"/>
                                <xsl:with-param name="reduced" select="$reduced"/>
                                <xsl:with-param name="disableOutputEscaping" select="$disableOutputEscaping"/>
                                <xsl:with-param name="local_browse_type" select="$local_browse_type"/>
                                <xsl:with-param name="isList" select="$isList" />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$null_message">
                            <xsl:copy-of select="$null_message"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Sin datos (no debería mostrarse)</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
        </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="render-metadata-values">
        <xsl:param name="separator">;</xsl:param>
        <xsl:param name="nodes"></xsl:param>
        <xsl:param name="anchor"></xsl:param>
        <xsl:param name="isDate"></xsl:param>
        <xsl:param name="disableOutputEscaping">False</xsl:param>
        <xsl:param name="reduced">False</xsl:param>
        <xsl:param name="local_browse_type"></xsl:param>
        <xsl:param name="isList">False</xsl:param>

        <xsl:choose>
            <xsl:when test="$nodes">
                    <xsl:if test="$isList">
                        <ul>
                        <xsl:for-each select="$nodes">
                            <li>
                                <span>
                                    <xsl:call-template name="render-one-metadata-value">
                                        <xsl:with-param name="isDate" select="$isDate"/>
                                        <xsl:with-param name="anchor" select="$anchor"/>
                                        <xsl:with-param name="reduced" select="$reduced"/>
                                        <xsl:with-param name="disableOutputEscaping" select="$disableOutputEscaping"/>
                                        <xsl:with-param name="local_browse_type" select="$local_browse_type"/>
                                        <xsl:with-param name="isList" select="$isList" />
                                    </xsl:call-template>
                                </span>
                            </li>
                        </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="not($isList)">
                        <xsl:for-each select="$nodes">
                            <span>                            
                                <xsl:call-template name="render-one-metadata-value">
                                    <xsl:with-param name="isDate" select="$isDate"/>
                                    <xsl:with-param name="anchor" select="$anchor"/>
                                    <xsl:with-param name="reduced" select="$reduced"/>
                                    <xsl:with-param name="disableOutputEscaping" select="$disableOutputEscaping"/>
                                    <xsl:with-param name="local_browse_type" select="$local_browse_type"/>
                                    <xsl:with-param name="isList" select="$isList" />
                                </xsl:call-template>
                            </span>
                            <xsl:if test="not(position()=last())">
                                <xsl:value-of select="$separator" /> 
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>    
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="render-one-metadata-value">
        <xsl:param name="separator">;</xsl:param>
        <xsl:param name="anchor"></xsl:param>
        <xsl:param name="isDate"></xsl:param>
        <xsl:param name="disableOutputEscaping">False</xsl:param>
        <xsl:param name="reduced">False</xsl:param>
        <xsl:param name="local_browse_type"></xsl:param>

        <xsl:if test="@language">
            <xsl:attribute name="xml:lang" ><xsl:value-of select="@language"/></xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$anchor">
                <xsl:choose>
                    <xsl:when test="$local_browse_type">
                        <xsl:choose>
                            <xsl:when test="@authority!=''">
                                <xsl:call-template name="build-anchor">
                                    <xsl:with-param name="a.href" select="concat('http://digital.cic.gba.gob.ar/browse?authority=', encoder:encode(@authority), '&amp;', 'type=', $local_browse_type)"/>
                                    <xsl:with-param name="a.value" select="text()"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="text()" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="@authority!=''">
                        <xsl:call-template name="build-anchor">
                            <xsl:with-param name="a.href" select="@authority"/>
                            <xsl:with-param name="a.value" select="text()"/>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- Si llega a este punto no tiene atributo authority
                        verifico el caso especial del metadato isPartOf issue,
                        sin authority no tiene que ser un link
                     -->
                    <xsl:when test="@qualifier='issue' and @element='isPartOf'">
                        <xsl:value-of select="text()" />
                    </xsl:when>
                    <xsl:when test="@element='creator'">
                        <xsl:call-template name="build-anchor">
                            <xsl:with-param name="a.href" select="concat('/browse?type=author', '&amp;', 'value=', text())"/>
                            <xsl:with-param name="a.value" select="text()"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="@element='subject'">
                        <xsl:call-template name="build-anchor">
                            <xsl:with-param name="a.href" select="concat('/browse?type=subject', '&amp;', 'value=', text())"/>
                            <xsl:with-param name="a.value" select="text()"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="build-anchor">
                            <xsl:with-param name="a.href" select="text()"/>
                            <xsl:with-param name="a.value" select="text()"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                    </xsl:choose>
            </xsl:when>
            <xsl:when test="$isDate">
                    <xsl:call-template name="cambiarFecha" >
                            <xsl:with-param name="isDate" select="$isDate"></xsl:with-param>
                    </xsl:call-template>
            </xsl:when>
            <xsl:when test="($disableOutputEscaping='True') and ($reduced='True')">
                <xsl:value-of select="substring(text(),1,200)" disable-output-escaping="yes"/>
                <xsl:value-of select="concat(substring-before(substring(text(),200,300),'.'), '.')" disable-output-escaping="yes"/>
            </xsl:when>
            <xsl:when test="$disableOutputEscaping='True'">
                <xsl:value-of select="text()" disable-output-escaping="yes"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="text()"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@qualifier='editor' or @qualifier='compilator'">
            <span class='editor-label'> (<i18n:text>xmlui.dri2xhtml.METS-1.0.item-dcterms_creator_<xsl:value-of select="@qualifier" /></i18n:text>)</span>
        </xsl:if>
    </xsl:template>
    <xsl:template name="cambiarFecha" match="dim:field/text()">
        <xsl:param name="isDate"></xsl:param>
        <xsl:if test="$isDate">
			<xsl:value-of select="date:year(.)" />
        </xsl:if>
    </xsl:template>
	<xsl:template name="generate-CC-Anchor-Logo">
		<xsl:param name="cc-uri"/>
		<xsl:param name="size-logo">88x31</xsl:param>
		<xsl:variable name="img_src">
			<xsl:value-of select="concat('https://licensebuttons.net/l/',substring-after($cc-uri, 'http://creativecommons.org/licenses/'),$size-logo,'.png')"/>
		</xsl:variable>
<br></br>		<xsl:choose>
			<xsl:when test="$cc-uri">
				<xsl:call-template name="build-anchor">
					<xsl:with-param name="a.href" select="$cc-uri"/>
					<xsl:with-param name="img.src" select="$img_src"/>
					<xsl:with-param name="img.alt" select="$cc-uri"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<i18n:text>xmlui.Submission.submit.CCLicenseStep.no_license</i18n:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> 
 </xsl:stylesheet>
