<?php
/*
 *    Zarafa User Details
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

$group = "";
if (isset($_GET['group']))    $group = $_GET['group'];
if (isset($_POST['group']))  $group = $_POST['group'];

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="zarafa-groups.css">';
echo '<title>Zarafa Group Details</title>';
echo '</head><body>';

echo '<form method="get">';
echo '<input type="hidden" name="page" value="execute"/>';
echo '<table align="center" valign="middle" id="entry">';
echo '<tr class="entry">';
echo '<th class="entry">Group name</th>';
echo '<td class="entry"><input type="text" name="group" value="',$group,'"/></td>';
echo '<td class="entry"><input type="submit" name="submit" value="Filter Names"/></td>';
echo '</tr>';
echo '</table>';
echo '<p align="center"><sub>Note: Use LDAP Search format (i.e. bra*)</sub></p>';
echo '</form>';


if ( $group !== "")  {
	// XML
	$output = shell_exec("sudo /opt/opw/zarafa-groups.py --output xml '$group'");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );

	// XSL
	$xsl = new DOMDocument();
      $xsl->load('zarafa-groups.xslt');
		
	// Proc
	$proc = new XSLTProcessor();
	$proc->importStylesheet($xsl);

	$output = $proc->transformToDoc($outputxml)->saveXML(); 
	
	echo "<pre>$output</pre>";
}

echo '</body></html>';
?>







