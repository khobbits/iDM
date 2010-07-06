<table width="95%"><tr><td>
<h1>Overall DM Stats</h1>
<?php

$date = date('Y/m/d');

$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(cash)` DESC";
$result = mysql_query($query);

$tMoney = mysql_result($result, 0, "SUM(cash)");
$tDM = mysql_result($result, 0, "SUM(count)");
$average = round($tMoney / $tDM);

print '<h3><strong>Total DMs:</strong> ' . number_format($tDM) . ' <strong>Total Cash:</strong> <abbr title="'. number_format($tMoney) .'">' . n2a($tMoney) .
'</abbr> <strong>Average:</strong> <abbr title="'. number_format($average) .'">' . n2a($average) . '</abbr></h3>';
?>

<table class="table-stats">
<tr><th>Top 10 Channels (Money)</th><th>Top 10 Channels (DMs)</th><th>Top 10 Bots (Money)</th><th>Top 10 Bots (DMs)</th></tr>
<tr><td><ul>

<?php
for ($a = 1; $a < 11; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	print '<li title="' . $money . '">' . $chan . '</li>';
}
?>
</ul></td><td><ul>
<?
$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(count)` DESC";
$result = mysql_query($query);

for ($a = 1; $a < 11; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$count = number_format(mysql_result($result, $a, "SUM(count)"));
	print '<li title="' . $count . '">' . $chan . '</li>';
}
?>
</ul></td><td><ul>
<?
$query = "SELECT * FROM loot_player_bot ORDER BY `loot_player_bot`.`SUM(cash)` DESC";
$result = mysql_query($query);

for ($a = 1; $a < 11; $a++) {
	$bot = mysql_result($result, $a, "bot");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	print '<li title="' . $money . '">' . $bot . '</li>';
}
?>
</ul></td><td><ul>
<?
$query = "SELECT * FROM loot_player_bot ORDER BY `loot_player_bot`.`SUM(count)` DESC";
$result = mysql_query($query);

for ($a = 1; $a < 11; $a++) {
	$bot = mysql_result($result, $a, "bot");
	$count = number_format(mysql_result($result, $a, "SUM(count)"));
	print '<li title="' . $count . '">' . $bot . '</li>';
}

?>
</ul></td></tr></table>

<?

print '<h1>Daily DM Stats (Last ' . date("G:i") . ')</h1>';

$query = "SELECT * FROM loot_player_date WHERE date='$date'";
$result = mysql_query($query);

$tMoney = mysql_result($result, 0, "SUM(cash)");
$tDM = mysql_result($result, 0, "SUM(count)");
$average = round($tMoney / $tDM);

print '<h3><strong>Total DMs:</strong> ' . number_format($tDM) . ' <strong>Total Cash:</strong> ' . n2a($tMoney) . ' <strong>Average:</strong> ' . n2a($average) . '</h3>';
?>

<table class="table-stats">
<tr><th>Top 10 Channels (Money)</th><th>Top 10 Channels (DMs)</th><th>Top 10 Bots (Money)</th><th>Top 10 Bots (DMs)</th></tr>
<tr><td><ul>

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
?>
</ul></td><td><ul>
<?
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
?>
</ul></td><td><ul>
<?
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
?>
</ul></td><td><ul>
<?
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

?>
</ul></td></tr></table>
</td>
</tr>
</table>
