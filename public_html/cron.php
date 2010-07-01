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

mysql_close();
?>