<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
		<meta http-equiv="Content-Type" charset="utf-8"/>
		<link rel="stylesheet" href="zarafaadmin.css"/>
		<title>Zarafa Administration</title>
	</head>
	<body>
		<div id="header" style="background: url(&quot;/images/header-line.gif&quot;) repeat-x scroll left top black;">
  			<div class="panel" style="background: url(&quot;/images/header-backgnd.gif&quot;) no-repeat scroll 0% 0% transparent;">
    			<div class="title1">Zarafa Admin</div>
    			<div class="title2">Office of Public Works - Zarafa Administration</b></div>
    			<div class="opwlogo"></div>
  			</div>
		</div>
		<table class="CmdTable">
			<tr>
				<td class="ColumnHead" nowrap="nowrap" align="left">&nbsp;&nbsp;Commands</td>
 				<td class="ColumnHead" nowrap="nowrap" align="right">&nbsp;Logged in as <?=strtolower( $_SERVER['PHP_AUTH_USER'] )?>&nbsp;
				<a href="https://logout:logout@<?=$_SERVER['HTTP_HOST']?>/">Logout</a>&nbsp;</td>
			</tr>
			<tr>
				<td class="Commands">
					<p></p>
					<p>&nbsp;Zarafa Management
					<ul>
						<li><a href="./zarafa-users.php" target="cmdiframe">Zarafa Users</a></li>
						<li><a href="./zarafa-groups.php" target="cmdiframe">Zarafa Groups</a></li>
						<li><a href="./zarafa-mdm.php" target="cmdiframe">Zarafa Devices</a></li>						
						<li><a href="./zarafa-system.php" target="cmdiframe">Zarafa System</a></li>
						<li><a href="./zarafa-session.php" target="cmdiframe">Zarafa Session</a></li>
					</ul></p>
					<p>&nbsp;Zarafa Logs
					<ul>
						<li><a href="./zarafa-logins.php" target="cmdiframe">Login Errors</a></li>
						<li><a href="./zarafa-errors.php?log=system" target="cmdiframe">System Errors</a></li>
						<li><a href="./zarafa-errors.php?log=mysql" target="cmdiframe">MySQL Errors</a></li>
						<li><a href="./zarafa-errors.php?log=z-push" target="cmdiframe">Z-Push Errors</a></li>						
					</ul></p>
				</td>
				<td class="Results">
					<iframe class="iFrameResult" src="blank.html" name="cmdiframe">Browser not compatible.</iframe>
				</td>
			</tr>
		</table>
	</body>
</html>
