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

<p>To gain an staff item you need to perform a task worthy of such a gift.<br />
Each item belongs to a different staff member and each staff member has a different idea
of what you have to do to be worthy of such a reward.<br />
Keep in mind however each item belongs to the admin, they can grant/remove the right to use their item
at will.</p>
<p>We've recently added cookies to idm, a reward which staff can award a user for services rendered.<br />
Cookies are given away for suggestions, bug reports, abuse reports, being helpful etc...<br />
The amount of cookies you will get will vairy on the task, an accepted feature suggestion can be worth between 40-100 cookies.
</p>

<p>Known ways to gain an admin item:<br />
Allegra will sell her item for 69 cookies.
Beau typically gives his item for being able to defeat him in a dm.<br />
Belongtome will sell his item for 101 cookies.<br />
KHobbits will sell his item for 100 cookies.<br />
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
