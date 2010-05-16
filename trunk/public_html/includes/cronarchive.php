<?php

// Code to archive items in loot_player to loot_week_chan and loot_week_bot
function archive_loot_player () {
    if (isset($_GET ['offset']) && is_numeric($_GET ['offset'])) {
    	$offset = (int)$_GET ['offset'];
    } else {
    	die('Offset needs to be numeric: ' . $_GET ['offset']);
    }

    // Define the date range
    $end_date = date('Y-m-d', strtotime('last Sunday -' . $offset . ' weeks'));
    $start_date = date('Y-m-d', strtotime('last Sunday -' . (1 + $offset) . ' weeks'));

    // Check to see if date has already been run
    $sql = "SELECT * FROM `loot_week_bot` WHERE date = '$start_date'";
    if (mysql_num_rows(mysql_query($sql))) {
    	echo 'Database has already been updated for week beginning: ' . $start_date;
    	return;
    }

    // Define the sql to update the tables
    $sql = "INSERT INTO `loot_week_chan`
       			SELECT chan, sum(cash), '$start_date', sum(count)
       			FROM `loot_player`
    			WHERE date >= '$start_date' AND date <= '$end_date'
       			GROUP BY chan";
    if (!mysql_query($sql)) die('Unable to insert records: ' . mysql_error());

    $sql = "INSERT INTO `loot_week_bot`
    			SELECT sum(cash), bot, '$start_date', sum(count)
    			FROM `loot_player`
    			WHERE date >= '$start_date' AND date <= '$end_date'
       			GROUP BY bot";

    if (!mysql_query($sql)) die('Unable to insert records: ' . mysql_error());

    // Remove the old entries from the table
    $sql = "DELETE FROM `loot_player`
    		WHERE date >= '$start_date'
    			AND date <= '$end_date'";
    if (!mysql_query($sql)) die('Unable to remove old records: ' . mysql_error());
    echo mysql_affected_rows() . ' records have been successfully archived';
    return;
}

// Code to archive items in user_log into user_archive
function archive_user_log () {

    // Define the date range
    $end_date = strtotime('midnight');

    // Define the sql to update the tables
    $sql = "INSERT INTO `user_log_archive`
       			SELECT *
       			FROM `user_log`
    			WHERE `date` <= '$end_date'";
    if (!mysql_query($sql)) die('Unable to insert records: ' . mysql_error());

    // Remove the old entries from the table
    $sql = "DELETE FROM `user_log`
    		WHERE date <= '$end_date'";
    if (!mysql_query($sql)) die('Unable to remove old records: ' . mysql_error());
    echo mysql_affected_rows() . ' records have been successfully archived to user_log_archive';
    return;
}

// Code to archive items in user_archive into user_total
function archive_user_log_total () {

    // Define the date range
    $end_date = strtotime('-1 month', strtotime(date('F')."1"));

    // Define the sql to update the tables
    $sql = "INSERT INTO `user_log_total`
							(SELECT user, (SUM(IF(type=1, 1, 0)) + SUM(IF(type=3, 1, 0))) AS wins,
								(SUM(IF(type=2, 1, 0)) + SUM(IF(type=4, 1, 0))) AS losses,
								(SUM(IF(type=3, data, 0)) - SUM(IF(type=4, data, 0)) +
									SUM(IF(type=5, IF(LOCATE(' gp', data), SUBSTRING_INDEX(data, ' gp', 1), 0), 0)) -
									SUM(IF(type=8, data, 0)) + SUM(IF(type=9, data, 0))
								) AS money
							FROM `user_log_archive`
							WHERE `date` <= '$end_date'
							GROUP BY user)";
    if (!mysql_query($sql)) die('Unable to insert records: ' . mysql_error());

    // Remove the old entries from the table
    $sql = "DELETE FROM `user_log_archive`
    		WHERE date <= '$end_date'";
    if (!mysql_query($sql)) die('Unable to remove old records: ' . mysql_error());
    echo mysql_affected_rows() . ' records have been successfully archived to user_log_total';
    return;
}
?>