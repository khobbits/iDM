<?

define ('ADMIN_RANK', 3);

function init($page) {
	global $dbname, $dbuser, $dbpasswd;
  $dbname = 'idm_bot';
  $dbuser = 'idm';
  $dbpasswd = 'Sp4rh4wk`Gh0$t`';

  if (!mysql_connect(localhost, $dbuser, $dbpasswd)) die("Unable to connect to database");
	if (!mysql_select_db($dbname)) die("Unable to select database");

	$pages = array (
		"dmstats" => "dmstats.php", "drops" => "drops.php", "hiscores" => "hiscores.php",
	    "user" => "user.php", "sitems" => "sitems.php", "clan" => "clan.php", "items" => "items.php",
		"bts" => "bts.php", "userstats" => "userstats.php", "u-help" => "includes/u-help.php"
	);

	if ($page == 1) {
		return 1;
	} elseif (isset($pages [$page])) {
		return $pages [$page];
	} elseif ($page == 'account') {
    include 'includes/a-session.php';
		return 'account.php';
	} else {
		include 'includes/news.php';
		news_init();
		return 'news.php';
	}
}

function msgchan ($chan,$message) {
  include_once('bnc/sbnc.php');
  $sbnc = new SBNC("127.0.0.1", 12000, "admin", 'Sp4rh4wk`Gh0$t`');
  $result = $sbnc->CallAs('admin', simul, array( 'privmsg ' . $chan . ' :' . $message));
  $sbnc->Destroy();
  return var_export($result,true);
}

function msgsupport ($message) {
  msgchan('+#idm.support', chr(03) . '7[' . chr(03) . '3Website' . chr(03) . '7]' . chr(03) . ' ' . $message);
}

