<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/zarafaadmin/log">

  <h2 align="center">Log entries for <xsl:value-of select="@log"/> using filter(s) <xsl:value-of select="@filters"/></h2>
  <table id="zarafa-logs">
    <xsl:apply-templates select="line"/>
  </table>
</xsl:template>

<xsl:template match="line">
  <tr><td><xsl:value-of select="."/></td></tr>
</xsl:template>

</xsl:stylesheet>
