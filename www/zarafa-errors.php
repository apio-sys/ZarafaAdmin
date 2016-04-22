<?php
/*
 *    Zarafa Log Viewer
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

$filter = "";
if (isset($_GET['filter']))  $filter = $_GET['filter'];
if (isset($_POST['filter'])) $filter = $_POST['filter'];

$log = "system";
if (isset($_GET['log']))     $log = $_GET['log'];
if (isset($_POST['log']))    $log = $_POST['log'];

$sort = "descending";
if (isset($_GET['sort']))    $sort = $_GET['sort'];
if (isset($_POST['sort']))   $sort = $_POST['sort'];

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="zarafaadmin.css">';
echo '<title>Zarafa Log Viewer</title>';
echo '</head><body>';

// User XML
$form = shell_exec("sudo /opt/brandt/ZarafaAdmin/bin/zarafa-errors.py --list --output xml");
$formxml = new DOMDocument();
$formxml->loadXML( $form );

// User XSL 
$formxsl = new DOMDocument();
$formxsl->load('zarafa-errors.xslt');

// Proc
$formproc = new XSLTProcessor();
$formproc->importStylesheet($formxsl);
if ( $log !== "" )    $formproc->setParameter( '', 'log', $log);
if ( $sort !== "" )   $formproc->setParameter( '', 'sort', $sort);
if ( $filter !== "" ) $formproc->setParameter( '', 'filter', $filter);

$form = $formproc->transformToDoc($formxml)->saveXML(); 
echo "$form";

// echo '<form method="get">';
// echo '<table align="center" valign="middle" id="entry">';
// echo '<tr class="entry">';
// echo '<td class="entry"><input type="text" name="filter" value="',$filter,'"/></td>';
// echo '<td class="entry"><input type="submit" name="submit" value="Filter Log"/></td>';
// echo '</tr>';
// echo '</table>';
// echo '</form>';

// User XML
$output = shell_exec("sudo /opt/brandt/ZarafaAdmin/bin/zarafa-errors.py --output xml --log $log $filter");
$outputxml = new DOMDocument();
$outputxml->loadXML( $output );

// User XSL 
$xsl = new DOMDocument();
$xsl->load('zarafa-errors.xslt');

// Proc
$proc = new XSLTProcessor();
$proc->importStylesheet($xsl);
$output = $proc->transformToDoc($outputxml)->saveXML(); 

echo "<pre>$output</pre>";

echo '</body></html>';
?>
