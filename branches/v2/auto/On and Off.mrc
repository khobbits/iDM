on $*:TEXT:/^[!.](on|off).*/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) IDM is currently disabled, please try again shortly | halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($1 == !on || $1 == .on) {
    if ($hget($chan)) { notice $nick $logo(ERROR) Please end the current DM before you turn on or off weapons | halt }
    if (!$2) { notice $nick $logo(ERROR) To use !on/off, type $1 attack,attack,attack,etc. Or, you can type $1 -h (heal attacks), $1 -L (list). | halt }
    if ($2 == -L) { notice $nick $displayoff($chan) | halt }
    else enablec $remove($2,$chr(32)) $nick #
  }
  elseif ($1 == !off || $1 == .off) {
    if ($hget($chan)) { notice $nick $logo(ERROR) Please end the current DM before you turn on or off weapons | halt }
    if (!$2) { notice $nick $logo(ERROR) To use !on/off, type $1 attack,attack,attack,etc. Or, you can type $1 -h (heal attacks), $1 -L (list). | halt }
    if ($2 == -L) { notice $nick $displayoff($chan) | halt }
    else disablec $remove($2,$chr(32)) $nick #
  }
}

on *:JOIN:#: {
  if ($nick != $me) {
    if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
    var %output = $displayoff($chan,1)
    if (%output) { notice $nick %output }
  }
}

alias displayoff {
  var %output
  var %sql = SELECT * FROM settings WHERE user = $db.safe($1)
  var %result $db.query(%sql)
  var %output
  while ($db.query_row(%result,>row)) {
    if (!%output) { var %output $hget(>row,setting) }
    else { var %output %output $+ $chr(44) $hget(>row,setting)
    }
  }
  db.query_end %result
  if (!%output && $2 = 1) return
  return $logo(DISABLED) These attacks are currently disabled in $1 $+ : $iif(%output,$v1,None) $+ .
}

alias isdisabled {
  var %sql = SELECT * FROM `settings` WHERE user = $db.safe($1) AND setting = $db.safe($2)
  return $iif($db.select(%sql,setting) === $null,0,1)
}

alias enablec {
  if ($2 isop $3) || ($db.get(admins,rank,$address($2,3)) > 2) { 
    tokenize 32 $replace($1,$chr(44),$chr(58)) $2-
    var %notice
    if ($1 == -h) {
      var %i 1
      while (%i <= $dmg(list,0)) {
        if ($dmg(list,%i).heal) db.remove settings $3 setting $dmg(list,%i)
        inc %i
      }
      var %notice %notice Healing attacks are now on in $3 $+ .
    }
    elseif (($1 == all) || ($1 == -a)) {
      db.remove settings $3
      var %notice %notice All attacks have been turned on in $3 $+ .
    }
    elseif ($attack($1)) {
      db.remove settings $3 setting $1
      var %notice %notice Enabled $1 in $3
    }
    elseif ($1 == staking) {
      db.remove settings $3 setting $1
      var %notice %notice Enabled $1 in $3  
    }
    else {
      var %notice Error: Could not find attack to enable.
    }
    notice $2 $displayoff($3) %notice
  }
}

alias disablec {
  if ($2 isop $3) || ($db.get(admins,rank,$address($2,3)) > 2) { 
    tokenize 32 $replace($1,$chr(44),$chr(58)) $2-
    var %notice
    if ($1 == -h) {
      var %i 1
      while (%i <= $dmg(list,0)) {
        if ($dmg(list,%i).heal) db.set settings setting $3 $dmg(list,%i)
        inc %i
      }
      var %notice %notice Healing attacks are now off.
    }
    elseif ($attack($1)) {
      db.set settings setting $3 $1
      var %notice %notice Disabled $1 in $3
    }
    elseif ($1 == staking) {
      db.set settings setting $3 $1
      var %notice %notice Disabled $1 in $3
    }
    else {
      var %notice %notice Error: Could not find attack to disable.
    }
    notice $2 $displayoff($3) %notice
  }
}

on $*:TEXT:/^[!@.](dm)?command(s)?$/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(COMMANDS) $&
    $s2(Account) $chr(91) $+ $s1(!money) $+ , $s1(!equip) $+ , $s1(!top/wtop/ltop N) $+ , $s1(!dmrank nick/N) $+ $chr(93) $&
    $s2(Clan) $chr(91) $+ $s1(!startclan name) $+ , $s1(!addmem/delmem nick) $+ , $s1(!joinclan name) $+ , $s1(!dmclan nick) $+ , $s1(!leaveclan) $+ , $s1(!share on/off) $+ $chr(93) $&
    $s2(Shop) $chr(91) $+ $s1(!buy/sell item) $+ , $s1(!store) $+ $chr(93) $&
    $s2(Clue) $chr(91) $+ $s1(!dmclue) $+ , $s1(!solve answer) $+ $chr(93) $&
    $s2(Misc) $chr(91) $+ $s1(!on/off att) $+ , $s1(!max att) $+ , $s1(!hitchance att dmg) $+ $chr(93)
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(COMMANDS) $&
    $s2(Control) $chr(91) $+ $s1(!dm) $+ , $s1(!stake [amount]) $+ , $s1(!enddm) $+ , $s1(!status) $+ $chr(93) $&
    $s2(Attacks) $chr(91) $+ $s1(!ags) $+ , $s1(!bgs) $+ , $s1(!sgs) $+ , $s1(!zgs) $+ , $s1(!whip) $+ , $s1(!guth) $+ , $s1(!dscim) $+ , $s1(!dh) $+ , $s1(!dds) $+ , $s1(!dclaws) $+ , $s1(!dmace) $+ , $s1(!dlong) $+ , $s1(!dhally) $+ , $s1(!gmaul) $+ , $s1(!cbow) $+ , $s1(!onyx) $+ , $s1(!dbow) $+ , $s1(!ice) $+ , $s1(!blood) $+ , $s1(!smoke) $+ , $s1(!surf) $+ , $s1(!specpot) $+ $chr(93) $&
    $s2(PvP Attacks) $chr(91) $+ $s1(!vspear) $+ , $s1(!statius) $+ , $s1(!vlong) $+ , $s1(!mjavelin) $+ $chr(93))
}

on $*:TEXT:/^[!@.](dm)?site$/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(DM-Link) iDM's website: $s2(http://idm-bot.com/)
}

on $*:TEXT:/^[!@.](dm)?rules$/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(DM-Link) iDM's rules: $s2(http://r.idm-bot.com/rules)
}

on $*:TEXT:/^[!@.](dm)?forum$/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(DM-Link) iDM's forums: $s2(http://forum.idm-bot.com)
}
