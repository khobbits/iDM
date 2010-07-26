<?php

if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

if($session['session']->rank < ADMIN_RANK || !isset($statType)) {
	echo "Invalid page access";
	return;
}

switch($statType) {
	case 'high':
	  displayHighStats();
	  return;
	case 'low':
	  displayLowStats();
		return;
	case 'idle':
	  displayIdleStats('support');
	  displayIdleStats('allegra');
	  displayIdleStats('beau');
	  displayIdleStats('belong');
	  displayIdleStats('kh');
	  displayIdleStats('snake');
	  displayIdleStats('cookies');
	  return;
 }
 
return;

function displayHighStats() {
	$sql = "SELECT * FROM _CHEAT_HIGHRATIO_60 ORDER BY ratio DESC LIMIT 0, 20";
	$result = mysql_query($sql);
?>
<h2>Top 10 Cheat High Ratio</h2>
<table class="table-stats">
	<thead>
	  <tr>
	    <th>Ranking</th>
	    <th>User</th>
	    <th>Money</th>
	    <th>Wins</th>
	    <th>Losses</th>
	    <th>Ratio</th>
	    <th>Clan</th>
	    <th>Address</th>
		</tr>
	</thead>
	<tbody>
<?php
	$index = 1;
	while(($row = mysql_fetch_object($result)) != NULL) {
	  $class = ($index % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=$index++?></td>
		  <td><?=$row->user?></td>
		  <td><?=n2a($row->money)?></td>
		  <td><?=$row->wins?></td>
		  <td><?=$row->losses?></td>
		  <td><?=$row->ratio?></td>
		  <td><?=($row->clan ? $row->clan : '')?></td>
		  <td><?=($row->address ? $row->address : '')?></td>
		</tr>
<?php
	}
?>
	</tbody>
</table>
<?php
}

function displayLowStats() {
	$sql = "SELECT * FROM _CHEAT_LOWRATIO_60 ORDER BY ratio ASC LIMIT 0, 20";
	$result = mysql_query($sql);
?>
<h2>Top 10 Cheat Low Ratio</h2>
<table class="table-stats">
	<thead>
	  <tr>
	    <th>Ranking</th>
	    <th>User</th>
	    <th>Money</th>
	    <th>Wins</th>
	    <th>Losses</th>
	    <th>Ratio</th>
	    <th>Clan</th>
	    <th>Address</th>
		</tr>
	</thead>
	<tbody>
<?php
	$index = 1;
	while(($row = mysql_fetch_object($result)) != NULL) {
	  $class = ($index % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=$index++?></td>
		  <td><?=$row->user?></td>
		  <td><?=n2a($row->money)?></td>
		  <td><?=$row->wins?></td>
		  <td><?=$row->losses?></td>
		  <td><?=$row->ratio?></td>
		  <td><?=($row->clan ? $row->clan : '')?></td>
		  <td><?=($row->address ? $row->address : '')?></td>
		</tr>
<?php
	}
?>
	</tbody>
</table>
<?php
}

function displayIdleStats( $who ) {
  $sql = "SELECT * FROM _IDLE_STAFF WHERE $who != '0' ORDER BY login LIMIT 0, 20";
	$result = mysql_query($sql);
?>
<h2>Top 20 idle users with <?=$who?></h2>
<table class="table-stats">
	<thead>
	  <tr>
	    <th>User</th>
	    <th>Last Login</th>
	    <th>allegra</th>
		  <th>beau</th>
		  <th>belong</th>
		  <th>kh</th>
		  <th>snake</th>
		  <th>support</th>
		  <th>cookies</th>
		</tr>
	</thead>
	<tbody>
<?php
	$index = 1;
	while(($row = mysql_fetch_object($result)) != NULL) {
	  $class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=$row->user?></td>
		  <td><?=date('Y-m-d G:i:s', $row->login)?></td>
		  <td><?=$row->allegra?></td>
		  <td><?=$row->beau?></td>
		  <td><?=$row->belong?></td>
		  <td><?=$row->kh?></td>
		  <td><?=$row->snake?></td>
		  <td><?=$row->support?></td>
		  <td><?=$row->cookies?></td>
		</tr>
<?php
	}
?>
	</tbody>
</table>
<?php
}
?>