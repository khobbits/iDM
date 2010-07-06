<?PHP

function adminlist($item) {
	$query = "SELECT * FROM equip_staff WHERE $item != '0' ORDER BY user";
	$result = mysql_query($query);
	$num = mysql_num_rows($result);
	print $num . " users.<br /><br />\n";

	for ($a = 0; $a < $num; $a++) {
		$name = mysql_result($result, $a, 'user');
		print htmlspecialchars(ucfirst($name)) . "<br />\n";
	}
}
?>
<h1>Staff Items</h1>
<p>Each item belongs to a different staff member with the exception of supporter which all support
staff have access to.<br />
Keep in mind however each item belongs to the respective admin, 
and <em>they can grant/remove the right to use their item at will.</em></p>

<h2>Cookies</h2>
<p>Most of the staff will give cookies for suggestions, bug reports, abuse reports, being helpful, etc.<br />
The amount of cookies you will receive can vary, depending on the task. <br />
For example, accepted feature suggestion can be worth between 25-100 cookies, 
whereas reporting abuse can reward you with up to 15 cookies.</p>

<p>Staff items can be bought for 100 cookies.</p>

<table class="table-sitems">
<tr>
<th style="width: 20%;">One Eyed Trouser Snake</td>
<th style="width: 16%;">KHonfound ring</td>
<th style="width: 16%;">Beaumerang</td>
<th style="width: 16%;">Belong Blade</td>
<th style="width: 16%;">Allergy Pills</td>
<th style="width: 16%;">Supporter</td>
</tr>
<tr style="vertical-align:top;">
<td>
<?php
adminlist('snake');
?></td>
<td><?php
adminlist('kh');
?></td>
<td><?php
adminlist('beau');
?></td>
<td><?php
adminlist('belong');
?></td>
<td><?php
adminlist('allegra');
?></td>
<td><?php
adminlist('support');
?></td>
</tr>
</table>
