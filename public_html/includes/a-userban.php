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
					AND status='p'
				ORDER BY request_date DESC";
$result = mysql_query($sql);
if($result && mysql_num_rows($result) > 0) {
	echo "<p>Your appeal has not been processed yet.  Please check again later.</p>";
	return;
}

$statement = (isset($_POST['additional']) ? trim($_POST['additional']) : '');
if(strlen($statement) == 0) {
?>
<h2>User Ban Appeal</h2>
<p>If you have been banned, please fill out the following form.</p>
<form id="a-userban-form" name="a-userban-form" action="/account/uban/" method="post">
	<table class="table-stats">
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
		  <td><?=$ban->who?></td>
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
 	$sql = "INSERT INTO appeal (user, request_type, ban_date, banned_by, reason, request_date, request)
        values ('$user', 'user', '$ban->time', '$ban->who', '$ban->reason', NOW(), '$statement')";

	mysql_query($sql);
	msgsupport("An appeal by $user was submitted for a ban issued by $ban->who on $ban->time");
?>
<p>Your request has been successfully submitted for review.</p>
<?php
}
?>