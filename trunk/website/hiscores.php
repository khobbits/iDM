<div style="width: 95%; padding-bottom: 10px; text-align: center;">
			<form name="input" action="/hiscores/" method="POST">
			<input name="money" type="submit" value="Sort by Money" />
			<input name="wins" type="submit" value="Sort by Wins" />
			<input name="losses" type="submit" value="Sort by Losses" />
			</form></div>

<table align="center" style="text-align: center;" border="0" cellpadding="2 px" cellspacing="0" class="table-hs">
		<tr><th>Rank</th><th>Username</th><th>Money</th><th>Wins</th><th>Losses</th></tr>

<?php

if(isset($_POST['wins'])) {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY wins DESC limit 30";
}
elseif(isset($_POST['losses'])) {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY losses DESC limit 30";
}
else {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY money DESC limit 30";
}

$result = mysql_query($query);

$rank = 1;

for ($a = 0; $a < 30; $a++) {
    $class = ($a % 2 == 0) ? 'even' : 'odd';
	$user = mysql_result($result, $a, "user");
	$money = number_format(mysql_result($result, $a, "money"));
	$wins = number_format(mysql_result($result, $a, "wins"));
	$losses = number_format(mysql_result($result, $a, "losses"));
	print '<tr class=' . $class . '><td>' . $rank .
		  '</td><td><a href="/u/' . urlencode($user) . '">' . ucfirst(htmlentities($user)) .
		  '</td><td>' . $money . '</td>';
	print '<td>' . $wins . '</td><td>' . $losses . '</td></tr>';
	$rank++;
}
?>
</table>
