<?PHP
$totalDMs = $result['wins'] + $result['losses'];
$PvP = $result['mjavelin'] + $result['statius'] + $result['vlong'] + $result['vspear'];
$sitems = 0;

if ($result['snow'] == 1 || $result['corr'] == 1) $sitem = 1;
else $sitem = 0;


$query = "SELECT * FROM achievements WHERE user = '$userd'";
$achiv = mysql_query($query);
if (!$achiv || sizeof($achiv = mysql_fetch_assoc($achiv)) == 0) {
	$achiv = array (
			'top12' => 0,
			'b-bug' => 0,
			's-bug' => 0,
			'b-cont' => 0,
			's-cont' => 0,
			'1hit' => 0,
			'elshield' => 0,
			'accumulator' => 0,
			'mbook' => 0,
			'ags' => 0,
			'bgs' => 0,
			'sgs' => 0,
			'zgs' => 0,
			'dclaws' => 0,
			'mudkip' => 0
	);
}

$oldtotal = $achiv['oldmoney'] + $achiv['oldlosses'] + $achiv['oldwins'];
$error = 'N/A';

?>

<h2>Achievements</h2>

<div>
  <table>
  <table class="table-user">
  	<thead>
  		<tr>

  			<th>Total</th>
  			<th>Wins</th>
  			<th>Losses</th>
  		</tr>
    </thead>
    <tbody>
  		<tr>
  			<td style="width: 25%;"><?=achiv(total, $totalDMs); ?></td>
  			<td style="width: 25%;"><?=achiv(wins, $result['wins']); ?></td>
  			<td style="width: 25%;"><?=achiv(losses, $result['losses']); ?></td>
  		</tr>
  	</tbody>
  </table>
<br />
  <table class="table-user">
  	<thead>
  		<tr>

  			<th>PvP</th>
  			<th>Special Pots</th>
  			<th>Cookies</th>
  		</tr>
    </thead>
    <tbody>
  		<tr>
       		<td style="width: 33%;"><?=achiv(pvp, $PvP); ?></td>
       		<td style="width: 33%;"><?=achiv(specpots, $result['specpot']); ?></td>
  			<td style="width: 33%;"><?=achiv(cookies, $result['cookies']); ?></td>
  		</tr>
  	</tbody>
  </table>
	<br />
  <table width="97%"><tr>
		<td valign="top" width="40%"><table class="table-user">
		<tr>
			<th colspan="3">iDM v2</th>
		</tr>
  		<tr class="even">
  			<td width="50%">Money</td>
			<td width="30%"><abbr title="<?=number_format($achiv['oldmoney'], 0, '', ',')?>"><?=n2a($achiv['oldmoney'])?></abbr> gp</td>
			<td width="20%"><?=$achiv['oldmoney'] ? getrank_old($userd,'oldmoney') : $error ?></td>
		</tr>
		<tr class="odd">
  			<td>Wins</td>
			<td><?=number_format($achiv['oldwins'], 0, '', ',')?></td>
			<td><?=$achiv['oldwins'] ? getrank_old($userd,'oldwins') : $error ?></td>
		</tr>
		<tr class="even">
  			<td>Losses</td>
			<td><?=number_format($achiv['oldlosses'], 0, '', ',')?></td>
			<td><?=$achiv['oldlosses'] ? getrank_old($userd,'oldlosses') : $error ?></td>
		</tr>
		<tr class="odd">
  			<td>Total Rank</td>
			<td colspan="2"><?=$oldtotal > 0 ? getrank_old($userd,'total') : $error ?></td>
		</tr>
		<tr class="even">
  			<td>Win/Loss Ratio</td>
			<td colspan="2"><?=ratiodist($achiv['oldwins'], $achiv['oldlosses'])?></td>
		</tr>
	</table></td>
	<td valign="top" width="30%"><table class="table-user">
		<tr>
			<th colspan="2">Special Achievements</th>
		</tr>
		<tr class="even">
  			<td>Big Bugfinder</td>
			<td width="25px;"><?=aCheck($achiv['b-bug']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Small Bugfinder</td>
			<td width="25px;"><?=aCheck($achiv['s-bug']); ?></td>
		</tr>
		<tr class="even">
  			<td>Big Contributor</td>
			<td width="25px;"><?=aCheck($achiv['b-cont']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Small Contributor</td>
			<td width="25px;"><?=aCheck($achiv['b-cont']); ?></td>
		</tr>
		<tr class="even">
  			<td>One Hit</td>
			<td width="25px;"><?=aCheck($achiv['1hit']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Obtaining a special drop</td>
			<td width="25px;"><?=aCheck($sitem); ?></td>
		</tr>
	</table></td>
		<td valign="top" width="30%"><table class="table-user">
		<tr>
			<th colspan="2">Drop Achievements</th>
		</tr>
  		<tr class="even">
  			<td>Elyisan</td>
			<td width="25px;"><?=aCheck($achiv['elshield']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Mudkip</td>
			<td width="25px;"><?=aCheck($achiv['mudkip']); ?></td>
		</tr>
		<tr class="even">
  			<td>Dragon Claws</td>
			<td width="25px;"><?=aCheck($achiv['dclaws']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Mage's Book</td>
			<td width="25px;"><?=aCheck($achiv['mbook']); ?></td>
		</tr>
		<tr class="even">
  			<td>Accumulator</td>
			<td width="25px;"><?=aCheck($achiv['accumulator']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Armadyl GS</td>
			<td width="25px;"><?=aCheck($achiv['ags']); ?></td>
		</tr>
		<tr class="even">
  			<td>Bandos GS</td>
			<td width="25px;"><?=aCheck($achiv['bgs']); ?></td>
		</tr>
		<tr class="odd">
  			<td>Saradomin GS</td>
			<td width="25px;"><?=aCheck($achiv['sgs']); ?></td>
		</tr>
		<tr class="even">
  			<td>Zamorak GS</td>
			<td width="25px;"><?=aCheck($achiv['zgs']); ?></td>
		</tr>
	</table></td>
</tr></table>
</div>
