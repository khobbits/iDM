<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

if($session['session']->rank < ADMIN_RANK) {
	echo "Invalid page access";
	return;
}

define('CHANGE_FEE', 5);

$operation = isset($_POST['operation']) ? strtolower(trim($_POST['operation'])) : '';
$username = isset($_POST['user']) ? mysql_real_escape_string(trim($_POST['user'])) : '';
$fee = isset($_POST['fee']) ? (100-CHANGE_FEE)/100 : 1;

if(($operation && !$username) || (!$operation && $username)) {
	echo 'Invalid operation.';
}
elseif($operation && $username) {

	// Verify the user is eligible for a name change
	$sql = "SELECT * FROM appeal
					WHERE request_type='username' AND status='p' AND user='$username'
					LIMIT 1";
	$result = mysql_query($sql);
	if(!$result || mysql_num_rows($result) == 0) {
	  echo "The specified user <em>$username</em> is not eligible for a name change";
	}
	else {
 		$row = mysql_fetch_object($result);
 		
		switch($operation) {
			case 'approve':
			  mysql_query("DELETE FROM user where user='$row->request'");
				mysql_query("UPDATE user SET user='$row->request', money=ROUND(user*$fee) WHERE user='$username'");
			  mysql_query("DELETE FROM equip_item where user='$row->request'");
				mysql_query("UPDATE equip_item SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM equip_pvp where user='$row->request'");
				mysql_query("UPDATE equip_pvp SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM equip_armour where user='$row->request'");
				mysql_query("UPDATE equip_armour SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM equip_staff where user='$row->request'");
				mysql_query("UPDATE equip_staff SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM clantracker where owner='$row->request'");
				mysql_query("UPDATE clantracker SET owner='$row->request' WHERE owner='$username'");
			  mysql_query("DELETE FROM user_log where user='$row->request'");
				mysql_query("UPDATE user_log SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM user_log_archive where user='$row->request'");
				mysql_query("UPDATE user_log_archive SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM user_log_total where user='$row->request'");
				mysql_query("UPDATE user_log_total SET user='$row->request' WHERE user='$username'");
			  mysql_query("DELETE FROM achievements where user='$row->request'");
				mysql_query("UPDATE achievements SET user='$row->request' WHERE user='$username'");
				mysql_query("UPDATE appeal SET user='$row->request', request='$username', status='a', processed_by='$user', processed_date=NOW() WHERE id=$row->id");
				mysql_query("UPDATE appeal SET user='$row->request' WHERE user='$username' AND id<>$row->id");
				echo 'The username has been successfully changed.';
				break;
			case 'deny':
			  mysql_query("UPDATE appeal SET status=0 WHERE id=$row->id");
			  echo "The namechange for <strong>$username</strong> has been denied";
        break;
			default:
			  echo 'Invalid operation.';
			  break;
	  }
  }
}

$sql = "SELECT * FROM appeal
				WHERE request_type='username' AND status='p'
				ORDER BY request_date ASC";
$result = mysql_query($sql);

?>

<h2>Usename Change Requests</h2>

<?php
if(!$result || mysql_num_rows($result) == 0) {
  echo "There are no pending username change requests.";
}
else {
?>
<table class="table-user">
	<thead>
		<tr>
		  <th>Current Name</th>
		  <th>Requested Name</th>
		  <th>Request Date</th>
			<th>Operations</th>
		</tr>
	</thead>
	<tbody>
<?
	$index = 1;
	while(($row = mysql_fetch_object($result)) != NULL) {
	  $class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><a href="http://idm-bot.com/account/history/<?=rawurlencode($row->user)?>" target="_blank">
      <?=$row->user?></a></td>
		  <td><a href="http://idm-bot.com/account/history/<?=rawurlencode($row->request)?>" target="_blank">
      <?=$row->request?></a></td>
		  <td><?=$row->request_date?></td>
		  <td>
		    <form method="post" action="/account/nchange/">
		      <input type="hidden" name="user" value="<?=$row->user?>" />
			    <input type="submit" name="operation" value="Approve" />
			    &nbsp;
			    <input type="submit" name="operation" value="Deny" />
			    <br />
			    <input type="checkbox" value="fee" />Apply <?=CHANGE_FEE?>% fee
				</form>
			</td>
		</tr>
<?
	}
	?>
	</tbody>
</table>
  <?
}
?>
