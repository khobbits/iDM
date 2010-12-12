on $*:TEXT:/^[!.](on|off).*/Si:#: {
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  if ($update) { notice $nick $logo(ERROR) iDM is currently disabled, please try again shortly | halt }
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
    if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
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
    if (($2 != 1) || ($hget(>row,setting) != timeout)) {
      if (!%output) { var %output $hget(>row,setting) }
      else { var %output %output $+ $chr(44) $hget(>row,setting) }
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
    elseif ($1 == staking) || ($1 == gwd) {
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
    elseif ($1 == staking) || ($1 == gwd) {
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
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  tokenize 32 $1 $2- $nick
  var %prefix $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(COMMANDS)
  var %account money equip account top/wtop/ltop-N dmrank-name/N
  var %clan startclan-name addmem/delmem-nick joinclan-name dmclan-nick leaveclan share-on/off
  var %items dmclue solve-answer
  var %misc on/off-att !max-att hitchance-att-dmg
  var %control dm-[noadmin] stake-[amount] gwd enddm status
  %prefix $cmdformat(Account,%account) $cmdformat(Clan,%clan) $cmdformat(Item,%items) $cmdformat(Misc,%misc) $cmdformat(Control,%control)
  %prefix $cmdfetch(Magic,$2) $cmdfetch(Range,$2) $cmdfetch(Melee,$2) $cmdfetch(PVP,$2)

}

on $*:TEXT:/^[!@.]admin$/Si:%staffchan: {
  if ($db.get(admins,rank,$address($nick,3)) >= 3 && $me == iDM) {
    var %prefix $iif($left($1,1) == @,msgsafe $chan,notice $nick)
    var %admin addsupport-nick join-bot-chan rehash ignoresync amsg (show/rem)dm-nick define/increase/decrease-account-item-amount addsupport-nick cookie-nick-adjust
    var %support chans active part-chan (r)suspend-nick (r)ignore-nick/host (r)blist-chan viewitems (give/take)item-nick whois-chan
    var %helper cignore-nick/host csuspend-nick cblist-chan !info-nick
    %prefix $cmdformat(Admin,%admin) $cmdformat(support,%support) $cmdformat(helper,%helper)
  }
}

alias cmdfetch {
  var %i 1
  while ($dmg(list,%i)) {
    if (($dmg(list,%i).item != admin) && ((($dmg(list,%i).type == $1) && ($dmg(list,%i).pvp == 0)) || (($1 == pvp) && ($dmg(list,%i).pvp == 1)))) {
      if ($showattack($dmg(list,%i),$2)) { 
        var %output $iif(%output,%output $+ $chr(44) $+ $chr(32)) $+ $s1 $+ $dmg(list,%i) $+  $+ $iif($dmg(list,%i).spec > 0,(s))
      }
    }
    inc %i
  }
  if (%output) { return $s2($1) $chr(91) $+ %output $+ $chr(93) }
  return
}

alias showattack {
     if (($1 == all) || ($1 == -a) || (!$hget($2))) { return $true }
     if ((!$isweapon($1)) && (!$ispvp($1))) { return $true } 
     if ($hget($2,$1)) { return $true }
     return $false
}

alias cmdformat {
  var %i 1
  while (%i <= $numtok($2,32)) {
    var %cmds $iif(%cmds,%cmds $+ $chr(44) $+ $chr(32)) $+ $s1($cmdsplit($gettok($2,%i,32)))
    inc %i
  }
  return $s2($1) $chr(91) $+ %cmds $+ $chr(93)
}

alias cmdsplit {
  var %i 1
  while (%i <= $numtok($1,45)) {
    if (!%cmds) { var %cmds $gettok($1,%i,45) }
    else { var %cmds %cmds  $+ $gettok($1,%i,45) $+  }
    inc %i
  }
  return %cmds
}

on $*:TEXT:/^[!@.](dm)?site$/Si:#: {
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(DM-Link) iDM's website: $s2(http://iDM-bot.com/)
}

on $*:TEXT:/^[!@.](dm)?rules$/Si:#: {
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(DM-Link) iDM's rules: $s2(http://r.iDM-bot.com/rules)
}

on $*:TEXT:/^[!@.](dm)?forum$/Si:#: {
  if (# == #idm || # == $staffchan) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
  $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(DM-Link) iDM's forums: $s2(http://forum.iDM-bot.com)
}
