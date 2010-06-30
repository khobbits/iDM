<?php

if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

$sql = "SELECT * FROM ilist WHERE user='$user' LIMIT 1";
$result = mysql_query($sql);
if(!$result || mysql_num_rows($result) == 0) {
	echo "No ban information found";
	return;
}

$ban = mysql_fetch_object($result);

// Check to see if this ban has already been appealed?
$sql = "SELECT * FROM appeal
				WHERE user = '$user'
					AND request_type = 'user'
					AND ban_date = '$ban->time'
				ORDER BY request_date DESC";
$result = mysql_query($sql);
if($result && mysql_num_rows($result) > 0) {
	$appeal = mysql_fetch_object($result);
	switch($appeal->status) {
	  case -1:
			$message = 'Your appeal has not been processed yet.  Please check again later.';
			break;
		case 0:
		  $message = 'Your appeal has been denied.';
		  break;
		case 1:
		  $message = 'Your appeal has been accepted.';
		  break;
	}
?>
<p><?=$message?></p>
<?php
	return;
}
else {
	$statement = (isset($_POST['additional']) ? trim($_POST['additional']) : '');
	if(strlen($statement) == 0) {
?>

<h1>User Ban Appeal</h1>
<p>If you have been banned, please fill out the following form.</p>
<form id="a-userban-form" name="a-userban-form" action="/account/uban/" method="post">
	<table>
		<tr>
			<td>IRC Name:</td>
			<td><?=$user?></td>
		</tr>
		<tr>
		  <td>Reason:</td>
		  <td><?=$ban->reason?></td>
		</tr>
		<tr>
		  <td>Issued by:</td>
		  <td><?=$ban->user?></td>
		</tr>
		<tr>
		  <td>Approx. Date:</td>
		  <td><?=$ban->time?></td>
		</tr>
	</table>
	<p>Please provide a statement to admins.<br />
	  <textarea name="additional"></textarea>
	</p>
	<br />
	<input type="submit" value="Submit" />
</form>
<?php
	}
	else {
		$statement = mysql_real_escape_string($statement);
	 	$sql = "INSERT INTO appeal (user, request_type, ban_date, reason, request_date, request)
	        values ('$user', 'user', '$ban->time', '$ban->reason', NOW(), '$statement')";

		mysql_query($sql);
?>
<p>Your request has been successfully submitted for review.</p>
<?php
	}
}
?>