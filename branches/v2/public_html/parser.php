<?PHP

// Setting up color functions
function c1($text) {
	return "\00307$text\003";
}

function c2($text) {
	return "\00303$text\003";
}

function logo($text) {
	return c1("[") . c2($text) . c1("]");
}

function logo2($text) {
	return c1(" (") . c2($text) . c1(")");
}

// Setting up global vars
$ptype = $_GET ['type'];
$date = date('Y/m/d');
$overall = array ();
$daily = array ();

// including config.php (contains functions and sql infomation)
include_once ("includes/config.php");
init(1);

if ($ptype == "chan") {
	if (isset($_GET ['c'])) {

		$channel = mysql_real_escape_string($_GET ['c']);
		$query = "SELECT * FROM loot_player_chan WHERE chan='$channel'";
		$result = mysql_query($query);

		if (mysql_num_rows($result)) {
			$overall ['cash'] = n2a(mysql_result($result, 0, "SUM(cash)"));
			$overall ['count'] = number_format(mysql_result($result, 0, "SUM(count)"));

			$query = "SELECT COUNT(*)-1 AS Rank
						FROM loot_player_chan r1
						INNER JOIN (loot_player_chan r2)
						ON (r1.`SUM(cash)` <= r2.`SUM(cash)`)
						WHERE r1.`chan` = '$channel'";

			$result = mysql_query($query);
			$array = mysql_fetch_assoc($result);

			$overall ['rank_money'] = $array ["Rank"];

			$query = "SELECT COUNT(*)-1 AS Rank
						FROM loot_player_chan r1
						INNER JOIN (loot_player_chan r2)
						ON (r1.`SUM(count)` <= r2.`SUM(count)`)
						WHERE r1.`chan` = '$channel'";

			$result = mysql_query($query);
			$array = mysql_fetch_assoc($result);

			$overall ['rank_dm'] = $array ["Rank"];

			echo logo("$channel Stats") . " Overall Rank (Money): " . c1($overall ['rank_money']) . " Overall Rank (DMs): " . c1($overall ['rank_dm']) . " Cash made: " . c1($overall ['cash']) . " DM Count: " . c1($overall ['count']) . "\n";
		} else
			echo logo("ERROR") . " Overall stats data is missing for $channel.\n";

		$query = "SELECT * FROM loot_player_chan_date WHERE chan='$channel' AND date='$date'";
		$result = mysql_query($query);

		if (mysql_num_rows($result)) {
			$daily ['cash'] = n2a(mysql_result($result, 0, "SUM(cash)"));
			$daily ['count'] = number_format(mysql_result($result, 0, "SUM(count)"));

			$query = "SELECT COUNT(*) AS Rank
						FROM loot_player_chan_date r1
						INNER JOIN (loot_player_chan_date r2)
						ON (r1.`SUM(cash)` <= r2.`SUM(cash)` AND  r2.`date` = '$date')
						WHERE r1.`chan` = '$channel' AND r1.`date` = '$date'";

			if (!($result = mysql_query($query))) die(mysql_error());
			$array = mysql_fetch_assoc($result);

			$daily ['rank_money'] = $array ["Rank"];

			$query = "SELECT COUNT(*) AS Rank
						FROM loot_player_chan_date r1
						INNER JOIN (loot_player_chan_date r2)
						ON (r1.`SUM(count)` <= r2.`SUM(count)` AND  r2.`date` = '$date')
						WHERE r1.`chan` = '$channel' AND r1.`date` = '$date'";

			if (!($result = mysql_query($query))) die(mysql_error());
			$array = mysql_fetch_assoc($result);

			$daily ['rank_dm'] = $array ["Rank"];

			echo logo("$channel Stats") . " Daily Rank (Money): " . c1($daily ['rank_money']) . " Daily Rank (DMs): " . c1($daily ['rank_dm']) . " Cash made: " . c1($daily ['cash']) . " DM Count: " . c1($daily ['count']);
		} else
			echo logo("ERROR") . " Daily stats data is missing for $channel.";

	} else {
		die("You have not entered a channel to look up");
	}
} else if ($ptype == "dailyt5") {
	$query = "SELECT * FROM loot_player_chan_date WHERE date='$date' ORDER BY `loot_player_chan_date`.`SUM(cash)` DESC";
	$result = mysql_query($query);

	echo logo("Daily Top 10 (Money)") . " ";

	for ($a = 0; $a < 10; $a++) {
		$chan = mysql_result($result, $a, "chan");
		$cash = n2a(mysql_result($result, $a, "SUM(cash)"));
		if ($a != "9")
			echo ($a + 1) . ") " . $chan . logo2($cash) . " | ";
		else
			echo ($a + 1) . ") " . $chan . logo2($cash);
	}

	$query = "SELECT * FROM loot_player_chan_date WHERE date='$date' ORDER BY `loot_player_chan_date`.`SUM(count)` DESC";
	$result = mysql_query($query);
	$num = mysql_num_rows($result);
	if ($num < 10)
		$max = $num;
	else
		$max = "10";

	echo "\n" . logo("Daily Top 10 (DMs)") . " ";

	for ($a = 0; $a < $max; $a++) {
		$chan = mysql_result($result, $a, "chan");
		$count = number_format(mysql_result($result, $a, "SUM(count)"));
		if ($a != "9")
			echo ($a + 1) . ") " . $chan . logo2($count) . " | ";
		else
			echo ($a + 1) . ") " . $chan . logo2($count);
	}
} else if ($ptype == "overallt5") {
	$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(cash)` DESC";
	$result = mysql_query($query);

	echo logo("Overall Top 10 (Money)") . " ";

	for ($a = 1; $a < 11; $a++) {
		$chan = mysql_result($result, $a, "chan");
		$money = n2a(mysql_result($result, $a, "SUM(cash)"));
		if ($a != "10")
			echo $a . ") " . $chan . logo2($money) . " | ";
		else
			echo $a . ") " . $chan . logo2($money);
	}

	$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(count)` DESC";
	$result = mysql_query($query);

	echo "\n" . logo("Overall Top 10 (DMs)") . " ";

	for ($a = 1; $a < 11; $a++) {
		$chan = mysql_result($result, $a, "chan");
		$count = number_format(mysql_result($result, $a, "SUM(count)"));
		if ($a != "10")
			echo $a . ") " . $chan . logo2($count) . " | ";
		else
			echo $a . ") " . $chan . logo2($count);
	}
} else if ($ptype == "drops") {
	$query = "SELECT * FROM loot_item ORDER BY count DESC";
	$result = mysql_query($query);

	echo logo("Common Drops") . " ";

	for ($a = 0; $a < 15; $a++) {
		$item = mysql_result($result, $a, "item");
		$count = number_format(mysql_result($result, $a, "count"));
		if ($a == "8") echo "\n" . logo("Common Drops") . " ";
		if ($a != "7" && $a != "14")
			echo ($a + 1) . ") " . $item . logo2($count) . " | ";
		else
			echo ($a + 1) . ") " . $item . logo2($count);
	}
} else {
	die("You have not entered a lookup type");
}
?>
