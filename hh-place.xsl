<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xi="http://www.w3.org/2001/XInclude">
	<!-- Your first job, for this test, is to transform all the HH stuff into paragraphs, and add info from the hh-place-names.xml to it. -->
	<xsl:output method="html"/>
	
	<!-- This is where params will go, if they work-->
	<xsl:param name="url" select="0"/>
	
	<!-- 
	TO-DO:
	-Update the $swap-lang template to find the language automatically, not just assuming Greek and English as the only options.
	
	-->
	
	
	<!-- Keep the path to Hermes here-->
	<xsl:variable name="hh4a" select="'./Perseus-DL/tlg0013/tlg004/tlg0013.tlg004.perseus-grc2.xml'"/>
	<xsl:variable name="placeography" select="'hh-place-names.xml'"/>
	
	
	<xsl:template match="/">
		
		<xsl:call-template name="main">
			<!-- This retrieves the source text from the file. I used to think the original needed single quotes around it, but that was unnecessary.-->
			<xsl:with-param name="hh4" select="string(.//@href)"/>
			
			<!-- This is the number of different tei:place elements associated with a given text -->
			
			<!--<xsl:with-param name="par-swap" select=""/>-->
		</xsl:call-template>
		
	</xsl:template>
	
	<xsl:template name="swap-lang">
		<xsl:param name="lang"/>
		<xsl:param name="swapdoc"/>
		<xsl:element name="a">
		<xsl:attribute name="href"><xsl:value-of select="$swapdoc"/></xsl:attribute>
		<xsl:choose>
			<xsl:when test="$lang = 'eng'">
				Greek
			</xsl:when>
			<xsl:when test="$lang = 'grc'">English
			</xsl:when>
			<xsl:otherwise>
				Error! Could not retrieve aligned language.
			</xsl:otherwise>
		</xsl:choose>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="doc-title">
		<xsl:param name="hh4"/>
		<xsl:value-of select="document($hh4)/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()"/>
	</xsl:template>
		
	
	<xsl:variable name="place" select="string(document($placeography)//tei:place[2]/tei:ptr[@type='start-before']/@target)"/>
	<xsl:template name="main">
	<xsl:param name="hh4"/>
	<html>
		<head>
			
			<title><xsl:value-of select="document($hh4)//tei:title"/></title>
			<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
			<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>
			<style>
				
				
				<!--div[type="map-container"]:hover + div[type="passage"]{
					background-color: red;
				} Left over from when I wanted it clear the map went with the whole passage-->
				
				<!--div[type="map-container"]{
					background-color: yellow;
				}-->
				
				.reveal {
					background-color: yellow;
					text-align: center;
				}
				
				.column:hover>div>div[type="map"]{
					visibility: visible;
					z-index: 2;
				}
				
				.column:nth-child(3):hover{
					background-color: red;
				}
				
				.column:nth-child(3):hover>.reveal{
					background-color: red;
				}
				
				div[type="map"] {
					visibility: hidden;
				}
				
				div[type="map"]:hover {
					visibility: visible;
				}
				
				.leaflet-container {
					height: 400px;
					width: 600px;
					max-width: 100%;
					max-height: 100%;
				}
				
				
				.column {
					float: left;
					width: 50%;
				}
				
				.row {
					display: block;
				}
				
				.filler {
					height: 20px;
					width: 50px;
					color: black;
				}			
				
				.row:after {
				  content: "";
				  display: table;
				  clear: both;
				}
			</style>
				
		</head>
		<header>
			<!-- Retrieve the Greek title and make it the header-->
			
			<h1><xsl:call-template name="doc-title"><xsl:with-param name="hh4" select="$hh4"/></xsl:call-template></h1><br/>
		</header>
		
		<a href="index.html">Home</a><br/>
		
		<!-- Add the link to the translation-->
		<xsl:call-template name="swap-lang">
			<xsl:with-param name='lang' select="document($hh4)//tei:div[1]/@xml:lang"/>
			<xsl:with-param name="swapdoc" select=".//@swap"/>
		</xsl:call-template>
		<br/>
		<p>
		Welcome to the map of <xsl:call-template name="doc-title"><xsl:with-param name="hh4" select="$hh4"/></xsl:call-template>!
		
		This text is divided into <b>passages</b>. Each passage is accompanied by a map in the right column with each of the points (for which there is data) mapped out. Scroll all the way to the bottom for a comprehensive map of the hymn.
		</p>
		
		<div>
			
			<!-- The reason why this loop skips ones with a '.' in them is because only on the second or above location in a single passage do we add a .2, .3 etc.; the first of each has no '.' so we can do this loop successfully, although there are probably better ways to do this-->
			<xsl:for-each select="document($placeography)//tei:place/tei:linkGrp[substring(string(@corresp), 1, 42)=substring($hh4, 1, 42) and contains(string(./@n), '.') = false()]"> <!-- We check for the substring because the file types obviously will not be equivalent between the two, but the part of the path which includes the URN will be-->
			<xsl:sort select="./@n" data-type="number"/> <!--DUDE, YOU CAN CHANGE THE DATA-TYPE? This makes sure the parts of the story come in the right order, no matter how they are in the placeography -->
			<div class="row">
			<h2>
			<xsl:choose>
				<xsl:when test="./../tei:placeName='empty'">
					No map data for this section
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="./../tei:placeName[@type='primary']"/><!-- The substring goes until the end of the tlg value, that is it cuts of .perseus-grc2.xml-->
						
				</xsl:otherwise>
			</xsl:choose>
			
			</h2>
			<!-- Get the URL for the map-->
				
				<div class="column" type="passage" style="z-index:1">
				<!-- Figure out what range of text to retrieve. Keep in mind that we need to check the language for proper alignment.-->
				<xsl:variable name="end" select="./tei:ptr[@type='end-after' and @xml:lang=document($hh4)//tei:text/@xml:lang]/@target"/>
				<xsl:variable name="start" select="./tei:ptr[@type='start-before' and @xml:lang=document($hh4)//tei:text/@xml:lang]/@target"/>
				<xsl:for-each select=
				"document($hh4)//tei:l[@n &lt; $end and @n &gt; $start or @n=$start or @n=$end]">
					<xsl:value-of select="./@n"/>: <xsl:copy><xsl:apply-templates select="./node()[boolean(@anchored) = false()]"/><p style="display: none;"><xsl:copy><xsl:apply-templates select="./node()"/></xsl:copy></p></xsl:copy><br/> <!-- I still have a lot to learn; node() seems to get text data? Either way, this preserves the notes without displaying them, I think-->
				</xsl:for-each>
				</div>
				
				<div class="column">
				<div class="reveal">
					<b>-&gt;Hover over me&lt;- </b>
				</div>
				<xsl:call-template name="passage-builder">
					<xsl:with-param name="passage-n" select="./@n"/>
					<xsl:with-param name="linkgrp" select="."/>
					<xsl:with-param name="hh">
						<xsl:value-of select="$hh4"/>
					</xsl:with-param>
					
				</xsl:call-template>
				
				</div>
			</div>
			<div class="filler">
			
			</div>
			
		</xsl:for-each>
		
			<p>
				<xsl:value-of select="document($hh4)//tei:l[$place]"/>
			</p>
			<!-- THIS IS VERY IMPORTANT: when you start pulling map data, make sure to have data for both English and Greek-->
			
			<!-- Now, go through each <div/> in the hh edition-->
			<!-- This was just a test
			<xsl:for-each select="document($hh4)//tei:body//tei:div">
				<p>
					
					<xsl:for-each select="./tei:l">
						<xsl:value-of select="."/><br/>
					</xsl:for-each>
				</p>
			</xsl:for-each>
			 -->
			 <br/>
			 <br/>
			 
			 <xsl:call-template name="full-map">
				<xsl:with-param name="length"> 
					<xsl:value-of select="count((document($placeography)//tei:place/tei:linkGrp[substring(string(./@corresp), 1, 42) = substring($hh4, 1, 42)]))"/> <!-- YOU WERE FIXING THE LENGTH IDENTIFYING ALGORITHM-->
				</xsl:with-param>
				<xsl:with-param name="placeography" select="$placeography"/>
				<xsl:with-param name="hh4" select="$hh4"/>
			 </xsl:call-template>
			 
			 
			<footer>
				Edition: <xsl:value-of select="document($hh4)//tei:sourceDesc/tei:bibl/tei:title"/><br/>
				<xsl:value-of select="document($hh4)//tei:sourceDesc/tei:bibl/tei:publisher"/>, <xsl:value-of select="document($hh4)//tei:sourceDesc/tei:bibl/tei:date"/>
			</footer>
		</div>
	</html>
	</xsl:template>
	
	<!-- Moved the map-generating code here to compartmentalize a little better-->
	
	<xsl:template name="passage-builder">
		<xsl:param name="passage-n"/> <!-- Get the passage number of the current map-->
		<xsl:param name="linkgrp"/>
		<xsl:param name="hh"/>
		
		<!-- Get the header info, which should be the location but leaves a message if it is empty-->
		
		<!-- The map container is one div, below, separate from the passage div with the text-->
		<div type="map-container">
			
			<div type="map">
				<p>
				See all the mapped locations in the passage below. Click on a location for information about the source or a description of why I chose to put the location in its spot. This is a work in progress: not all my notes are included and some data is missing. <b>If the coordinate data is supposed to exist but cannot be located, the location defaults to Delos.</b>
				</p>
				<p>
				Another feature in progress is polygons/highlighted regions. Pleiades, the source for the positional data, also stores locations as series of points for highlighting features like rivers and islands. As my implemenetation of this is in progress, I use single points to reference complex locations: often these points are representative of a larger region or features. Pleiades calls the points I use in these cases the <b>representative point</b>. For a description of some of these different types of region, and how the representative point works, see <a href="https://pleiades.stoa.org/help/get-coordinates/?searchterm=%22representative%20point%22#:~:text=For%20each%20Pleiades%20place%20resource,with%20a%20distinctive%20orange%20circle." target="_blank">this page</a>.
				</p>
				<xsl:choose>
					<xsl:when test="boolean($linkgrp/../tei:location)">
						<xsl:call-template name="goog-url">
							
							<xsl:with-param name="placename">
								<xsl:value-of select="$linkgrp/..//tei:placeName[@type='short']/text()"/>
							</xsl:with-param>
							<xsl:with-param name="passage">
								<xsl:value-of select="$linkgrp/@n"/>
							</xsl:with-param>
							<xsl:with-param name="coord">
								<xsl:value-of select="string($linkgrp/../tei:location/tei:geo/@source)"/>
							</xsl:with-param>
							<xsl:with-param name="total-linkgrps">
								<xsl:value-of select="count(document('hh-place-names.xml')//tei:linkGrp[string(@corresp) = $hh and substring-before(string(@n), '.') = string($passage-n)]) + 1"/> <!-- Gets the total number of linkgrps associated with this one passage; adds one because this will never identify the first, which has no period, but we nonetheless know exists because we have entered the loop wrapping this template in the first place-->
							</xsl:with-param>
							<xsl:with-param name="linkgrp" select="$linkgrp"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<p>No map data available.</p>
					</xsl:otherwise>
				</xsl:choose>
					<br/><br/>
			</div>
		</div><br/><!--Added a break in here because the new absolute position was putting the map in the text-->
	</xsl:template>
	
	<!-- This covers creating the map and, if there are multiple entries in a single one, -->
	<xsl:template name="goog-url">
		<xsl:param name="placename"/> <!-- the #short placename from the xml file-->
		<xsl:param name="passage"/> <!-- The number of the passage in the work, given from @n in the linkGrp-->
		<xsl:param name="coord"/>
		<xsl:param name="total-linkgrps"/>
		<xsl:param name="linkgrp"/>
		<xsl:param name="map-name"/>
		
		
		<xsl:element name="div">
		 <!--<xsl:value-of select="concat(string($placename), string($passage)"/>-->
		
			<xsl:attribute name="id"><xsl:value-of select="concat(string($placename), string($passage))"/></xsl:attribute>
			<xsl:attribute name="style">width: 600px; height: 400px;</xsl:attribute>
			<!--SEE COMMENT AT START OF <script> JUST BELOW </script><xsl:attribute name="onmouseover"><xsl:value-of select="concat(string($placename), string($passage))"/>_onMouseover()</xsl:attribute>-->
		<script>
			<!--function <xsl:value-of select="concat(string($placename), string($passage))"/>_onMouseover() {
				<xsl:value-of select="concat(string($placename), string($passage))"/>.panTo(L.latLng(<xsl:value-of select="string($coord)"/>))
			}I WANTED TO USE THIS TO FORCE THE MAP TO UPDATE, but it didn't work; additionally, using the onmouseover event makes the map hard to use. I may return to
			this, which is why I'm saving it.-->
			<![CDATA[
			const ]]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[ = L.map(']]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[').setView([]]>
			<xsl:choose>
				<xsl:when test="count(document('hh-pleiades-data.xml')//item[@type='object' and boolean(./pair[text() = $coord])]/pair[@name='features']/*) &gt; 0">
					<xsl:call-template name="bare-point">
						<xsl:with-param name="array" select="document('hh-pleiades-data.xml')/json/*[boolean(./pair[text() = string($coord)])]/pair[@name='reprPoint']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					37.3920222,25.2702389
				</xsl:otherwise>
			</xsl:choose>
			<![CDATA[], 6);

			const ]]><xsl:value-of select="concat('tiles', string($passage))"/><![CDATA[ = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
				maxZoom: 19,
				trackResize: true,
				attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
			}).addTo(]]><xsl:value-of select="concat(string($placename), string($passage))"/>);
			<!--Now add the markers-->
			<xsl:call-template name="retrieve-pleiades">
					<xsl:with-param name="id" select="$coord"/>
					<xsl:with-param name="linkgrp" select="$linkgrp"/>
					<xsl:with-param name="pleiades" select="document('hh-pleiades-data.xml')//item[@type='object']"/>
					<xsl:with-param name="passage" select="$passage"/>
					<xsl:with-param name="placename" select="$placename"/>
					<xsl:with-param name="map-name" select="concat(string($placename), string($passage))"/>
			</xsl:call-template>
			<xsl:for-each select="$linkgrp/../../tei:place/tei:linkGrp[@corresp=$linkgrp/@corresp and contains(string(@n), '.') and string($linkgrp/@n) = substring-before(string(@n), '.')]">
				<xsl:call-template name="retrieve-pleiades">
					<xsl:with-param name="id" select="./../tei:location/tei:geo/@source"/>
					<xsl:with-param name="linkgrp" select="."/>
					<xsl:with-param name="pleiades" select="document('hh-pleiades-data.xml')//item[@type='object']"/>
					<xsl:with-param name="passage" select="substring-after(string(@n), '.')"/>
					<xsl:with-param name="placename" select="./../tei:placeName[@type='short']/text()"/>
					<xsl:with-param name="map-name" select="concat(string($placename), string($passage))"/>
				</xsl:call-template>
			</xsl:for-each>
		</script>
		
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="full-map">
		<xsl:param name="length"/>
		<xsl:param name="placeography"/>
		<xsl:param name="hh4"/>
		
		<p>
		Full map of locations in <xsl:call-template name="doc-title"><xsl:with-param name="hh4" select="$hh4"/></xsl:call-template>:
		
		This map has all the locations in the hymn. The line should follow the path of the action, but some missing data means that this is still a work in progress. If you click on each popup, it will tell you the name of the location and where it appears in the hymn.
		</p>
		<xsl:element name="div">
				<xsl:attribute name="id">map</xsl:attribute>
				<xsl:attribute name="style">width: 800px; height: 600px;</xsl:attribute>
				<xsl:attribute name="test"><xsl:value-of select="$length"/></xsl:attribute>
				<script>
					<![CDATA[
						const map = L.map('map').setView([51.505, -0.09], 13);
						
						const tiles = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
							maxZoom: 19,
							attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
						}).addTo(map);
						// create a red polyline from an array of LatLng points
						const latlngs = [
							]]><xsl:for-each select="document($placeography)//tei:place[substring(string(./tei:linkGrp/@corresp), 1, 42)=substring($hh4, 1, 42) and boolean(./tei:location/tei:geo/@source)]">
								
									
									[<xsl:call-template name="full-map-point">
										<xsl:with-param name="geo" select="string(./tei:location/tei:geo/@source)"/>
									</xsl:call-template>]<xsl:if test="position() &lt; count(document($placeography)//tei:place[substring(string(./tei:linkGrp/@corresp), 1, 42)=substring($hh4, 1, 42) and boolean(./tei:location/tei:geo/@source)])">,</xsl:if><!-- YOU CHEATED HERE! FIX THIS LATER, OR ADD A # OF LOCATIONS FIELD-->
								
							</xsl:for-each> <![CDATA[
						];

						const polyline = L.polyline(latlngs, {color: 'red'}).addTo(map);

						// zoom the map to the polyline
						map.fitBounds(polyline.getBounds());
						
						]]><xsl:for-each select="document($placeography)//tei:place[count(./tei:linkGrp[substring(string(@corresp), 1, 42)=substring($hh4, 1, 42)]) &gt; 0 and boolean(./tei:location/tei:geo/@source)]">
								<!--NO longer necessary, I don't sort the big map <xsl:sort select="./@n" data-type="number"/>-->
								const marker_<xsl:value-of select="./tei:placeName[@type='short']/text()"/> = L.marker([<xsl:call-template name="full-map-point"><xsl:with-param name="geo" select="string(./tei:location/tei:geo/@source)"/></xsl:call-template>]).addTo(map);
								
								marker_<xsl:value-of select="./tei:placeName[@type='short']/text()"/>.bindPopup(&quot;<xsl:value-of select="./tei:placeName[@type='primary']"/>&#58;<br/>
								<xsl:for-each select="./tei:linkGrp[substring(string(@corresp), 1, 42)=substring($hh4, 1, 42)]">
									<xsl:sort select="@n" data-type="number"/>
									<xsl:text>Lines: </xsl:text>									
									<xsl:value-of select="string(./tei:ptr[@xml:lang=document($hh4)//tei:div[1]/@xml:lang and @type='start-before']/@target)"/>
									
									<!--It is awkward to have something like 'Lines 101-101', so this checks to avoid that-->
									<xsl:if test="(number(./tei:ptr[@xml:lang=document($hh4)//tei:div[1]/@xml:lang and @type='end-after']/@target) - number(./tei:ptr[@xml:lang=document($hh4)//tei:div[1]/@xml:lang and @type='start-before']/@target)) &gt; 1">
										<xsl:text>-</xsl:text>	
										<xsl:value-of select="number(string(./tei:ptr[@xml:lang=document($hh4)//tei:div[1]/@xml:lang and @type='end-after']/@target)) - 1"/>
									</xsl:if>
									<!--@xml:lang=document($hh4)//tei:div[1]/@xml:lang--><br/>
								</xsl:for-each>&quot;).openPopup();
								</xsl:for-each><![CDATA[
					]]>
				</script>
			 </xsl:element>
	</xsl:template>
	
	<xsl:template name="retrieve-pleiades">
		<xsl:param name="id"/> <!-- id from @source of the geo element of the chosen place-->
		<xsl:param name="pleiades"/>
		<xsl:param name="passage"/>
		<xsl:param name="placename"/>
		<xsl:param name="map-name"/>
		<xsl:param name="linkgrp"/>
		
		<!-- Get both files, since they were split into two for conversion to xml-->
		<!--These will have to be provided with the params
		<xsl:variable name="pleiades1" select="document('pleiades-xml1.xml')//item[@type='object']"/>
		<xsl:variable name="pleiades2" select="document('pleiades-xml2.xml')//item[@type='object']"/>-->
		const marker_<xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[ = ]]>
		<xsl:call-template name="choose-points">
			<xsl:with-param name="linkgrp" select="$linkgrp"/>
			<xsl:with-param name="geometry" select="$pleiades[boolean(./pair[text() = string($id)])]"/> <!-- Cheated a little here: this is where we pull the geographic data, but if it is attested in multiple sources, the map breaks. Currently, this picks the first set of coordinate data in "features" and sticks with that.-->
		</xsl:call-template><![CDATA[).addTo(]]><xsl:value-of select="$map-name"/><![CDATA[)]]>
		
		<!--The following binds a popup to the marker which has the Pleiades URL (the one ending in pair[@name='link']/text()) and the other the description of the source (the one ending in pair[@name='description']/text()). It also adds a description from the hh-place-names.xml document, if one is available-->
		marker_<xsl:value-of select="concat(string($placename), string($passage))"/>.bindPopup(&quot;<xsl:value-of select="./../tei:placeName[@type='primary']/text()"/>:<br/><![CDATA[<a href=\"]]><xsl:value-of select="$pleiades[boolean(./pair[text() = string($id)])]/pair[@name='features']/item/pair[@name='properties']/pair[@name='link']/text()"/><![CDATA[\" target=\"_blank\">]]><xsl:value-of select="$pleiades[boolean(./pair[text() = string($id)])]/pair[@name='features']/item/pair[@name='properties']/pair[@name='description']/text()"/><![CDATA[</a>]]><br/><xsl:value-of select="$linkgrp/../tei:desc/text()"/><br/>&quot;)
	</xsl:template>		
	
	<xsl:template name="choose-points">
		<!--This selects which template to use depending on whether the geometry is a Point, LineString, MultiLineString, Polygon or MultiPolygon (I checked the data to make sure this is it)-->
		<xsl:param name="geometry"/>
		<xsl:param name="linkgrp"/> <!--Added so we can have backup points in the case there is no Pleiades data-->
		
		<xsl:choose>
			<xsl:when test="count(($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]//pair[@name='coordinates']/*) &gt; 0">
				<xsl:choose>
				<!--If it is a Point...-->
				<xsl:when test="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='type']/text() = 'Point'">
					<xsl:call-template name="point-template">
						<xsl:with-param name="array" select="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='coordinates']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='type']/text() = 'MultiLineString'">
					<xsl:call-template name="multilinestr-template">
						<xsl:with-param name="array" select="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='coordinates']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='type']/text() = 'LineString'">
					<xsl:call-template name="linestr-template">
						<xsl:with-param name="array" select="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='coordinates']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='type']/text() = 'Polygon'">
					<xsl:call-template name="polygon-template">
						<xsl:with-param name="array" select="($geometry/pair[@name='features']/item/pair[@name='geometry'])[1]/pair[@name='coordinates']"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="placeholder-coord">
						<xsl:with-param name="array" select="$geometry/pair[@name='reprPoint']"/>
					</xsl:call-template>
						
				</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="boolean($geometry) = false()">
				L.marker([<xsl:value-of select="$linkgrp/../tei:location/tei:geo/text()"/>]
			</xsl:when>
			<xsl:when test="boolean($geometry/pair[@name='reprPoint']/*)">
				<xsl:call-template name="placeholder-coord">
						<xsl:with-param name="array" select="$geometry/pair[@name='reprPoint']"/>
					</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>L.marker([37.3920222,25.2702389]</xsl:text> <!--Updated 12/8/23 because we no longer add the marker in higher templates, now that the switching between polygons/lines feature is implemented-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="point-template">
		<!--Used if the given coordinates are a single point-->
    <xsl:param name="array"/><!-- The array containing the coordinates-->
		L.marker([
		<xsl:value-of select="concat($array/*[2]/text(), ', ',$array/*[1]/text())"/>]
			
	</xsl:template>
	
	<xsl:template name="polygon-template">
		<xsl:param name="array"/>
		
		L.polygon([<xsl:call-template name="multipoint-template">
				<xsl:with-param name="array" select="$array/item"/>
			</xsl:call-template>]
	</xsl:template>
	
	
	
	<xsl:template name="linestr-template">
		<xsl:param name="array"/>
		L.polyline([
			<xsl:call-template name="multipoint-template">
				<xsl:with-param name="array" select="$array"/>
			</xsl:call-template>]
	</xsl:template>
	
	<xsl:template name="multipoint-template">
		<xsl:param name="array"/>
		<xsl:for-each select="$array/item">
			[<xsl:value-of select="./item[2]/text()"/>,<xsl:value-of select="./item[1]/text()"/>]
			<xsl:choose>
				<xsl:when test="position() &lt; count($array/item)">,</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
			</xsl:for-each>
	</xsl:template>
	
	
	
	<xsl:template name="placeholder-coord">
		<xsl:param name="array"/>
		<!--Since I have not figured out every shape yet, we can get the representative point if we need to-->
		L.marker([<xsl:value-of select="concat($array/item[2]/text(), ',', $array/item[1]/text())"/>]
	</xsl:template>
	
	<xsl:template name="bare-point">
		<!-- Accepts the reprPoint pair (or another parent of coordinate data), and returns only the point-->
		<xsl:param name="array"/>
		
		<xsl:value-of select="concat($array/item[2]/text(), ',', $array/item[1]/text())"/>
	</xsl:template>
	
	<xsl:template name="multilinestr-template">
		<!--As a multiline, this has a series of item elements whose @type is 'array and each of those has two items whose @type is 'number'-->
		<xsl:param name="array"/>
		L.polyline([
		<xsl:for-each select="$array/item">
			[<xsl:call-template name="multipoint-template">
				<xsl:with-param name="array" select="."/>
			</xsl:call-template>]
			<xsl:choose>
				<xsl:when test="position() &lt; count($array/item)">,</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>]
	</xsl:template>
	
	
	
	<xsl:template name="full-map-point">
		<xsl:param name="geo"/>
		
				<xsl:value-of select="document('hh-pleiades-data.xml')//item[@type='object' and ./pair[@name='id']/text() = $geo]/pair[@name='reprPoint']/item[2]/text()"/>,<xsl:value-of select="document('hh-pleiades-data.xml')/json/item[@type='object' and ./pair[@name='id']/text() = $geo]/pair[@name='reprPoint']/item[1]/text()"/>
			
	</xsl:template>
	
	
	
	<!--
	<xsl:template name="MultiLineString-template">
	
	</xsl:template>-->
	
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="hh4-map-edition.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml=""
		          commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator="">
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="xsltVersion" value="2.0"/>
			<advancedProp name="schemaCache" value="||"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bGenerateByteCode" value="true"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="sInitialMode" value=""/>
		</scenario>
		<scenario default="no" name="Scenario2" userelativepaths="yes" externalpreview="no" url="hh3-map-edition.xml" htmlbaseurl="" outputurl="" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml=""
		          commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator="">
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="xsltVersion" value="2.0"/>
			<advancedProp name="schemaCache" value="||"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bGenerateByteCode" value="true"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="sInitialMode" value=""/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="hh3-map-edition.xml" srcSchemaRoot="html" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
			<SourceSchema srcSchemaPath="hh-place-names.xml" srcSchemaRoot="TEI" AssociatedInstance="file:///c:/Users/matth/Documents/GitHub/AMS-9187/hh-place-names.xml" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="xsl:call-template" x="384" y="0"/>
				<block path="xsl:call-template/string[0]" x="338" y="0"/>
			</template>
			<template name="retrieve-pleiades"></template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->