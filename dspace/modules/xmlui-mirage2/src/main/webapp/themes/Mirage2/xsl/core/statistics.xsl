<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc ">

	<!-- Ocultamos estadisticas de pais y ciudad para comunidades y colecciones debido a la falta de confianza en éstas -->
	<xsl:template match="/dri:document/dri:body/dri:div[@n='community-home' and @id='aspect.statistics.StatisticsTransformer.div.community-home']/dri:div[@n='stats' and @id='aspect.statistics.StatisticsTransformer.div.stats']/dri:table[dri:head/i18n:text/text()='xmlui.statistics.visits.countries' or dri:head/i18n:text/text()='xmlui.statistics.visits.cities']"/>
	
	<xsl:template match="/dri:document/dri:body/dri:div[@n='collection-home' and @id='aspect.statistics.StatisticsTransformer.div.collection-home']/dri:div[@n='stats' and @id='aspect.statistics.StatisticsTransformer.div.stats']/dri:table[dri:head/i18n:text/text()='xmlui.statistics.visits.countries' or dri:head/i18n:text/text()='xmlui.statistics.visits.cities']"/>
	
	<!-- Este template es como el "principal" llama a los otros templates y 
		organiza la pagina -->

	<xsl:template match="/dri:document/dri:body/dri:div[@n='item-home' and @id='aspect.statistics.StatisticsTransformer.div.item-home']/dri:div[@n='stats' and @id='aspect.statistics.StatisticsTransformer.div.stats']">
		<xsl:variable name="path">
			<xsl:call-template name="print-path">
				<xsl:with-param name="path"
					select="substring-before( /dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='URI'] , '/statistics')" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="dri:table[@id='aspect.statistics.StatisticsTransformer.table.list-table']/dri:row/dri:cell[@n='01']">
				<div class="row item-head">
					<div class="col-xs-8 curso">
						<p></p>
						<div>
							<xsl:if test="dri:table[@id='aspect.statistics.StatisticsTransformer.table.list-table']/dri:row/dri:cell[@n='01']">
								<xsl:value-of select="dri:table[@id='aspect.statistics.StatisticsTransformer.table.list-table']/dri:row/dri:cell[@n='01']"></xsl:value-of>
							</xsl:if>
						</div>
					</div>
					<div class="col-xs-4 col-xs-push-1 contenedor-cuadrado">
							<div class="cuadrado">
								<div class="encuadrado">
									<xsl:choose>
										<xsl:when test="dri:table[@id='aspect.statistics.StatisticsTransformer.table.list-table']/dri:row/dri:cell[@n='02']">
											<xsl:value-of select="dri:table[@id='aspect.statistics.StatisticsTransformer.table.list-table']/dri:row/dri:cell[@n='02']"></xsl:value-of>
										</xsl:when>
									</xsl:choose>
								</div>
							</div>
							<h4>
								<i18n:text select="dri:table/dri:row/dri:cell/i18n:text[text()='xmlui.statistics.visits.views']">
									<xsl:value-of select="dri:table/dri:row/dri:cell/i18n:text[text()='xmlui.statistics.visits.views']"></xsl:value-of>
								</i18n:text>
							</h4>
						</div>
				</div>
				<br/>
				<div id="charts-section">
					<xsl:apply-templates select="dri:div[@id='aspect.statistics.StatisticsTransformer.div.tablewrapper']" />
					<!-- Sacamos estadísticas de país por no ser confiables... -->
					<!-- 
					<xsl:apply-templates select="dri:table/dri:head/i18n:text[text()='xmlui.statistics.visits.countries']" />
					-->
				</div>
				<br/>
				<br/>
				<br/>
				<div id="bitstreams-views">
					<xsl:apply-templates select="dri:table/dri:head/i18n:text[text()='xmlui.statistics.visits.bitstreams']" />
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div>
					<div>
						<div class="tittle-statistics">
							<p><i18n:text>xmlui.statistics.no-stats</i18n:text></p>
						</div>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		<a class="btn btn-default" id="stats-go-back-item-view">
			<xsl:attribute name="href">
				<xsl:value-of select="$path"></xsl:value-of>
			</xsl:attribute>
			<i18n:text>xmlui.statistics.stats-go-back</i18n:text>
		</a>
	</xsl:template>


	<!-- Este template carga las visitas al fichero -->

	<xsl:template match="dri:table/dri:head/i18n:text[text()='xmlui.statistics.visits.bitstreams']">
		<xsl:if test="../../dri:row/dri:cell[@role='data']">
			<div class="tittle-statistics">
				<i18n:text>
					<xsl:value-of select="."></xsl:value-of>
				</i18n:text>
				<div class="linea-statistics">
					<xsl:comment></xsl:comment>
				</div>
			</div>
			<ul class="lista_statistics">
				<xsl:for-each select="../../dri:row">
					<xsl:if test="dri:cell[@rend='datacell']">
							<li>	
								<span id="bitstream-name">
									<xsl:value-of select="dri:cell[@rend='labelcell']"></xsl:value-of>
								</span>
								<span id="bitstream-views-number">
									<xsl:value-of select="dri:cell[@rend='datacell']"></xsl:value-of>
								</span>
							</li>
					</xsl:if>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<!-- Este template carga las visitas al item por mes -->

	<xsl:template match="dri:div[@id='aspect.statistics.StatisticsTransformer.div.tablewrapper']">
		<xsl:if test="/dri:document/dri:body/dri:div[@n='item-home']/dri:div[@n='stats']/dri:div[@id='aspect.statistics.StatisticsTransformer.div.tablewrapper']/dri:table/dri:row/dri:cell[text()!='' and @rend='datacell']">
			<div>
				<xsl:comment></xsl:comment>
				<div class="tittle-statistics">
					<i18n:text>
						<xsl:value-of select="dri:table/dri:head/i18n:text[text()='xmlui.statistics.visits.month']/."></xsl:value-of>
					</i18n:text>
					<div class="linea-statistics"><xsl:comment> &#32;</xsl:comment></div>
			</div> 	
		    	<div class="tamanio ct-chart ct-perfect-fourth"><xsl:comment> &#32;</xsl:comment></div>
	    	</div>
		</xsl:if>


	</xsl:template>
	
	<!--  Este template carga las visitas al item por pais-->
		<xsl:template match="dri:table/dri:head/i18n:text[text()='xmlui.statistics.visits.countries']">		   
			<xsl:if test="/dri:document/dri:body/dri:div[@n='item-home']/dri:div[@n='stats']/dri:table[last()-1]/dri:row/dri:cell[text()!='' and @role='data' and @rend='datacell']">
				<div>
					<xsl:comment></xsl:comment>
					<div class="tittle-statistics">
			    		 <i18n:text><xsl:value-of select="."></xsl:value-of></i18n:text>	
			    		 <div class="linea-statistics"><xsl:comment> &#32;</xsl:comment></div>
			    	</div> 
			    	<div class=" tamanio ct-chart" id="chart2"><xsl:comment> &#32;</xsl:comment></div>
		    	</div>
		   	</xsl:if>
		</xsl:template>
</xsl:stylesheet>