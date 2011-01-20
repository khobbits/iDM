alias logo { return $+($s2,[,$s1,$$1-,$iif(%ver,- $+ $v1),,$s2,],) }

alias cs1 return 3
alias cs2 return 7
alias c1 return 03
alias c2 return 07

alias s1 {
  if ($1 === $null) return  $+ $c1
  return $+(,$iif($left($1,1) isnum,$c1,$cs1),$1-,) 
}
alias s2 { 
  if ($1 === $null) return  $+ $c2
  return $+(,$iif($left($1,1) isnum,$c2,$cs2),$1-,) 
}

alias tag { return $iif($len($me) != 7,Hub,$mid($me,5,2)) }

on *:CONNECT: {
  if ($me == iDM[OFF]) { nick iDM | mnick iDM }
  join $staffchan
  if (%botnum != $null) {
    .timer 1 10 privmsg $staffchan Autoconnected on load.  Botnum: %botnum
  }
  mode $me +pB
  mysql_close %db
  unsetall
  botrefresh
  echo -s 4Connected.
  .timer 1 10 privmsg $staffchan Reconnected to server clearing vars, logins and currentdm list
}

alias botrefresh {
  dbcheck
  if ($hget(>weapon)) { hfree >weapon }
  if ($hget(>gwd)) { hfree >gwd }
  if ($hget(>store)) { hfree >store }
  echo -s 4Clearing active dms
  db.clear user indm
  set %staffchan $staffchan
  set %staffchans $staffchan $+ , $+ $supportchan
}

alias pingo {
  scon -at1 raw -q ping Anti-10053
}

on *:START:.timerAnti-10053 -o 0 60 scon -at1 raw -q ping Anti-10053
on ^*:PONG:if ($2 == Anti-10053) haltdef

alias update {
  if ($chan == $staffchan) { return $false }
  if (%disable == 1) { return $true }
  if (%dbfail > 3) { 
    if (!$timer(dbinit)) timerdbinit 0 2 dbinit
    return $true 
  }
  return $false
}

alias staffchan {
  return #idm.staff
}

alias supportchan {
  return #idm.support
}

on *:DISCONNECT: {
  mysql_close %db
}

alias msgsafe {
  if ($1 == $staffchan) { dblog STAFFCHAN: $me $+ : $2- }
  if ((c isincs $chan($1).mode) || (S isincs $chan($1).mode)) {
    var %text $replace($2-,$s1,)
    msg $1 $strip(%text,c)
  }
  else {
    msg $1 $2-
  }
}

on $*:TEXT:/^[!@.]status/Si:#: {
  if ((# == #idm || # == $staffchan) && ($me != iDM)) { halt }
  if ($isbanned($nick)) { halt }
  if ($hget($chan,gwd.npc)) {
    if ($hget($chan,gwd.time)) {
      $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(GWD-STATUS) $status($chan)
    }
    else {
      $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(GWD-STATUS) $s1($gettok($hget($chan,players),1,44)) is waiting for a team for $s1($hget($chan,gwd.npc)) $+ . Join now by typing !gwd $+ .
    }
  }
  elseif ($hget($chan,p2)) {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $status($chan)
  }
  elseif ($hget($chan,p1)) {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(STATUS) $s1($hget($chan,p1)) is waiting for someone to DM in $lower($chan) $+ .
  }
  else {
    $iif($left($1,1) == @,msgsafe $chan,notice $nick) $logo(STATUS) There is no DM/GWD in $lower($chan) $+ .
  }
}

alias status {
  if ($hget($chan,gwd.time)) {
    var %e = $hget($1,players), %x = 1, %m = $hget($chan,gwd.npc)
    while (%x <= $gettok(%e,0,44)) {
      var %o $gettok(%e,%x,44)
      var %hp %hp $s1(%o) $s2($hget(%o,hp))
      var %sp %sp $s1(%o)) $s2($iif($hget(%o,sp) < 1,0,$calc(25 * $hget(%o,sp))) $+ $chr(37)))
      inc %x
    }
    return HP: $s1(%m) $s2($hget(<gwd> $+ $chan,hp)) %hp Special Bar: %sp
  }
  else {
    var %p1 = $hget($1,p1), %p2 = $hget($1,p2)
    var %turn Turn: $s1(%p1) $+ 's
    var %hp HP: $s1(%p1) $s2($hget(%p1,hp)) $iif($hget(%p1,poison) >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $iif($hget(%p1,frozen),$+($chr(40),12Frozen,$chr(41))) $s1(%p2) $s2($hget(%p2,hp)) $iif($hget(%p2,poison) >= 1,$+($chr(40),Pois $s2($v1),$chr(41))) $iif($hget(%p2,frozen),$+($chr(40),12Frozen,$chr(41)))
    var %specbar Special Bar: $s1(%p1) $s2($iif($hget(%p1,sp) < 1,0,$calc(25 * $hget(%p1,sp))) $+ $chr(37)) $s1(%p2) $s2($iif($hget(%p2,sp) < 1,0,$calc(25 * $hget(%p2,sp))) $+ $chr(37))
    return $logo(STATUS) %turn %hp %specbar
  }
}
