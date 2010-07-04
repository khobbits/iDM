<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

$action = isset($_POST['action']) ? strtolower(trim($_POST['action'])) : '';
$value = isset($_POST['value']) ? trim($_POST['value']): '';
?>
<h2>Username Change</h2>
<?php
switch($action) {
	case 'name':
	  // Check name field
	  if(!$value) {
	    displayChangeForm($user, 'name');
		}
		
	  // Submit the name
	  $name = mysql_real_escape_string(strtolower($value));
	  $sql = "INSERT INTO appeal (user, request_type, request_date, request, status)
	          VALUES ('$user', 'username', NOW(), '$name', 'u')";
		mysql_query($sql);
		$id = mysql_insert_id();
		
	  // Display instructions for performing confirmation
	  displayConfirmationInstructions($value, $id);
	  break;
	case 'cancel':
	  // Verify the ability to cancel the request
	  if(!is_int($value))
	  {
	    echo "<p>An invalid request was made.</p>";
	    return;
		}
		$result = mysql_query("SELECT * FROM appeal WHERE id=$value LIMIT 1");
		if(!$result || mysql_num_rows($result) == 0) {
			echo "<p>There was a problem retrieving your information.  If this continues, please contact a member of staff.</p>";
			return;
		}
		
		$request = mysql_fetch_object($result);
		switch($request->status) {
		  case 'a':
		    echo "<p>Your request has already been processed and approved.  If you wish to revert, you must submit another request</p>";
		    displayChangeForm($user, 'name');
		    return;
			case 'd':
			  echo "<p>Your request has already been denied.  You must continue to use your original username</p>";
			  break;
			default:
				mysql_query("UPDATE appeal SET status='c' WHERE id=$value");
				echo "</p>Your request has been successfully canceled.  You must coninue to use your original username</p>";
				break;
		}
		destroySession();
	  break;
	case 'confirm':
	  $id = isset($_POST['id']) ? $_POST['id'] : 0;
	  if(!$id) {
	    echo "An error has occured processing your request.  If this continues to happen, please contact a member of staff.";
	    return;
	  }
	  
	  // Verify the ability to confirm/deny
	  $sql = "SELECT * FROM appeal WHERE id=$id AND request='$user' AND status LIKE 'u' LIMIT 1";
	  $result = mysql_query($sql);
	  if(!$result || mysql_num_rows($result) == 0) {
	    echo "There was a problem locating your request.  If this continues, please contact a member of staff.";
	    return;
		}
	  switch(strtolower($value)) {
	    case 'confirm':
			  // Store confirmation
	      $sql = "UPDATE appeal SET status='p' WHERE id=$id AND status LIKE 'u'";
	      $result = mysql_query($sql);
	      
			  // Display confirmation
				echo "<p>You have successfully confirmed your request.  It is now awaiting staff approval.</p>";
	  
	  		// Display cancel option
	  		displayCancelationForm($id);
	  		break;
			case 'deny':
			  // Cancel the confirmation
			  mysql_query("UPDATE appeal SET status='c' WHERE id=$id");
			  echo "<p>Your request has been successfully canceled.  To submit a new request, you must log in using your original username.</p>";
			  destroySession();
			  break;
			default:
			  echo "<p>An unknown error has occured.  Please try again.</p>";
			  break;
		}
	  break;
	default:
	  // Is there a pending name change?
	  $sql = "SELECT * FROM appeal WHERE request='$user' AND request_type='username' AND status='p' LIMIT 1";
	  $result = mysql_query($sql);
	  if(mysql_num_rows($result)) {
	    $request = mysql_fetch_object($result);
			echo "<p>Your request for a name change has already been submitted for staff approval.</p>";
			displayCancelationForm($request->id);
	    return;
	  }
	  
	  // Is this an attempt at confirmation
		$sql = "SELECT * FROM appeal WHERE request='$user' AND request_type='username' AND status='u' LIMIT 1";
		$result = mysql_query($sql);
		if(mysql_num_rows($result)) {
		  $request = mysql_fetch_object($result);
		  
		  // Display confirmation form
		  displayConfirmationForm($request);
	    return;
		}
		
		displayChangeForm($user, 'name');
}
	
function displayChangeForm($name, $action) {
?>
<form id="name-change-form" method="post" action="/account/cname/">
	<input type="hidden" name="action" value="<?=$action?>" />
	<table>
	  <tr>
	    <td>Current Name:</td>
	    <td><?=$name?></td>
		</tr>
		<tr>
		  <td>Requested Name:</td>
			<td><input type="text" name="value" /></td>
		</tr>
	</table>
	<br />
	<input type="submit" value="Request Change" />
</form>
<?php
}

