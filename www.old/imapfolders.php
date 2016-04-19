<?php
/*
 *    IMAP Folder migration web tool
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
$dominouser = "";
$zarafauser = "";
$dominopass = "";
$zarafapass = "";
$dryrun = "";
if (isset($_GET['page']))        $page = $_GET['page'];
if (isset($_POST['page']))       $page = $_POST['page'];
if (isset($_GET['dominouser']))  $dominouser = $_GET['dominouser'];
if (isset($_POST['dominouser'])) $dominouser = $_POST['dominouser'];
if (isset($_GET['zarafauser']))  $zarafauser = $_GET['zarafauser'];
if (isset($_POST['zarafauser'])) $zarafauser = $_POST['zarafauser'];
if (isset($_GET['dominopass']))  $dominopass = $_GET['dominopass'];
if (isset($_POST['dominopass'])) $dominopass = $_POST['dominopass'];
if (isset($_GET['zarafapass']))  $zarafapass = $_GET['zarafapass'];
if (isset($_POST['zarafapass'])) $zarafapass = $_POST['zarafapass'];
if (isset($_GET['dryrun']))      $dryrun = $_GET['dryrun'];
if (isset($_POST['dryrun']))     $dryrun = $_POST['dryrun'];
$dominouser = preg_replace("/[^\w\d\.\@ ]/ui", '', $dominouser);
$zarafauser = preg_replace("/[^\w\d\.\@ ]/ui", '', $zarafauser);
$dominopass = preg_replace("/[^\w\d\.\@ ]/ui", '', $dominopass);
$zarafapass = preg_replace("/[^\w\d\.\@ ]/ui", '', $zarafapass);


echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="imapfolders.css">';
echo '<title>IMAPfolders Migration Page</title>';
echo '</head>';
switch ($page) {
   case 'verify':
	// XML
	$output = shell_exec("sudo /opt/opw/imapfolders.sh --dominouser \"$dominouser\" --zarafauser \"$zarafauser\" --output xml --force --check");
	$outputxml = new DOMDocument();
	$outputxml->loadXML( $output );
	
	// XSL
	$dominoxsl = new DOMDocument();
	$dominoxsl->loadXML('<?xml version="1.0" encoding="ISO-8859-1"?>
	<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
	<select name="dominouser">
	  <xsl:apply-templates select="results/domino"><xsl:sort/></xsl:apply-templates>
	</select>
	</xsl:template>
	
	<xsl:template match="domino">
	  <option value="{@cn}">
	    <xsl:value-of select="."/>
	  </option>
	</xsl:template>
	</xsl:stylesheet>');
	
	$zarafaxsl = new DOMDocument();
	$zarafaxsl->loadXML('<?xml version="1.0" encoding="ISO-8859-1"?>
	<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
	<select name="zarafauser">
	  <xsl:apply-templates select="results/zarafa"><xsl:sort/></xsl:apply-templates>
	</select>
	</xsl:template>
	
	<xsl:template match="zarafa">
	  <option value="{@cn}">
	    <xsl:value-of select="."/>
	  </option>
	</xsl:template>
	</xsl:stylesheet>');
	
	// Proc
	$proc = new XSLTProcessor();
	$proc->importStylesheet($dominoxsl);
	$output_domino = $proc->transformToDoc($outputxml)->saveXML();
	$proc->importStylesheet($zarafaxsl);
	$output_zarafa = $proc->transformToDoc($outputxml)->saveXML();	   

	echo '<body>';		    
      echo '<form method="get">';
      echo '<input type="hidden" name="page" value="execute"/>';
      echo '<table align="center" valign="middle">';
      echo '<tr>';
      echo '<th>&nbsp;</th>';
      echo '<th align="center">Domino Information</th>';
      echo '<th>&nbsp;&nbsp;&nbsp;</th>';
      echo '<th align="center">Zarafa Information</th>';
      echo '</tr>';
      echo '<tr>';
      echo '<th align="right">User</th>';
      echo '<td align="center">',$output_domino,'</td>';
      echo '<td>&nbsp;&rarr;&nbsp;</td>';
      echo '<td align="center">',$output_zarafa,'</td>';
      echo '</tr>';
      echo '<tr>';
      echo '<th align="right">&nbsp;&nbsp;&nbsp;Password</th>';
      echo '<td align="center"><input type="password" name="dominopass" value=""/></td>';
      echo '<td>&nbsp;&nbsp;&nbsp;</td>';
      echo '<td align="center"><input type="password" name="zarafapass" value=""/></td>';
      echo '</tr>';
      echo '<tr>';
      echo '<td align="right"><label>Dry Run<input type="checkbox" class="dryrun" name="dryrun" checked="" value="--dry"/></label></td>';
      echo '<td colspan="3" align="center"><input type="submit" name="submit" value="Migrate Folders"/></td>';
      echo '</tr>';
      echo '</table>';
      echo '</form>';
      break;
   case 'execute':
	echo '<body>';   
      echo '<div class="imapfolders-div">';
	$output = shell_exec("sudo /opt/opw/imapfolders.sh --dominouser \"$dominouser\" --zarafauser \"$zarafauser\" --dominopass \"$dominopass\" --zarafapass \"$zarafapass\" --force $dryrun");
      echo "<pre>$output</pre></div>";    
      echo '<form method="get"><div align="center"><input type="submit" name="submit" value="Start Over"/></div></form>';
      break;
   default:
		echo '<body onload="document.getElementById("startfocus").focus();">';   
      echo '<form method="get">';
      echo '<input type="hidden" name="page" value="verify"/>';
      echo '<table align="center" valign="middle">';
      echo '<tr>';
      echo '<th>&nbsp;</th>';
      echo '<th align="center">Domino Information</th>';
      echo '<th>&nbsp;&nbsp;&nbsp;</th>';
      echo '<th align="center">Zarafa Information</th>';
      echo '</tr>';
      echo '<tr>';
      echo '<th align="right">User</th>';
      echo '<td align="center"><input type="text" id="startfocus" name="dominouser" value="',$dominouser,'"/></td>';
      echo '<td>&nbsp;&rarr;&nbsp;</td>';
      echo '<td align="center"><input type="text" name="zarafauser" value="',$zarafauser,'"/></td>';
      echo '</tr>';
      echo '<tr>';
      echo '<td>&nbsp;</td>';
      echo '<td colspan="3" align="center"><input type="submit" name="submit" value="Verify Names"/></td>';
      echo '</tr>';
      echo '</table>';
      echo '</form>';
      break;      
}
echo '</body></html>';
?>








