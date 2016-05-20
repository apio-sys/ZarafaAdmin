<?php
/*
 *    Zarafa Orphaned Stores
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

$user = "";
if (isset($_GET['user']))    $user = $_GET['user'];
if (isset($_POST['user']))   $user = $_POST['user'];

echo '<html><head>';
echo '<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
echo '<meta http-equiv="Content-Type" charset="utf-8">';
echo '<link rel="stylesheet" href="zarafaadmin.css">';
echo '<title>Zarafa (Un)Set Out of Office</title>';
?>




<table>
	<tr>
		<td colspan="5" align="center">Set/Unset Out-of-Office for FullName (emailaddress)</td>
	</tr>
	<tr>
		<td>
			<select name="mode">
			  <option value="0">Disable Out-of-Office</option>
			  <option value="1"> Enable Out-of-Office</option>
			</select>
		</td>
		<td align="right">From:</td>
		<td><input type="date" name="from"/></td>
		<td align="right">Until:</td>
		<td><input type="date" name="until"/></td>
	</tr>
	<tr>
		<td align="right">Subject:</td>
		<td colspan="4"><input type="text" name="subject" width="100%"/></td>
	</tr>
	<tr>
		<td colspan="5" align="left">AutoReply only once to each sender with the following text:</td>
	</tr>
	<tr>
		<td colspan="5"><textarea rows="4" cols="50" name="message" width="100%"/></td>
	</tr>
</table>



</body></html>














