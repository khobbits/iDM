<?PHP

$user = mysql_real_escape_string($_GET ['user']);

$user = str_replace(" ", "_", strtolower($user));

if ($user == '') {
	$search = mysql_real_escape_string($_POST ['search']);
	$search = str_replace(" ", "_", strtolower($search));
	?>

<p>Search for a user to fetch their stats.</p>
<div style="width: 100%; padding-bottom: 10px; text-align: center;">
<form name="input" action="/u/" method="POST"><input name="search"
	type="text" value="" /> <input name="submit" type="submit"
	value="Lookup User" /></form>
</div>

<?php
	if ($search != '') {
		$query = "SELECT * FROM user WHERE user like '%$search%' ORDER BY user ASC LIMIT 25";
		$result = mysql_query($query);
		$num = mysql_num_rows($result);

		if ($num == 0) {
			print '<p>Could not find a user matching "' . $search . '".  Try using a partial search.</p>';
		} else {
			print '<p>Searching for "'. $search .'", click on one of the matched usernames below.</p>';
			print '<table><tbody>';
			while ($row = mysql_fetch_object($result)) {
				print '<tr><td><a href="/u/' . $row->user . '/">' . $row->user . '</td></tr>';
			}
			print '</tbody></table>';
			if ($num == 25) {
				print '<p>There are more results than what can be displayed, you may want to do a more exact search.</p>';
			}
		}
	}
} else {

	print '<h1>' . strtoupper($user) . '</h1>';

	$data = array ();
	$query = "SELECT *
				FROM user u
				LEFT JOIN (
				  SELECT *
				  FROM equip_armour
				  WHERE user = '$user'
				) AS a ON ( u.user = a.user )
				LEFT JOIN (
				  SELECT *
				  FROM equip_item
				  WHERE user = '$user'
				) AS i ON ( u.user = i.user )
				LEFT JOIN (
				  SELECT *
				  FROM equip_pvp
				  WHERE user = '$user'
				) AS p ON ( u.user = p.user )
				LEFT JOIN (
				  SELECT *
				  FROM equip_staff
				  WHERE user = '$user'
				) AS s ON ( u.user = s.user )
				WHERE u.user = '$user'";
	$result = mysql_fetch_assoc(mysql_query($query));
	if (sizeof($result) == 0) {
		$result = array (
				'money' => 0,
				'wins' => 0,
				'losses' => 0,
				'clan' => 'None',
				'banned' => 0,
				'login' => 0,
				'firecape' => 0,
				'bgloves' => 0,
				'void' => 0,
				'void-mage' => 0,
				'accumulator' => 0,
				'mbook' => 0,
				'godcape' => 0,
				'ags' => 0,
				'bgs' => 0,
				'sgs' => 0,
				'zgs' => 0,
				'dclaws' => 0,
				'mudkip' => 0,
				'wealth' => 0,
				'specpot' => 0,
				'clue' => 0,
				'mjavelin' => 0,
				'statius' => 0,
				'vlong' => 0,
				'vspear' => 0,
				'allegra' => 0,
				'beau' => 0,
				'belong' => 0,
				'kh' => 0,
				'snake' => 0
		);
	}
	//$num = mysql_num_rows($result);

function valuebool ($value) {
	if ($value == 0) {
		return "No";
	} else {
		return "Yes";
	}
}

function ratiodist ($wins, $losses) {
	if ($losses) {
		return number_format(($wins/$losses), 2, '.', '') . ' (' .
		number_format((($wins/($losses+$wins))*100), 2, '.', ''). '%)';
	} else {
		return '1 (100%)';
	}
}

	print '
<div>
<h2>User Stats</h2>
<table class="table-user-clean">
	<tbody>
		<tr>
			<td>Money: ' . number_format($result ['money'], 0, '', ',') . ' gp</td>
		</tr>
		<tr>
			<td>Wins: ' . number_format($result ['wins'], 0, '', ',') . '</td>
		</tr>
		<tr>
			<td>Losses: ' . number_format($result ['losses'], 0, '', ',') . '</td>
		</tr>
		<tr>
			<td>Win/Loss Ratio: ' . ratiodist($result ['wins'],$result ['losses']) . '</td>
		</tr>
		<tr>
			<td>Clan: ' . $result ['clan'] . '</td>
		</tr>
		<tr>
			<td>Logged in: ' . valuebool($result ['login']) . '</td>
		</tr>
		<tr>
			<td>Banned: ' . valuebool($result ['banned']) . '</td>
		</tr>
	</tbody>
</table>
<h2>Weapons</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>Saradomin Godsword</td>
			<th>Armadyl Godsword</td>
			<th>Bandos Godsword</td>
			<th>Zamorak Godsword</td>
			<th>Dragon Claws</td>
			<th>Mudkip</td>
		</tr>
		<tr>
			<td style="width: 20%;">' . number_format($result ['sgs'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['ags'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['bgs'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['zgs'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['dclaws'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['mudkip'], 0, '', ',') . '</td>
		</tr>
	</tbody>
</table>
<h2>Defense</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>Firecape</td>
			<th>Barrows Gloves</td>
			<th>Void Range</td>
			<th>Void Mage</td>
			<th>Accumulator</td>
			<th>Mage Book</td>
			<th>God Cape</td>
		</tr>
		<tr>
			<td style="width: 14%;">' . number_format($result ['firecape'], 0, '', ',') . '</td>
			<td style="width: 14%;">' . number_format($result ['bgloves'], 0, '', ',') . '</td>
			<td style="width: 14%;">' . number_format($result ['void'], 0, '', ',') . '</td>
			<td style="width: 14%;">' . number_format($result ['void-mage'], 0, '', ',') . '</td>
			<td style="width: 14%;">' . number_format($result ['accumulator'], 0, '', ',') . '</td>
			<td style="width: 14%;">' . number_format($result ['mbook'], 0, '', ',') . '</td>
			<td style="width: 14%;">' . number_format($result ['godcape'], 0, '', ',') . '</td>
		</tr>
	</tbody>
</table>
<h2>Items</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>Ring of Wealth</td>
			<th>Special Pot</td>
			<th>Clue Scroll</td>
		</tr>
		<tr>
			<td style="width: 30%;">' . number_format($result ['wealth'], 0, '', ',') . '</td>
			<td style="width: 30%;">' . number_format($result ['specpot'], 0, '', ',') . '</td>
			<td style="width: 30%;">' . number_format($result ['clue'], 0, '', ',') . '</td>
		</tr>
	</tbody>
</table>
<h2>PvP Items</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>Morrigan\'s Javelin</td>
			<th>Statius\'s Warhammer</td>
			<th>Vesta\'s Longsword</td>
			<th>Vesta\'s Spear</td>
		</tr>
		<tr>
			<td style="width: 25%;">' . number_format($result ['mjavelin'], 0, '', ',') . '</td>
			<td style="width: 25%;">' . number_format($result ['statius'], 0, '', ',') . '</td>
			<td style="width: 25%;">' . number_format($result ['vlong'], 0, '', ',') . '</td>
			<td style="width: 25%;">' . number_format($result ['vspear'], 0, '', ',') . '</td>
		</tr>
	</tbody>
</table>
<h2>Staff Items</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>One-Eyed Trouser Snake</td>
			<th>KHonfound Ring</td>
			<th>Belong Blade</td>
			<th>Allergy Pills</td>
			<th>Beaumerang</td>
			<th>The Supporter</td>
		</tr>
		<tr>
			<td style="width: 20%;">' . number_format($result ['snake'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['kh'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['belong'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['allegra'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . number_format($result ['beau'], 0, '', ',') . '</td>
			<td style="width: 16%;">' . (isset($result ['support']) ? 1 : 0) . '</td>
		</tr>
	</tbody>
</table>
</div>
';
}
?>