<?php

if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

if($session['session']->rank <= ADMIN_RANK) {
	echo "Invalid page access";
	return;
}

//Fixing apache/php handling of urls with %23 - treat $GET as $_GET
parse_str ($_SERVER['REDIRECT_QUERY_STRING'], $GET);
if(isset($GET['name'])) {
	$name = $GET['name'];
}
else {
	$name = isset($_POST['name']) ? trim($_POST['name']) : '';
}

if($name) {
	$name = mysql_real_escape_string($name);
	$table = array();
	$isChannel = FALSE;
	
	// Is this a channel?
	if(strpos($name, '#') === FALSE) {
	  $sql = "(SELECT user, time AS ban_date, who AS banned_by, reason,
							'' AS request_date, '' AS processed_by, '' AS processed_date,
							'' AS explanation, '' AS status
						FROM ilist WHERE user='$name')
						UNION
						(SELECT user, ban_date, banned_by, reason, request_date,
							processed_by, processed_date, explanation, status
						FROM appeal WHERE user='$name' AND request_type='user')
						ORDEr BY ban_date DESC";
	  $result = mysql_query($sql);
	  while(($row = mysql_fetch_object($result)) != NULL) {
	    $table[] = $row;
		}
	}
	else {
	  $isChannel = TRUE;
	  $sql = "(SELECT '' AS user, user AS channel, time AS ban_date,
							who AS banned_by, reason, '' AS request_date, '' AS processed_by,
							'' AS processed_date, '' AS explanation, '' AS status
						FROM blist WHERE user='$name')
						UNION
						(SELECT user, channel, ban_date, banned_by, reason, request_date,
						  processed_by, processed_date, explanation, status
						FROM appeal WHERE channel='$name' AND request_type='channel')
						ORDER BY ban_date DESC";
	  $result = mysql_query($sql);
	  while(($row = mysql_fetch_object($result)) != NULL) {
	    $table[] = $row;
		}
	}
	
	if(sizeof($table) == 0) {
	  echo "<p>No bans found for $name.</p>";
	}
	else {
?>
<h2>Ban history for <?=$name?></h2>
<br />
<table class="table-stats">
	<thead>
	  <tr>
	    <th>Ban Date</th>
	    <th>Reason</th>
	    <th>Banned By</th>
<?php
		if($isChannel) {
?>
	    <th>Appealed by</th>
<?php
		}
?>
			<th>Appeal Date</th>
			<th>Explanation</th>
			<th>Appeal Status</th>
		</tr>
	</thead>
	<tbody>
<?php
		foreach($table as $index => $row) {
		$class = ($index % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=$row->ban_date?></td>
		  <td><?=$row->reason?></td>
		  <td><?=$row->banned_by?></td>
<?php
			if($isChannel) {
?>
			<td><?=$row->user ? $row->user : 'N/A'?></td>
<?php
			}
?>
			<td><?=$row->request_date ? $row->request_date : 'N/A'?></td>
			<td><?=$row->explanation ? $row->explanation : 'N/A'?></td>
<?php
			switch($row->status) {
			  case 'p':
			    echo '<td>Pending Review</td>';
			    break;
				case 'a':
				  echo '<td>Appeal Accepted</td>';
				  break;
				case 'd':
				  echo '<td>Appeal Denied</td>';
				  break;
				default:
				  echo '<td>N/A</td>';
				  break;
			}
?>
		</tr>
<?php
		}
?>
	</tbody>
</table>
<?php
	}
}
// Retrieve a list of all bans in the db
$sql = "(SELECT DISTINCT(user) FROM blist)
				UNION
				(SELECT DISTINCT(user) FROM ilist)
				UNION
				(SELECT DISTINCT(user) FROM appeal)
				ORDER BY user";
$result = mysql_query($sql);
$userList = array();
while(($row = mysql_fetch_object($result)) != NULL) {
	$userList[] = $row->user;
}

?>
<script type="text/javascript">
$(function() {
	var userList = <?=json_encode($userList)?>;
	$('#name').autocomplete({
	  source: userList,
	  minLength: 2,
	  select: function(event, ui) {
			$('#name').val(ui.item.value);
			$('#ban-name-lookup-form').submit();
		}
	});
});
</script>
<h3>Ban History Lookup</h3>
<form id="ban-name-lookup-form" method="post" action="/account/history/">
	<label for="name">Username / Channel name: </label>
	<input type="text" id="name" name="name" />
	<input type="submit" value="Lookup" />
</form>