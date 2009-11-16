<table width="100%"><tr><td width="80%">
<h1>Overall DM Stats</h1>

<?php
$date = date('Y/m/d');

$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(cash)` DESC";
$result = mysql_query($query);

$tMoney = mysql_result($result, 0, "SUM(cash)");
$tDM = mysql_result($result, 0, "SUM(count)");
$average = round($tMoney / $tDM);

print '<h2><strong>Total DMs:</strong> ' . number_format($tDM) . ' <strong>Total Cash:</strong> ' . n2a($tMoney) . ' <strong>Average:</strong> ' . n2a($average) . '</h2>';
?>

<table width="100%" align="center">
<tr><td>Top 10 Channels (Money)</td><td>Top 10 Channels (DMs)</td><td>Top 10 Bots (Money)</td><td>Top 10 Bots (DMs)</td></tr>
<tr><td>

<?php
for ($a = 1; $a < 11; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	print '<li title="' . $money . '">' . $chan . '</li>';
}

print '</td><td>';

$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(count)` DESC";
$result = mysql_query($query);

for ($a = 1; $a < 11; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$count = number_format(mysql_result($result, $a, "SUM(count)"));
	print '<li title="' . $count . '">' . $chan . '</li>';
}

print '</td><td>';

$query = "SELECT * FROM loot_player_bot ORDER BY `loot_player_bot`.`SUM(cash)` DESC";
$result = mysql_query($query);

for ($a = 1; $a < 11; $a++) {
	$bot = mysql_result($result, $a, "bot");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	print '<li title="' . $money . '">' . $bot . '</li>';
}

print '</td><td>';

$query = "SELECT * FROM loot_player_bot ORDER BY `loot_player_bot`.`SUM(count)` DESC";
$result = mysql_query($query);

for ($a = 1; $a < 11; $a++) {
	$bot = mysql_result($result, $a, "bot");
	$count = number_format(mysql_result($result, $a, "SUM(count)"));
	print '<li title="' . $count . '">' . $bot . '</li>';
}

print '</td></tr></table>';

print '<h1>Daily DM Stats (Last ' . date("G:i") . ')</h1>';

$query = "SELECT * FROM loot_player_date WHERE date='$date'";
$result = mysql_query($query);

$tMoney = mysql_result($result, 0, "SUM(cash)");
$tDM = mysql_result($result, 0, "SUM(count)");
$average = round($tMoney / $tDM);

print '<h2><strong>Total DMs:</strong> ' . number_format($tDM) . ' <strong>Total Cash:</strong> ' . n2a($tMoney) . ' <strong>Average:</strong> ' . n2a($average) . '</h2>';
?>

<table width="100%" align="center">
<tr><td>Top 10 Channels (Money)</td><td>Top 10 Channels (DMs)</td><td>Top 10 Bots (Money)</td><td>Top 10 Bots (DMs)</td></tr>
<tr><td>

<?php
$query = "SELECT * FROM loot_player_chan_date WHERE date='$date' ORDER BY `loot_player_chan_date`.`SUM(cash)` DESC";
$result = mysql_query($query);
$num = mysql_num_rows($result);
if ($num < 10)
	$max = $num;
else
	$max = "10";

for ($a = 0; $a < $max; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	print '<li title="' . $money . '">' . $chan . '</li>';
}

print '</td><td>';

$query = "SELECT * FROM loot_player_chan_date WHERE date='$date' ORDER BY `loot_player_chan_date`.`SUM(count)` DESC";
$result = mysql_query($query);
$num = mysql_num_rows($result);
if ($num < 10)
	$max = $num;
else
	$max = "10";

for ($a = 0; $a < $max; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$count = number_format(mysql_result($result, $a, "SUM(count)"));
	print '<li title="' . $count . '">' . $chan . '</li>';
}

print '</td><td>';

$query = "SELECT * FROM loot_player_bot_date WHERE date='$date' ORDER BY `loot_player_bot_date`.`SUM(cash)` DESC";
$result = mysql_query($query);
$num = mysql_num_rows($result);
if ($num < 10)
	$max = $num;
else
	$max = "10";

for ($a = 0; $a < $max; $a++) {
	$bot = mysql_result($result, $a, "bot");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	print '<li title="' . $money . '">' . $bot . '</li>';
}

print '</td><td>';

$query = "SELECT * FROM loot_player_bot_date WHERE date='$date' ORDER BY `loot_player_bot_date`.`SUM(count)` DESC";
$result = mysql_query($query);
$num = mysql_num_rows($result);
if ($num < 10)
	$max = $num;
else
	$max = "10";

for ($a = 0; $a < $max; $a++) {
	$bot = mysql_result($result, $a, "bot");
	$count = number_format(mysql_result($result, $a, "SUM(count)"));
	print '<li title="' . $count . '">' . $bot . '</li>';
}

print '</td></tr></table>';

?>