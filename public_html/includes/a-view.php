<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

$id = isset($_POST['id']) ? (int)$_POST['id'] : 0;

if(!$id) {
	echo "Invalid request.  Please try again.";
	return;
}

$result = mysql_query("SELECT * FROM appeal WHERE id=$id LIMIT 1");
if(!$result || mysql_num_rows($result) == 0) {
	echo "No record found.  If this problem continues, please contact a member of staff.";
	return;
}

$row = mysql_fetch_object($result);
?>
<table>
	<tbody>
<?php
switch($row->request_type) {
	case 'user':
		$table = array(
			array('Ban Type: ', 'User'),
			array('Ban Date: ', $row->ban_date),
			array('Reason: ', $row->reason),
			array('Statement: ', $row->request),
		);
		switch($row->status) {
		  case 'p':
		    $table[] = array('Status: ', 'Pending staff approval');
		    break;
			case 'a':
			  $table[] = array('Status: ', 'Ban appeal accepted');
			  $table[] = array('Processed by: ', $row->processed_by);
			  break;
			case 'd':
			  $table[] = array('Status: ', 'Ban appeal denied');
			  $table[] = array('Processed by: ', $row->processed_by);
			  $table[] = array('Explanation: ', $row->explanation ? $row->explanation : 'None given');
			  break;
		}
		break;
	case 'channel':
	  $table = array(
	    array('Ban Type: ', 'Channel'),
	    array('Ban Date: ', $row->ban_date),
	    array('Reason: ', $row->reason),
	    array('Appealed by: ', $row->user),
	    array('Statement: ', $row->request),
		);
		switch($row->status) {
		  case 'p':
		    $table[] = array('Status: ', 'Pending staff approval');
		    break;
			case 'a':
			  $table[] = array('Status: ', 'Ban appeal accepted');
			  $table[] = array('Processed by: ', $row->processed_by);
			  break;
			case 'd':
			  $table[] = array('Status: ', 'Ban appeal denied');
			  $table[] = array('Processed by: ', $row->processed_by);
			  $table[] = array('Explanation: ', $row->explanation ? $row->explanation : 'None given');
			  break;
		 }
	 	break;
	case 'username':
		$table = array(
		  array('Request Type: ', 'Username change'),
		  array('Request Date: ', $row->request_date),
		);
		switch($row->status) {
		  case 'u':
		    $table[] = array('Current Name: ', $user);
		    $table[] = array('Requested Name: ', $row->request);
		    $table[] = array('Status: ', 'Unconfirmed');
		    break;
		  case 'p':
				$table[] = array('Current Name: ', $user);
				$table[] = array('Requested Name: ', $row->request);
				$table[] = array('Status: ', 'Pending Approval');
				break;
			case 'c':
			  $table[] = array('Current Name: ', $user);
			  $table[] = array('Requested Name: ', $row->request);
			  $table[] = array('Status: ', 'Canceled by User');
			  break;
			case 'a':
			  $table[] = array('New Name: ', $user);
			  $table[] = array('Old Name: ', $row->request);
			  $table[] = array('Status: ', 'Request Approved');
			  $table[] = array('Processed By: ', $row->processed_by);
			  $table[] = array('Process Date: ', $row->processed_date);
			  break;
			case 'd':
			  $table[] = array('Current Name: ', $user);
			  $table[] = array('Requested Name: ', $row->request);
			  $table[] = array('Status: ', 'Request Denied');
			  $table[] = array('Processed By: ', $row->processed_by);
			  $table[] = array('Process Date: ', $row->processed_date);
			  $table[] = array('Explanation: ', $row->explanation);
			  break;
		}
		break;
}

$index = 1;
foreach($table as $ptr) {
	$class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=$ptr[0]?></td>
		  <td><?=$ptr[1]?></td>
		</tr>
<?php
}
?>
	</tbody>
</table>
