<?php
/*
 *    Zarafa Perform Action form
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

$action = "";
if (isset($_GET['action']))    $action = $_GET['action'];
if (isset($_POST['action']))   $action = $_POST['action'];

$execute = "no";
if (isset($_GET['execute']))    $execute = $_GET['execute'];
if (isset($_POST['execute']))   $execute = $_POST['execute'];

$username = "";
if (isset($_GET['username']))    $username = $_GET['username'];
if (isset($_POST['username']))   $username = $_POST['username'];

$fullname = "";
if (isset($_GET['fullname']))    $fullname = $_GET['fullname'];
if (isset($_POST['fullname']))   $fullname = $_POST['fullname'];

$email = "";
if (isset($_GET['email']))    $email = $_GET['email'];
if (isset($_POST['email']))   $email = $_POST['email'];

$mode = "";
if (isset($_GET['mode']))    $mode = $_GET['mode'];
if (isset($_POST['mode']))   $mode = $_POST['mode'];

$from = "";
if (isset($_GET['from']))    $from = $_GET['from'];
if (isset($_POST['from']))   $from = $_POST['from'];

$until = "";
if (isset($_GET['until']))    $until = $_GET['until'];
if (isset($_POST['until']))   $until = $_POST['until'];

$subject = "";
if (isset($_GET['subject']))    $subject = $_GET['subject'];
if (isset($_POST['subject']))   $subject = $_POST['subject'];

$message = "";
if (isset($_GET['message']))    $message = $_GET['message'];
if (isset($_POST['message']))   $message = $_POST['message'];

$referer = "";
if (isset($_GET['referer']))    $referer = $_GET['referer'];
if (isset($_POST['referer']))   $referer = $_POST['referer'];

switch ($action) {
  case "ooo":
  	if ($mode == "1") {
    	$title = "Enable Out of Office";
    } else {
    	$title = "Disable Out of Office";
    }
    break;
  case label2:
    code to be executed if n=label2;
    break;
} 

?>
<html><head>
	<meta http-equiv="content-type" content="text/html; charset=UTF-8">
	<meta http-equiv="Content-Type" charset="utf-8">
	<link rel="stylesheet" href="zarafaadmin.css">
	<title><?=$title?></title>
</head>
<body>

<p class="action-title"><?=$title?> for <?=$fullname?> (<?=$email?>)</p>

</body></html>
