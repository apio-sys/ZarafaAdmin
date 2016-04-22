<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:param name="log" select="'system'"/>
<xsl:param name="sort" select="'descending'"/>
<xsl:param name="filter"/>

<xsl:template match="/zarafaadmin/logs">
	<form method="get">
		<table valign="middle" id="entry" align="center">
			<tr class="entry">
				<td class="entry">
					<select name="log">
						<xsl:for-each select="log">
							<option value="{@name}">
								<xsl:if test="$log = @name"><xsl:attribute name="selected"/></xsl:if>
								<xsl:value-of select="@display"/>
							</option>
						</xsl:for-each>
					</select>
				</td>
				<td class="entry"> 
					<select name="sort">
					  <option value="ascending">
							<xsl:if test="$sort = 'ascending'"><xsl:attribute name="selected"/></xsl:if>
					  	Sort Ascending
					  </option>
					  <option value="descending">
							<xsl:if test="$sort = 'descending'"><xsl:attribute name="selected"/></xsl:if>
					  	Sort Descending
					  </option>					  
					</select>
				</td>			
				<td class="entry"><input name="filter" type="text" value="{$filter}"></td>
				<td class="entry"><input name="submit" value="Filter Log" type="submit"></td>
			</tr>	
		</table>
	</form>
</xsl:template>

<xsl:template match="/zarafaadmin/log">
  <h2 align="center"><xsl:value-of select="@log"/> Log entries <xsl:if test="@filters != ''">using filter(s): <xsl:value-of select="@filters"/></xsl:if></h2>
  <table id="zarafa-logs">
    <xsl:apply-templates select="line"/>
  </table>
</xsl:template>

<xsl:template match="line">
  <tr><td><xsl:value-of select="."/></td></tr>
</xsl:template>

</xsl:stylesheet>
