<h1>DM Drop Stats</h1>

<center>
<h2>Top 30 drops</h2>

<?php
$query = "SELECT * FROM loot_item ORDER BY count DESC";
$result = mysql_query($query);

for ($a = 0; $a < 30; $a++) {
	$item = mysql_result($result, $a, "item");
	$count = number_format(mysql_result($result, $a, "count"));
	print '<li title=' . $count . '>' . $item . '</li>';
}
?>
</center>
