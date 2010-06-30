<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

$channel_name = mysql_real_escape_string(isset($_POST['channel']) ? trim($_POST['channel']) : '');
$statement = mysql_real_escape_string(isset($_POST['statement']) ? trim($_POST['statement']) : '');

// Build channel list for autocomplete
$sql = "SELECT user FROM blist ORDER BY user";
$result = mysql_query($sql);
?>

<script type="text/javascript">
$(function() {
	var channels = new Array();
<?php
$index = 0;
while(($row = mysql_fetch_object($result)) != NULL) {
?>
	channels[<?=$index++?>] = '<?=$row->user?>';
<?php
}
?>
	$('#channel').autocomplete({
	  source: channels,
	  minLength: 2,
	  select: function(event, ui) {
	    $('#channel').val(ui.item.value);
	    $('#channel-ban-lookup-form').submit();
	  }
	});
});
</script>

<form id='channel-ban-lookup-form' method='post' action='/account/cban/'>
	<div id="channel-ban-div">
		<div class="ui-widget">
		  <label for="channel">Channel Name: </label>
		  <input name="channel" id="channel" type="text" value="<?=$channel_name?>" />
		</div>
	</div>
	<br />
	<input type='submit' value='Lookup' />
</form>
<br />

<?php
if(strlen($channel_name) > 0) {
	$sql = "SELECT * FROM blist where user='$channel_name' LIMIT 1";
	$result = mysql_query($sql);
	if(!$result || mysql_num_rows($result) == 0) {
?>
<p>Channel <em><?=$channel_name?></em> has not been banned.</p>
<?php
		return;
	}
	$ban = mysql_fetch_object($result);
	
	// Has the ban already been appealed?
	$sql = "SELECT *
					FROM appeal
					WHERE request_type='channel' AND channel='$channel_name'
					  AND ban_date = '$ban->time'
					ORDER BY request_date DESC";
	$result = mysql_query($sql);
	if($result && mysql_num_rows($result) > 0) {
	  $appeal = mysql_fetch_object($result);
	  switch($appeal->status) {
	    case -1:
	      $message = 'An appeal has already been submitted and is under review.  Please check back later.';
	      break;
			case 0:
			  $message = 'The appeal has been declined.';
			  break;
			case 1:
			  $message = 'The appeal has been accepted.';
			  break;
	 	}
?>
<p>Channel <em><?=$channel_name?></em> appeal status:<br />
<ul>
	<li><?=$message?></li>
<ul>
<?php
		return;
	}
	
	// Do we have a statement to process?
	if(strlen($statement) > 0) {
		$sql = "INSERT INTO appeal (user, channel, request_type, ban_date, reason, request_date, request)
		        VALUES ('$user', '$channel_name', 'channel', '$ban->time', '$ban->reason', NOW(), '$statement')";
		mysql_query($sql);

?>
<p>Your appeal for Channel <em><?=$channel_name?></em> has been submitted for review.</p>
<?php
		return;
	}
?>
<form id="channel-appeal-form" method="post" action="/account/cban/">
	<input type="hidden" name="channel" value="<?=$channel_name?>" />
	<table>
	  <tr>
	    <td>IRC Name:</td>
	    <td><?=$user?></td>
		</tr>
		<tr>
		  <td>Channel:</td>
			<td><?=$channel_name?></td>
		</tr>
		<tr>
		  <td>Reason:</td>
		  <td><?=$ban->reason?></td>
		</tr>
		<tr>
		  <td>Issued By:</td>
		  <td><?=$ban->who?></td>
		</tr>
		<tr>
		  <td>Approx. Date:</td>
		  <td><?=$ban->time?></td>
		</tr>
	</table>
	<p>Please provide a statement to admins.<br />
	  <textarea name="statement"></textarea>
	</p>
	<br />
	<input type="submit" value="Submit" />
</form>
<?php
}
?>