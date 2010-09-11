<?php
if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

if($session['session']->rank < ADMIN_RANK) {
	echo "Invalid page access";
	return;
}


$sql = "SELECT DISTINCT(`chan`) AS `channel` FROM `chan_log` ORDER BY `chan` ASC";
$result = mysql_query($sql);
?>

<script type="text/javascript" src="/js/jquery.dataTables-extend.js"></script>
<script type="text/javascript">
  var ajaxSource = 'http://idm-bot.com/ajax/chan-log.php',
      lastUpdate = 0,
      logTable,
      timerID;

  function updateLog() {
    aoData = new Array();
    aoData.push({ name: 'channel', value: $('#channel-list').val()}, { name: 'history', value: $('#history').val()}, { name: 'lastUpdate', value: lastUpdate});
    logTable.fnReloadAjax(ajaxSource, aoData);
    lastUpdate = (new Date()).getTime();
  }

  function beginRefresh() {
    timerID = setInterval("updateLog()", (parseInt($('#refresh-rate').val()) * 1000));
  }
  
  function resetRefresh() {
    clearInterval(timerID);
    beginRefresh();
  }

  $(document).ready(function() {

    logTable = $('#log-viewer-table').dataTable({
      'bAutoWidth'    : false,
      'bJqueryUI'     : true,
      'bLengthChange' : false,
      'bPaginate'     : false,
      'bSort'         : true,
      'aaSortingFixed': [[0, 'asc']],
      'iDisplayLength': 50,
      'sAjaxSource'   : ajaxSource,
      'fnServerData'  : function(sSource, aoData, fnCallback) {
        aoData = new Array();
        aoData.push({ name: 'channel', value: $('#channel-list').val()}, { name: 'history', value: $('#history').val()}, { name: 'lastUpdate', value: lastUpdate });
        $.ajax({
          url     : sSource,
          dataType: 'json',
          type    : 'post',
          data    : aoData,
          success : fnCallback
        });
      },
      'aoColumns'     : [
        { 'sWidth'    : '6%', 'bSortable' : false }, /* timestamp */
        { 'sWidth'    : '6%', 'bSortable' : false }, /* bot */
        { 'sWidth'    : '11%', 'bSortable' : false }, /* nick */
        { 'sWidth'    : '75%', 'bSortable' : false }  /* text */
      ]
    });

    $('#channel-list').change(function() {
      lastUpdate = 0;
      updateLog();
    });

    $('#history').change(function() {
      lastUpdate = 0;
      updateLog();
    });
    
    $('#refresh-rate').change(function() {
      resetRefresh();
    });
    
    beginRefresh();
  });
</script>

<h2>Log viewer</h2>
<p>
  To begin viewing logs, please select a channel from the list below.<br />
  Select a refresh rate (default is 5 seconds).
</p>

<div id="log-header">
  <div id="channel-select-div">
    <label for="channel-list">Channels: </label>
    <select id="channel-list">
      <option value="">&nbsp;</option>
        <?php
        while(($row = mysql_fetch_object($result)) != NULL) {
        ?>
              <option value="<?=$row->channel?>"><?=$row->channel?></option>
        <?php
        }
        ?>
    </select>
  </div>
  <div id="refresh-select-div">
    <label for="refresh-rate">Refresh rate: </label>
    <select id="refresh-rate">
      <option value="1">1 sec</option>
      <option value="5" selected>5 sec</option>
      <option value="10">10 sec</option>
      <option value="30">30 sec</option>
      <option value="60">1 min</option>
    </select>
  </div>
  <div id="history-select-div">
    <label for="history">Line History: </label>
    <select id="history">
      <option value="20" selected>20 Lines</option>
      <option value="40" >40 Lines</option>
      <option value="100">100 Lines</option>
      <option value="500">500 Lines</option>
      <option value="2000">2000 Lines</option>
      <option value="20000">20000 Lines</option>
    </select>
  </div>
</div>
<div id="log-viewer" style="overflow:auto;">
  <table id="log-viewer-table">
    <thead>
      <tr>
        <th>Timestamp</th>
        <th>Bot</th>
        <th>Nick</th>
        <th>Text</th>
      </tr>
    </thead>
    <tbody>
    </tbody>
  </table>
</div>
