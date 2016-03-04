<?php
/*
 *    Z-Push Details
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
echo '<link rel="stylesheet" href="z-push-details.css">';
echo '<title>Z-Push User Details</title>';
echo '</head><body>';

echo '<form method="get">';
echo '<input type="hidden" name="page" value="execute"/>';
echo '<table align="center" valign="middle" id="entry">';
echo '<tr class="entry">';
echo '<th class="entry">User or Device</th>';
echo '<td class="entry"><input type="text" name="object" value="',$object,'"/></td>';
echo '<td class="entry"><input type="submit" name="submit" value="Filter Names"/></td>';
echo '</tr>';
echo '</table>';
echo '<p align="center"><sub>Note: Use Regular Expression format (i.e. ict-.*)</sub></p>';
echo '</form>';

if ( ( $page !== "")  || ( $object !== "" ) ) {
	// XML
	$output = shell_exec("sudo /opt/opw/z-push-details.sh --output xml $object");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );
	// XSL
	$xsl = new DOMDocument();
	$xsl->loadXML('<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/results">

<xsl:if test="@format = \'list\'">
<table id="list">
<tr><th>Username</th><th>Device</th></tr>
<xsl:for-each select="result"><xsl:sort select="translate(@username, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" />
<tr class="hover"><td><a href="z-push-details.php?object={@username}"><xsl:value-of select="@username"/></a></td><td><a href="z-push-details.php?object={@deviceid}"><xsl:value-of select="@deviceid"/></a></td></tr>
</xsl:for-each>
</table>
</xsl:if>

<xsl:if test="@format = \'details\'">
<xsl:for-each select="result">
<table id="details">
<tr><th colspan="2" class="center">Device Information</th><th colspan="2" class="center">Wipe Information</th></tr>
<tr class="hover"><th>User</th><td><a href="z-push-details.php?object={@username}"><xsl:value-of select="@username"/></a></td><th>Request On</th><td><xsl:value-of select="wipe/@requeston"/></td></tr>
<tr class="hover"><th>Device ID</th><td><a href="z-push-details.php?object={@deviceid}"><xsl:value-of select="@deviceid"/></a></td><th>Request By</th><td><xsl:value-of select="wipe/@requestby"/></td></tr>
<tr class="hover"><th>Device Type</th><td><xsl:value-of select="@devicetype"/></td><th>Wiped On</th><td><xsl:value-of select="wipe/@wipedon"/></td></tr>
<tr class="hover"><th>User Agent</th><td><xsl:value-of select="@useragent"/></td><td colspan="2"></td></tr>
<tr class="hover"><th>Device Model</th><td><xsl:value-of select="@devicemodel"/></td><th colspan="2" class="center">Folder Information</th></tr>
<tr class="hover"><th>Device IMEI</th><td><xsl:value-of select="@deviceimei"/></td><th>First Sync</th><td><xsl:value-of select="folders/@firstsync"/></td></tr>
<tr class="hover"><th>Device Name</th><td><xsl:value-of select="@devicename"/></td><th>Last Sync</th><td><xsl:value-of select="folders/@lastsync"/></td></tr>
<tr class="hover"><th>Device OS</th><td><xsl:value-of select="@deviceos"/></td><th>Total Folders</th><td><xsl:value-of select="folders/@total"/></td></tr>
<tr class="hover"><th>Device Language</th><td><xsl:value-of select="@devicelanguage"/></td><th>Status</th><td><xsl:value-of select="folders/@status"/></td></tr>
<tr class="hover"><th>Device Operator</th><td><xsl:value-of select="@deviceoperator"/></td><th colspan="2" class="center">Synced Folders (<xsl:value-of select="folders/@synced"/>)</th></tr>
<tr class="hover"><th>Version</th><td><xsl:value-of select="@version"/></td><td colspan="2" class="center">
<xsl:for-each select="folders/folder">
<xsl:value-of select="@name"/>&#xA0;
</xsl:for-each>
</td></tr>
<tr class="hover"><th>Errors</th><td colspan="3"><xsl:value-of select="errors/@text"/></td></tr>
</table>

<table>
<tr><td>&#xA0;</td><td>
<table id="errors">
<xsl:for-each select="errors/error">
<tr class="hover"><th>Object</th><td><xsl:value-of select="@object"/></td></tr>
<tr class="hover"><th>Information</th><td><xsl:value-of select="@infomation"/></td></tr>
<tr class="hover"><th>Reason</th><td><xsl:value-of select="@reason"/></td></tr>
<tr class="hover"><th>Item/Parent ID</th><td><xsl:value-of select="@id"/></td></tr>
</xsl:for-each>
</table>

</td></tr>
</table>

</xsl:for-each>
</xsl:if>
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







