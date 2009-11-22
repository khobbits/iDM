<?
function init($page) {
	global $dbname, $dbuser, $dbpasswd;
    $dbname = 'idm';
    $dbuser = 'idm';
    $dbpasswd = 'Sp4rh4wk`Gh0$t`';

    if (!mysql_connect(localhost, $dbuser, $dbpasswd)) die("Unable to connect to database");
	if (!mysql_select_db($dbname)) die("Unable to select database");

	$pages = array (
		"stats" => "stats.php", "drops" => "drops.php", "hiscores" => "hiscores.php",
	    "user" => "user.php", "sitems" => "sitems.php", "clan" => "clan.php"
	);

	if ($page == 1) {
		return 1;
	} elseif (isset($pages [$page])) {
		return $pages [$page];
	} else {
		include 'news.php';
		news_init();
		return 'news.php';
	}
}

#    Output easy-to-read numbers
#    by james at bandit.co.nz
function n2a($n) {
	// first strip any formatting;
	$n = (0 + str_replace(",", "", $n));

	// is this a number?
	if (!is_numeric($n)) return false;

	// now filter it;
	if ($n > 1000000000000) {
		return round(($n / 1000000000000), 2) . 't';
	} else if ($n > 1000000000) {
		return round(($n / 1000000000), 2) . 'b';
	} else if ($n > 1000000) {
		return round(($n / 1000000), 2) . 'm';
	} else if ($n > 1000) {
		return round(($n / 1000), 2) . 'k';
	}
	return number_format($n);
}

function displayContent($page) {
	if ($page == "news.php") {
		news_display();
	} else {
		include $page;
	}
	mysql_close();
}

function displayQuickStats() {
	include 'qstats.php';
}

function valuebool ($value, $text = 0, $dplaces = 0) {
	if ($value == 0) {
		if (($text == 0) || ($value == '') || ($value == '0')) {
			return "No";
		}
	}
	if (($value == 1) || ($text == 1)) {
		return "Yes";
	}
	return number_format($value, $dplaces, '.', ',') ;
}

function ratiodist ($wins, $losses) {
	if ($losses) {
		return number_format(($wins/$losses), 2, '.', '') . ' (' .
		number_format((($wins/($losses+$wins))*100), 2, '.', ''). '%)';
	} else {
		return '1 (100%)';
	}
}

?>