function msgstaff ($message) {
  msgchan('#idm.staff', chr(03) . '7[' . chr(03) . '3Website' . chr(03) . '7]' . chr(03) . ' ' . $message);
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
	include 'includes/qstats.php';
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

/**
 * @return number with ordinal suffix
 * @param int $number
 * @param int $ss Turn super script on/off
 */
function ordinalSuffix($number, $ss=0) {
    /*** check for 11, 12, 13 ***/
    if ($number % 100 > 10 && $number %100 < 14) {
        $os = 'th';
    }
    /*** check if number is zero ***/
    elseif($number == 0) {
        $os = '';
    }
	else {
        /*** get the last digit ***/
        $last = substr($number, -1, 1);
        switch($last)
        {
            case "1":
            $os = 'st';
            break;
            case "2":
            $os = 'nd';
            break;
            case "3":
            $os = 'rd';
            break;
            default:
            $os = 'th';
        }
    }
    $os = $ss==0 ? $os : '<sup>'.$os.'</sup>';
    return number_format($number).$os;
}

function getrank ($user, $column) {
	$user = mysql_real_escape_string(strtolower($user));
 	if ($column == 'total') {
    $column = '(wins+losses) AS total';
    $match = '((r1.wins)+(r1.losses)) < (r2.total)';
  }
 	else {
    $column = mysql_real_escape_string(strtolower($column));
    $match = "(r1.{$column} ) < (r2.{$column})";
  }
    
  $sql = "SELECT COUNT(*)+1 AS rank FROM user AS r1
    INNER JOIN (SELECT $column FROM user WHERE banned = '0' AND exclude = '0')
    AS r2 ON $match
    WHERE r1.user = '$user'";

  $query = mysql_query($sql);
	
	while ($row = mysql_fetch_object($query)) {
	 $rank = ordinalSuffix($row->rank);
	 return $rank;
	}
}

function getrank_old ($user, $column) {
	$user = mysql_real_escape_string(strtolower($user));
 	if ($column == 'total') {
    $column = '(oldwins+oldlosses) AS total';
    $match = '((r1.oldwins)+(r1.oldlosses)) < (r2.total)';
  }
 	else {
    $column = mysql_real_escape_string(strtolower($column));
    $match = "(r1.{$column} ) < (r2.{$column})";
  }
    
  $sql = "SELECT COUNT(*)+1 AS rank FROM achievements AS r1
    INNER JOIN (SELECT $column FROM achievements)
    AS r2 ON $match
    WHERE r1.user = '$user'";

  $query = mysql_query($sql);

	while ($row = mysql_fetch_object($query)) {
	 $rank = ordinalSuffix($row->rank);
	 return $rank;
	}
}

function event_type($num) {
	if ($num == 1) return 'Win';
	elseif ($num == 2) return 'Loss';
	elseif ($num == 3) return 'Won Stake';
	elseif ($num == 4) return 'Lost Stake';
	elseif ($num == 5) return 'Drop';
	elseif ($num == 6) return 'Buy';
	elseif ($num == 7) return 'Sell';
	elseif ($num == 8) return 'Penalty';
	else return 'Clue';
}

function event_msg($num, $data) {
	if ($num == 1) return 'Defeated <a href="/u/'. urlencode($data) .'">'. htmlentities($data) .'</a>';
	elseif ($num == 2) return 'Got defeated by <a href="/u/'. urlencode($data) .'">'. htmlentities($data) .'</a>';
	elseif ($num == 3) return 'Won '. n2a($data) .' in Stake';
	elseif ($num == 4) return 'Lost '. n2a($data) .' in Stake';
	elseif ($num == 5) return "Won $data";
	elseif ($num == 6) return "Bought $data";
	elseif ($num == 7) return "Sold $data";
	elseif ($num == 8) return 'Recieved a '. n2a($data) .' penalty';
	return 'Clue scroll dropped '. n2a($data);
}


function time_since($date)
{

	$age = time() - $date;

	$days = floor($age/(3600*24));
	$hours = floor($age/3600);
	$minutes = floor($age/60);
	$seconds = $age;
			
	if ($days >= 1) return "$days days ago";
	elseif ($hours >= 1) return "$hours hours ago";
	elseif ($minutes >= 1) return "$minutes mins ago";
	else return "$seconds secs ago";
}

function event_date($time) {
	$date = date("m/d/y h:i:s", $time);
	$timesince = time_since($time);
	return "<abbr title=\"$timesince\">$date</abbr>";
}


function achiv($type, $num) {
	if ($type == wins) {
		if ($num > 5000) $rank = 5;
		elseif ($num >= 3000) $rank = 4;
		elseif ($num >= 2000) $rank = 3;
		elseif ($num >= 1000) $rank = 2;
		elseif ($num >= 500) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == losses) {
		if ($num > 5000) $rank = 5;
		elseif ($num >= 3000) $rank = 4;
		elseif ($num >= 2000) $rank = 3;
		elseif ($num >= 1000) $rank = 2;
		elseif ($num >= 500) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == total) {
		if ($num > 10000) $rank = 5;
		elseif ($num >= 6000) $rank = 4;
		elseif ($num >= 4000) $rank = 3;
		elseif ($num >= 2000) $rank = 2;
		elseif ($num >= 1000) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == money) {
		if ($num > 100000000000) $rank = 5;
		elseif ($num >= 50000000000) $rank = 4;
		elseif ($num >= 20000000000) $rank = 3;
		elseif ($num >= 2000000000) $rank = 2;
		elseif ($num >= 500000000) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == cookies) {
		if ($num > 250) $rank = 5;
		elseif ($num >= 200) $rank = 4;
		elseif ($num >= 150) $rank = 3;
		elseif ($num >= 100) $rank = 2;
		elseif ($num >= 50) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == specpots) {
		if ($num > 250) $rank = 5;
		elseif ($num >= 200) $rank = 4;
		elseif ($num >= 150) $rank = 3;
		elseif ($num >= 100) $rank = 2;
		elseif ($num >= 50) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == pvp) {
		if ($num > 1200) $rank = 5;
		elseif ($num >= 600) $rank = 4;
		elseif ($num >= 300) $rank = 3;
		elseif ($num >= 150) $rank = 2;
		elseif ($num >= 75) $rank = 1;
		else $rank = "0";
	}
	elseif ($type == sitems) {
		$rank = $num;
	}
	return "<div style=\"margin: 5px; background-color: ".aColor($rank)."; border: 1px solid #000000; color: #000;\">".aNum($type,$rank)."</div>";
}

function aColor($num) {
	if ($num == 1) return "#B5E3B5";
	elseif ($num == 2) return "#90D590";
	elseif ($num == 3) return "#649064";
	elseif ($num == 4) return "#4F724F";
	elseif ($num == 5) return "#3A543A";
}

function aCheck($num) {
	if ($num == 1) return "&#10003";
	else return " ";
}

function aNum($type, $num) {
	if ($type == wins) {
		if ($num == 5) $anum = "5000+ Achievement";
		elseif ($num == 4) $anum = "3000+ Achievement";
		elseif ($num == 3) $anum = "2000+ Achievement";
		elseif ($num == 2) $anum = "1000+ Achievement";
		elseif ($num == 1) $anum = "500+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == losses) {
		if ($num == 5) $anum = "5000+ Achievement";
		elseif ($num == 4) $anum = "3000+ Achievement";
		elseif ($num == 3) $anum = "2000+ Achievement";
		elseif ($num == 2) $anum = "1000+ Achievement";
		elseif ($num == 1) $anum = "500+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == total) {
		if ($num == 5) $anum = "10000+ Achievement";
		elseif ($num == 4) $anum = "6000+ Achievement";
		elseif ($num == 3) $anum = "4000+ Achievement";
		elseif ($num == 2) $anum = "2000+ Achievement";
		elseif ($num == 1) $anum = "1000+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == money) {
		if ($num == 5) $anum = "100b+ Achievement";
		elseif ($num == 4) $anum = "50b+ Achievement";
		elseif ($num == 3) $anum = "20b+ Achievement";
		elseif ($num == 2) $anum = "2b+ Achievement";
		elseif ($num == 1) $anum = "500m+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == cookies) {
		if ($num == 5) $anum = "250+ Achievement";
		elseif ($num == 4) $anum = "200+ Achievement";
		elseif ($num == 3) $anum = "150+ Achievement";
		elseif ($num == 2) $anum = "100+ Achievement";
		elseif ($num == 1) $anum = "50+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == specpots) {
		if ($num == 5) $anum = "250+ Achievement";
		elseif ($num == 4) $anum = "200+ Achievement";
		elseif ($num == 3) $anum = "150+ Achievement";
		elseif ($num == 2) $anum = "100+ Achievement";
		elseif ($num == 1) $anum = "50+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == pvp) {
		if ($num == 5) $anum = "1200+ Achievement";
		elseif ($num == 4) $anum = "600+ Achievement";
		elseif ($num == 3) $anum = "300+ Achievement";
		elseif ($num == 2) $anum = "150+ Achievement";
		elseif ($num == 1) $anum = "75+ Achievement";
		else $anum = "No Achievement";
	}
	elseif ($type == sitems) {
		if ($num == 5) $anum = "5 Staff Items";
		elseif ($num == 4) $anum = "4 Staff Items";
		elseif ($num == 3) $anum = "3 Staff Items";
		elseif ($num == 2) $anum = "2 Staff Items";
		elseif ($num == 1) $anum = "1 Staff Items";
		else $anum = "0 Staff Items";
	}
	return $anum;
}

?>
