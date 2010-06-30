<?PHP

$userd = str_replace(" ", "_", strtolower($_GET ['user']));
$user = mysql_real_escape_string($userd);

if ($user == '') {
	$searchd = str_replace(" ", "_", strtolower($_POST ['search']));
	$search = mysql_real_escape_string($searchd);
	?>

<p>Search for a user to fetch their stats.</p>
<div style="width: 100%; padding-bottom: 10px; text-align: center;">
<form name="input" action="/u/" method="post"><input name="search"
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
				print '<tr><td><a href="/u/' . urlencode($row->user) . '">' . htmlentities($row->user) . '</td></tr>';
			}
			print '</tbody></table>';
			if ($num == 25) {
				print '<p>There are more results than what can be displayed, you may want to do a more exact search.</p>';
			}
		}
	}
	
	
	return;
}

$data = array ();
$query = "SELECT *,(wins + losses) AS total
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
			'total' => 0,
			'losses' => 0,
			'clan' => 'None',
			'profile' => '',
			'banned' => 0,
			'login' => 0,
			'cookies' => 0,
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
			'snow' => 0,
			'corr' => 0,
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

?>
	<script type="text/javascript">
	$(function() {
		$("#tabs").tabs({
			ajaxOptions: {
				error: function(xhr, status, index, anchor) {
					$(anchor.hash).html("Couldn\'t load this tab. We\'ll try to fix this as soon as possible.");
				}
			}
		});
	});
	</script>
<div id="tabs">
	<ul>
		<li><a href="#tabs-1">User</a></li>
		<li><a href="#tabs-2">Weapons</a></li>
		<li><a href="#tabs-3">Items</a></li>
		<li><a href="#tabs-4">Achievements</a></li>
		<li><a href="/ajax/event-log.php?user=<?=$user?>">Recent Activity</a></li>

	</ul>
	<div id="tabs-1">
	<?
    include 'includes/u-user.php';
	?>
  </div>
  <div id="tabs-2">
  <?
    include 'includes/u-weapon.php';
  ?>
	</div>
	<div id="tabs-3">
  <?
    include 'includes/u-item.php';
  ?>
	</div>
	<div id="tabs-4">
  <?
    include 'includes/u-achiv.php';
  ?>
	</div>
</div>

