<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

$sql = "SELECT user, money, wins, a . * , i . * , p . *
				FROM user
				LEFT JOIN (
					SELECT *
					FROM equip_armour
					WHERE user = '$user'
					LIMIT 1
				)a USING ( user )
				LEFT JOIN (
					SELECT *
					FROM equip_item
					WHERE user = '$user'
					LIMIT 1
				)i USING ( user )
				LEFT JOIN (
					SELECT *
					FROM equip_pvp
					WHERE user = '$user'
					LIMIT 1
				)p USING ( user )
				WHERE user = '$user'
				LIMIT 1";
$result = mysql_query($sql);
if(!$result || mysql_num_rows($result) == 0) {
	echo "There was a problem accessing your information.  If you continue to see this message, please contact a member of staff.";
	return;
}
$current = mysql_fetch_object($result);
// Retrieve the cost of the items
$sql = "SELECT * FROM sale_item ORDER BY name";
$result = mysql_query($sql);
if(!$result || mysql_num_rows($result) == 0) {
	echo "There was a problem accessing the store.  If you continue to see this message, please contact a member of staff.";
	return;
}
?>
<h3>The iDM Store</h3>
<p>You have <strong><div id="current_balance"><?=n2a($current->money)?></div></strong> gp in your account.</p>

<form method="post" action="/account/shop/">
	<input type="hidden" id="balance" name="balance" value="<?=$current->money?>" />
  <table class="shopping-table">
    <tr>
      <th>Item</th>
      <th>Purchase Price</th>
      <th>Selling Price</th>
      <th>Minimum Wins</th>
      <th>Qty</th>
		</tr>
<?php
$index = 1;
$items = array();
while(($row = mysql_fetch_object($result)) != NULL) {
	$class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
	$items[] = $row;
	$qty = (isset($current->{$row->item})) ? (int)$current->{$row->item} : 0;
?>
		<tr <?=$class?>>
			<td><?=$row->name?></td>
			<td><?=n2a($row->purchase_price)?></td>
			<td><?=n2a($row->sell_price)?></td>
			<td><?=$row->required_wins?></td>
			<td>
				<a href="#" class="sub" id="<?=$row->item?>"> - </a>
				<input type="text" class="cart-qty" id="<?=$row->item?>" name="<?=$row->item?>" value="<?=$qty?>" />
				<a href="#" class="add" id="<?=$row->item?>"> + </a>
			</td>
		</tr>
<?php
}
?>
	</table>
	<input type="submit" value="Complete" />
</form>
<script type="text/javascript">
	var running_total;
	var o_totals = new Array();
	var items = new Array();
	$(function() {
	  running_total = parseInt($('#balance').val());
<?php
foreach($items as $ptr) {
?>
			o_totals["<?=$ptr->item?>"] = <?=isset($current->{$ptr->item}) ? $current->{$ptr->item} : 0?>;
			items["<?=$ptr->item?>"] = <?=json_encode(array('purchase_price' => $ptr->purchase_price, 'sell_price' => $ptr->sell_price, 'required_wins' => $ptr->required_wins))?>;
<?php
}
?>
	  $('a.sub').click(function() {
	    var id = $(this).attr('id');
	    var qty_ptr = $('input[name="'+id+'"]');
	    var qty = parseInt(qty_ptr.val());
			if(qty > 0) {
				qty_ptr.val(qty-1);
				running_total += items[id]['sell_price'];
				$('#current_balance').html(n2a(running_total));
			}
	    return false;
	  });
	  
	  $('a.add').click(function() {
	    var id = $(this).attr('id');
	    var qty_ptr = $('input[name="'+id+'"]');
	    var qty = parseInt(qty_ptr.val());
			if(qty < 1) {
				qty_ptr.val(qty+1);
				running_total -= items[id]['purchase_price'];
				$('#current_balance').html(n2a(running_total));
			}
	    return false;
	  });
	});
function n2a(n) {
	// first strip any formatting;
	//n.replace(",", "");

	// is this a number?
	if (isNaN(n)) return false;

	// now filter it;
	if (n > 1000000000000) {
		return Math.round((n / 1000000000000), 2) + 't';
	} else if (n > 1000000000) {
		return Math.round((n / 1000000000), 2) + 'b';
	} else if (n > 1000000) {
		return Math.round((n / 1000000), 2) + 'm';
	} else if (n > 1000) {
		return Math.round((n / 1000), 2) + 'k';
	}
	return n;
}</script>

<style type="text/css">
.cart-qty {
	width: 20px;
}

div#current_balance {
	display: inline;
}
</style>