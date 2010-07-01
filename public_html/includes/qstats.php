<?PHP
$query = "SELECT * FROM loot_player_chan ORDER BY `loot_player_chan`.`SUM(cash)` DESC";
$result = mysql_query($query);

$tMoney = n2a(mysql_result($result, 0, "SUM(cash)"));
$tMoneyFull = number_format(mysql_result($result, 0, "SUM(cash)"));
$tDM = number_format(mysql_result($result, 0, "SUM(count)"));

print '<p>
        <strong>Total DMs:</strong> ' . $tDM . '<br />
        <strong>Total Cash:</strong> <abbr title="' . $tMoneyFull . ' ">' . $tMoney . '</abbr>
    </p>';

print '<p><strong>Top 5 Channels:</strong></p><ul>';

for ($a = 1; $a < 6; $a++) {
	$chan = mysql_result($result, $a, "chan");
	$money = n2a(mysql_result($result, $a, "SUM(cash)"));
	echo "<li title=\"$money\">" . $chan . "</li>\n";
}

$query = "SELECT * FROM loot_item ORDER BY count DESC";
$result = mysql_query($query);

print '</ul><p><strong>5 Most Common Drops:</strong></p><ul>';

for ($a = 0; $a < 5; $a++) {
	$item = mysql_result($result, $a, "item");
	$count = number_format(mysql_result($result, $a, "count"));
	echo "<li title=\"$count\">" . $item . "</li>\n";
}
print '</ul>
<p>You can hover over most numbers and columns for more info.</p>';

?>