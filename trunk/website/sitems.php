<?PHP

function adminlist($item) {
	$query = "SELECT * FROM equip_staff WHERE $item != '0'";
	$result = mysql_query($query);
	$num = mysql_num_rows($result);

	for ($a = 1; $a < $num; $a++) {
		$name = mysql_result($result, $a, 'user');
		print '' . ucfirst($name) . '<br />';
	}
	print '';
}
?>

<p>To gain an admin item you need to perform a task worthy of such a
gift.  Each item belongs to a different staff member and each staff member has
a different idea of what you have to do to be worthy of such a reward.</p>
<p>For example:<br />
Beau typically gives his item for being able to defeat him in a dm.<br />
KHobbits typically gives his item for people who have suggested iDM
features that were added to the bot.<br />
Belongtome typically gives his item for bug reports, and helping with
bot maintaince.<br />
</p>
<p>The easiest way to NOT get an item is to beg or continually ask for
it, this is more likely to gain you the 'banned' status.</p>
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
?></td><td><?php
adminlist('kh');
?></td><td><?php
adminlist('beau');
?></td><td><?php
adminlist('belong');
?></td><td><?php
adminlist('allegra');
?></td><td><?php
adminlist('support');
?></td>