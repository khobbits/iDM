<?

function msgchan ($chan, $action, $user, $message) {
  include_once('includes/bnc/sbnc.php');
  $sbnc = new SBNC("127.0.0.1", 12000, "admin", 'Sp4rh4wk`Gh0$t`');
  $result = $sbnc->CallAs('admin', tcl, array( 'captchareturn ' . $chan . ' ' . $action . ' ' . $user . ' {' . $message . '}'));
  $sbnc->Destroy();
  return var_export($result,true);
}

function failcaptcha ($chan, $user) {
  $reply =  msgchan($chan, '!kb ', $user, 'Failed CAPTCHA');
  if ($reply != "'1'") {
    echo 'Error: ' . $reply;
  }
  else {
    echo 'Sorry, wrong answer.';
  }
}

function passcaptcha ($chan, $user) {
  $reply = msgchan($chan, '!voice ', $user, '');
  if ($reply != "'1'") {
    echo 'Error: ' . $reply;
  }
  else {
    echo 'You will be voiced in a moment.';
  }
}

$answer = isset($_POST['answer']) ? (trim($_POST['answer'])) : '';
$chan = isset($_REQUEST['chan']) ? (trim($_REQUEST['chan'])) : '';
$user = isset($_REQUEST['user']) ? (trim($_REQUEST['user'])) : '';

?>

<html>
<title><?=$chan?> CAPTCHA</title>
<body>
<h1><?=$chan?> CAPTCHA</h1>

<?

if ((!$user) || (!$chan)) {
  die ("<p>I'm sorry but this URL is invalid, please try again</p></body></html>");
}

if ($answer) {
  if ($answer == '2') {
    passcaptcha ($chan, $user);
  }
  else {
    failcaptcha ($chan, $user);
  }
}
else {
?>


<h2>Complete the form below if you need voice</h2>


	      <form method="post" action="captcha.php">
    		<input type="hidden" name="user" value="<?=$user?>" />
        <input type="hidden" name="chan" value="<?=$chan?>" />
        Are you intending to spam, or otherwise waste our time?:
        <select name="answer">
          <option value="1" selected="selected">Yes</option>
          <option value="2">No</option>
        </select>
	        <input type="submit" value="Submit" />
	      </form>


<?
}
?>
</body></html>