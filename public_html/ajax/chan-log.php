<?php
include_once "../includes/config.php";
include_once "../includes/irccolors.php";
$format = new irccolors;
init(1);

$channel = isset($_POST['channel']) ? trim($_POST['channel']) : '';
$history = isset($_POST['history']) ? trim($_POST['history']) : 100;
$startTime = isset($_POST['startTime']) ? strtotime(trim($_POST['startTime'])) : 0;
$log = array();

if($channel) {
  $sql = sprintf("SELECT * FROM `chan_log`
          WHERE `chan` = '%s' AND `date` >= %d
          ORDER BY `date` DESC
          LIMIT 0,%d",
          mysql_real_escape_string($channel),
          $startTime,
          $history);
  $result = mysql_query($sql);

  while(($row = mysql_fetch_object($result)) != NULL) {
    $log[] = array(
      date('d/m H:i:s', $row->date),
      $row->bot,
      $row->nick,
      $format->parse($row->text),
    );
  }
}

#print_r ($log);
print json_encode(array('aaData' => $log));
exit();