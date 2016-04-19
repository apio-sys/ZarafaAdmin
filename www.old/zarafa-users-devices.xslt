<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/z-push-details">

  <table id="zarafa-user-devices">
  <tr><th colspan="3" class="center">Mobile Devices</th></tr>
  <tr>
    <th class="center">Username</th>
    <th class="center">Device ID</th>
    <th class="center">Last Sync</th>
  </tr>
  <xsl:for-each select="device">
    <tr class="hover">
      <td class="hover"><a href="./z-push-details.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="@username"/></a></td>
      <td class="hover"><a href="./z-push-details.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="@deviceid"/></a></td>
      <td class="hover"><a href="./z-push-details.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="@sync"/></a></td>
    </tr>
  </xsl:for-each>
</table>
</xsl:template>

</xsl:stylesheet>
