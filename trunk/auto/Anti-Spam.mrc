on $*:TEXT:/^[!@.]((end)?dm|command(s)?|dmcommand(s)?|stake|gwd|account|(.)?top|dmrank|dmclue|solve|money|equip(ment)?|status|max|hitchance|buy|sell|store|vspear|statius|mjavelin|on|off|whip|dds|gmaul|guth|(d|m)bow|(b|e)bolt|onyx|rknives|snow|dh|[bsaz]gs|ice|blood|(e|f)surge|surf|corr|d(claws|mace|hally)|specpot|(start|add|join|dm)clan|leave|share)(\s\S+)?$/S:#:{
  if ($chan == $staffchan) { halt }
  if (# == #idm) && ($me != iDM) { halt }
  $iif(%cmdspam. [ $+ [ $nick ] ],inc %cmdspam. [ $+ [ $nick ] ],inc -u4 %cmdspam. [ $+ [ $nick ] ])
  if (%cmdspam. [ $+ [ $nick ] ] >= 6) {
    msgsafe $staffchan $logo(SPAM) $s1(Command) spam detected by $s2($nick) in $s2($chan) $+ . Added to ignore for two minutes.
    notice $nick $logo(SPAM) You are now added to ignore for $s2(TWO minutes) due to spam.
    ignore -u120 $nick 3
    halt
  }
}

on *:TEXT:*:?:{
  if ($nick == -sbnc) { halt }
  close -m $nick
  $iif(%cmdspam. [ $+ [ $nick ] ],inc %cmdspam. [ $+ [ $nick ] ],inc -u4 %cmdspam. [ $+ [ $nick ] ])
  if (%cmdspam. [ $+ [ $nick ] ] >= 6) {
    msgsafe $staffchan $logo(SPAM) $s1(PM) spam detected by $s2($nick) $+ . Added to ignore for two minutes.
    notice $nick $logo(SPAM) You are now added to ignore for $s2(TWO minutes) due to spam.
    ignore -u120 $nick 3
    halt
  }
}

alias cacheclear {
  var %ti $ctime
  .ignore -r

  var %sql = SELECT * FROM `admins` WHERE `rank` > '4'
  var %result = $db.query(%sql)
  while ($db.query_row_data(%result,address)) {
    var %user = $v1
    if (@ isin %user) { ignore -x %user }
  }
  db.query_end %result
  botrefresh
  msgsafe $staffchan $logo(DBSync) Database cache cleared. Script took $calc($ctime - %ti) seconds.
  var %botnum $botnum
  inc %botnum
  putlog perform cacheclear.run %botnum
}

alias cacheclear.run {
  if ($cid != $scon(1)) { halt }
  var %botnum $botnum
  if (%botnum == $null) { msgsafe $staffchan $logo(Error) This bot doesn't have a instance number, it wasn't auto started, halting update. }
  if ($1 == %botnum) {
    .timer -m 1 500 cacheclear
  }
}
