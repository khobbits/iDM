<h2>Weapons</h2>
<table class="table-user">
	<thead>
		<tr>
			<th>Cutlass of Corruption</th>
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
			<td style="width: 12%;"><?=valuebool($result ['corr'])?></td>
			<td style="width: 12%;"><?=valuebool($result ['sgs'])?></td>
			<td style="width: 12%;"><?=valuebool($result ['ags'])?></td>
			<td style="width: 12%;"><?=valuebool($result ['bgs'])?></td>
			<td style="width: 12%;"><?=valuebool($result ['zgs'])?></td>
			<td style="width: 12%;"><?=valuebool($result ['dclaws'])?></td>
			<td style="width: 12%;"><?=valuebool($result ['mudkip'])?></td>
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
			<th>Archer Ring</th>
		</tr>
	</thead>
  <tbody>
		<tr>
  		<td style="width: 16%;"><?=valuebool($result ['accumulator'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['bgloves'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['firecape'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['godcape'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['mbook'])?></td>
			<td style="width: 16%;"><?=valuebool($result ['archer'])?></td>
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
			<td style="width: 50%;"><?=valuebool($result ['elshield'])?></td>
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
