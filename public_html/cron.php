<?php

include_once 'includes/config.php';
include_once 'includes/cronarchive.php';
include_once 'includes/cronban.php';
init(1);

// Archive player data
archive_loot_player();
echo '<br /><br />';
archive_user_log();
echo '<br /><br />';
archive_user_log_total();
echo '<br /><br />';

// Remove old sessions keys from urlmap
$sql = "DELETE FROM urlmap WHERE `time` <= DATE_sub(now(), interval 12 hour)";
mysql_query($sql);
echo '<br /><br />';

// Remove bans that have expired
delete_ban_user();
echo '<br /><br />';
delete_ban_chan();
echo '<br /><br />';


mysql_close();
?>