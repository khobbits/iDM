<?php

define ('ITEM_COST', 100);
define ('MAX_ITEMS', 1);

if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

// Retrieve list of items
$sql = "SELECT DISTINCT(name) AS name, item
				FROM admins
				WHERE name <> ''";
$result = mysql_query($sql);
$admin_items = array();
while(($row = mysql_fetch_object($result)) != NULL) {
	$admin_items[$row->name] = $row->item;
}

// Stores the item requested for purchase.
$purchase = isset($_POST['purchase']) ? trim($_POST['purchase']) : NULL;

// Check to see if there are any missing items that need to be added
$sql = "SHOW COLUMNS FROM equip_staff";
$result = mysql_query($sql);
while(($row = mysql_fetch_object($result)) != NULL) {
	if($row->Field == 'user' || $row->Field == 'cookies') {
	  continue;
	}
	
	if(!isset($admin_items[$row->Field])) {
	  $admin_items[$row->Field] = $row->Field;
	}
}

$sql = "SELECT * FROM equip_staff WHERE user='$user' LIMIT 1";
$cookies = mysql_fetch_object(mysql_query($sql));

$message = '';
// Process the purchase if available
if($purchase) {
	$value = 1;
	
	// Do they have enough money?
	if((int)$cookies->cookies < ITEM_COST) {
	  $message = 'You do not have enough cookies to purchase this item.';
	}
	// Do they already have this item?
	elseif($cookies->{$purchase} > 0) {
	  $message = "You already have this item.  You are only allowed ".MAX_ITEMS." of each item.";
	}
	// If this is a support item...do they already have one?
	elseif($purchase == 'support') {
		if($cookies->support != '0') {
	  	$message = "You already have a support item, and cannot purchase another at this time.";
		}

		// This must be changed to 'cookie'
		$value = 'cookie';
	}

	if(strlen($message) == 0) {
		$balance = (int)$cookies->cookies - ITEM_COST;
		// Purchase the item
		$sql = "UPDATE equip_staff SET $purchase='$value', cookies=$balance
		        WHERE user='$user'";
		if(!mysql_query($sql)) {
		  $message = 'There was a problem processing your purchase.  Please try again.  If this continues, please contact a member of staff.';
		}
		else {
?>
<p>Your purchase has been successfully completed.</p>
<?php
			return;
		}
	}
}
?>

<h2>Item Purchase</h2>
<p><em><?=$message?></em></p>
<p>You have <strong><?=$cookies->cookies?></strong> cookies to spend.</p>
<p><em>Each item costs <strong><?=ITEM_COST?></strong> cookies, and you can only have <strong><?=MAX_ITEMS?></strong> of each item.</em></p>
<table>
	<tr>
	  <th>Item</th>
	  <th># in Inventory</th>
	  <th>Purchase</th>
	</tr>
<?php
	foreach($admin_items as $key => $value) {
		if($cookies->$key != 0 || ($key == 'support' && $cookies->support != '0')) {
		  $disabled = ' disabled="disabled"';
		  $purchase = 'Not Available';
		}
		else {
		  $disabled = '';
		  $purchase = 'Purchase';
		}
?>
	<tr>
	  <td><?=$value?></td>
	  <td><?=$cookies->{$key}?></td>
	  <td>
			<form method="post" action="/account/cookie/">
			  <input type="hidden" name="purchase" value="<?=$key?>" />
			  <input type="submit" value="<?=$purchase?>"<?=$disabled?> />
			</form>
		</td>
	</tr>
<?php
	}
?>
</table>
	