<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:param name="sort" select="'username'"/>

<xsl:template match="/zarafa-admin/login-errors">
<table id="zarafa-login-errors">
<tr>
<th><a href="./zarafa-logins.php?sort=username">Username</a></th>
<th><a href="./zarafa-logins.php?sort=m1">1 Min</a></th>
<th><a href="./zarafa-logins.php?sort=m5">5 Min</a></th>
<th><a href="./zarafa-logins.php?sort=m15">15 Min</a></th>
<th><a href="./zarafa-logins.php?sort=h1">1 Hour</a></th>
<th><a href="./zarafa-logins.php?sort=h4">4 Hour</a></th>
<th><a href="./zarafa-logins.php?sort=h8">8 Hour</a></th>
<th><a href="./zarafa-logins.php?sort=d1">1 Day</a></th>
<th><a href="./zarafa-logins.php?sort=d3">3 Day</a></th></tr>

<xsl:choose>
<xsl:when test="$sort = 'm1'">
    <xsl:apply-templates select="user"><xsl:sort select="@m1" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'm5'">
    <xsl:apply-templates select="user"><xsl:sort select="@m5" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'm15'">
    <xsl:apply-templates select="user"><xsl:sort select="@m15" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'h1'">
    <xsl:apply-templates select="user"><xsl:sort select="@h1" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'h4'">
    <xsl:apply-templates select="user"><xsl:sort select="@h4" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'h8'">
    <xsl:apply-templates select="user"><xsl:sort select="@h8" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'd1'">
    <xsl:apply-templates select="user"><xsl:sort select="@d1" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:when test="$sort = 'd3'">
    <xsl:apply-templates select="user"><xsl:sort select="@d3" order="descending" data-type="number"/></xsl:apply-templates>
</xsl:when>
<xsl:otherwise>
    <xsl:apply-templates select="user"><xsl:sort select="translate(@username, 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" order="ascending" /></xsl:apply-templates>
</xsl:otherwise>
</xsl:choose>
</table>
</xsl:template>

<xsl:template match="user">
<tr class="hover" id="{@username}-basic">

<td><img id="{@username}-img" src="/images/toggle-expand.png" onclick="toggle('{@username}');"/>&#xA0;
<a href="./zarafa-users.php?user={@username}"><xsl:value-of select="@username"/></a></td>
<td class="number"><xsl:value-of select="@m1"/></td>
<td class="number"><xsl:value-of select="@m5"/></td>
<td class="number"><xsl:value-of select="@m15"/></td>
<td class="number"><xsl:value-of select="@h1"/></td>
<td class="number"><xsl:value-of select="@h4"/></td>
<td class="number"><xsl:value-of select="@h8"/></td>
<td class="number"><xsl:value-of select="@d1"/></td>
<td class="number"><xsl:value-of select="@d3"/></td>
</tr>
<tr class="hide" id="{@username}-details">
<td colspan="9">
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;Windows DN: <xsl:value-of select="@dn"/><br/>
&#xA0;Bad Password Count: <xsl:value-of select="@badpwdcount"/><br/>
&#xA0;&#xA0;Bad Password Time: <xsl:value-of select="@badpasswordtime"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;Last Logoff: <xsl:value-of select="@lastlogoff"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;Last Login: <xsl:value-of select="@lastlogon"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;Logon Hours: <xsl:value-of select="@logonhours"/><br/>
&#xA0;&#xA0;Password Last Set: <xsl:value-of select="@pwdlastset"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;Account Expires: <xsl:value-of select="@accountexpires"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;Logon Count: <xsl:value-of select="@logoncount"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;Last Login Time: <xsl:value-of select="@lastlogontimestamp"/><br/>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;Errors: <xsl:value-of select="@error"/>
</td></tr>
</xsl:template>

</xsl:stylesheet>
