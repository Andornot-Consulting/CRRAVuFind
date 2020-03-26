<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/2001/XMLSchema-instance">
    <xsl:output method="xml" indent="yes" encoding="utf-8"/>
    <xsl:param name="institution">My University</xsl:param>
    <xsl:param name="building">My Library</xsl:param>
    <xsl:param name="idprefix">pp</xsl:param>
    
    <xsl:template match="metadata">
		<add>
		    <xsl:for-each select="./dc-record">
				<doc>
					<!-- identifier - first is ID; second is URL -->
					<xsl:for-each select="./identifier">
						<xsl:if test="position()=1">
							<field name="id">
								<xsl:value-of select="$idprefix"/><xsl:value-of disable-output-escaping="no" select="normalize-space(string(.))" />
							</field>
						</xsl:if>
						<xsl:if test="position()=2">
							<field name="url">
								<xsl:value-of disable-output-escaping="no"  select="normalize-space(string(.))"/>
							</field>
						</xsl:if>
					</xsl:for-each>
				
					<!-- ALLFIELDS -->
					<field name="allfields">
						<xsl:value-of select="normalize-space(.)"/>
					</field>

					<!-- institution -->
					<field name="institution">
						<xsl:value-of select="$institution" />
					</field>

					<!-- building -->
					<field name="building">
						<xsl:value-of select="$building" />
					</field>
				
					<!-- RECORD FORMAT -->
					<field name="record_format">index</field>				

					<!-- title -->
					<field name="title">
						<xsl:value-of select="normalize-space(./title)"/>
					</field>
					<field name="title_short">
						<xsl:value-of select="normalize-space(./title)"/>
					</field>
					<field name="title_full">
						<xsl:value-of select="normalize-space(./title)"/>
					</field>
				
					<field name="title_sort">
						<xsl:call-template name="RemoveLeadingArticles">
							<xsl:with-param name="TextToReplace" select="string(./title)"/>
						</xsl:call-template>
					</field>
			
					<!-- dates -->
					<field name="publishDate">
						<xsl:value-of select="normalize-space(./date)"/>
					</field>

					<field name="publishDateSort">
						<xsl:call-template name="TruncateDate">
							<xsl:with-param name="TextToReplace" select="string(./date)"/>
						</xsl:call-template>
					</field>

					<!-- publisher: first occurence is place; second is publisher name; combine with : -->
					<xsl:for-each select="./publisher">
						<field name="publisher">
							<xsl:if test="position()=1">
								<xsl:value-of disable-output-escaping="no" select="normalize-space(string(.))" />
								<xsl:text disable-output-escaping="yes"> : </xsl:text>
							</xsl:if>
							<xsl:if test="position()=2">
								<xsl:value-of disable-output-escaping="no"  select="normalize-space(string(.))"/>
							</xsl:if>
						</field>
					</xsl:for-each>		
				
					<!-- format -->
					<xsl:for-each select="./format">
						<field name="format">
							<xsl:value-of select="normalize-space(.)"/>
						</field>
					</xsl:for-each>

					<!-- language -->
					<xsl:for-each select="./language">
						<field name="language">
							<xsl:value-of select="normalize-space(.)"/>
						</field>
					</xsl:for-each>

					<!-- series -->
					<xsl:for-each select="./relation">
						<field name="series">
							<xsl:value-of select="normalize-space(.)"/>
						</field>
					</xsl:for-each>

					<!-- subjects -->
					<xsl:for-each select="./subject">
						<field name="topic">
							<xsl:value-of select="normalize-space(.)"/>
						</field>
					</xsl:for-each>

					<!-- author -->
					<xsl:for-each select="./creator">
						<field name="author">
							<xsl:value-of select="normalize-space(.)"/>
						</field>
					</xsl:for-each>
					<xsl:for-each select="./creator">
						<xsl:if test="position()=1">
							<field name="author_sort">
								<xsl:value-of disable-output-escaping="no" select="normalize-space(string(.))" />
							</field>
						</xsl:if>
					</xsl:for-each>
				</doc>
			</xsl:for-each>
		</add>
    </xsl:template>
    
	<!-- Template to remove leading chars from dates and return a 4 digit year	-->
	<xsl:template name="TruncateDate">
		<xsl:param name="TextToReplace"></xsl:param>
		<xsl:choose>
			<xsl:when test="(substring($TextToReplace,1,2)='[c')">
				<xsl:value-of select="substring($TextToReplace,3,4)"/>
			</xsl:when>	
			<xsl:when test="(substring($TextToReplace,1,1)='c')">
				<xsl:value-of select="substring($TextToReplace,2,4)"/>
			</xsl:when>
			<xsl:when test="(substring($TextToReplace,1,1)='[')">
				<xsl:value-of select="substring($TextToReplace,2,4)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($TextToReplace,1,4)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>		
    

	<!-- Template to remove leading articles from title for title_sort since the PHP code errors -->
	<xsl:template name="RemoveLeadingArticles">
		<xsl:param name="TextToReplace"></xsl:param>
		<xsl:choose>
			<xsl:when test="(substring($TextToReplace,1,2)='A ')">
				<xsl:value-of select="substring($TextToReplace,3)"/>
			</xsl:when>	
			<xsl:when test="(substring($TextToReplace,1,3)='An ')">
				<xsl:value-of select="substring($TextToReplace,4)"/>
			</xsl:when>	
			<xsl:when test="(substring($TextToReplace,1,4)='The ')">
				<xsl:value-of select="substring($TextToReplace,5)"/>
			</xsl:when>	
			<xsl:otherwise>
				<xsl:value-of select="$TextToReplace"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>


