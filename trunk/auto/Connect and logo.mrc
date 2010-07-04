alias logo { return $+($s2,[,$s1,$$1-,$iif(%ver,- $+ $v1),,$s2,],) }

alias c1 return 03
alias c2 return 07

alias s1 {
  if ($1 === $null) return $c1
  return $+($c1,$1-,) 
}
alias s2 { 
  if ($1 === $null) return $c2
  return $+($c2,$1-,) 
}

alias tag { return $iif($len($me) != 7,Hub,$mid($me,5,2)) }

on *:CONNECT: {
  if ($me == iDM[OFF]) { nick iDM | mnick iDM }
  join #idm.staff
  if (%botnum != $null) {
    timer 1 10 privmsg #idm.staff Autoconnected on load.  Botnum: %botnum
  }
  mode $me +pB
  mysql_close %db
  unsetall
  botrefresh
  echo -s 4Connected.
  timer 1 10 privmsg #idm.staff Reconnected to server clearing vars, logins and currentdm list
}

alias botrefresh {
  dbcheck
  if ($hget(>weapon)) { hfree >weapon }
  echo -s 4Clearing active dms
  db.clear user indm
}

alias pingo {
  scon -at1 raw -q ping Anti-10053
}

on *:START:.timerAnti-10053 -o 0 60 scon -at1 raw -q ping Anti-10053
on ^*:PONG:if ($2 == Anti-10053) haltdef

alias update {
  return $true
  if (%dbfail > 3) { 
    if (!$timer(dbinit)) timerdbinit 0 2 dbinit
    return $true 
  }
  return $false
}

alias secondchan {
  return #idm.Staff
}

on *:DISCONNECT: {
  mysql_close %db
}

alias msgsafe {
  if ((c isincs $chan($1).mode) || (S isincs $chan($1).mode)) {
    var %text $replace($2-,$s1,)
    msg $1 $strip(%text,c)
  }
  else {
    msg $1 $2-
  }
}

on $*:TEXT:/^[!@.]status/Si:#: {
  if (# == #idm || # == #idm.Staff) && ($me != iDM) { halt }
  if ($isbanned($nick)) { halt }
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
