<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Main structure of the page, determines where
    header, footer, body, navigation are structurally rendered.
    Rendering of the header, footer, trail and alerts

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

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
                xmlns:confman="org.dspace.core.ConfigurationManager"
                xmlns:xmlui="xalan://ar.edu.unlp.sedici.dspace.xmlui.util.XSLTHelper"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman xmlui">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Requested Page URI. Some functions may alter behavior of processing depending if URI matches a pattern.
        Specifically, adding a static page will need to override the DRI, to directly add content.
    -->
    <xsl:variable name="request-uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>

    <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">

        <xsl:choose>
            <xsl:when test="not($isModal)">


            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
            </xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7]&gt; &lt;html class=&quot;no-js lt-ie9 lt-ie8 lt-ie7&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 7]&gt;    &lt;html class=&quot;no-js lt-ie9 lt-ie8&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 8]&gt;    &lt;html class=&quot;no-js lt-ie9&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if gt IE 8]&gt;&lt;!--&gt; &lt;html class=&quot;no-js&quot; lang=&quot;en&quot;&gt; &lt;!--&lt;![endif]--&gt;
            </xsl:text>

                <!-- First of all, build the HTML head element -->

                <xsl:call-template name="buildHead"/>

                <!-- Then proceed to the body -->
                <body>
                    <!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
                   chromium.org/developers/how-tos/chrome-frame-getting-started -->
                    <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
                    <xsl:choose>
                        <xsl:when
                                test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                            <xsl:apply-templates select="dri:body/*"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="buildHeader"/>
                            <xsl:call-template name="buildTrail"/>
                            <!--javascript-disabled warning, will be invisible if javascript is enabled-->
                            <div id="no-js-warning-wrapper" class="hidden">
                                <div id="no-js-warning">
                                    <div class="notice failure">
                                        <xsl:text>JavaScript is disabled for your browser. Some features of this site may not work without it.</xsl:text>
                                    </div>
                                </div>
                            </div>

                            <div id="main-container" class="container">

                                <div class="row row-offcanvas row-offcanvas-right">
                                    <div class="horizontal-slider clearfix">
                                        <div class="col-xs-12 col-sm-12 col-md-9 main-content">
                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>

                                            <div class="visible-xs visible-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>
                                        </div>
                                        <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar" role="navigation">
                                            <xsl:apply-templates select="dri:options"/>
                                        </div>

                                    </div>
                                </div>

                                <!--
                            The footer div, dropping whatever extra information is needed on the page. It will
                            most likely be something similar in structure to the currently given example. -->
                            <div class="hidden-xs hidden-sm">
                            <xsl:call-template name="buildFooter"/>
                             </div>
                         </div>


                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Javascript at the bottom for fast page loading -->
                    <xsl:call-template name="addJavascript"/>
                </body>
                <xsl:text disable-output-escaping="yes">&lt;/html&gt;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <!-- This is only a starting point. If you want to use this feature you need to implement
                JavaScript code and a XSLT template by yourself. Currently this is used for the DSpace Value Lookup -->
                <xsl:apply-templates select="dri:body" mode="modal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
    information is either user-provided bits of post-processing (as in the case of the JavaScript), or
    references to stylesheets pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

            <!-- Use the .htaccess and remove these lines to avoid edge case issues.
             More info: h5bp.com/i/378 -->
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>

            <!-- Mobile viewport optimized: h5bp.com/viewport -->
            <meta name="viewport" content="width=device-width,initial-scale=1"/>

            <link rel="shortcut icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/favicon.ico</xsl:text>
                </xsl:attribute>
            </link>
            <link rel="apple-touch-icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/apple-touch-icon.png</xsl:text>
                </xsl:attribute>
            </link>

            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>DSpace</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                    </xsl:if>
                </xsl:attribute>
            </meta>

            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS'][not(@qualifier)]">
                <meta name="ROBOTS">
                    <xsl:attribute name="content">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS']"/>
                    </xsl:attribute>
                </meta>
            </xsl:if>

            <!-- Add stylesheets -->

            <!--TODO figure out a way to include these in the concat & minify-->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$theme-path"/>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <link rel="stylesheet" href="{concat($theme-path, 'styles/main.css')}"/>

            <!-- Add syndication feeds -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='autolink']"/>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>

            <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
            <script>
                //Clear default text of emty text areas on focus
                function tFocus(element)
                {
                if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                }
                //Clear default text of emty text areas on submit
                function tSubmit(form)
                {
                var defaultedElements = document.getElementsByTagName("textarea");
                for (var i=0; i != defaultedElements.length; i++){
                if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                function disableEnterKey(e)
                {
                var key;

                if(window.event)
                key = window.event.keyCode;     //Internet Explorer
                else
                key = e.which;     //Firefox and Netscape

                if(key == 13)  //if "Enter" pressed, then disable!
                return false;
                else
                return true;
                }
                function FnArray(){
                  this.funcs = new Array;
                }
                FnArray.prototype.add = function(f){
                  if( typeof f!= "function" ){
                    f = new Function(f);
                  }
                  this.funcs[this.funcs.length] = f;
                };
                FnArray.prototype.execute = function(){
                  for( var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> this.funcs.length; i++ ){
                    this.funcs[i]();
                  }
                };
                var runAfterJSImports = new FnArray();
            </script>

            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 9]&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/html5shiv/dist/html5shiv.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/respond/dest/respond.min.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;![endif]--&gt;</xsl:text>

            <!-- Modernizr enables HTML5 elements & feature detects -->
            <script src="{concat($theme-path, 'vendor/modernizr/modernizr.js')}">&#160;</script>

            <!-- Add the title in -->
            <xsl:call-template name="addPageTitle"/>

            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                              disable-output-escaping="yes"/>
            </xsl:if>

            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>

            <!-- Add MathJAX JS library to render scientific formulas-->
            <xsl:if test="confman:getProperty('webui.browse.render-scientific-formulas') = 'true'">
                <script type="text/x-mathjax-config">
                    MathJax.Hub.Config({
                      tex2jax: {
                        inlineMath: [['$latex','$'], ['\\(','\\)']],
                        ignoreClass: "detail-field-data|detailtable|exception"
                      },
                      TeX: {
                        Macros: {
                          AA: '{\\mathring A}'
                        }
                      }
                    });
                </script>
                <script type="text/javascript" src="//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">&#160;</script>
            </xsl:if>

             <xsl:if test="/dri:document/dri:body/dri:div[@id='aspect.submission.StepTransformer.div.submit-describe']/dri:list[@id='aspect.submission.StepTransformer.list.submit-describe']">
                <script type="text/javascript" src="//cdn.ckeditor.com/4.4.7/full/ckeditor.js">&#160;</script>
                <script type="text/javascript">var path= "<xsl:value-of select="$context-path"/>";
                CKEDITOR.config.customConfig =path.concat("/static/js/editorConfig.js");                    
                CKEDITOR.config.language= "<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page' and @qualifier='currentLocale']"/>";
                </script>
            </xsl:if>
            <link rel="stylesheet" href="//cdn.jsdelivr.net/chartist.js/latest/chartist.min.css" />
             <script src="//cdn.jsdelivr.net/chartist.js/latest/chartist.min.js">&#160;</script>
            
        </head>
    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildHeader">


        <header>
            <div role="navigation">
                 <div class="container">
                     <a href="{$context-path}/">
                         <img class="img-responsive header-img" src="{$theme-path}/images/ri-uner-logo.png" />
                     </a>
                     <a href="http://www.uner.edu.ar/" target="_blank" class="pull-right hidden-xs">
                         <img class="img-responsive header-img" src="{$theme-path}/images/uner-logo.png" />
                     </a>
                 </div>
            </div>
        </header>

    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildTrail">
        <div class="trail-wrapper hidden-print">
            <div class="container">
                <div class="row">
                    <!--TODO-->
                    <div class="pull-left">
                        <xsl:choose>
                            <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) > 1">
                                <div class="breadcrumb dropdown visible-xs">
                                    <a id="trail-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                       data-toggle="dropdown">
                                        <xsl:variable name="last-node"
                                                      select="/dri:document/dri:meta/dri:pageMeta/dri:trail[last()]"/>
                                        <xsl:choose>
                                            <xsl:when test="$last-node/i18n:*">
                                                <xsl:apply-templates select="$last-node/*"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="$last-node/text()"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>&#160;</xsl:text>
                                        <b class="caret"/>
                                    </a>
                                    <ul class="dropdown-menu" role="menu" aria-labelledby="trail-dropdown-toggle">
                                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"
                                                             mode="dropdown"/>
                                    </ul>
                                </div>
                                <ul class="breadcrumb hidden-xs">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                </ul>
                            </xsl:when>
                            <xsl:otherwise>
                                <ul class="breadcrumb">
                                    <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                </ul>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="pull-right">
	                    <div class="navbar-header hidden-xs hidden-sm">
	                        <ul class="nav navbar-nav">
								<xsl:if test="dri:options/dri:list[@id='aspect.viewArtifacts.Navigation.list.context']/dri:item">
									<xsl:call-template name="topright-element">
										<xsl:with-param name="element" select="'context'" />
									</xsl:call-template>
								</xsl:if>
	                        </ul>
	                        <ul class="nav navbar-nav">
								<xsl:if test="dri:options/dri:list[@id='aspect.viewArtifacts.Navigation.list.administrative']/dri:item">
									<xsl:call-template name="topright-element">
										<xsl:with-param name="element" select="'administrative'" />
									</xsl:call-template>
								</xsl:if>
	                        </ul>
				            <xsl:if test="not(/dri:document/dri:meta/dri:userMeta/dri:metadata[@qualifier='group'][@element='identifier']/text() = 'Administrator')">
		                        <ul class="nav navbar-nav">
		                        	<xsl:call-template name="about"/>
		                        </ul>
	                        </xsl:if>
				
				            <xsl:if test="not(/dri:document/dri:meta/dri:userMeta/dri:metadata[@qualifier='group'][@element='identifier']/text() = 'Administrator')">
		                        <ul class="nav navbar-nav">
		                        	<xsl:call-template name="howTo"/>
		                        </ul>
	                        </xsl:if>
