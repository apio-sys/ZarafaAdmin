<?php
/*
 *    Kopano Group Details
 *
 *    Created by: Bob Brandt (http://brandt.ie)
 *    Created on: 2016-04-23
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
// The following is needed to display loading screen using Progressive Rendering
ob_start(); // not needed if output_buffering is on in php.ini
ob_implicit_flush(); // implicitly calls flush() after every ob_flush()
$buffer = ini_get('output_buffering'); // retrive the buffer size from the php.ini file
if (!is_numeric($buffer)) $buffer = 8192;

$group = "";
if (isset($_GET['group']))   $group = $_GET['group'];
if (isset($_POST['group']))  $group = $_POST['group'];

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="kopanoadmin.css">';
echo '<title>Kopano Group Details</title>';
echo '<script src="loading.js"></script>';
echo '</head><body onload="hide_loading();">';
echo str_pad('',$buffer)."\n"; ob_flush();

echo '<div id="loading"><img src="loading.gif"/> Loading...</div>';
echo str_pad('',$buffer)."\n"; ob_flush();

// XML
$command = "sudo /opt/brandt/ZarafaAdmin/bin/zarafa-groups.py --output xml";
if ( $group !== "" ) $command = "$command ".escapeshellarg($group);
$output = shell_exec($command);
$outputxml = new DOMDocument();
$outputxml->loadXML( $output );

// XSL
$xsl = new DOMDocument();
$xsl->load('zarafa-groups.xslt');
	
// Proc
$proc = new XSLTProcessor();
$proc->importStylesheet($xsl);

$output = $proc->transformToDoc($outputxml)->saveXML(); 

echo "$output";
echo '</body></html>';
?>






