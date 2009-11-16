<?php include_once "config.php"; $page = init($_GET ['page']); ;
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>iDM &#187; SwiftIRC DMing Bot</title>
<link rel="stylesheet" type="text/css" href="/main.css" />
</head>

<body>
<div id="header"><img src="/img/header.gif" alt="header" /></div>
<div id="container">
<div id="sidebar">
<div class="header">Navigation</div>
<ul>
	<li><a href="/">Home</a></li>
	<li><a href="http://forum.idm-bot.com">Forums</a></li>
	<li><a href="http://forum.idm-bot.com/viewtopic.php?f=4&amp;t=4">Rules</a></li>
	<li><a href="http://forum.idm-bot.com/viewtopic.php?f=7&amp;t=5">Commands</a></li>
	<li><a href="/dmstats/">Channel Stats</a></li>
	<li><a href="/drops/">Drop Stats</a></li>
	<li><a href="/hiscores/">Hiscores</a></li>
	<li><a href="/sitems/">Admin Items</a></li>
	<li><a href="/u/">User</a></li>
</ul>
<div class="header">Quick Stats</div>
<div style="padding: 5px;"><? displayQuickStats()?></div>
</div>
<div id="content">
<div style="padding: 10px;"><? displayContent($page)?></div>
</div>
</div>
</body>
</html>
