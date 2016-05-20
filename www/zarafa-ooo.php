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


<input type="date" />
<p>
Usage: /usr/bin/zarafa-set-oof -u [username of mailbox]

Manage out of office messages of users

Required arguments:
	-u, --user          user to set out of office message for
	-m, --mode          0 to disable out of office (default), 1 to enable

optional arguments:
	--from              specify the date/time when oof should become active
	--until             specify the date/time when oof should become inactive again
	-t, --subject       specify the subject to be set in oof message
	-n, --message       text file containing body of out of office message
	-h, --host          Host to connect with. Default: file:///var/run/zarafa
	-s, --sslkey-file   SSL key file to authenticate as admin.
	-p, --sslkey-pass   Password for the SSL key file.
	--help              Show this help message and exit.
</p>
<table>
	<tr>
		<td colspan="5" align="center">Set/Unset Out-of-Office for FullName (emailaddress)</td>
	</tr>
	<tr>
		<td>
			<select name="mode">
			  <option value="volvo">Set Out-of-Office</option>
			  <option value="saab">Unset Out-of-Office</option>
			</select>
		</td>
		<td>From:</td>
		<td><input type="text" name="from"/></td>
		<td>Until:</td>
		<td><input type="text" name="until"/></td>
	</tr>
	<tr>
		<td>Subject:</td>
		<td colspan="4"><input type="text" name="subject"/></td>
	</tr>
	<tr>
		<td colspan="5">AutoReply only once to each sender with the following text:</td>
	</tr>
	<tr>
		<td colspan="5"><input type="text" name="message"/></td>
	</tr>
</table>



</body></html>