<!-- 	                        <ul class="nav navbar-nav"> -->
<!-- 	                        	<xsl:call-template name="languageSelection"/> -->
<!-- 	                        </ul> -->
	                        <ul class="nav navbar-nav visible-xs">
	                            <xsl:choose>
	                                <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
	                                    <li class="dropdown">
	                                        <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
	                                           data-toggle="dropdown">
	                                            <span class="hidden-xs">
	                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
	                            dri:metadata[@element='identifier' and @qualifier='firstName']"/>
	                                                <xsl:text> </xsl:text>
	                                                <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/
	                            dri:metadata[@element='identifier' and @qualifier='lastName']"/>
	                                                &#160;
	                                                <b class="caret"/>
	                                            </span>
	                                        </a>
	                                        <ul class="dropdown-menu pull-right" role="menu"
	                                            aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
	                                            <li>
	                                                <a href="{/dri:document/dri:meta/dri:userMeta/
	                            dri:metadata[@element='identifier' and @qualifier='url']}">
	                                                    <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
	                                                </a>
	                                            </li>
	                                            <li>
	                                                <a href="{/dri:document/dri:meta/dri:userMeta/
	                            dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
	                                                    <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
	                                                </a>
	                                            </li>
	                                        </ul>
	                                    </li>
	                                </xsl:when>
	                                <xsl:otherwise>
	                                    <li>
	                                        <a href="{/dri:document/dri:meta/dri:userMeta/
	                            dri:metadata[@element='identifier' and @qualifier='loginURL']}">
	                                            <span class="hidden-xs">
	                                                <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
	                                            </span>
	                                        </a>
	                                    </li>
	                                </xsl:otherwise>
	                            </xsl:choose>
	                        </ul>
	                        <ul class="nav navbar-nav">
	                            <xsl:choose>
		                            <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
										<xsl:if test="dri:options/dri:list[@id='aspect.viewArtifacts.Navigation.list.account']/dri:item">						    
											<xsl:call-template name="topright-element">
												<xsl:with-param name="element" select="'account'" />
											</xsl:call-template>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:if test="dri:options/dri:list[@id='aspect.viewArtifacts.Navigation.list.account']/dri:item">						    
											<li>
												<a>
													<xsl:attribute name="href">
														<xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='loginURL']"/>
													</xsl:attribute>
													<i18n:text>xmlui.EPerson.Navigation.login</i18n:text>
												</a>
											</li>
										</xsl:if>									
									</xsl:otherwise>
								</xsl:choose>
	                        </ul>
	                        
	
	                    </div>
                        <button data-toggle="offcanvas" class="navbar-toggle visible-xs visible-sm" type="button">
                            <span class="sr-only"><i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                    </div>
                </div>
            </div>
        </div>


    </xsl:template>

    <!--The Trail-->
    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail-->
        <li>
            <xsl:if test="position()=1">
                <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
            </xsl:if>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="dri:trail" mode="dropdown">
        <!--put an arrow between the parts of the trail-->
        <li role="presentation">
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a role="menuitem">
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:if test="position()=1">
                            <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                        </xsl:if>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:when test="position() > 1 and position() = last()">
                    <xsl:attribute name="class">disabled</xsl:attribute>
                    <a role="menuitem" href="#">
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:if test="position()=1">
                        <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                    </xsl:if>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <!--The License-->
    <xsl:template name="cc-license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                />
        <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="row">
            <div class="col-sm-3 col-xs-12">
                <a rel="license"
                   href="{$ccLicenseUri}"
                   alt="{$ccLicenseName}"
                   title="{$ccLicenseName}"
                        >
                    <xsl:call-template name="cc-logo">
                        <xsl:with-param name="ccLicenseName" select="$ccLicenseName"/>
                        <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri"/>
                    </xsl:call-template>
                </a>
            </div> <div class="col-sm-8">
                <span>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <xsl:value-of select="$ccLicenseName"/>
                </span>
            </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="cc-logo">
        <xsl:param name="ccLicenseName"/>
        <xsl:param name="ccLicenseUri"/>
        <xsl:variable name="ccLogo">
             <xsl:choose>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by/')">
                       <xsl:value-of select="'cc-by.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-sa/')">
                       <xsl:value-of select="'cc-by-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nd/')">
                       <xsl:value-of select="'cc-by-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc/')">
                       <xsl:value-of select="'cc-by-nc.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-sa/')">
                       <xsl:value-of select="'cc-by-nc-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-nd/')">
                       <xsl:value-of select="'cc-by-nc-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/zero/')">
                       <xsl:value-of select="'cc-zero.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/mark/')">
                       <xsl:value-of select="'cc-mark.png'" />
                  </xsl:when>
                  <xsl:otherwise>
                       <xsl:value-of select="'cc-generic.png'" />
                  </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
        <img class="img-responsive">
             <xsl:attribute name="src">
                <xsl:value-of select="concat($theme-path,'/images/creativecommons/', $ccLogo)"/>
             </xsl:attribute>
             <xsl:attribute name="alt">
                 <xsl:value-of select="$ccLicenseName"/>
             </xsl:attribute>
        </img>
    </xsl:template>

    <!-- Like the header, the footer contains various miscellaneous text, links, and image placeholders -->
    <xsl:template name="buildFooter">
        <footer>
                <div class="row">
                    <hr/>
                    <div id="logo-footer" class="col-xs-12 col-sm-8">
                        <a class="pull-left" id="img-logo-footer" href="http://www.uner.edu.ar/">
                            <img class="img-responsive" src="{$theme-path}/images/uner_footer.gif" />
                        </a>
                    </div>    
                    <div id="info-footer" class="col-xs-12 col-sm-4 pull-right">
                            <a href="#">RIUNER</a><br></br>
                                <addres>
                                    <small>Depende: Secretaría Académica</small><br></br> 
                                    <small>Dirección postal:  Eva Perón 24</small><br></br> 
                                    <small>Tel: 03442-421558</small><br></br>
                                    <small>Correo electrónico: riuner@uner.edu.ar</small><br></br>
                            </addres>
                            <div class="hidden-print">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of
                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                        <xsl:text>/feedback</xsl:text>
                                    </xsl:attribute>
                                    <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>
                                </a>
                            </div>
                        </div>
                    
                </div>
                <!--Invisible link to HTML sitemap (for search engines) -->
                <a class="hidden">
                    <xsl:attribute name="href">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/htmlmap</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </a>
            <p>&#160;</p>
        </footer>
    </xsl:template>


    <!--
            The meta, body, options elements; the three top-level elements in the schema
    -->




    <!--
        The template to handle the dri:body element. It simply creates the ds-body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->
    <xsl:template match="dri:body">
        <div>
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div class="alert">
                    <button type="button" class="close" data-dismiss="alert">&#215;</button>
                    <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                </div>
            </xsl:if>

            <xsl:choose>
                <!-- Handler for Static pages -->
                <xsl:when test="starts-with($request-uri, 'page/')">
                    <div class="static-page">
                        <xsl:copy-of select="document(concat('../../',$request-uri,'.xhtml') )" />
                    </div>
                </xsl:when>
                <!-- Otherwise use default handling of body -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>

        </div>
    </xsl:template>


    <!-- Currently the dri:meta element is not parsed directly. Instead, parts of it are referenced from inside
        other elements (like reference). The blank template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>

    <!-- Meta's children: userMeta, pageMeta, objectMeta and repositoryMeta may or may not have templates of
        their own. This depends on the meta template implementation, which currently does not go this deep.
    <xsl:template match="dri:userMeta" />
    <xsl:template match="dri:pageMeta" />
    <xsl:template match="dri:objectMeta" />
    <xsl:template match="dri:repositoryMeta" />
    -->

    <xsl:template name="addJavascript">

        <script type="text/javascript"><xsl:text>
                         if(typeof window.publication === 'undefined'){
                            window.publication={};
                          };
                        window.publication.contextPath= '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/><xsl:text>';</xsl:text>
            <xsl:text>window.publication.themePath= '</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>
        <!--TODO concat & minify!-->

        <script>
            <xsl:text>if(!window.DSpace){window.DSpace={};}window.DSpace.context_path='</xsl:text><xsl:value-of select="$context-path"/><xsl:text>';window.DSpace.theme_path='</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>

        <!--inject scripts.html containing all the theme specific javascript references
        that can be minified and concatinated in to a single file or separate and untouched
        depending on whether or not the developer maven profile was active-->
        <xsl:variable name="scriptURL">
            <xsl:text>cocoon://themes/</xsl:text>
            <!--we can't use $theme-path, because that contains the context path,
            and cocoon:// urls don't need the context path-->
            <xsl:value-of select="$pagemeta/dri:metadata[@element='theme'][@qualifier='path']"/>
            <xsl:text>scripts-dist.xml</xsl:text>
        </xsl:variable>
        <xsl:for-each select="document($scriptURL)/scripts/script">
            <script src="{$theme-path}{@src}">&#160;</script>
        </xsl:for-each>

        <!-- Add javascript specified in DRI -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script>
                <xsl:attribute name="src">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>

        <!-- add "shared" javascript from static, path is relative to webapp root-->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support
            out of our theme without modifying the administrative and submission sitemaps.
            This is obviously not ideal, but adding those scripts in those sitemaps is far
            from ideal as well-->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$theme-path"/>
                            <xsl:text>js/choice-support.js</xsl:text>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
            <xsl:call-template name="choiceLookupPopUpSetup"/>
        </xsl:if>

        <xsl:call-template name="addJavascript-google-analytics" />
        
        <script type="text/javascript">
            function scroll(){
                <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='jumpTo']">
                    <xsl:variable name="field_id" select="concat('aspect_submission_StepTransformer_field_',/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='jumpTo'])" />
                    $("body").animate({scrollTop: $("label[for='<xsl:value-of select="$field_id"/>']").parent().offset().top });
                    $(<xsl:value-of select="$field_id" />).focus();
                </xsl:if>
            }
            $(document).ready(function(){
                <xsl:if test="/dri:document/dri:body/dri:div[@id='aspect.submission.StepTransformer.div.submit-describe']/dri:list[@id='aspect.submission.StepTransformer.list.submit-describe']">
                    var path= "<xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>";
                    path=path.concat("/static/js/eqneditor/");
                    CKEDITOR.plugins.addExternal( 'eqneditor', path, 'plugin.js' );
                    CKEDITOR.config.extraPlugins = 'eqneditor';
                </xsl:if>
        <!-- Se realiza el scroll dependiendo de si existe un editor en pantalla. Si existe un editor, es necesario a que se instancie el mismo para luego hacer el scroll -->
                <xsl:choose>
                    <xsl:when test="/dri:document/dri:body/dri:div[@id='aspect.submission.StepTransformer.div.submit-describe']/dri:list[@id='aspect.submission.StepTransformer.list.submit-describe']/dri:item/dri:field/dri:params[@editorToolbar]">
                        CKEDITOR.on( 'instanceReady', function(evt) {
                            scroll();               
                        });
                    </xsl:when>
                    <xsl:otherwise>
                        scroll();
                    </xsl:otherwise>
                </xsl:choose>
            });
        </script>        
        
        <!-- El java script de abajo genera el grafico de barras para las estadisticas de los items -->
        <script type="text/javascript">
          $(document).ready(function(){ 
          if($( "#aspect_statistics_StatisticsTransformer_div_item-home" ).length )
          {
            var data = {
              labels: [<xsl:for-each select="/dri:document/dri:body/dri:div[@n='item-home']/dri:div[@n='stats']/dri:div[@id='aspect.statistics.StatisticsTransformer.div.tablewrapper']/dri:table/dri:row/dri:cell[text()!='' and @role='header']">'<xsl:value-of select="." />',</xsl:for-each>],
              series: [
                [<xsl:for-each select="/dri:document/dri:body/dri:div[@n='item-home']/dri:div[@n='stats']/dri:div[@id='aspect.statistics.StatisticsTransformer.div.tablewrapper']/dri:table/dri:row/dri:cell[text()!='' and @rend='datacell']"><xsl:value-of select="." />,</xsl:for-each>]
              ],
              colors:['#9ec4cd']
            };
            var options = {
              seriesBarDistance: 10
            };      
            new Chartist.Bar('.ct-chart', data, options);
          }      
            
            });
        </script>
        <!-- Este script genera el grafico de tortas para las estadisticas del item -->
        <script type="text/javascript">
         $(document).ready(function(){  
         if($( "#aspect_statistics_StatisticsTransformer_div_item-home" ).length )
         {
            // Configure data for "Pie" chart.
            var data = {
              labels: [<xsl:for-each select="/dri:document/dri:body/dri:div[@n='item-home']/dri:div[@n='stats']/dri:table[last()-1]/dri:row/dri:cell[text()!='' and @role='data' and @rend='labelcell']">'<xsl:value-of select="." />',</xsl:for-each>],
              series: [<xsl:for-each select="/dri:document/dri:body/dri:div[@n='item-home']/dri:div[@n='stats']/dri:table[last()-1]/dri:row/dri:cell[text()!='' and @role='data' and @rend='datacell']">'<xsl:value-of select="." />',</xsl:for-each>]
            };

            <xsl:text disable-output-escaping="yes">            
            if(data.labels.length > 0 &amp;&amp; data.series.length > 0){
            /*Calculate: what series are under the 'minimumUmbralProportion' of the statistics values? 
              Group them in a group 'others' to prevent a label overlay. */
            var minimumUmbralProportion = 0.04;
            var total = data.series.reduce(function sum(prev, curr) { return parseInt(prev) + parseInt(curr); });
            var totalAccessUnderUmbral = 0; 
            data.series = data.series.filter(function(element, index){
                if (parseInt(element) / total &lt; minimumUmbralProportion){
                    //If element is under the umbral, mark the corresponding label as to delete.
                    data.labels.splice(index,1,'-1');
                    totalAccessUnderUmbral += parseInt(element);
                    return false;
                }
                return true;
            });
            data.labels = data.labels.filter(function(element, index){
                if (element == '-1'){
                    return false;
                }
                return true;
            });
            
            if(totalAccessUnderUmbral &gt; 0){
            </xsl:text>
                data.labels.push('<i18n:text>xmlui.statistics.display.chartist.country.others</i18n:text>');
                data.series.push(totalAccessUnderUmbral.toString());
            }
            
            // Configure options for "Pie" chart.
            var options = {
              labelInterpolationFnc: function(value, index) {
                var pertentage = (parseInt(data.series[index]) / total * 100).toFixed(1);
                return value + ' (' + pertentage.toString() + '%)';
              },
              labelOffset: 100,
              labelDirection: 'explode',
              chartPadding: {top: 40, right: 5, bottom: 40, left: 5}
            };
            
            var responsiveOptions = [
              ['screen and (max-width: 767px)', {
                labelOffset: 5,
                labelPosition: 'outside',
              }],
              //Rule to disable the percentage when the device be in 'portrait' orientation. 
              //Otherwise, on this width (less than 768px), the text will be displayed 'out' of the screen. 
              ['screen and (max-width: 767px) and (orientation: portrait)', {
                labelInterpolationFnc: function(value) {
                    return value;
                },
              }],
              ['screen and (min-width: 768px)', {
                labelOffset: 80,
              }]
            ];
            
            // Create the "Pie" chart.
            new Chartist.Pie('#chart2', data, options, responsiveOptions);
            }
            }
        });
        </script>
                
        <xsl:if test="/dri:document/dri:body/dri:div[@id='aspect.administrative.item.EditItemMetadataForm.div.edit-item-status']">
	        <script type="text/javascript">
	        	updateMetadataForLookup();
	        </script>
        </xsl:if>
        
    </xsl:template>

    <xsl:template name="addJavascript-google-analytics">
        <!-- Add a google analytics script if the key is present -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script><xsl:text>
                (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

                ga('create', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/><xsl:text>');
                ga('send', 'pageview');
            </xsl:text></script>
        </xsl:if>
    </xsl:template>

    <!--The Language Selection-->
    <xsl:template name="languageSelection">
        <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
            <li id="ds-language-selection" class="dropdown">
                <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                <a id="language-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">
                    <span class="hidden-xs">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$active-locale]"/>
                        <xsl:text>&#160;</xsl:text>
                        <b class="caret"/>
                    </span>
                </a>
                <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle" data-no-collapse="true">
                    <xsl:for-each
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                        <xsl:variable name="locale" select="."/>
                        <li role="presentation">
                            <xsl:if test="$locale = $active-locale">
                                <xsl:attribute name="class">
                                    <xsl:text>disabled</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$current-uri"/>
                                    <xsl:text>?locale-attribute=</xsl:text>
                                    <xsl:value-of select="$locale"/>
                                </xsl:attribute>
                                <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>

    <xsl:template name="about">
    	<li class="dropdown">
    		<a id="language-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">
            	<span class="hidden-xs">
            		<i18n:text>xmlui.unerdigital.title.que-es-riuner</i18n:text>
            		<xsl:text>&#160;</xsl:text>
            		<b class="caret"/>
            	</span>
            </a>
            <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle" data-no-collapse="true">
            	<li>
	            	<!-- Qué es RIUNER -->
	            	<xsl:call-template name="add-static-page-anchor">
		            	<xsl:with-param name="static-page-i18n-key-uri">xmlui.unerdigital.staticPage.que-es-riuner.uri</xsl:with-param>
						<xsl:with-param name="static-page-i18n-key-title">xmlui.unerdigital.title.about</xsl:with-param>
		            </xsl:call-template>
				</li>
            	<li>
		            <!-- Políticas del repositorio -->
	            	<xsl:call-template name="add-static-page-anchor">
		            	<xsl:with-param name="static-page-i18n-key-uri">xmlui.unerdigital.staticPage.politicas-del-repositorio.uri</xsl:with-param>
						<xsl:with-param name="static-page-i18n-key-title">xmlui.unerdigital.title.politicas-del-repositorio</xsl:with-param>
		            </xsl:call-template>
				</li>
            </ul>
		</li>
    </xsl:template>
    
    <xsl:template name="howTo">
       <li>
    		<!-- Cómo subir material -->
    		<xsl:call-template name="add-static-page-anchor">
			    <xsl:with-param name="static-page-i18n-key-uri">xmlui.unerdigital.staticPage.como-subir-material.uri</xsl:with-param>
				<xsl:with-param name="static-page-i18n-key-title">xmlui.unerdigital.title.como-subir-material</xsl:with-param>
			</xsl:call-template>
    	</li>
    </xsl:template>


    <xsl:template name="topright-element">
        <xsl:param name="element"></xsl:param>
    	<xsl:param name="elementId" select="concat('aspect.viewArtifacts.Navigation.list.',$element)" />
    	
    	<li class="dropdown">
    		<a id="context-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">
    			<span class="hidden-xs">
    				<i18n:text><xsl:value-of select="dri:options/dri:list[@id=$elementId]/dri:head"></xsl:value-of></i18n:text>
    				<b class="caret"/>
				</span>
			</a>
			<ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle" data-no-collapse="true">
				<xsl:for-each select="dri:options/dri:list[@id=$elementId]/dri:item">
					<li>
						<a>
							<xsl:attribute name="href">
			                    <xsl:value-of select="./dri:xref/@target"/>
			                </xsl:attribute>

							<i18n:text><xsl:value-of select="./dri:xref//i18n:text"></xsl:value-of></i18n:text>
						</a>
					</li>
				</xsl:for-each>
				<xsl:for-each select="dri:options/dri:list[@id=$elementId]/dri:list">
						<xsl:for-each select="./*">
							<li>
								<xsl:choose>
									<xsl:when test="name(.)='head'">
										<div>
							                <xsl:attribute name="class">
							                	<xsl:value-of select="'submenu-header'"></xsl:value-of>
							                </xsl:attribute>
				
											<i18n:text><xsl:value-of select="."></xsl:value-of></i18n:text>
										</div>
									</xsl:when>
									<xsl:otherwise>
										<a>
											<xsl:attribute name="href">
							                    <xsl:value-of select="./dri:xref/@target"/>
							                </xsl:attribute>
				
											<i18n:text><xsl:value-of select="./dri:xref//i18n:text"></xsl:value-of></i18n:text>
										</a>
									</xsl:otherwise>
								</xsl:choose>
							</li>
						</xsl:for-each>
				</xsl:for-each>
				
			</ul>
	    </li>        
	</xsl:template>

    <xsl:template name="addPageTitle">
        <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
            <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/')">
                        <i18n:text>
                            <xsl:value-of select="concat('xmlui.unerdigital.title.', xmlui:replaceAll(substring-after($request-uri,'/'), '(_en|_es)', ''))"/>
                        </i18n:text>
                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>  </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>
    </xsl:template>

</xsl:stylesheet>
