<h2>Weapons</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Saradomin Godsword</th>
			<th>Armadyl Godsword</th>
			<th>Bandos Godsword</th>
			<th>Zamorak Godsword</th>
			<th>Dragon Claws</th>
			<th>Mudkip</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 20%;"><?=valuebool($result ['sgs'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['ags'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['bgs'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['zgs'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['dclaws'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['mudkip'])?></td>
		</tr>
	</tbody>
</table>
<h2>Attack Bonuses</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Accumulator</th>
			<th>Barrows Gloves</th>
			<th>Firecape</th>
			<th>God Cape</th>
			<th>Mage Book</th>
			<th>Void Range</th>
			<th>Void Mage</th>
		</tr>
	</thead>
  <tbody>
		<tr>
  		<td style="width: 14%;"><?=valuebool($result ['accumulator'])?></td>
			<td style="width: 14%;"><?=valuebool($result ['bgloves'])?></td>
			<td style="width: 14%;"><?=valuebool($result ['firecape'])?></td>
			<td style="width: 14%;"><?=valuebool($result ['godcape'])?></td>
			<td style="width: 14%;"><?=valuebool($result ['mbook'])?></td>
			<td style="width: 14%;"><?=valuebool($result ['void'])?></td>
			<td style="width: 14%;"><?=valuebool($result ['void-mage'])?></td>
		</tr>
	</tbody>
</table>

<h2>Defence Bonuses</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Elysian Shield</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 25%;"><?=valuebool($result ['elshield'])?></td>
		</tr>
	</tbody>
</table>

<h2>PvP Items</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Morrigan\'s Javelin</th>
			<th>Statius\'s Warhammer</th>
			<th>Vesta\'s Longsword</th>
			<th>Vesta\'s Spear</th>
		</tr>
	</thead>
  <tbody>
		<tr>
			<td style="width: 25%;"><?=valuebool($result ['mjavelin'])?></td>
			<td style="width: 25%;"><?=valuebool($result ['statius'])?></td>
			<td style="width: 25%;"><?=valuebool($result ['vlong'])?></td>
			<td style="width: 25%;"><?=valuebool($result ['vspear'])?></td>
		</tr>
	</tbody>
</table>
