<h2 style="margin-top: 0px;"> <?=htmlentities(strtoupper($userd)); ?> </h2>
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
  <h2>User Tracking</h2>
  <table class="table-user">
    <thead>
  		<tr>
  			<th>Data</th>
  			<th title="Everything in the last 24 hours">Last 24 Hours</th>
  			
  			  		<?
            		 $sql = "(SELECT user,
                          SUM( IF(TYPE =1, 1, 0) ) AS wins,
                          SUM( IF(TYPE =2, 1, 0) ) AS losses,
                          (
                            SUM( IF(TYPE =3, DATA, 0) )
                            - SUM( IF(TYPE =4, DATA, 0) )
                            + SUM( IF(TYPE =5, IF(LOCATE(' gp', DATA), SUBSTRING_INDEX(DATA, ' gp', 1), 0), 0) )
                            - SUM( IF(TYPE =8, DATA, 0) )
                            + SUM( IF(TYPE =9, DATA, 0) )
                          ) AS money,
                          (
                            SUM( IF(TYPE =1, 1, 0) )
                            + SUM( IF(TYPE =2, 1, 0) )
                          ) AS dms";
                $sql1 = "$sql
                          FROM `user_log`
                          WHERE `user` = '$user')";
                $day = mysql_query($sql1);
                if (!$day || sizeof($day = mysql_fetch_assoc($day)) == 0 || $day['user'] == NULL) {
                  	$day = array (
                        'dms' => 0,
                  			'money' => 0,
                  			'wins' => 0,
                        'losses' => 0,
                        );
                }
        		?>

  			<th title="Everything since <?=date('d M',strtotime("-7 days"))?>">Last 7 Days</th>
  			
  			 		<?
            		 $end_date = strtotime('-7 days');
            		 $sql2 = "$sql
                          FROM `user_log_archive`
                          WHERE `date` >= '$end_date'
                          AND `user` = '$user')";
                $week = mysql_query($sql2);
                if (!$week || sizeof($week = mysql_fetch_assoc($week)) == 0 || $week['user'] == NULL) {
                  	$week = array (
                        'dms' => 0,
                  			'money' => 0,
                  			'wins' => 0,
                        'losses' => 0,
                        );
                }
         		?>

  			<th title="Everything since <?=date('d M',strtotime("-1 month"))?>">Last Month</th>
  			
  			  	<?
               $sql3 = "$sql
                          FROM `user_log_archive`
                          WHERE `user` = '$user')";
                $month = mysql_query($sql3);
                if (!$month || sizeof($month = mysql_fetch_assoc($month)) == 0 || $month['user'] == NULL) {
                  	$month = array (
                        'dms' => 0,
                  			'money' => 0,
                  			'wins' => 0,
                        'losses' => 0,
                        );
                }
        		?>

  			
  			<th title="Since records began">Ever</th>
  			
  			  		 <?
               $sql4 = "(SELECT *,(wins + losses) AS dms
                          FROM `user_log_total`
                          WHERE `user` = '$user')";
                $ever = mysql_query($sql4);
                if (!$ever || sizeof($ever = mysql_fetch_assoc($ever)) == 0 || $ever['user'] == NULL) {
                  	$ever = array (
                        'dms' => 0,
                  			'money' => 0,
                  			'wins' => 0,
                        'losses' => 0,
                        );
                }
        		?>
  			
  		</tr>
  	</thead>
    <tbody>
  		<tr class="odd">
        <td style="width: 20%;" title="Number of DM's and Stakes">Total DMs</td>
  			<td style="width: 20%;"><?=$day['dms']?></td>
  			<td style="width: 20%;"><?=($week['dms']+$day['dms'])?></td>
  			<td style="width: 20%;"><?=($month['dms']+$day['dms'])?></td>
  			<td style="width: 20%;"><?=($ever['dms']+$month['dms']+$day['dms'])?></td>
  		</tr>
  		<tr class="even">
        <td style="width: 20%;">Wins</td>
  			<td style="width: 20%;"><?=$day['wins']?></td>
  			<td style="width: 20%;"><?=($week['wins']+$day['wins'])?></td>
  			<td style="width: 20%;"><?=($month['wins']+$day['wins'])?></td>
        <td style="width: 20%;"><?=($ever['wins']+$month['wins']+$day['wins'])?></td>
  		</tr>
  		<tr class="odd">
        <td style="width: 20%;">Losses</td>
  			<td style="width: 20%;"><?=$day['losses']?></td>
  			<td style="width: 20%;"><?=($week['losses']+$day['losses'])?></td>
  			<td style="width: 20%;"><?=($month['losses']+$day['losses'])?></td>
        <td style="width: 20%;"><?=($ever['losses']+$month['losses']+$day['losses'])?></td>
  		</tr>
  		<tr class="even">
        <td style="width: 20%;">Money</td>
  			<td style="width: 20%;"><?=$day['money']?></td>
  			<td style="width: 20%;"><?=($week['money']+$day['money'])?></td>
  			<td style="width: 20%;"><?=($month['money']+$day['money'])?></td>
        <td style="width: 20%;"><?=($ever['money']+$month['money']+$day['money'])?></td>
  		</tr>
  	</tbody>
  </table>

  <br />
  <div id="uevents">
  <?
  if ($result['image']) {
    if ($result['link']) {
      print '<a href="' . htmlentities($result['link']) . '" class="postlink">
      <img src="' . htmlentities($result['image']) . '" alt="Sig" width="500px" style="max-height:150px" />
      </a>';
    }
    else {
      print '<img src="'. htmlentities($result['image']) .'" alt="Sig" width="500px" style="max-height:150px" />';
    }
  }
  ?>
  </div>
</div>
