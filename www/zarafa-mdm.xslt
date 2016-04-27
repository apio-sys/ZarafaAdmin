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
          <tr>
            <th colspan="3" class="center">Device Information</th>
            <th colspan="3" class="center">Wipe Information</th>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">User:&#xA0;</th>
            <td><a href="./zarafa-users.php?user={device/@synchronizedbyuser}"><xsl:value-of select="device/@synchronizedbyuser"/></a></td>
            <td>&#xA0;</td>
            <th align="right">Request On:&#xA0;</th>
            <td><xsl:value-of select="wipe/@wiperequeston"/></td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device ID:&#xA0;</th>
            <td><a href="./zarafa-mdm.php?device={device/@deviceid}"><xsl:value-of select="device/@deviceid"/></a></td>
            <td>&#xA0;</td>
            <th align="right">Request By:&#xA0;</th>
            <td><xsl:value-of select="wipe/@wiperequestby"/></td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device Type:&#xA0;</th>
            <td><xsl:value-of select="device/@devicetype"/></td>
            <td>&#xA0;</td>
            <th align="right">Wiped On:&#xA0;</th>
            <td><xsl:value-of select="wipe/@wipedon"/></td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">User Agent:&#xA0;</th>
            <td><xsl:value-of select="device/@useragent"/></td>
            <td colspan="3">&#xA0;</td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device Model:&#xA0;</th>
            <td><xsl:value-of select="device/@devicemodel"/></td>
            <th colspan="3" class="center">Folder Information</th>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device IMEI:&#xA0;</th>
            <td><xsl:value-of select="device/@deviceimei"/></td>
            <td>&#xA0;</td>
            <th align="right">First Sync:&#xA0;</th>
            <td><xsl:value-of select="device/@firstsync"/></td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device Name:&#xA0;</th>
            <td><xsl:value-of select="device/@devicefriendlyname"/></td>
            <td>&#xA0;</td>
            <th align="right">Last Sync:&#xA0;</th>
            <td><xsl:value-of select="device/@lastsync"/></td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device OS:&#xA0;</th>
            <td><xsl:value-of select="device/@deviceos"/></td>
            <td>&#xA0;</td>
            <th align="right">Total Folders:&#xA0;</th>
            <td><xsl:value-of select="device/@totalfolders"/></td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device Language:&#xA0;</th>
            <td><xsl:value-of select="device/@deviceoslanguage"/></td>
            <td colspan="3">&#xA0;</td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Status:&#xA0;</th>
            <td><xsl:value-of select="device/@status"/></td>
            <td colspan="3">&#xA0;</td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Outbound SMS:&#xA0;</th>
            <td><xsl:value-of select="device/@deviceoutboundsms"/></td>
            <td colspan="3">&#xA0;</td>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Device Operator:&#xA0;</th>
            <td><xsl:value-of select="device/@deviceoperator"/></td>
            <th colspan="3" class="center">Synced Folders (<xsl:value-of select="device/@synchronizedfolders"/>)</th>
          </tr>
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Version:&#xA0;</th>
            <td><xsl:value-of select="device/@activesyncversion"/></td>
            <td colspan="3" class="center"><xsl:value-of select="device/@synchronizeddata"/></td>
          </tr>
        </table>
        <table id="zarafa-device-errors">
          <tr class="hover">
            <td>&#xA0;</td>
            <th align="right">Errors:&#xA0;</th>
            <td><xsl:value-of select="device/@attentionneeded"/></td>
          </tr>          
          <xsl:for-each select="device/error">
            <tr><td colspan="3">&#xA0;</td></tr>
            <tr class="hover">
              <td>&#xA0;</td>
              <th align="right">Object:&#xA0;</th>
              <td><xsl:value-of select="@brokenobject"/></td>
            </tr>
            <tr class="hover">
              <td>&#xA0;</td>
              <th align="right">Information:&#xA0;</th>
              <td><xsl:value-of select="@information"/></td>
            </tr>
            <tr class="hover">
              <td>&#xA0;</td>
              <th align="right">Reason:&#xA0;</th>
              <td><xsl:value-of select="@reason"/></td>
            </tr>
            <tr class="hover">
              <td>&#xA0;</td>
              <th align="right">Item/Parent ID:&#xA0;</th>
              <td><xsl:value-of select="@itemparentid"/></td>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:when>

      <xsl:otherwise>
        <table id="zarafa-devices">
          <tr>
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
  <tr class="hover">
    <td><a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a></td>
    <td><a href="./zarafa-mdm.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="@deviceid"/></a></td>
    <td><a href="./zarafa-mdm.php?user={@username}&amp;device={@deviceid}"><xsl:value-of select="lastsync"/></a></td>
  </tr>
</xsl:template>

</xsl:stylesheet>

