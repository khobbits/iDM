on $*:TEXT:/^[!.](on|off).*/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($1 == !on || $1 == .on) {
    if (%p2 [ $+ [ # ] ]) { notice $nick $logo(ERROR) You can't use this command while people are DMing. | halt }
    if (!$2) { notice $nick $logo(ERROR) To use !on/off, type $1 attack,attack,attack,etc. Or, you can type $1 -h (heal attacks), $1 -L (list).| halt }
    if ($2 == -L) { notice $nick $displayoff($chan) | halt }
    else enablec $remove($2-,$chr(32)) $nick #
  }
  elseif ($1 == !off || $1 == .off) {
    if (%p2 [ $+ [ # ] ]) { notice $nick $logo(ERROR) You can't use this command while people are DMing. | halt }
    if (!$2) { notice $nick $logo(ERROR) To use !on/off, type $1 attack,attack,attack,etc. Or, you can type $1 -h (heal attacks), $1 -L (list). | halt }
    if ($2 == -L) { notice $nick $displayoff($chan) | halt }
    else disablec $remove($2-,$chr(32)) $nick #
  }
}

on *:JOIN:#: {
  if ($nick != $me) {
    var %output = $displayoff($chan,1)
    if (%output) { notice $nick %output }
  }
}

alias displayoff {
  var %output
  var %sql = SELECT * FROM settings WHERE user = $db.safe($1)
  var %result $db.query(%sql)
  var %output
  while ($db.query_row(%result,row)) {
    if (!%output) { var %output $hget(row,setting) }
    else { var %output %output $+ $chr(44) $hget(row,setting)
    }
  }
  db.query_end %result
  if (!%output && $2 = 1) return
  return $logo(DISABLED) These attacks are currently disabled: $iif(%output,$v1,None) $+ .
}

alias isdisabled {
  var %sql = SELECT * FROM `settings` WHERE user = $db.safe($1) AND setting = $db.safe($2)
  return $iif($db.select(%sql,setting) === $null,0,1)
}

alias enablec {
  if ($2 !isop $3) && (!$db.get(admins,position,$address($2,3))) { halt }
  tokenize 32 $replace($1,$chr(44),$chr(58)) $2-
  var %notice
  if ($1 == -h) {
    db.remove settings $3 setting guth
    db.remove settings $3 setting sgs
    db.remove settings $3 setting blood
    db.remove settings $3 setting onyx
    var %notice %notice Healing attacks are now on in $3 $+ .
  }
  elseif ($1 == all) {
    db.remove settings $3
    var %notice %notice All attacks have been turned on in $3 $+ .
  }
  elseif ($attack($1)) {
    db.remove settings $3 setting $1
    var %notice %notice Enabled $1 in $3
  }
  else {
    var %notice Error: Could not find attack to enable.
  }
  notice $2 $displayoff($3) %notice
}

alias disablec {
  if ($2 !isop $3) && (!$db.get(admins,position,$address($2,3))) { halt }
  tokenize 32 $replace($1,$chr(44),$chr(58)) $2-
  var %notice
  if ($1 == -h) {
    db.set settings setting $3 guth
    db.set settings setting $3 sgs
    db.set settings setting $3 blood
    db.set settings setting $3 onyx
    var %notice %notice Healing attacks are now off.
  }
  elseif ($attack($1)) {
    db.set settings setting $3 $1
    var %notice %notice Disabled $1 in $3
  }
  else {
    var %notice %notice Error: Could not find attack to disable.
  }
  notice $2 $displayoff($3) %notice
}

on $*:TEXT:/^[!@.](dm)?command(s)?$/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  $iif($left($1,1) == @,msg #,notice $nick) $logo(COMMANDS) $&
    $s2(Account) $chr(91) $+ $s1(!money) $+ , $s1(!top/wtop/ltop N) $+ , $s1(!dmrank nick/N) $+ $chr(93) $&
    $s2(Clan) $chr(91) $+ $s1(!startclan name) $+ , $s1(!addmem/delmem nick) $+ , $s1(!joinclan name) $+ , $s1(!dmclan nick) $+ , $s1(!leave) $+ , $s1(!share on/off) $+ $chr(93) $&
    $s2(Shop) $chr(91) $+ $s1(!buy/sell item) $+ , $s1(!store) $+ $chr(93) $&
    $s2(Clue) $chr(91) $+ $s1(!dmclue) $+ , $s1(!solve answer) $+ $chr(93) $&
    $s2(Misc) $chr(91) $+ $s1(!on/off att) $+ , $s1(!max att) $+ , $s1(!hitchance att dmg) $+ $chr(93)
  $iif($left($1,1) == @,msg #,notice $nick) $logo(COMMANDS) $&
    $s2(Control) $chr(91) $+ $s1(!dm) $+ , $s1(!stake [amount]) $+ , $s1(!enddm) $+ , $s1(!status) $+ $chr(93) $&
    $s2(Attacks) $chr(91) $+ $s1(!ags) $+ , $s1(!bgs) $+ , $s1(!sgs) $+ , $s1(!zgs) $+ , $s1(!whip) $+ , $s1(!guth) $+ , $s1(!dscim) $+ , $s1(!dh) $+ , $s1(!dds) $+ , $s1(!dclaws) $+ , $s1(!dmace) $+ , $s1(!dlong) $+ , $s1(!dhally) $+ , $s1(!gmaul) $+ , $s1(!cbow) $+ , $s1(!onyx) $+ , $s1(!dbow) $+ , $s1(!ice) $+ , $s1(!blood) $+ , $s1(!smoke) $+ , $s1(!surf) $+ , $s1(!specpot) $+ $chr(93) $&
    $s2(PvP Attacks) $chr(91) $+ $s1(!vspear) $+ , $s1(!statius) $+ , $s1(!vlong) $+ , $s1(!mjavelin) $+ $chr(93))
}
