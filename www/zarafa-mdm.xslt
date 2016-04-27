<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />
<xsl:param name="sort" select="'username'"/>
<xsl:param name="device"/>
<xsl:param name="user"/>

<xsl:template match="/zarafaadmin/error">
  <table align="center">
    <caption style="color:red">An Error occurred, Please contact your System Administrator</caption>
    <tr>
      <td align="right" style="color:red">Error Number:</td>
      <td align="left"><xsl:value-of select="@code"/></td>
    </tr>
    <tr>
      <td align="right" style="color:red">Error Message:</td>
      <td align="left"><xsl:value-of select="@msg"/></td>
    </tr>
    <tr>
      <td align="right" style="color:red">Original Command:</td>
      <td align="left"><xsl:value-of select="@cmd"/></td>
    </tr>
  </table>
</xsl:template>

<xsl:template match="/zarafaadmin/devices">
  <pre>
    <xsl:choose>
      <xsl:when test="count(device) = 1">
        <table id="zarafa-device">
          <tr><th colspan="2" class="center">Device Information</th><th colspan="2" class="center">Wipe Information</th></tr>
          <tr class="hover"><th>User</th><td><a href="./zarafa-users.php?user={device/@synchronizedbyuser}"><xsl:value-of select="device/@synchronizedbyuser"/></a></td><th>Request On</th><td><xsl:value-of select="wipe/@wiperequeston"/></td></tr>
          <tr class="hover"><th>Device ID</th><td><a href="./zarafa-mdm.php?device={device/@deviceid}"><xsl:value-of select="device/@deviceid"/></a></td><th>Request By</th><td><xsl:value-of select="wipe/@wiperequestby"/></td></tr>
          <tr class="hover"><th>Device Type</th><td><xsl:value-of select="device/@devicetype"/></td><th>Wiped On</th><td><xsl:value-of select="wipe/@wipedon"/></td></tr>
          <tr class="hover"><th>User Agent</th><td><xsl:value-of select="device/@useragent"/></td><td colspan="2"></td></tr>
          <tr class="hover"><th>Device Model</th><td><xsl:value-of select="device/@devicemodel"/></td><th colspan="2" class="center">Folder Information</th></tr>
          <tr class="hover"><th>Device IMEI</th><td><xsl:value-of select="device/@deviceimei"/></td><th>First Sync</th><td><xsl:value-of select="device/@firstsync"/></td></tr>
          <tr class="hover"><th>Device Name</th><td><xsl:value-of select="device/@devicefriendlyname"/></td><th>Last Sync</th><td><xsl:value-of select="device/@lastsync"/></td></tr>
          <tr class="hover"><th>Device OS</th><td><xsl:value-of select="device/@deviceos"/></td><th>Total Folders</th><td><xsl:value-of select="device/@totalfolders"/></td></tr>
          <tr class="hover"><th>Device Language</th><td><xsl:value-of select="device/@deviceoslanguage"/></td><td colspan="2">&#xA0;</td></tr>
          <tr class="hover"><th>Status</th><td><xsl:value-of select="device/@status"/></td><td colspan="2">&#xA0;</td></tr>
          <tr class="hover"><th>Outbound SMS</th><td><xsl:value-of select="device/@deviceoutboundsms"/></td><td colspan="2">&#xA0;</td></tr>

          <tr class="hover"><th>Device Operator</th><td><xsl:value-of select="device/@deviceoperator"/></td><th colspan="2" class="center">Synced Folders (<xsl:value-of select="device/@synchronizedfolders"/>)</th></tr>
          <tr class="hover"><th>Version</th><td><xsl:value-of select="device/@activesyncversion"/></td>
          <td colspan="2" class="center"><xsl:value-of select="device/@synchronizeddata"/>&#xA0;</td></tr>
          <tr class="hover"><th>Errors</th><td colspan="3"><xsl:value-of select="device/@attentionneeded"/></td></tr>
    
          <xsl:for-each select="device/error">
            <tr><td>&#xA0;</td><td>
              <table id="zarafa-device-errors">
              <tr class="hover"><th style="width: 100;">Object</th><td><xsl:value-of select="@brokenobject"/></td></tr>
              <tr class="hover"><th>Information</th><td><xsl:value-of select="@information"/></td></tr>
              <tr class="hover"><th>Reason</th><td><xsl:value-of select="@reason"/></td></tr>
              <tr class="hover"><th>Item/Parent ID</th><td><xsl:value-of select="@itemparentid"/></td></tr>
              </table>
            </td></tr>
          </xsl:for-each>
        </table>
      </xsl:when>

      <xsl:otherwise>
        <table id="zarafa-devices">
          <tr class="hover">
            <th><a href="./zarafa-mdm.php?user={$user}&amp;device={@device}&amp;sort=username">Username</a></th>
            <th><a href="./zarafa-mdm.php?user={$user}&amp;device={@device}&amp;sort=device">Device ID</a></th>
            <th><a href="./zarafa-mdm.php?user={$user}&amp;device={@device}&amp;sort=sync">Last Sync</a></th>
          </tr>
          <xsl:choose>
          <xsl:when test="$sort = 'device'">
            <xsl:apply-templates select="device"><xsl:sort select="translate(@deviceid, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$sort = 'sync'">
            <xsl:apply-templates select="device"><xsl:sort select="lastsync/@lag" order="ascending" data-type="number"/></xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="device"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
          </xsl:otherwise>
          </xsl:choose>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </pre>
</xsl:template>

<xsl:template match="device">
  <tr>
    <td><a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a></td>
    <td><a href="./zarafa-mdm.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="@deviceid"/></a></td>
    <td><a href="./zarafa-mdm.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="lastsync"/></a></td>
  </tr>
</xsl:template>

</xsl:stylesheet>

