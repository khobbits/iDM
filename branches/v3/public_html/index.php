<?php include_once "includes/config.php"; $page = init($_GET ['page']);
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>iDM &#187; SwiftIRC DMing Bot</title>
<link rel="stylesheet" type="text/css" href="/css/main.css" />
<link type="text/css" href="/css/custom-theme/jquery-ui-1.8.2.custom.css" rel="Stylesheet" />
<link type="text/css" href="/css/table_jui.css" rel="Stylesheet" />

<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.2/jquery-ui.min.js"></script>
<script type="text/javascript">
if (typeof jQuery == 'undefined')
{
    document.write(unescape("%3Cscript src='/js/jquery-1.4.2.min.js' type='text/javascript'%3E%3C/script%3E"));
    document.write(unescape("%3Cscript src='/js/jquery-ui-1.8.2.custom.min.js' type='text/javascript'%3E%3C/script%3E"));
}
</script>
<script type="text/javascript" src="/js/jquery.dataTables.min.js"></script>
</head>
<body>
<div id="header"><img src="/img/header.png" alt="iDM-Bot" /></div>
<div id="container">
  <div id="sidebar">
    <div class="header">Navigation</div>
    <ul>
    	<li><a href="/">Home</a></li>
    	<li><a href="http://forum.idm-bot.com">Forums</a></li>
    	<li><a href="http://forum.idm-bot.com/viewtopic.php?f=4&amp;t=4">Rules</a></li>
    	<li><a href="http://forum.idm-bot.com/viewtopic.php?f=7&amp;t=5">Commands</a></li>
    	<li><a href="/sitems/">Staff Items</a></li>
    </ul>
    <div class="header">Bot Stats</div>
    <ul>
    	<li><a href="/dmstats/">DM Statistics</a></li>
    	<li><a href="/drops/">Dropped Loot</a></li>
    	<li><a href="/userstats/">User and Equipment</a></li>
    	<li><a href="/hiscores/">Hiscore Lists</a></li>
    </ul>
    <div class="header">Lookups</div>
    <ul>
    	<li><a href="/u/">User</a></li>
    	<li><a href="/c/">Clan</a></li>
    </ul>
    <div class="headerend">&nbsp;</div>
    <div><? displayQuickStats()?></div>
  </div> <!-- End Sidebar -->
  <div id="content">
    <div style="padding: 10px;"><? displayContent($page)?></div>
  </div>  <!-- End Content -->
</div>  <!-- End Container -->
<p align="center">&copy; 2008-2010 KHobbits - The website and the implementation of the 
concept described within are copyright to KHobbits and the iDM 
Group.</p>
</body>
</html>
