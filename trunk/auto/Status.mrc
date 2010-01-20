alias autoidm.run {
  ; $1 = chan
  if (!$isdisabled($1,timeout)) {
    enddm $1
    return
  }
  autoidm.start $1
}
alias autoidm.start {
  var %nick $lower(<idm> $+ $1)
  var %p1 $hget($1,p1)
  if (!%p1) halt
  db.set user indm %p1 1
  chaninit %nick %p1 $1
  set -u25 %enddm [ $+ [ $1 ] ] 0
  var %winloss $winloss(%nick,%p1,iDM)
  var %winlossp1 $gettok(%winloss,1,45)
  var %winlossp2 $gettok(%winloss,2,45)
  msgsafe $1 $logo(DM) $s1(%nick) %winlossp1 has accepted $s1(%p1) $+ 's %winlossp2 DM. $s1($hget($1,p1)) gets the first move.
  if ($hget($1,p1) == %nick) autoidm.turn $1
}

alias autoidm.turn {
  var %nick $lower(<idm> $+ $1)
  var %p2 $hget($1,p2)
  var %spec $hget(%nick,sp)
  var %hp $hget(%nick,hp)
  var %hp2 $hget(%p2,hp)
  if (%hp2 <= 15) var %attcmd surf
  elseif ((%hp <= 9) && (%hp2 <= 50)) var %attcmd dh
  elseif ($hget(%p2,laststyle) == melee) {
    if ($hget(%p2,poison) >= 1) || (%hp < 60) {
      if ((%hp >= 70) && (%spec >= 3) && (!$hget(%nick,frozen))) var %attcmd dclaws
      else var %attcmd blood
    }
    else var %attcmd smoke    
  }
  elseif ($hget(%p2,laststyle) == mage) {
    if ((%spec >= 3) && ($hget(%p2,poison) >= 1)) var %attcmd dbow
    elseif ((%spec >= 1) && (%hp > 50)) var %attcmd mjavelin
    else var %attcmd onyx
  }
  elseif ($hget(%p2,laststyle) == range) || ($hget(%p2,laststyle) == pot) {
    if ($hget(%nick,frozen)) var %attcmd onyx
    elseif ((!$hget(%p2,poison)) && (%spec >= 1) && (%hp2 > 50)) var %attcmd dds
    elseif (%spec >= 3) {
      if ((%hp >= 50) || (%hp2 < 30)) var %attcmd dhally
      else var %attcmd sgs
    }
    elseif (%spec >= 2) {
      if ((%hp >= 50) || (%hp2 < 30)) var %attcmd dclaws
      else var %attcmd sgs
    }
    elseif (%spec >= 1) var %attcmd dds
    else var %attcmd guth
  }
  else {
    var %attcmd mjavelin
  }
  set -u25 %enddm [ $+ [ $1 ] ] 0
  damage %nick %p2 %attcmd $1
  if ($hget(%p2,hp) < 1) {
    dead $1 %p2 iDM
    halt
  }
  if ($specused(%attcmd)) {
    hdec %nick sp $calc($specused(%attcmd) /25)
  }
  hadd %nick frozen 0
  hadd $1 p1 %p2
  hadd $1 p2 %nick
}

on $*:TEXT:/^[!@.]status/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($hget($chan,p2)) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $status($chan)
  }
  elseif ($hget($chan,p1)) {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(STATUS) $hget($chan,p1) is waiting for someone to DM in $lower($chan) $+ .
  }
  else {
    $iif($left($1,1) == @,msgsafe #,notice $nick) $logo(STATUS) There is no DM in $lower($chan) $+ .
  }
}

alias status {
  var %p1 = $hget($1,p1), %p2 = $hget($1,p2)
  var %turn Turn: $s1(%p1) $+ 's
  var %hp HP: $s1(%p1) $s2($hget(%p1,hp)) $iif($hget(%p1,poison) >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $iif($hget(%p1,frozen),$+($chr(40),12Frozen,$chr(41))) $s1(%p2) $s2($hget(%p2,hp)) $iif($hget(%p2,poison) >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $iif($hget(%p2,frozen),$+($chr(40),12Frozen,$chr(41)))
  var %specbar Special Bar: $s1(%p1) $s2($iif($hget(%p1,sp) < 1,0,$gettok(25 50 75 100,$hget(%p1,sp),32)) $+ $chr(37)) $s1(%p2) $s2($iif($hget(%p2,sp) < 1,0,$gettok(25 50 75 100,$hget(%p2,sp),32)) $+ $chr(37))
  return $logo(STATUS) %turn %hp %specbar
}
