<?php

include_once 'config.php';
init(1);

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
	die('Database has already been updated for week beginning: ' . $start_date);
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

mysql_close();
?>