function processCancel($id) {
	//Check to see if the request has already been processed
	$sql = "SELECT status FROM appeal WHERE id=$id LIMIT 1";
	$result = mysql_query($sql);
	if(!$result || mysql_num_rows($result) == 0) {
	  return "There was a problem processing your request.  If this continues, please contact a member of staff.";
	}
	
	switch(mysql_result($result, 0)) {
	  case 'u':
	  case 'p':
			mysql_query("UPDATE appeal SET status='c' WHERE id=$id");
			return "Your request has been successfully canceled.";
		case 'a':
		  return "Your request has already been processed and approved.  If you would like to change your name back, please submit a new request.";
		case 'd':
		  return "Your request has already been processed and denied.  There is no further action required.";
	}
}

function processName($user, $name) {
	// Check to see if this is a confirmation of the new username
	$sql = "SELECT * FROM appeal WHERE request_type='username' AND request='$user'";
	$request = mysql_query($sql);

	if(strlen($name) > 0) {
		$name = mysql_real_escape_string(strtolower($name));
		$sql = "INSERT INTO appeal (user, request_type, request_date, request, status)
						VALUES ('$user', 'username', NOW(), '$name', 'u')";
		mysql_query($sql);
		$id = mysql_insert_id();
?>
<p>Your request has been submitted.<br />
<?php
		displayConfirmationInstructions($name, $id);
	}
}

function displayConfirmationInstructions($name, $id, $message='') {
?>
<p><?=$message?></p>
<ol>
  <li>Log into the IRC channel with your requested username (<?=$name?>).</li>
  <li>Request a new account access URL.</li>
  <li>Log into your new account using the provided URL.</li>
  <li>Click on the 'Request a name change' link.</li>
  <li>Follow the instructions on the name change page.</li>
</ol>
<?=displayCancelationForm($id)?>
<?php
}

function displayCancelationForm($id) {
?>
<form method="post" action="/account/cname/">
	<input type="hidden" name="action" value="cancel" />
	<input type="hidden" name="value" value="<?=$id?>" />
	<p><input type="submit" value="Click here" /> if you would like to cancel your request.</p>
</form>
<?php
}

function displayConfirmationForm($request) {
?>
<form method="post" action="/account/cname/">
	<input type="hidden" name="action" value="confirm" />
	<input type="hidden" name="id" value="<?=$request->id?>" />
	<table>
		<tr>
			<td>Current Name:</td>
			<td><?=$request->user?></td>
		</tr>
		<tr>
			<td>Requested Name:</td>
			<td><?=$request->request?></td>
		</tr>
	</table>
	<p>
		To confirm the request click confirm below. <br />
		All items/money on the new account will be erased once your request has been approved by staff.
	</p>
	<input type="submit" name="value" value="Confirm" />
	<input type="submit" name="value" value="Deny" />
</form>
<?php
}

function checkChangeStatus($name) {
	// Check to see if this user has already requested a name change
	$sql = "SELECT * FROM appeal
					WHERE user = '$name' AND request_type='username' AND status IN ('u','p')
					LIMIT 1";
	$request = mysql_query($sql);
	if(mysql_num_rows($request) > 0) {
		$change = mysql_fetch_object($request);
		echo '<p>You have already requested a name change.</p>';
		displayConfirmationInstructions($change->request, $change->id);
		return FALSE;
	}
	
	// Check to see if the is a confirmation check
	$sql = "SELECT * FROM appeal
	        WHERE request = '$name' AND request_type='username' AND status IN ('u','p')
	        LIMIT 1";
	$request = mysql_query($sql);
	if(mysql_num_rows($request) > 0) {
	  $change = mysql_fetch_object($request);
	  switch($change->status) {
	    case 'u':
?>
<form id="name-change-confirmation" method="post" action="/account/cname/">
		<table>
	  <tr>
	    <td>Current Name:</td>
	    <td><?=$change->user?></td>
		</tr>
		<tr>
		  <td>Requested Name:</td>
			<td><?=$change->request?></td>
		</tr>
	</table>
 	<p>
  To confirm the request click confirm below. <br />
  All items/money on the new account will be erased once staff has approved your request.
  </p>
  <input type="submit" name="confirm" value="Confirm" />
	<input type="submit" name="confirm" value="Cancel" />
</form>
<?php
				return false;
			case 'p':
			  mysql_query("UPDATE appeal SET status='p' WHERE id={$change->id}");
			  echo 'Your request has been successfully submitted for staff approval.';
			  return true;
		}
	}
}
?>