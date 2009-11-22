<?PHP
print_r ($_GET);
$cland = str_replace(" ", "_", strtolower($_GET ['clan']));
$clan = mysql_real_escape_string($cland);

if ($clan == '') {
	$searchd = str_replace(" ", "_", strtolower($_POST ['search']));
	$search = mysql_real_escape_string($searchd);
	?>

<p>Search for a clan to fetch their stats.</p>
<div style="width: 100%; padding-bottom: 10px; text-align: center;">
<form name="input" action="/c/" method="POST"><input name="search"
	type="text" value="" /> <input name="submit" type="submit"
	value="Clan Search" /></form>
</div>

<?php
	if ($search != '') {
		$query = "SELECT * FROM clantracker WHERE user like '%$search%' ORDER BY user ASC LIMIT 25";
		$result = mysql_query($query);
		$num = mysql_num_rows($result);

		if ($num == 0) {
			print '<p>Could not find a user matching "' . htmlentities($searchd) . '".  Try using a partial search.</p>';
		} else {
			print '<p>Searching for "' . htmlentities($searchd) . '", click on one of the matched clans below.</p>';
			print '<table><tbody>';
			while ($row = mysql_fetch_object($result)) {
				print '<tr><td><a href="/c/' . urlencode($row->user) . '/">' . htmlentities($row->user) . '</td></tr>';
			}
			print '</tbody></table>';
			if ($num == 25) {
				print '<p>There are more results than what can be displayed, you may want to do a more exact search.</p>';
			}
		}
	}
} else {

	$data = array ();
	$query = "SELECT * FROM clantracker WHERE user = '$clan'";
	$result = mysql_fetch_assoc(mysql_query($query));
	if (sizeof($result) == 0) {
		$result = array (

			'owner' => 'None',
			'wins' => 0,
			'losses' => 0,
			'money' => '0',
			'share' => 0
		);
	}
	//$num = mysql_num_rows($result);
	$mquery = "SELECT * FROM user WHERE clan = '$clan' ORDER BY user";
	$mresult = mysql_query($mquery);
	$mnum = mysql_num_rows($mresult);

	print '<h1 style="margin-top: 0px;">' . htmlentities(strtoupper($cland)) . '</h1>
<div>
<table class="table-user-clean">
	<tbody>
		<tr>
			<th>Owner</td>
			<td><a href="/u/' . urlencode($result ['owner']) . '/">' . htmlentities($result ['owner']) . '</td>
		</tr>
		<tr>
			<th style="width: 40%;">Lootshare?</td>
			<td style="width: 60%;">' . valuebool($result ['share'], 1) . '</td>
		</tr>
	</tbody>
</table>
<br />
<table class="table-user">
	<tbody>
		<tr>
			<th>Members</td>
			<th>Money</td>
			<th>Wins</td>
			<th>Losses</td>
			<th>Win/Loss Ratio</td>
		</tr>
		<tr>
			<td style="width: 20%;">' . $mnum . ' users</td>
			<td style="width: 20%;">' . number_format($result ['money'], 0, '', ',') . 'gp</td>
			<td style="width: 15%;">' . number_format($result ['wins'], 0, '', ',') . '</td>
			<td style="width: 15%;">' . number_format($result ['losses'], 0, '', ',') . '</td>
			<td style="width: 30%;">' . ratiodist($result ['wins'], $result ['losses']) . '</td>
		</tr>
	</tbody>
</table>';

?>
<br />
<h2>Member List</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>User
			</td>
			<th>Money
			</td>
			<th>Wins
			</td>
			<th>Losses
			</td>
			<th>Win/Loss Ratio
			</td>
		</tr>
<?php
	$i = 1;
	while ($mrow = mysql_fetch_object($mresult)) {
		$class = ($i % 2 == 0) ? 'even' : 'odd';
		print '
		<tr class=' . $class . '>
			<td style="width: 20%;"><a href="/u/' . urlencode($mrow->user) . '/">' . htmlentities($mrow->user) . '</td>
			<td style="width: 20%;">' . number_format($mrow->money, 0, '', ',') . 'gp</td>
			<td style="width: 15%;">' . number_format($mrow->wins, 0, '', ',') . '</td>
			<td style="width: 15%;">' . number_format($mrow->losses, 0, '', ',') . '</td>
			<td style="width: 30%;">' . ratiodist($mrow->wins, $mrow->losses) . '</td>
		</tr>';
		$i++;
	}
?>
	</tbody>
</table>
</div>
<?php
}
?>