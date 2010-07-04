<?php

include_once 'includes/config.php';
include_once 'includes/cronarchive.php';
init(1);

archive_loot_player();
echo '<br /><br />';
archive_user_log();
echo '<br /><br />';
archive_user_log_total();
echo '<br /><br />';

// Define the date range
$end_date = strtotime('-1 day');

// Remove day-old sessions keys from urlmap
//$sql = "DELETE FROM urlmap WHERE `time` <= '$end_date'";
//mysql_query($sql);

mysql_close();
?>