<?PHP
define ('ADMIN_RANK', 3);

$session = verifySession();
echo $session['message'];
if ($session['status'] == TRUE) {
	$user = $session['session']->account;
?>

<h1><a href="/account/" title="Back to main page">iDM Account Management...</a></h1>

<?php

	if(isset($_GET['sub'])) {

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
			case 'sig':
			  include 'includes/a-sig.php';
			  break;
			case 'cname':
			  include 'includes/a-username.php';
			  break;
			case 'cookie':
			  include 'includes/a-cookies.php';
			  break;
			case 'bappeal':
			  include 'includes/a-banadmin.php';
			  break;
			case 'nchange':
			  include 'includes/a-nameadmin.php';
			  break;
			case 'shop':
			  include 'includes/a-shop.php';
			  break;
			case 'view':
			  include 'includes/a-view.php';
			  break;
			case 'history':
			  include 'includes/a-history.php';
			  break;
			case 'hstat':
			  $statType = 'high';
			  include 'includes/a-stats.php';
			  break;
			case 'lstat':
			  $statType = 'low';
			  include 'includes/a-stats.php';
			  break;
			case 'istat':
			  $statType = 'idle';
				include 'includes/a-stats.php';
				break;
			default:
			  echo "<p>Page not found.</p>";
			  break;
		}
	}
	else {
?>
	<script type="text/javascript">
	$(function() {
		$("#tabs").tabs({
			ajaxOptions: {
				error: function(xhr, status, index, anchor) {
					$(anchor.hash).html("Couldn\'t load this tab. We\'ll try to fix this as soon as possible.");
				}
			}
		});
	});
	</script>
<div id="tabs">
	<ul>
		<li><a href="#tabs-1">Account</a></li>
		<li><a href="#tabs-2">History</a></li>
		<? if($session['session']->rank >= ADMIN_RANK) { ?> <li><a href="#tabs-3">Admin</a></li> <? } ?>
  </ul>
	<div id="tabs-1">
<h2>Account Management</h2>
<p>Welcome <?=$user?></p>
<p>From this account management panel you will be able to edit user details and appeal an user or channel ban.</p>
<p></p>
<p>Please select an option below:</p>
<ul>
  <li><h3>Change account details</h3>
    <ul>
    <li><a href="/account/sig/">Change profile signature</a></li>
    <li><a href="/account/cname/">Request a name change</a></li>
    </ul>
  </li>

	<li><h3>Visit iDM Shop</h3>
	  <ul>
	    <li><a href="#tab-1">Shop</a></li>
	    <li><a href="/account/cookie/">Cookie store</a></li>
		</ul>
	</li>
	
  <li><h3>Appeal a ban</h3>
    <ul>
    <li><a href="/account/cban/">Appeal a channel ban</a></li>
    <li><a href="/account/uban/">Appeal a suspended account</a></li>
    </ul>
  </li>
</ul>
</div>
<div id="tabs-2">
<h2>Account History</h2>
<h3>Appeal History</h3>
<?
		$result = mysql_query("SELECT * FROM appeal WHERE request_type IN ('user', 'channel') AND user='$user' ORDER BY id DESC");
		if(!$result || mysql_num_rows($result) == 0) {
		  echo "<p>You have no ban history.</p>";
		}
		else {
?>

<table class="table-user">
	<thead>
		<tr>
		  <th>Ban Type</th>
			<th>Channel Name</th>
		  <th>Ban Date</th>
		  <th>Status</th>
		  <th>Operation</th>
		</tr>
	</thead>
	<tbody>
<?php
			while(($row = mysql_fetch_object($result)) != NULL) {
				$class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=ucwords($row->request_type)?></td>
		  <td><?=($row->request_type=='channel' ? $row->channel : '')?></td>
		  <td><?=$row->ban_date?></td>
		  <td>
<?php
				switch($row->status) {
				  case 'p':
				    echo 'Pending Review';
				    break;
					case 'a':
					  echo 'Appeal Approved';
					  break;
					case 'd':
					  echo 'Appeal Denied';
					  break;
				}
?>
			</td>
			<td>
			  <form method="post" action="/account/view/" class="account-operation">
			    <input type="hidden" name="id" value="<?=$row->id?>" />
			    <input type="submit" value="View Details" />
			  </form>
			</td>
		</tr>
<?php
			}
?>
	</tbody>
</table>
<?php
		}
?>
<h3>Username Change History</h3>
<?
		$result = mysql_query("SELECT * FROM appeal WHERE request_type = 'username' AND (user='$user' OR request='$user')");
		if(!$result || mysql_num_rows($result) == 0) {
		  echo "<p>You have no username change request history.</p>";
		}
		else {
?>

<table class="table-user">
	<thead>
		<tr>
		  <th>Requested Name</th>
		  <th>Request Date</th>
		  <th>Status</th>
		  <th>Operation</th>
		</tr>
	</thead>
	<tbody>
<?php
			$index = 1;
			while(($row = mysql_fetch_object($result)) != NULL) {
				$class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
?>
		<tr <?=$class?>>
		  <td><?=$row->request?></td>
		  <td><?=$row->request_date?></td>
		  <td>
<?php
				switch($row->status) {
				  case 'u':
				    echo 'Awaiting Confirmation';
				    break;
				  case 'p':
				    echo 'Request Review';
				    break;
					case 'a':
					  echo 'Request Approved';
					  break;
					case 'd':
					  echo 'Request Denied';
					  break;
					case 'c':
					  echo 'Request Canceled';
					  break;
				}
?>
			</td>
			<td>
			  <form method="post" action="/account/view/">
			    <input type="hidden" name="id" value="<?=$row->id?>" />
			    <input type="submit" value="View Details" />
			  </form>
			</td>
		</tr>
<?php
			}
?>
	</tbody>
</table>
<?
}
?>
</div>
<?php
		if($session['session']->rank >= ADMIN_RANK) {
			$sql = "SELECT COUNT(id) AS total FROM appeal WHERE request_type IN ('user', 'channel') AND status='p'
			        UNION
			        SELECT COUNT(user) FROM ilist
			        UNION
			        SELECT COUNT(user) FROM blist";
			$result = mysql_query($sql);
			$row = mysql_fetch_object($result);
			$appeals = $row->total;
			$row = mysql_fetch_object($result);
			$bans = $row->total;
			$row = mysql_fetch_object($result);
			$bans += $row->total;

			$sql = "SELECT COUNT(id) AS total FROM appeal WHERE request_type='username' AND status='p'";
			$result = mysql_query($sql);
			$row = mysql_fetch_object($result);
			$nameChanges = $row->total;

?>
	<div id="tabs-3">
	<h2>Account Admin</h2>
	<ul>
	<li><h3>Process Requests</h3>
	  <ul>
	    <li><a href="/account/bappeal/">Process ban appeals (<?=$appeals?> appeals / <?=$bans?> bans)</a></li>
	    <li><a href="/account/nchange/">Process name changes (<?=$nameChanges?> pending)</a></li>
		</ul>
	</li>
	<li><h3>Appeal History</h3>
	  <ul>
	    <li><a href="/account/history/">Review a user's/channel's ban history</a></li>
		</ul>
	</li>
	<li><h3>iDM Stats</h3>
	  <ul>
	    <li><a href="/account/hstat/">Top Cheat High Ratio</a></li>
	    <li><a href="/account/lstat/">Top Cheat Low Ratio</a></li>
	    <li><a href="/account/istat/">Idle Staff</a></li>
		</ul>
	</li>
	</ul>
	</div>
<?php
		}
		?>
</div>
    <?
	}
}
?>