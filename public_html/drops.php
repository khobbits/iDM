<h1>DM Drop Stats</h1>

<center>

<table class="table-stats">
<tr><th>Most Common Drops</th><th>Rarest Drops</th><th>Most Expensive Drops</th></tr>
<tr><td><ul>

<?php
$query = "SELECT * FROM loot_item ORDER BY count DESC";
$result = mysql_query($query);

for ($a = 0; $a < 30; $a++) {
	$item = mysql_result($result, $a, "item");
	$count = number_format(mysql_result($result, $a, "count"));
	print '<li title=' . $count . '>' . $item . '</li>';
}
?>
</ul></td>
<td><ul>

<?php
$query = "SELECT * FROM loot_item ORDER BY count ASC";
$result = mysql_query($query);

for ($a = 0; $a < 30; $a++) {
	$item = mysql_result($result, $a, "item");
	$count = number_format(mysql_result($result, $a, "count"));
	print '<li title=' . $count . '>' . $item . '</li>';
}
?>
</ul></td>

<td><ul>

<?php
$query = "SELECT * FROM drops ORDER BY price DESC";
$result = mysql_query($query);

for ($a = 0; $a < 30; $a++) {
	$item = mysql_result($result, $a, "item");
	$price = number_format(mysql_result($result, $a, "price"));
	print '<li title=' . $price . '>' . $item . '</li>';
}
?>
</ul></td>

</tr>
</table>
</center>
