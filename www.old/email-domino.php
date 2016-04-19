<?php
/*
 *    Domino User Emails
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

$object = "";
if (isset($_GET['object']))  $object = $_GET['object'];
if (isset($_POST['object'])) $object = $_POST['object'];

//$object = preg_replace("/[^\w\d\.\@ ]/ui", '', $object);

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="email.css">';
echo '<title>Domino User Emails</title>';
echo '</head><body>';

echo '<form method="get">';
echo '<table align="center" valign="middle" id="entry">';
echo '<tr class="entry">';
echo '<th class="entry">Domino Username</th>';
echo '<td class="entry"><input type="text" name="object" value="',$object,'"/></td>';
echo '<td class="entry"><input type="submit" name="submit" value="Display"/></td>';
echo '</tr>';
echo '</table>';
echo '<p align="center"><sub>Note: Must be full, single username.</sub></p>';
echo '</form>';

if ( $object !== "" ) {
	// XML
	$output = shell_exec("sudo email-domino --output xml \"$object\"");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );
	
	// XSL
	$xsl = new DOMDocument();
	$xsl->loadXML('<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/results">
<table id="details" align="center">
<tr><th>Email Addresses(<xsl:value-of select="count(result)"/>) for <xsl:value-of select="@username"/></th></tr>
<xsl:for-each select="result">
<tr class="hover"><td><xsl:value-of select="."/></td></tr>
</xsl:for-each>
</table>
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







