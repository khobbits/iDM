<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

?>

<h2>The iDM Store</h2>
<?

// Retrieve the cost of the items
$store_sql = "SELECT * FROM sale_item ORDER BY name";
$store = mysql_query($store_sql);
if(!$store || mysql_num_rows($store) == 0) {
	echo "There was a problem accessing the store.  If you continue to see this message, please contact a member of staff.";
	return;
}

$current_sql = "SELECT user, money, wins, a.* , i.*
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
				WHERE user = '$user'
				LIMIT 1";

// Has the form been submitted?
if(isset($_POST['submit'])) {
?><div>
  <? process_cart($current_sql, $store_sql, $user); ?>
  </div><br />
<?
}

$current_result = mysql_query($current_sql);
if(!$current_result || mysql_num_rows($current_result) == 0) {
	echo "There was a problem accessing your information.  If you continue to see this message, please contact a member of staff.";
	return;
}
$current = mysql_fetch_object($current_result);
$total = $current->money;

?>

<form method="post" action="/account/shop/">
	<input type="hidden" id="balance" name="balance" value="<?=$current->money?>" />
  <table class="table-user">
    <tr>
      <th>Item</th>
      <th>Purchase Price</th>
      <th>Selling Price</th>
      <th>Unmet Requirements</th>
      <th>Old Qty</th>
      <th>New Qty</th>
		</tr>
<?php
$index = 1;
$items = array();
while(($row = mysql_fetch_object($store)) != NULL) {
	$class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
	$items[] = $row;
 	$qty = (isset($current->{$row->item})) ? (int)$current->{$row->item} : 0;
?>
		<tr <?=$class?>>
			<td><?=$row->name?></td>
			<td><?=n2a($row->purchase_price)?></td>
			<td><?=n2a($row->sell_price)?></td>
			<td><?=$row->required_wins > $current->wins ? 'Need '.($row->required_wins - $current->wins).' more wins':'None' ?></td>
      <td><?=$qty?></td>
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
  <p>You will not be able to purchase duplicates of any item using this store.</p>
  <table>
     <tr><td><strong>Old Balance</strong></td><td><span><?=$total?></span></td></tr>
     <tr><td><strong>New Balance</strong></td><td><span id="current_balance"><?=$total?></span></td></tr>
  </table>
	<p>
  	<input type="submit" name="submit" value="Complete" />
	  <input type="reset" id="reset" value="Reset" />
  </p>
</form>
<script type="text/javascript">
	var running_total, starting_total;
	var o_totals = new Array();
	var items = new Array();
	var num_wins = <?=$current->wins?>;
	$(function() {
	  running_total = starting_total = parseInt($('#balance').val());
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
        if(qty > o_totals[id]) {
          // Changed mind about buying the item
          running_total += parseInt(items[id]['purchase_price']);
        }
        else {
  				running_total += parseInt(items[id]['sell_price']);
        }
				$('#current_balance').html(running_total);
			}
	    return false;
	  });
	  
	  $('a.add').click(function() {
	    var id = $(this).attr('id');
	    var qty_ptr = $('input[name="'+id+'"]');
	    var qty = parseInt(qty_ptr.val());
      if(qty < 1) {
        if(qty < o_totals[id]) {
          // Changed mind about selling the item
          var thisitemprice = parseInt(items[id]['sell_price']);
        }
        else {
          var thisitemprice = parseInt(items[id]['purchase_price']);
        }
        if(running_total >= thisitemprice) {
          if(items[id]['required_wins'] <= num_wins) {
    				qty_ptr.val(qty+1);
     				running_total -= thisitemprice;
    				$('#current_balance').html(running_total);
          }
          else {
            alert('You do not have enough wins to purchase this item.');
          }
        } else {
          alert('You do not have enough money to purchase this item.');
        }

      }
			else {
        alert('You can only purchase one of these items.');
      }
	    return false;
	  });
	  
	  $('#reset').click(function() {
	   $('#current_balance').html(starting_total);
	   running_total = starting_total;
    });
	});
</script>
<?php
function process_cart($currentSQL, $itemSQL, $user) {
  $currentR = mysql_query($currentSQL);
  if(!$currentR || mysql_num_rows($currentR) == 0) {	return; }
  $current = mysql_fetch_object($currentR);
  $itemR = mysql_query($itemSQL);
  $total = $current->money;
  $do_query = FALSE;
  
  $queries = array(
    'equip_armour' => array(
      'update' => '',
      'insert' => array('column' => 'user,', 'value' => "'$user',")
    ),
    'equip_item' => array(
      'update' => '',
      'insert' => array('column' => 'user,', 'value' => "'$user',")
    )
  );
  
  while(($row = mysql_fetch_object($itemR)) != NULL) {
    if(!is_numeric($_POST[$row->item])) {
      echo "There was a problem with your cart (non-numeric value for quantity).  Please try again.  ";
      return;
    }
    elseif($_POST[$row->item] < 0) {
      echo "There was a problem with your cart (non-positive value for quantity).  Please try again.";
      return;
    }
    
    $qty = (int)$_POST[$row->item];
    if($qty < $current->{$row->item}) {
      $totalcost = (($current->{$row->item} - $qty) * $row->sell_price);
      echo 'Sold ' . ($current->{$row->item} - $qty) . ' ' . $row->name . ' for ' . $totalcost . 'gp<br />';
      $total += $totalcost;
    }
    elseif($qty > $current->{$row->item}) {
      if($qty > 1) {
        echo "You can only purchase one(1) of each item.";
        return;
      }
      elseif($current->wins < $row->required_wins) {
        echo "You do not have enough wins to complete this transaction.";
        return;
      }
      $totalcost = (($qty - $current->{$row->item}) * $row->purchase_price);
      echo 'Bought ' . ($qty - $current->{$row->item}) . ' ' . $row->name . ' for ' . $totalcost . 'gp<br />';
      $total -= $totalcost;
    }
    $queries[$row->table]['update'] .= "$row->item=VALUES($row->item),";
    $queries[$row->table]['insert']['value'] .= "'$qty',";
    $queries[$row->table]['insert']['column'] .= "$row->item,";
    $do_query = TRUE;
  }
  
  if($total < 0) {
    echo "You do not have enough gp to complete this transaction.  Please try again.";
    return;
  }
  elseif($do_query) {
    mysql_query("UPDATE user SET money=$total WHERE user='$user'");
    foreach($queries as $table => $ptr) {
      $sql = "INSERT INTO $table (".rtrim($queries[$table]['insert']['column'], ',').")
                VALUES (".rtrim($queries[$table]['insert']['value'], ',').")
              ON DUPLICATE KEY UPDATE ".rtrim($queries[$table]['update'], ',');
      mysql_query($sql);
    }
    echo "<p>Thank you for shopping the iDM Store.  Your transaction has been successfully completed.</p>";
    return;
  }
}
?>