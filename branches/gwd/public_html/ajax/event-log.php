<?php
include_once '../includes/config.php';
init(1);

$user = str_replace(" ", "_", strtolower($_GET['user']));
$user = mysql_real_escape_string($user);

if ($user == '') { die("No user defined"); }

$query = "(SELECT * FROM user_log WHERE user = '$user')
UNION (SELECT * FROM user_log_archive WHERE user = '$user')
ORDER BY date DESC LIMIT 2000";
$result = mysql_query($query);

if(!$result) { die ("No user found"); }
?>
		<script type="text/javascript" charset="utf-8">
			$(document).ready(function() {
				$('#pageit').dataTable( {
            "bAutoWidth": false,
            "bFilter": false,
            "bInfo": true,
            "bJQueryUI": true,
            "bLengthChange": true,
            "bPaginate": true,
            "bSort": false,
            "bSortClasses": false,
            "iDisplayLength": 22,
            "sZeroRecords": "No recent events for this user.",
        		"aoColumns": [
        			{ "sWidth": "25%" },
        			{ "sWidth": "15%" },
        			{ "sWidth": "60%" }
        		]

          } );
			} );
		</script>

<table class="table-hs" id="pageit">
		<thead>
			<tr>
				<th>Date</th>
				<th>Type</th>
				<th>Event</th>
</tr>
</thead>
<tbody>

<?php


  while ($data = mysql_fetch_assoc($result)) {
?>
    <tr>
			<td><?=event_date($data['date'])?></td>
			<td><?=event_type($data['type'])?></td>
			<td><?=event_msg($data['type'],$data['data'])?></td>
		</tr>
<?php
  }
?>
</tbody>
</table>
