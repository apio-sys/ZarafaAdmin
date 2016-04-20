<?php
/*
 *    Zarafa Failed Login Errors
 *
 *    Created by: Bob Brandt (http://brandt.ie)
 *    Created on: 2015-11-23
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

$sort = "";
if (isset($_GET['sort']))    $sort = $_GET['sort'];
if (isset($_POST['sort']))   $sort = $_POST['sort'];

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="zarafaadmin.css">';
echo '<title>Zarafa Login Errors Result Page</title>';
echo '<script>';
echo 'function toggle(obj) {';
echo '    var img = document.getElementById(obj+"-img");';
echo '    var row = document.getElementById(obj+"-details");';
echo '    if ( row.className == "hide" ) {';
echo '        img.src = "/images/toggle-collapse.png";';
echo '        row.className = "show";';
echo '    }';
echo '    else {';
echo '        img.src = "/images/toggle-expand.png";';
echo '        row.className = "hide";';
echo '    }';
echo '}';
echo '</script>';
echo '</head><body>';

// XML
$output = shell_exec("sudo /opt/opw/zarafa-logins.py --output xml");
$outputxml = new DOMDocument();
$outputxml->loadXML( $output );

// XSL
$xsl = new DOMDocument();
$xsl->load('zarafa-logins.xslt');

// Proc
$proc = new XSLTProcessor();
$proc->importStylesheet($xsl);
if ( $sort !== "" ) $proc->setParameter( '', 'sort', $sort);    

$output = $proc->transformToDoc($outputxml)->saveXML();

echo "<pre>$output</pre>";

echo '</body></html>';
?>


