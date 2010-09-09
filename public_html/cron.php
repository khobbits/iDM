<?php
$time0 = microtime(true);
include_once 'includes/config.php';
include_once 'includes/cronarchive.php';
include_once 'includes/cronban.php';
include_once 'includes/croncleanup.php';
init(1);

// Archive player data
archive_loot_player();
echo '<br /><br />';
archive_user_log();
echo '<br /><br />';
archive_user_log_total();
echo '<br /><br />';

// Remove bans that have expired
delete_ban_user();
echo '<br /><br />';
delete_ban_chan();
echo '<br /><br />';

// Cleanup tables
cleanup_urlmap();
echo '<br /><br />';
cleanup_chanlog();
echo '<br /><br />';

$time1 = microtime(true) - $time0;
echo "Scripts executed in $time1 seconds\n<br /><br />";

cleanup_optimize();
echo '<br /><br />';

mysql_close();
?>