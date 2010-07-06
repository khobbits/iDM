<h1>DM Drop Stats</h1>

<center>

<table class="table-stats">
<tr><th>Most Common Drops</th><th>Rarest Drops</th><th>Most Expensive Drops</th></tr>
<tr><td><ul>

<?php
$query = "SELECT * FROM loot_item ORDER BY count DESC LIMIT 30";
$result = mysql_query($query);

while ($row = mysql_fetch_object($result)) {
	print '<li title=' . $row->count . '>' . $row->item . '</li>';
}
?>
</ul></td>
<td><ul>

<?php
$query = "SELECT * FROM loot_item ORDER BY count ASC LIMIT 30";
$result = mysql_query($query);

while ($row = mysql_fetch_object($result)) {
	print '<li title=' . $row->count . '>' . $row->item . '</li>';
}
?>
</ul></td>

<td><ul>

<?php
$query = "SELECT * FROM drops ORDER BY price DESC LIMIT 30";
$result = mysql_query($query);

while ($row = mysql_fetch_object($result)) {
	print '<li title=' . $row->price . '>' . $row->item . '</li>';
}
?>
</ul></td>

</tr>
</table>
</center>
