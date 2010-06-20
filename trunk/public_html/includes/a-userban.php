<?php

$session = validateSession();
if($session->status == FALSE) {
	echo "No direct access";
	exit;
}

$user = $session->session['acount'];
$sql = "SELECT * FROM ilist WHERE user='$user' LIMIT 1";
$result = mysql_query($sql);
if(!$result || mysql_num_rows($result) == 0) {
	echo "No ban information found";
	exit;
}

$ban = mysql_fetch_object($result);
?>

<h1>User Ban Appeal</h1>
<p>If you have been banned, please fill out the following form.</p>
<form id="a-userban-form" action="" method="post">
	<table>
		<tr>
			<td>IRC Name:</td>
			<td><?=$user?></td>
		</tr>
		<tr>
		  <td>Reason:</td>
		  <td><input type="textarea" name="reason" /></td>
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
	<p>Please provide any additional information to admins.<br />
	  <input type="textarea" name="additional" />
	</p>
	<br />
	<input type="submit" value="Submit" />
</form>