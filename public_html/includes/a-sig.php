<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}
$image = isset($_POST['image']) ? trim($_POST['image']) : '';
$link = isset($_POST['link']) ? trim($_POST['link']) : '';
$message = '';

if(strlen($image) > 0) {
	// Verify this is a valid url
	$pattern = "/http\:\/\/[[:alnum:]]*\.(imageshack\.us|photobucket\.com)\/.*/";
	if(filter_var($image, FILTER_VALIDATE_URL)) {
	  if(preg_match($pattern, $image) > 0) {
		  $image = mysql_real_escape_string($image);
			$sql = "UPDATE user SET image = '$image' WHERE user = '$user'";
			mysql_query($sql);
			$message .= 'Your signature image has been saved.<br />';
		}
		else {
		  $message .= 'All images must be hosted on imageshack.us or photobucket.com<br />';
		}
	}
	else {
	  $message .= 'The image url is invalid.<br />';
	}
}

if(strlen($link) > 0) {
	// Verify this is a valid url
	if(filter_var($link, FILTER_VALIDATE_URL)) {
	  $link = mysql_real_escape_string($link);
	  $sql = "UPDATE user SET link = '$link' WHERE user = '$user'";
	  mysql_query($sql);
	  $message .= 'Your signature link has been saved.<br />';
	}
	else {
	  $message .= 'The signature link is invalid.';
	}
}

$sql = "SELECT * FROM user WHERE user LIKE '$user' LIMIT 1";
$result = mysql_query($sql);
if(!$result || mysql_num_rows($result) == 0) {
?>
<p>Unable to locate your user record.  Please contact an admin for further support.</p>
<?php
	return;
}

$userData = mysql_fetch_object($result);
?>
<h1>Account Signature Change</h1>
<p>
	<h3><?=$message?></h3>
</p>
<div id="existing-signature">
<p>Your current signature is as follows:</p>
<p>Image URL: <code><?=$userData->image?></code><br /><br />
<img src="<?=$userData->image?>" alt="No Image Found" />
</p>
<p>Signature Link: <a href="<?=$userData->link?>" target="_blank"><?=$userData->link?></a><br />
</p>
</div>

<h2>To change your signature, enter the new urls below</h2>
<form id="sig-change-form" method="post" action="/account/sig/">
	<table>
	  <tr>
	    <td>Image URL:</td>
	    <td><input type="text" name="image" /></td>
		</tr>
		<tr>
		  <td>Signature Link:</td>
		  <td><input type="text" name="link" /></td>
		</tr>
	</table>
	<br />
	<input type="submit" value="Update" />
</form>
