<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
		<meta http-equiv="Content-Type" charset="utf-8"/>
		<link rel="stylesheet" href="kopanoadmin.css"/>
		<title>Kopano Administration</title>
	</head>
	<body>
		<div id="frame-wrapper">
		<div id="frame-header">
  			<div id="header-panel">
    			<div id="header-title1">Kopano Admin</div>
    			<div id="header-title2">Office of Public Works - Kopano Administration</b></div>
    			<div id="header-opwlogo"></div>
  			</div>
		</div>
		<table id="frame-table">
			<tr>
 				<td id="table-header">&nbsp;&nbsp;Commands</td>
 				<td id="table-user" align="right">&nbsp;Logged in as <?=strtolower( $_SERVER['PHP_AUTH_USER'] )?>
				&nbsp;<a href="https://logout:logout@<?=$_SERVER['HTTP_HOST']?>/">Logout</a>&nbsp;&nbsp;</td>
			</tr>
			<tr>
				<td id="table-commands">
					<p></p>
					<p>&nbsp;Kopano Management
					<ul>
						<li><a href="./kopano-users.php" target="cmdiframe">Kopano Users</a></li>
						<li><a href="./kopano-groups.php" target="cmdiframe">Kopano Groups</a></li>
						<li><a href="./kopano-mdm.php" target="cmdiframe">Kopano Devices</a></li>						
						<li><a href="./kopano-system.php" target="cmdiframe">Kopano System</a></li>
						<li><a href="./kopano-session.php" target="cmdiframe">Kopano Session</a></li>
						<li><a href="./kopano-license.php" target="cmdiframe">Kopano License</a></li>
					</ul></p>
					<p>&nbsp;Kopano Logs
					<ul>
						<li><a href="./kopano-logins.php" target="cmdiframe">Login Errors</a></li>
						<li><a href="./kopano-errors.php?log=system" target="cmdiframe">System Log</a></li>
						<li><a href="./kopano-errors.php?log=mysql" target="cmdiframe">MySQL Log</a></li>
						<li><a href="./kopano-errors.php?log=z-push" target="cmdiframe">Z-Push Log</a></li>						
						<li><a href="./kopano-errors.php?log=mail" target="cmdiframe">Mail Log</a></li>						
					</ul></p>					
					<p>&nbsp;Email Addresses
					<ul>
						<li><a href="./kopano-emails.php" target="cmdiframe">OPW Emails</a></li>					
					</ul></p>
					<p>&nbsp;Mail Stores
					<ul>
						<li><a href="./kopano-orphans.php" target="cmdiframe">Orphaned Stores</a></li>					
					</ul></p>
					<p>&nbsp;External Sites
					<ul>
						<li><a href="/dashboard/" target="cmdiframe">OPW Dashboard</a></li>
						<li><a href="https://graf.kopano.io" target="cmdiframe">Kopano Dashboard</a></li>
					</ul></p>					
				</td>
				<td id="table-results">
					<iframe id="cmdiframe" src="blank.html" name="cmdiframe">Browser not compatible.</iframe>
				</td>
			</tr>
		</table>
		</div>
	</body>
</html>
