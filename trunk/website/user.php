<?PHP

$userd = str_replace(" ", "_", strtolower($_GET ['user']));
$user = mysql_real_escape_string($userd);

if ($user == '') {
	$searchd = str_replace(" ", "_", strtolower($_POST ['search']));
	$search = mysql_real_escape_string($searchd);
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
		if(!$result) {
		  $num = 0;
		}
		else {
  		$num = mysql_num_rows($result);
		}

		if ($num == 0) {
			print '<p>Could not find a user matching "' . htmlentities($searchd) . '".  Try using a partial search.</p>';
		} else {
			print '<p>Searching for "' . htmlentities($searchd) . '", click on one of the matched usernames below.</p>';
			print '<table><tbody>';
			while ($row = mysql_fetch_object($result)) {
				print '<tr><td><a href="/u/' . urlencode($row->user) . '/">' . htmlentities($row->user) . '</td></tr>';
			}
			print '</tbody></table>';
			if ($num == 25) {
				print '<p>There are more results than what can be displayed, you may want to do a more exact search.</p>';
			}
		}
	}
} else {

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
	$result = mysql_query($query);
	if (!$result || sizeof($result = mysql_fetch_assoc($result)) == 0) {
		$result = array (

				'money' => 0,
				'wins' => 0,
				'losses' => 0,
				'clan' => 'None',
				'profile' => '',
				'banned' => 0,
				'login' => 0,
				'firecape' => 0,
				'bgloves' => 0,
				'elshield' => 0,
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
				'snake' => 0,
				'support' => '0'
		);
	}
	//$num = mysql_num_rows($result);


	print '<h1 style="margin-top: 0px;">' . htmlentities(strtoupper($userd)) . '</h1>
<div>
<table class="table-user-clean">
	<tbody>
		<tr>
			<th>Clan</td>
			<td><a href="/c/' . urlencode($result ['clan']) . '/">' . htmlentities($result ['clan']) . '</td>

		</tr>
		<tr>
			<th>Logged in?</td>
			<td>' . valuebool($result ['login'], 1) . '</td>
		</tr>
		<tr>
			<th style="width: 40%;">Banned?</td>
			<td style="width: 60%;">' . valuebool($result ['banned'], 1) . '</td>
		</tr>
	</tbody>
</table>
<br />
<table class="table-user">
	<tbody>
		<tr>
			<th>Money</td>
			<th>Wins</td>
			<th>Losses</td>
			<th>Win/Loss Ratio</td>
		</tr>
		<tr>
			<td style="width: 30%;">' . number_format($result ['money'], 0, '', ',') . 'gp</td>
			<td style="width: 20%;">' . number_format($result ['wins'], 0, '', ',') . '</td>
			<td style="width: 20%;">' . number_format($result ['losses'], 0, '', ',') . '</td>
			<td style="width: 30%;">' . ratiodist($result ['wins'], $result ['losses']) . '</td>
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
			<td style="width: 20%;">' . valuebool($result ['sgs']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['ags']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['bgs']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['zgs']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['dclaws']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['mudkip']) . '</td>
		</tr>
	</tbody>
</table>
<h2>Attack Bonuses</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>Accumulator</td>
			<th>Barrows Gloves</td>
			<th>Firecape</td>
			<th>God Cape</td>
			<th>Mage Book</td>
			<th>Void Range</td>
			<th>Void Mage</td>
		</tr>
		<tr>

			<td style="width: 14%;">' . valuebool($result ['accumulator']) . '</td>
			<td style="width: 14%;">' . valuebool($result ['bgloves']) . '</td>
			<td style="width: 14%;">' . valuebool($result ['firecape']) . '</td>
			<td style="width: 14%;">' . valuebool($result ['godcape']) . '</td>
			<td style="width: 14%;">' . valuebool($result ['mbook']) . '</td>
			<td style="width: 14%;">' . valuebool($result ['void']) . '</td>
			<td style="width: 14%;">' . valuebool($result ['void-mage']) . '</td>
		</tr>
	</tbody>
</table>
<h2>Other Items</h2>
<table class="table-user">
	<tbody>
		<tr>
			<th>Special Pot</td>
			<th>Ring of Wealth</td>
			<th>Elysian Shield</td>
			<th>Clue Scroll</td>
		</tr>
		<tr>
			<td style="width: 25%;">' . valuebool($result ['specpot']) . '</td>
			<td style="width: 25%;">' . valuebool($result ['wealth']) . '</td>
			<td style="width: 25%;">' . valuebool($result ['elshield']) . '</td>
			<td style="width: 25%;">' . valuebool($result ['clue']) . '</td>
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
			<td style="width: 25%;">' . valuebool($result ['mjavelin']) . '</td>
			<td style="width: 25%;">' . valuebool($result ['statius']) . '</td>
			<td style="width: 25%;">' . valuebool($result ['vlong']) . '</td>
			<td style="width: 25%;">' . valuebool($result ['vspear']) . '</td>
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
			<td style="width: 20%;">' . valuebool($result ['snake']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['kh']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['belong']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['allegra']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['beau']) . '</td>
			<td style="width: 16%;">' . valuebool($result ['support'], 1) . '</td>
		</tr>
	</tbody>
</table>

<div>
<br />
' . $result ['profile'] . '
</div>
</div>
';
}
?>