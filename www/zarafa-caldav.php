<?php
/*
 *    Zarafa User List
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
echo '<link rel="stylesheet" href="zarafa-caldav.css">';
echo '<title>Zarafa Calendar List</title>';
echo '</head><body>';

echo '<form method="get">';
echo '<input type="hidden" name="page" value="execute"/>';
echo '<table align="center" valign="middle" id="entry">';
echo '<tr class="entry">';
echo '<th class="entry">UserName</th>';
echo '<td class="entry"><input type="text" name="object" value="',$object,'"/></td>';
echo '<td class="entry"><input type="submit" name="submit" value="Filter Names"/></td>';
echo '</tr>';
echo '</table>';
echo '<p align="center"><sub>Note: Use Regular Expression format (i.e. ict-.*)</sub></p>';
echo '</form>';

if ( ( $page !== "")  || ( $object !== "" ) ) {
	// XML
	$output = shell_exec("sudo /opt/opw/zarafa-caldav.sh $object");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );
	
	// XSL
	$xsl = new DOMDocument();
	$xsl->loadXML('<?xml version="1.0" encoding="UTF-8"?>
	<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:template match="/results">
	
	<table id="list">
	<tr><th>Username</th><th>Fullname</th><th>CalDAV Calendar</th><th>CalDAV Tasks</th></tr>
	<xsl:for-each select="result">
	<xsl:sort select="translate(@username, \'abcdefghijklmnopqrstuvwxyz\',\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\')" order="ascending" />
	<tr class="details">
	<td><a href="zarafa-caldav.php?page=execute&amp;object={@username}"><xsl:value-of select="@username"/></a></td>
	<td><xsl:value-of select="@fullname"/></td>
	<td>https://caldav.i.opw.ie:8443/caldav/<xsl:value-of select="translate(@username, \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\',\'abcdefghijklmnopqrstuvwxyz\')"/>/calendar</td>
	<td>https://caldav.i.opw.ie:8443/caldav/<xsl:value-of select="translate(@username, \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\',\'abcdefghijklmnopqrstuvwxyz\')"/>/tasks</td>
	</tr>
	</xsl:for-each>
	</table>
	</xsl:template>
	</xsl:stylesheet>');
			
	// Proc
	$proc = new XSLTProcessor();
	$proc->importStylesheet($xsl);
	$output = $proc->transformToDoc($outputxml)->saveXML(); 
	
	#$output = shell_exec("sudo zarafa-details --output xml $object");
	echo "<pre>$output</pre>";
}
echo '</body></html>';
?>







