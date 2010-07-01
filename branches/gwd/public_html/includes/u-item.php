<h2>Special Drops</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Special Pot</th>
 			<th>Clue Scroll</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 20%;"><?=valuebool($result ['specpot'])?></td>
   		<td style="width: 20%;"><?=valuebool($result ['clue'], 1)?></td>
		</tr>
	</tbody>
</table>

<h2>Seasonal Drops</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Snow Globe</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 20%;"><?=valuebool($result ['snow'])?></td>
		</tr>
	</tbody>
</table>

<h2>Special Items</h2>
<table class="table-user">
	<thead>
		<tr>
      <th>Ring of Wealth</th>
			<th>Cookies</th>
		</tr>
	</thead>
  <tbody>
		<tr>
		  <td style="width: 20%;"><?=valuebool($result ['wealth'])?></td>
			<td style="width: 20%;"><?=valuebool($result ['cookies'])?></td>
		</tr>
	</tbody>
</table>

<h2>Staff Items</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>One-Eyed Trouser Snake</th>
			<th>KHonfound Ring</th>
			<th>Belong Blade</th>
			<th>Allergy Pills</th>
			<th>Beaumerang</th>
			<th>The Supporter</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 20%;"><?=valuebool($result ['snake'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['kh'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['belong'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['allegra'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['beau'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['support'], 1)?></td>
		</tr>
	</tbody>
</table>
