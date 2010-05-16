<h1 style="margin-top: 0px;"> <?=htmlentities(strtoupper($userd)); ?> </h1>
<div>
  <table class="table-user-clean">
  	<tbody>
  		<tr>
  			<th>Clan</th>
  			<td><a href="/c/<?=urlencode($result ['clan'])?>"><?=htmlentities($result ['clan'])?></a></td>

  		</tr>
  		<tr>
  			<th>Logged in?</th>
  			<td><?=valuebool($result ['login'], 1)?></td>
  		</tr>
  		<tr>
  			<th style="width: 40%;">Banned?</th>
  			<td style="width: 60%;"><?=valuebool($result ['banned'], 1)?></td>
  		</tr>
  	</tbody>
  </table>
  <br />
  <table class="table-user">
  	<thead>
  		<tr>
  			<th>Money</th>
  			<th>Wins</th>
  			<th>Losses</th>
  			<th>Total</th>
  		</tr>
  	</thead>
    <tbody>
  		<tr class="odd">
  			<td style="width: 28%;"><?=getrank($userd,'money')?></td>
  			<td style="width: 22%;"><?=getrank($userd,'wins')?></td>
  			<td style="width: 22%;"><?=getrank($userd,'losses')?></td>
  			<td style="width: 28%;"><?=getrank($userd,'total')?></td>
  		</tr>
   	</tbody>
  </table>
  <br />
  <table class="table-user">
  	<thead>
  		<tr>
  			<th>Money</th>
  			<th>Wins</th>
  			<th>Losses</th>
  			<th>Win/Loss Ratio</th>
  		</tr>
    </thead>
    <tbody>
  		<tr class="odd">
        <td style="width: 28%;"><abbr title="<?=number_format($result ['money'], 0, '', ',')?>"><?=n2a($result ['money'])?></abbr> gp</td>
  			<td style="width: 22%;"><?=number_format($result ['wins'], 0, '', ',')?></td>
  			<td style="width: 22%;"><?=number_format($result ['losses'], 0, '', ',')?></td>
  			<td style="width: 28%;"><?=ratiodist($result ['wins'], $result ['losses'])?></td>
  		</tr>
  	</tbody>
  </table>
  <h2 style="display:none">User Tracking</h2>
  <table class="table-user" style="display:none">
    <thead>
  		<tr>
  			<th>Data</th>
  			<th>Last Day</th>
  			<th>Last Week</th>
  			<th>Last Month</th>
  			<th>Ever</th>
  		</tr>
  	</thead>
    <tbody>
  		<tr class="odd">
        <td style="width: 20%;">DMs</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  		</tr>
  		<tr class="even">
        <td style="width: 20%;">Wins</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  		</tr>
  		<tr class="odd">
        <td style="width: 20%;">Losses</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  		</tr>
  		<tr class="even">
        <td style="width: 20%;">Money</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  			<td style="width: 20%;">x</td>
  		</tr>
  	</tbody>
  </table>

  <br />
  <div id="uevents">
  <?
  if ($result['image']) {
    if ($result['link']) {
      print '<a href="' . htmlentities($result['link']) . '" class="postlink">
      <img src="' . htmlentities($result['image']) . '" alt="Sig" width="500px" style="max-height:160px" />
      </a>';
    }
    else {
      print '<img src="'. htmlentities($result['image']) .'" alt="Sig" width="500px" style="max-height:160px" />';
    }
  }
  ?>
  </div>
</div>
