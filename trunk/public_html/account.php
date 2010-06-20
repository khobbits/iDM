<?PHP
$session = verifySession();
echo $session['message'];
if ($session['status'] == TRUE) {
	$user = $session['session']->account;
?>

<h1>iDM Account Management</h1>
<h2>Welcome <?=$user?></h2>

<?

	if(isset($_GET['sub'])) {
	echo "<p><a href=\"/account/\">.. Back to account.</a></p>";
	
		switch($_GET['sub']) {
		  case 'uban':
		    include 'includes/a-userban.php';
		    break;
			case 'cban':
			  include 'includes/a-channelban.php';
			  break;
			case 'search':
			  include 'includes/a-channelsearch.php';
			  break;
		}
	}
	else {
?>
<p>From this account management panel you will be able to edit user details and appeal an user or channel ban.</p>
<p></p>
<p>Please select an option below:</p>
<ul>
  <li><h3>Change account details</h3>
    <ul>
    <li><a href="/account/sig/">Change profile signature</a></li>
    <li><a href="/account/cname/">Request a name change</a></li>
    <li><a href="/account/cookie/">Buy something with cookies</a></li>
    </ul>
  </li>

  <li><h3>Appeal a ban</h3>
    <ul>
    <li><a href="/account/cban/">Appeal a channel ban</a></li>
    <li><a href="/account/uban/">Appeal a suspended account</a></li>
    </ul>
  </li>


<?
	}
}
?>