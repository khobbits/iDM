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
	$('#channelbox').autocomplete({
	  source: channels,
	  minLength: 4,
	  select: function(event, ui) {
	    $('#channelbox').val(ui.item.value);
	    $('#channel-ban-lookup-form').submit();
	  }
	});
});
</script>
<h2>Channel Ban Lookup</h2>
<form id='channel-ban-lookup-form' method='post' action='/account/cban/'>
	<div id="channel-ban-div">
		<div class="ui-widget">
		  <label for="channel">Channel Name: </label>
		  <input name="channel" id="channelbox" type="text" value="<?=$channel_name?>" width="40" />
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
					  AND ban_date = '$ban->time' AND status='p'
					ORDER BY request_date DESC";
	$result = mysql_query($sql);
	if($result && mysql_num_rows($result) > 0) {
	  $message = 'An appeal has already been submitted and is under review.  Please check back later.';
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
		$sql = "INSERT INTO appeal (user, channel, request_type, ban_date, banned_by, reason, request_date, request)
		        VALUES ('$user', '$channel_name', 'channel', '$ban->time', '$ban->who', '$ban->reason', NOW(), '$statement')";
		mysql_query($sql);
		msgsupport("An appeal by $user was submitted for a ban against $channel_name issued by $ban->who on $ban->time");

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
	    <td class="view-header">IRC Name:</td>
	    <td class="view-detail"><?=$htmluser?></td>
		</tr>
		<tr>
		  <td class="view-header">Channel:</td>
			<td class="view-detail"><?=$channel_name?></td>
		</tr>
		<tr>
		  <td class="view-header">Reason:</td>
		  <td class="view-detail"><?=$ban->reason?></td>
		</tr>
		<tr>
		  <td class="view-header">Issued By:</td>
		  <td class="view-detail"><?=$ban->who?></td>
		</tr>
		<tr>
		  <td class="view-header">Approx. Date:</td>
		  <td class="view-detail"><?=$ban->time?></td>
		</tr>
	</table>
	<p>Please provide a statement to admins.<br />
	  <textarea name="statement" class="ban-statement" cols="50" rows="5"></textarea>
	</p>
	<br />
	<input type="submit" value="Submit" />
</form>
<?php
}
?>