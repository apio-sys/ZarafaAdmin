<?php
/*
 *    Zarafa User or Group Details
 *
 *    Created by: Bob Brandt (http://brandt.ie)
 *    Created on: 2014-07-23
 *
 *                             GNU GENERAL PUBLIC LICENSE
 *                                Version 2, June 1991
 *    -------------------------------------------------------------------------
 *    Copyright (C) 2013 Bob Brandt
 *
 *    This program is free software; you can redistribute it and/or modify it
 *    under the terms of the GNU General Public License as published by the
 *    Free Software Foundation; either version 2 of the License, or (at your
 *    option) any later version.
 *
 *    This program is distributed in the hope that it will be useful, but
 *    WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *    General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License along
 *    with this program; if not, write to the Free Software Foundation, Inc.,
 *    59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

// Turn off all error reporting
//error_reporting(0);
// Report all PHP errors
error_reporting(-1);

$page = "";
$object = "";
if (isset($_GET['page']))    $page = $_GET['page'];
if (isset($_POST['page']))   $page = $_POST['page'];
if (isset($_GET['object']))  $object = $_GET['object'];
if (isset($_POST['object'])) $object = $_POST['object'];

//$object = preg_replace("/[^\w\d\.\@ ]/ui", '', $object);

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="zarafa-details.css">';
echo '<title>Zarafa User or Group Details</title>';
echo '</head><body>';

echo '<form method="get">';
echo '<input type="hidden" name="page" value="execute"/>';
echo '<table align="center" valign="middle" id="entry">';
echo '<tr class="entry">';
echo '<th class="entry">User/Group Name</th>';
echo '<td class="entry"><input type="text" name="object" value="',$object,'"/></td>';
echo '<td class="entry"><input type="submit" name="submit" value="Filter Names"/></td>';
echo '</tr>';
echo '</table>';
echo '<p align="center"><sub>Note: Use LDAP Search format (i.e. bra*)</sub></p>';
echo '</form>';


if ( ( $page !== "")  || ( $object !== "" ) ) {
	// XML
	$output = shell_exec("sudo /opt/opw/zarafa-details.sh --output xml $object");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );
	// XSL
	$xsl = new DOMDocument();
	$xsl->loadXML('<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/results">
<xsl:if test="count(group) = 0 and count(user) = 0">
<p>bad</p>
</xsl:if>

<xsl:if test="count(user) &gt; 1">
<table id="details">
<tr><th>Username</th><th>Fullname</th><th>Email</th><th>Active</th><th>Admin</th><th>Visible</th><th>Auto-accept</th><th>Logon</th><th>Logoff</th><th class="left">&#xA0;&#xA0;Groups</th></tr>
<xsl:apply-templates select="user"><xsl:sort select="translate(@username, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" /></xsl:apply-templates>
</table>
</xsl:if>

<xsl:if test="count(user) = 1">
<table id="userdetail">
<tr><th colspan="4" class="center">User Detail for <xsl:value-of select="user/@username"/></th></tr>
<tr><th colspan="2" class="center">Zarafa Details</th><th colspan="2" class="center">LDAP Details</th></tr>
<tr class="hover"><th>Username</th><td><xsl:value-of select="user/@username"/></td><th>GivenName</th><td><xsl:value-of select="user/@givenname"/></td></tr>
<tr class="hover"><th>Email</th><td><xsl:value-of select="user/@email"/></td><th>Surname</th><td><xsl:value-of select="user/@surname"/></td></tr>
<tr class="hover"><th>Active</th><td><xsl:if test="user/@active = \'yes\'">&#x2713;</xsl:if></td><th>Fullname</th><td><xsl:value-of select="user/@fullname"/></td></tr>
<tr class="hover"><th>Administrator</th><td><xsl:if test="user/@admin = \'yes\'">&#x2713;</xsl:if></td><th>Title</th><td><xsl:value-of select="user/@title"/></td></tr>
<tr class="hover"><th>Visible</th><td><xsl:if test="user/@visible = \'Visible\'">&#x2713;</xsl:if></td><th>Section</th><td><xsl:value-of select="user/@department"/></td></tr>
<tr class="hover"><th>Auto-accept</th><td><xsl:if test="user/@autoaccept = \'yes\'">&#x2713;</xsl:if></td><th>Location</th><td><xsl:value-of select="user/@location"/></td></tr>
<tr class="hover"><th>Logon</th><td><xsl:value-of select="user/@logon"/></td><th>Telephone</th><td><xsl:value-of select="user/@telephone"/></td></tr>
<tr class="hover"><th>Logoff</th><td><xsl:value-of select="user/@logoff"/></td><th>Mobile</th><td><xsl:value-of select="user/@mobile"/></td></tr>
<tr class="hover"><td colspan="2">&#xA0;</td><th>Fax</th><td><xsl:value-of select="user/@fax"/></td></tr>
<tr><th colspan="4" class="center">Quota Information<xsl:if test="user/@quota = \'yes\'">&#xA0;(Override Defaults &#x2713;)</xsl:if></th></tr>
<tr class="hover"><th>Warning Level</th><td><xsl:value-of select="user/@warning"/></td><th>Soft Level</th><td><xsl:value-of select="user/@soft"/></td></tr>
<tr class="hover"><th>Hard Level</th><td><xsl:value-of select="user/@hard"/></td><th>Current Size</th><td><xsl:value-of select="user/@size"/></td></tr>
<tr><th colspan="2">Groups</th><td colspan="2">
<xsl:for-each select="user/groups/group"><xsl:sort select="translate(@groupname, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" />
<xsl:if test="@groupname != \'Everyone\'"><a href="zarafa-details.php?page=execute&amp;object={@groupname}"><xsl:value-of select="@groupname"/></a></xsl:if>
<xsl:if test="@groupname = \'Everyone\'"><xsl:value-of select="@groupname"/></xsl:if>
<br/></xsl:for-each>
</td></tr>
</table>
</xsl:if>

<xsl:if test="count(group) &gt; 1">
<table id="details">
<tr><th>Groupname</th><th>Fullname</th><th>Email</th><th>Visible</th><th>#</th><th class="left">&#xA0;&#xA0;Users</th></tr>
<xsl:apply-templates select="group"><xsl:sort select="translate(@groupname, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" /></xsl:apply-templates>
</table>
</xsl:if>

<xsl:if test="count(group) = 1">
<table id="groupdetail">
<tr><th colspan="2" class="center">Group Detail for <xsl:value-of select="group/@groupname"/></th></tr>
<tr class="hover"><th>Groupname</th><td><xsl:value-of select="group/@groupname"/></td></tr>
<tr class="hover"><th>Fullname</th><td><xsl:value-of select="group/@fullname"/></td></tr>
<tr class="hover"><th>Email</th><td><xsl:value-of select="group/@email"/></td></tr>
<tr class="hover"><th>Visible</th><td><xsl:if test="group/@visible = \'Visible\'">&#x2713;</xsl:if></td></tr>
<tr class="hover"><th>Number of Users</th><td><xsl:value-of select="group/users/@count"/></td></tr>
<tr><th>Users</th>
<td><xsl:for-each select="group/users/user"><xsl:sort select="translate(@username, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" />
<a href="zarafa-details.php?page=execute&amp;object={@username}"><xsl:value-of select="@username"/></a><br/></xsl:for-each></td></tr>
</table>
</xsl:if>

</xsl:template>

<xsl:template match="user">
<tr class="hover">
<td><a href="zarafa-details.php?page=execute&amp;object={@username}"><xsl:value-of select="@username"/></a></td>
<td><xsl:value-of select="@fullname"/></td>
<td><xsl:value-of select="@email"/></td>
<td><xsl:if test="@active = \'yes\'">&#x2713;</xsl:if></td>
<td><xsl:if test="@admin = \'yes\'">&#x2713;</xsl:if></td>
<td><xsl:if test="@visible = \'Visible\'">&#x2713;</xsl:if></td>
<td><xsl:if test="@autoaccept = \'yes\'">&#x2713;</xsl:if></td>
<td><xsl:value-of select="@logon"/></td>
<td><xsl:value-of select="@logoff"/></td>
<td><xsl:for-each select="groups/group"><xsl:sort select="translate(@groupname, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" />
<xsl:if test="@groupname != \'Everyone\'"><a href="zarafa-details.php?page=execute&amp;object={@groupname}"><xsl:value-of select="@groupname"/></a></xsl:if>
<xsl:if test="@groupname = \'Everyone\'"><xsl:value-of select="@groupname"/></xsl:if>
&#xA0;</xsl:for-each></td>
</tr>
</xsl:template>

<xsl:template match="group">
<tr class="hover">
<td><a href="zarafa-details.php?page=execute&amp;object={@groupname}"><xsl:value-of select="@groupname"/></a></td>
<td><xsl:value-of select="@fullname"/></td>
<td><xsl:value-of select="@email"/></td>
<td><xsl:if test="@visible = \'Visible\'">&#x2713;</xsl:if></td>
<td><xsl:value-of select="users/@count"/></td>
<td><xsl:for-each select="users/user"><xsl:sort select="translate(@username, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" />
<a href="zarafa-details.php?page=execute&amp;object={@username}"><xsl:value-of select="@username"/></a>&#xA0;</xsl:for-each></td>
</tr>
</xsl:template>

</xsl:stylesheet>');
		
	// Proc
	$proc = new XSLTProcessor();
	$proc->importStylesheet($xsl);
	$output = $proc->transformToDoc($outputxml)->saveXML(); 
	
	echo "<pre>$output</pre>";    
}

echo '</body></html>';
?>







