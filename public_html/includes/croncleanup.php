<?php

// Remove old sessions keys from urlmap
function cleanup_urlmap () {
  $sql = "DELETE FROM urlmap WHERE `time` <= DATE_sub(now(), interval 12 hour)";
 if (!mysql_query($sql)) die('Unable to remove expired urls: ' . mysql_error());
    echo mysql_affected_rows() . ' records have been successfully deleted from urlmap';
    return;
}


// Remove channel logs older than 24 hours
function cleanup_chanlog () {
  $date = time() - (24 * 60 * 60);
  $sql = "DELETE FROM chan_log WHERE `date` <= '$date'";
 if (!mysql_query($sql)) die('Unable to remove old channel logs: ' . mysql_error());
    echo mysql_affected_rows() . ' records have been successfully deleted from chan_log';
    return;
}

//Optimize tables
function cleanup_optimize () {
$time0 = microtime(true);
 $sql = "OPTIMIZE TABLE `achievements` , `admins` , `appeal` , `blist` , `chan_log` , `clantracker`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());
 $sql = "OPTIMIZE TABLE `equip_armour` , `equip_item` , `equip_pvp` , `equip_staff` , `ilist`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());
 $sql = "OPTIMIZE TABLE `loot_item` , `loot_player` , `loot_week_bot` , `loot_week_chan`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());
 $sql = "OPTIMIZE TABLE `settings` , `urlmap` , `user`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());
 $sql = "OPTIMIZE TABLE `user_log`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());
 $sql = "OPTIMIZE TABLE `user_log_archive`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());
 $sql = "OPTIMIZE TABLE `user_log_total`";
 if (!mysql_query($sql)) die('Unable to optimize tables: ' . mysql_error());

 $time = microtime(true) - $time0;
 echo "Tables Optimized in $time seconds";
 return;
}

?>