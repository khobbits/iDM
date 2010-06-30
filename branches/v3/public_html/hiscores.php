<div style="width: 95%; padding-bottom: 10px; text-align: center;">
			<form name="input" action="/hiscores/" method="POST">
			<input name="money" type="submit" value="Sort by Money" />
			<input name="wins" type="submit" value="Sort by Wins" />
			<input name="losses" type="submit" value="Sort by Losses" />
			<input name="total" type="submit" value="Sort by Total DMs" />
			</form></div>

		<script type="text/javascript" charset="utf-8">
			$(document).ready(function() {
				$('#pageit').dataTable( {
            "bAutoWidth": false,
            "bFilter": false,
            "bInfo": true,
            "bJQueryUI": true,
            "bLengthChange": true,
            "bPaginate": true,
            "bSort": false,
            "bSortClasses": false,
            "iDisplayLength": 27

          } );
			} );
		</script>

<table border="0" cellpadding="2 px" cellspacing="0" class="table-hs" id="pageit">
    <thead>
		<tr><th>Rank</th><th>Username</th><th>Money</th><th>Wins</th><th>Losses</th></tr>
		</thead><tbody>

<?php

if(isset($_POST['wins'])) {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY wins DESC limit 200";
}
elseif(isset($_POST['losses'])) {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY losses DESC limit 200";
}
elseif(isset($_POST['total'])) {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY wins+losses DESC limit 200";
}
else {
	$query = "SELECT * FROM user WHERE exclude = '0' AND banned = '0' ORDER BY money DESC limit 200";
}

$results = mysql_query($query);

$rank = 1;

while ($result = mysql_fetch_assoc($results)) {

	$money = number_format($result['money']);
	$wins = number_format($result['wins']);
	$losses = number_format($result['losses']);
	print '<tr><td>' . $rank .
		  '</td><td><a href="/u/' . urlencode($result['user']) . '">' . ucfirst(htmlentities($result['user'])) .
		  '</td><td>' . $money . '</td>';
	print '<td>' . $wins . '</td><td>' . $losses . '</td></tr>';
	$rank++;
}
?>
</tbody>
</table>
