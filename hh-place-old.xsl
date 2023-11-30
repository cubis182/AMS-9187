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
				
				div[type="map-container"]>b {
					background-color: yellow;
				}
				
				div[type="map-container"]>b:hover {
					background-color: red;
				}
				
				div[type="map-container"]>b:hover+div[type="map"] {
					visibility: visible;
					z-index: 2;
				}
				
				div[type="map"] {
					visibility: hidden;
					background-color: red;
				}
				div[type="map"]:hover {
					visibility: visible;
				}
				div[type="map"]:hover]
				.leaflet-container {
					height: 400px;
					width: 600px;
					max-width: 100%;
					max-height: 100%;
				}
			</style>
				
		</head>
		<header>
			<!-- Retrieve the Greek title and make it the header-->
			
			<h1><xsl:value-of select="document($hh4)//tei:div[1]/tei:head"/></h1><br/>
		</header>
		
		<!-- Add the link to the translation-->
		<xsl:call-template name="swap-lang">
			<xsl:with-param name='lang' select="document($hh4)//tei:div[1]/@xml:lang"/>
			<xsl:with-param name="swapdoc" select=".//@swap"/>
		</xsl:call-template>
		
		<div>
			<!-- The reason why this loop skips ones with a '.' in them is because only on the second or above location in a single passage do we add a .2, .3 etc.; the first of each has no '.' so we can do this loop successfully, although there are probably better ways to do this-->
			<xsl:for-each select="document($placeography)//tei:place/tei:linkGrp[substring(string(@corresp), 1, 42)=substring($hh4, 1, 42) and contains(string(./@n), '.') = false()]"> <!-- We check for the substring because the file types obviously will not be equivalent between the two, but the part of the path which includes the URN will be-->
			<xsl:sort select="./@n" data-type="number"/> <!--DUDE, YOU CAN CHANGE THE DATA-TYPE? This makes sure the parts of the story come in the right order, no matter how they are in the placeography -->
			<div>
			<!-- Get the URL for the map-->
			
				<xsl:call-template name="passage-builder">
					<xsl:with-param name="passage-n" select="./@n" data-type="number"/>
					<xsl:with-param name="linkgrp" select="."/>
					<xsl:with-param name="hh">
						<xsl:value-of select="$hh4"/>
					</xsl:with-param>
					
				</xsl:call-template>
				
				<div type="passage" style="z-index:1">
				<!-- Figure out what range of text to retrieve. Keep in mind that we need to check the language for proper alignment.-->
				<xsl:variable name="end" select="./tei:ptr[@type='end-after' and @xml:lang=document($hh4)//tei:text/@xml:lang]/@target"/>
				<xsl:variable name="start" select="./tei:ptr[@type='start-before' and @xml:lang=document($hh4)//tei:text/@xml:lang]/@target"/>
				<xsl:for-each select=
				"document($hh4)//tei:l[@n &lt; $end and @n &gt; $start or @n=$start or @n=$end]">
					
					<xsl:value-of select="./@n"/>: <xsl:copy><xsl:apply-templates select="text()"/><p style="display: none;"><xsl:copy><xsl:apply-templates select="./node()"/></xsl:copy></p></xsl:copy><br/> <!-- I still have a lot to learn; node() seems to get text data? Either way, this preserves the notes without displaying them, I think-->
				</xsl:for-each>
				</div>
				<!-- Now, get the map information-->
			<p>----------------------------------------------------------------</p>
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
		<h2>
			<xsl:choose>
				<xsl:when test="$linkgrp/../tei:placeName='empty'">
					No map data for this section
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$linkgrp/../../tei:place/tei:linkGrp[(substring-before(string(@n), '.') = string($passage-n) or string(@n) = string($linkgrp/@n)) and substring(string(@corresp), 1, 42)=substring(string($linkgrp/@corresp), 1, 42)]/../tei:placeName[@type='primary']"/><!-- The substring goes until the end of the tlg value, that is it cuts of .perseus-grc2.xml-->
						
				</xsl:otherwise>
			</xsl:choose>
			
		</h2>
		<!-- The map container is one div, below, separate from the passage div with the text-->
		<div type="map-container" style="position:absolute">
			<b>-&gt;Hover over me&lt;- </b>
			<div type="map">
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
								<xsl:value-of select="$linkgrp/../tei:location/tei:geo"/>
							</xsl:with-param>
							<xsl:with-param name="total-linkgrps">
								<xsl:value-of select="count(document('hh-place-names.xml')//tei:linkGrp[string(@corresp) = $hh and substring-before(string(@n), '.') = string($passage-n)]) + 1"/> <!-- Gets the total number of linkgrps associated with this one passage; adds one because this will never identify the first, which has no period, but we nonetheless know exists because we have entered the loop wrapping this template in the first place-->
							</xsl:with-param>
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
			const ]]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[ = L.map(']]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[').setView([]]><xsl:value-of select="string($coord)"/><![CDATA[], 13);

			const ]]><xsl:value-of select="concat('tiles', string($passage))"/><![CDATA[ = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
				maxZoom: 19,
				trackResize: true,
				attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
			}).addTo(]]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[);
			
			const marker_]]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[ = L.marker([]]><xsl:value-of select="string($coord)"/><![CDATA[]).addTo(]]><xsl:value-of select="concat(string($placename), string($passage))"/><![CDATA[)
			
			]]>
		</script>
		
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="full-map">
		<xsl:param name="length"/>
		<xsl:param name="placeography"/>
		<xsl:param name="hh4"/>
		
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
							]]><xsl:for-each select="document($placeography)//tei:linkGrp[string(@corresp)=$hh4 and boolean(./../tei:location)]">
								<xsl:sort select="./@n" data-type="number"/>
								<xsl:value-of select="concat('[', string(./../tei:location/tei:geo), ']')"/><xsl:if test="number(./@n) &lt; number($length)">,</xsl:if> <!-- YOU CHEATED HERE! FIX THIS LATER, OR ADD A # OF LOCATIONS FIELD-->
							</xsl:for-each> <![CDATA[
						];

						const polyline = L.polyline(latlngs, {color: 'red'}).addTo(map);

						// zoom the map to the polyline
						map.fitBounds(polyline.getBounds());
						
						]]><xsl:for-each select="document($placeography)//tei:linkGrp[string(@corresp)=$hh4 and boolean(./../tei:location)]">
								<xsl:sort select="./@n" data-type="number"/>
								const marker_<xsl:value-of select="string(@n)"/> = L.marker([<xsl:value-of select="string(./../tei:location/tei:geo)"/>]).addTo(map);
								
								marker_<xsl:value-of select="string(@n)"/>.bindPopup(&quot;<xsl:value-of select="concat(string(@n), ':&lt;br/&gt;', string(./../tei:placeName[@type='primary']))"/>&quot;);
								</xsl:for-each><![CDATA[
					]]>
				</script>
			 </xsl:element>
	</xsl:template>
	
	
	
</xsl:stylesheet>