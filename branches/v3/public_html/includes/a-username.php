<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

$name = isset($_POST['name']) ? trim($_POST['name']) : '';
$confirm = isset($_POST['confirm']) ? intval(trim($_POST['confirm'])) : 0;

// Check to see if this is a confirmation of the new username
$sql = "SELECT * FROM appeal WHERE request_type='username' AND request='$user'";
$request = mysql_query($sql);
if(mysql_num_rows($request) > 0) {
	$change = mysql_fetch_object($request);
	switch($change->status) {
	  case -1:
	    if($confirm == 1) {
	      $sql = "UPDATE appeal SET status=-2 WHERE id={$change->id}";
				mysql_query($sql);
				$message = 'Your request has been confirmed and submitted for staff approval.';
			}
			else {
?>
<form id="name-change-confirmation" method="post" action="/account/cname/">
	<input type="hidden" name="confirm" value="1" />
	<p>To confirm you own this account <input type="submit" value="Click Here" /></p>
</form>
<?php
				return;
			}
		case 0:
		  $message = 'The name change you have requested has been denied.';
		  break;
		case 1:
		  $message = 'The name change you have requested has been accepted.';
		  break;
		case -2:
		  $message = 'The requested name change is pending staff approval.';
		  break;
	}
?>
<p><?=$message?></p>
<?php
	return;
}

if(strlen($name) > 0) {
	$name = mysql_real_escape_string($name);
	$sql = "INSERT INTO appeal (user, request_type, request_date, request)
					VALUES ('$user', 'username', NOW(), '$name')";
	mysql_query($sql);
?>
<p>Your request has been submitted.<br />
	<ol>
	  <li>Log into the IRC channel with your requested username.</li>
	  <li>Request a new account access URL.</li>
	  <li>Log into your new account using the provided URL.</li>
	  <li>Click on the 'Request a name change' link.</li>
	  <li>Follow the instructions on the name change page.</li>
	</ol>
</p>
<?php
	return;
}

// Check to see if this user has already requested a name change
$sql = "SELECT * FROM appeal
				WHERE user = '$user' AND request_type='username' and status=-1";
$request = mysql_query($sql);
if(mysql_num_rows($request) > 0) {
	$change = mysql_fetch_object($request);
?>
<p>You have already submitted a name change.
	<ol>
	  <li>Log into the IRC channel with your requested username (<?=$change->request?>).</li>
	  <li>Request a new account access URL.</li>
	  <li>Log into your new account using the provided URL.</li>
	  <li>Click on the 'Request a name change' link.</li>
	  <li>Follow the instructions on the name change page.</li>
	</ol>
</p>
<?php
	return;
}
?>

<form id="name-change-form" method="post" action="/account/cname/">
	<table>
	  <tr>
	    <td>Current Name:</td>
	    <td><?=$user?></td>
		</tr>
		<tr>
		  <td>Requested Name:</td>
			<td><input type="text" name="name" /></td>
		</tr>
	</table>
	<br />
	<input type="submit" value="Request Change" />
</form>