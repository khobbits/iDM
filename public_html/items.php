<table align="center" border="0" cellpadding="2 px" cellspacing="0" class="table-user">
		<tr><th>Item</th><th>Price</th><th>Chance</th></tr>

<?PHP

$query = "SELECT * FROM drops";
$result = mysql_query($query);
$num = mysql_num_rows($result);

for ($a = 0; $a < $num; $a++) {
    $class = ($a % 2 == 0) ? 'even' : 'odd';
	$item = mysql_result($result, $a, "item");
	$price = number_format(mysql_result($result, $a, "price"));
	$chance = number_format(mysql_result($result, $a, "chance"));
	print '<tr class=' . $class . '><td>' . $item .
		  '</td><td>'. $price .
		  '</td><td>' . $chance . '</td></tr>';
}

?>

</table>