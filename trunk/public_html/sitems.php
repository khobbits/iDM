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

<p>To gain a staff item you need to perform a task worthy of such a gift.<br />
Each item belongs to a different staff member and each staff member has a different idea of 
what you have to do to be worthy of receiving their item. <br />
Keep in mind however each item belongs to the respective admin, 
and <em>they can grant/remove the right to use their item at will.</em></p>

<p>Most of the staff will trade their items for cookies which are given away for suggestions, bug reports, 
abuse reports, being helpful, etc. The amount of cookies you will receive can vary, depending on the task. <br />
For example, accepted feature suggestion can be worth between 25-100 cookies, 
whereas reporting abuse can reward you with up to 15 cookies.</p>

<p><strong>Known ways to gain an staff item:</strong><br />
All staff items can be bought for 100 cookies however some can also be obtained through other methods: <br />
One Eyed Trouser Snake and Beaumerang can be obtained by DMing the respective owner or hanging in their channels.<br />
Belong Blade can be earned randomly by being in the owner's iDM clan(Team-B) after the clan earns 50b or 25 members.<br />
Or finally Belong Blade or KHonfound ring can be earned by suggesting a big feature for iDM.</p>

<p>&nbsp;</p>
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
