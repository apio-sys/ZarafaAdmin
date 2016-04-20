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
header("Expires: Tue, 01 Jan 2000 00:00:00 GMT");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

$user = "";
if (isset($_GET['user']))    $user = $_GET['user'];
if (isset($_POST['user']))   $user = $_POST['user'];

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="zarafaadmin.css">';
echo '<title>Zarafa User Details</title>';
echo '</head><body>';

echo '<form method="get">';
echo '<table align="center" valign="middle" id="entry">';
echo '<tr class="entry">';
echo '<th class="entry">Username</th>';
echo '<td class="entry"><input type="text" name="user" value="',$user,'"/></td>';
echo '<td class="entry"><input type="submit" name="submit" value="Filter Names"/></td>';
echo '</tr>';
echo '</table>';
echo '<p align="center"><sub>Note: Use LDAP Search format (i.e. bra*)</sub></p>';
echo '</form>';

if ( $user !== "")  {
	// User XML
	$output = shell_exec("sudo /opt/brandt/ZarafaAdmin/bin/zarafa-users.py --output xml '$user'");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );

	// Device XML
	$devices = shell_exec("sudo /opt/opw/z-push-details.py --output xml --list -u '$user'");
	$devicesxml = new DOMDocument();
	$devicesxml->loadXML( $devices );

	// User XSL 
	$xsl = new DOMDocument();
    $xsl->load('zarafa-users.xslt');

	// Device XSL 
	$devicexsl = new DOMDocument();
    $devicexsl->load('zarafa-users-devices.xslt');
		
	// Proc
	$proc = new XSLTProcessor();
	$proc->importStylesheet($xsl);
	$output = $proc->transformToDoc($outputxml)->saveXML(); 
	echo '<div id="zarafa-users-div"><pre>';
	echo "$output";

	$proc->importStylesheet($devicexsl);
	$proc->setParameter( '', 'sort', 'sync');
	$output = $proc->transformToDoc($devicesxml)->saveXML(); 
	echo "$output</pre></div>";
}

echo '</body></html>';
?>







