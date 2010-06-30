<?PHP
session_start();

// unset all session variables and destroy the session\
function destroySession() {
	session_unset();
	session_destroy();
}

function verifySession() {
	$sessionID = session_id();
	if(isset($_GET['code'])) {
		$code = mysql_real_escape_string($_GET ['code']);
		// Validate code against db
		$sql = "SELECT user, account, time, TIMESTAMPDIFF(MINUTE, time, NOW()) AS diff
					  FROM urlmap WHERE user = '$code'  AND session = '' LIMIT 1";
		$result = mysql_query($sql);
		if(!$result || mysql_num_rows($result) == 0) {
		  destroySession();
	    return array('status' => FALSE, 'message' => 'Invalid Access Code');
		}

		$sessionData = mysql_fetch_object($result);
		$sql = "UPDATE urlmap SET session = '$sessionID',
		          time = NOW(),
							ip_address = '$_SERVER[REMOTE_ADDR]'
						WHERE user = '$code'";
		mysql_query($sql);
		if($sessionData->diff > 20) {
		  destroySession();
	    return array('status' => FALSE, 'message' => 'Invalid Access Code');
		}

		$_SESSION['code'] = $code;
    return array('status' => TRUE, 'message' => '<script type="text/javascript">window.location = "/account/";</script>', 'session' => $session);
	}
	elseif(isset($_SESSION['code'])) {
		$sql = "SELECT user, account, time, ip_address,
							TIMESTAMPDIFF(MINUTE, time, NOW()) AS diff, rank
					  FROM urlmap
						LEFT JOIN(
						  SELECT user AS hostmask, rank
						  FROM admins
						) a USING(hostmask)
						WHERE user = '$_SESSION[code]' AND session = '$sessionID' LIMIT 1";
		$result = mysql_query($sql);
		if(!$result || mysql_num_rows($result) == 0) {
		  destroySession();
		  return array('status' => FALSE, 'message' => 'The session has expired');
		}
		
		$session = mysql_fetch_object($result);
		// Verify first 6 chars of IP
		if(substr($session->ip_address, 0, 6) !=
		  substr($_SERVER['REMOTE_ADDR'], 0, 6)) {
		    destroySession();
		    return array('status' => FALSE, 'message' => 'Invalid IP Address');
		 }
		 // verify access within 15 minutes
		 elseif($session->diff > 15) {
		  destroySession();
	    return array('status' => FALSE, 'message' => 'Session Timeout');
		}
		// valid session
		else {
		  $sql = "UPDATE urlmap SET time = NOW() WHERE user = '$_SESSION[code]'";
			mysql_query($sql);
	    return array('status' => TRUE, 'message' => '', 'session' => $session );
		}
	}
	else {
    return array('status' => FALSE, 'message' => 'Invalid Page Access');
	}
}


