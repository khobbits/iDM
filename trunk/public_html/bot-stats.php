<?php

die();

$prices = array('firecape' => 4000000000, 'bgloves' => 3000000000, 'elshield' => 8000000000, 'void-range' => 500000000, 'accumulator' => 1000000000, 'void-mage' => 800000000, 'mbook' => 1000000000, 'godcape' => 1200000000, 'ags' => 400000000, 'bgs' => 500000000, 'sgs' => 600000000, 'zgs' => 400000000, 'dclaws' => 2500000000, 'mudkip' => 200000000);

$dbname = 'idm';
$dbuser = 'idm';
$dbpasswd = 'Sp4rh4wk`Gh0$t`';

if (!mysql_connect(localhost, $dbuser, $dbpasswd)) die("Unable to connect to database");
if (!mysql_select_db($dbname)) die("Unable to select database");

$query = "SELECT SUM(firecape) firecape, SUM(bgloves) bgloves, SUM(elshield) elshield, SUM(void) `void-range`, SUM(accumulator) accumulator, SUM(`void-mage`) `void-mage`, SUM(mbook) mbook, SUM(godcape) godcape FROM equip_armour";
$result = mysql_query($query);
$armour = mysql_fetch_assoc($result);

$query = "SELECT SUM(ags) ags, SUM(bgs) bgs, SUM(sgs) sgs, SUM(zgs) zgs, SUM(dclaws) dclaws,SUM(mudkip) mudkip, SUM(wealth) wealth, SUM(specpot) specpot FROM equip_item";
$result = mysql_query($query);
$item = mysql_fetch_assoc($result);

$query = "SELECT count(clue) clue FROM equip_item WHERE clue != '0'";
$result = mysql_query($query);
$item['clue'] = mysql_result($result, 0, "clue");

$query = "SELECT SUM(mjavelin) mjavelin, SUM(statius) statius, SUM(vlong) vlong, SUM(vspear) vspear FROM equip_pvp";
$result = mysql_query($query);
$pvp = mysql_fetch_assoc($result);

$equipment = array_merge(array_merge($armour, $item), $pvp);

$query = "SELECT count(*) dms,SUM(money) money,SUM(wins) wins,SUM(losses) losses FROM user";
$result = mysql_query($query);
$totals = mysql_fetch_assoc($result);

$query = "SELECT clan,count(clan) count FROM user WHERE clan != '0' GROUP BY clan ORDER BY count(clan) DESC";
$result = mysql_query($query);
$totals['clans'] = mysql_num_rows($result);

$clans = array();
for ($a = 0; $a < 5; $a++) {
	$name = mysql_result($result, $a, "clan"); $count = number_format(mysql_result($result, $a, "count"));
	$clans[$a]['name'] = $name;
	$clans[$a]['count'] = $count;
}

print_r($equipment);
print_r($totals);
print_r($clans);

mysql_close();

echo date("r");

?>