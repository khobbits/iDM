<?php

$prices = array('firecape' => 4000000000, 'bgloves' => 3000000000, 'elshield' => 8000000000, 'void-range' => 500000000, 'accumulator' => 1000000000, 'void-mage' => 800000000, 'mbook' => 1000000000, 'godcape' => 1200000000, 'ags' => 400000000, 'bgs' => 500000000, 'sgs' => 600000000, 'zgs' => 400000000, 'dclaws' => 2500000000, 'mudkip' => 200000000);

$query = "SELECT SUM(firecape) firecape, SUM(bgloves) bgloves, SUM(elshield) elshield, SUM(void) `void-range`, SUM(accumulator) accumulator, SUM(`void-mage`) `void-mage`, SUM(mbook) mbook, SUM(godcape) godcape FROM user,equip_armour WHERE user.user = equip_armour.user AND user.banned = '0' AND user.exclude = '0'";
$result = mysql_query($query);
$armour = mysql_fetch_assoc($result);

$query = "SELECT SUM(ags) ags, SUM(bgs) bgs, SUM(sgs) sgs, SUM(zgs) zgs, SUM(dclaws) dclaws,SUM(mudkip) mudkip, SUM(wealth) wealth, SUM(specpot) specpot FROM user,equip_item WHERE user.user = equip_item.user AND user.banned = '0' AND user.exclude = '0'";
$result = mysql_query($query);
$item = mysql_fetch_assoc($result);

$query = "SELECT count(clue) clue FROM equip_item WHERE clue != '0'";
$result = mysql_query($query);
$item['clue'] = mysql_result($result, 0, "clue");

$query = "SELECT SUM(mjavelin) mjavelin, SUM(statius) statius, SUM(vlong) vlong, SUM(vspear) vspear FROM user,equip_pvp WHERE user.user = equip_pvp.user AND user.banned = '0' AND user.exclude = '0'";
$result = mysql_query($query);
$pvp = mysql_fetch_assoc($result);

$equip = array_merge(array_merge($armour, $item), $pvp);

$query = "SELECT count(*) users,SUM(money) money,SUM(wins) wins,SUM(losses) losses FROM user WHERE user.banned = '0' AND user.exclude = '0'";
$result = mysql_query($query);
$totals = mysql_fetch_assoc($result);

/*$query = "SELECT clan,count(clan) count FROM user WHERE clan != '0' GROUP BY clan ORDER BY count(clan) DESC";
$result = mysql_query($query);
$totals['clans'] = mysql_num_rows($result);

$clans = array();
for ($a = 0; $a < 5; $a++) {
	$name = mysql_result($result, $a, "clan"); $count = number_format(mysql_result($result, $a, "count"));
	$clans[$a]['name'] = $name;
	$clans[$a]['count'] = $count;
}

$value = 0;

foreach ($equip as $key => $count) {
    $value += $prices[$key] * $count;
}

echo $value;*/




print '<h1>Equipment / User Stats</h1>
<h2>Equipment</h2>

<table class="table-user">
	<thead>
		<tr>
			<th>AGS</th>
			<th>BGS</th>
			<th>SGS</th>
			<th>ZGS</th>
			<th>Dragon Claws</th>
			<th>Mudkip</th>
			<th>Wealth</th>
			<th>Specpot</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 13%;">' . number_format($equip['ags']) . '</td>
			<td style="width: 13%;">' . number_format($equip['bgs']) . '</td>
			<td style="width: 13%;">' . number_format($equip['sgs']) . '</td>
			<td style="width: 13%;">' . number_format($equip['zgs']) . '</td>
			<td style="width: 12%;">' . number_format($equip['dclaws']) . '</td>
			<td style="width: 12%;">' . number_format($equip['mudkip']) . '</td>
			<td style="width: 12%;">' . number_format($equip['wealth']) . '</td>
			<td style="width: 12%;">' . number_format($equip['specpot']) . '</td>
		</tr>
	</tbody>
</table><br />

<table class="table-user">
	<thead>
		<tr>
			<th>Firecape</th>
			<th>Barrows Gloves</th>
			<th>Elysian Shield</th>
			<th>Void Range</th>
			<th>Void Mage</th>
			<th>Accumulator</th>
			<th>Mage Book</th>
			<th>God Cape</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 13%;">' . number_format($equip['firecape']) . '</td>
			<td style="width: 13%;">' . number_format($equip['bgloves']) . '</td>
			<td style="width: 13%;">' . number_format($equip['elshield']) . '</td>
			<td style="width: 13%;">' . number_format($equip['void-range']) . '</td>
			<td style="width: 12%;">' . number_format($equip['void-mage']) . '</td>
			<td style="width: 12%;">' . number_format($equip['accumulator']) . '</td>
			<td style="width: 12%;">' . number_format($equip['mbook']) . '</td>
			<td style="width: 12%;">' . number_format($equip['godcape']) . '</td>
		</tr>
	</tbody>
</table><br />

<table class="table-user">
	<thead>
		<tr>
			<th>Clues</th>
			<th>Morrigan\'s javelin</th>
			<th>Statius\'s Warhammer</th>
			<th>Vesta\'s Longsword</th>
			<th>Vesta\'s Spear</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 20%;">' . number_format($equip['clue']) . '</td>
			<td style="width: 20%;">' . number_format($equip['mjavelin']) . '</td>
			<td style="width: 20%;">' . number_format($equip['statius']) . '</td>
			<td style="width: 20%;">' . number_format($equip['vlong']) . '</td>
			<td style="width: 20%;">' . number_format($equip['vspear']) . '</td>
		</tr>
	</tbody>
</table>

<h2>User Data</h2>

<table class="table-user">
	<thead>
		<tr>
			<th>Users</th>
			<th>Money</th>
			<th>Wins **</th>
			<th>Losses **</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 25%;">' . number_format($totals['users']) . '</td>
			<td style="width: 25%;">' . number_format($totals['money']) . '</td>
			<td style="width: 25%;">' . number_format($totals['wins']) . '</td>
			<td style="width: 25%;">' . number_format($totals['losses']) . '</td>
		</tr>
	</tbody>
</table>
** Note: The difference in this is due to the fact that some user accounts have been deleted/altered.';

?>