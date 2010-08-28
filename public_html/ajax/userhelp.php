<?php
include_once '../includes/config.php';
init(1);
?>
<h1>Achievement Help Page</h1>

<table class="table-user">
	<thead>
		<tr>
			<th>Rank #1</th>
			<th>Rank #2</th>
			<th>Rank #3</th>
			<th>Rank #4</th>
			<th>Rank #5</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td style="background-color: <?=acolor('1'); ?>;">&nbsp;</td>
			<td style="background-color: <?=acolor('2'); ?>;">&nbsp;</td>
			<td style="background-color: <?=acolor('3'); ?>;">&nbsp;</td>
			<td style="background-color: <?=acolor('4'); ?>;">&nbsp;</td>
			<td style="background-color: <?=acolor('5'); ?>;">&nbsp;</td>
		</tr>
	</tbody>
</table>
<br />
<table class="table-user">
	<thead>
		<tr>
			<th></th>
			<th>Total DMs</th>
			<th>Wins</th>
			<th>Losses</th>
			<th>Money</th>
			<th>PvP</th>
			<th>Special Pots</th>
			<th>Cookies</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<th width="23%">Rank #1 (Lowest)</th>
			<td width="11%">1,000+</td>
			<td width="11%">500+</td>
			<td width="11%">500+</td>
			<td width="11%">500m+</td>
			<td width="11%">75+</td>
			<td width="11%">50+</td>
			<td width="11%">50+</td>
		</tr>
		<tr>
			<th>Rank #2</th>
			<td>2,000+</td>
			<td>1,000+</td>
			<td>1,000+</td>
			<td>2b+</td>
			<td>150+</td>
			<td>100+</td>
			<td>100+</td>
		</tr>
		<tr>
			<th>Rank #3</th>
			<td>4,000+</td>
			<td>2,000+</td>
			<td>2,000+</td>
			<td>20b+</td>
			<td>300+</td>
			<td>150+</td>
			<td>150+</td>
		</tr>
		<tr>
			<th>Rank #4</th>
			<td>6,000+</td>
			<td>3,000+</td>
			<td>3,000+</td>
			<td>50b+</td>
			<td>600+</td>
			<td>200+</td>
			<td>200+</td>
		</tr>
		<tr>
			<th>Rank #5 (Highest)</th>
			<td>10,000+</td>
			<td>5,000+</td>
			<td>5,000+</td>
			<td>100b+</td>
			<td>1,200+</td>
			<td>250+</td>
			<td>250+</td>
		</tr>
	</tbody>
</table>