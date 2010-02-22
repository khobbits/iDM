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
  botrefresh
  echo -s 4Connected.
  timer 1 10 privmsg #idm.staff Reconnected to server clearing vars, logins and currentdm list
}

alias botrefresh {
  mysql_close %db
  unsetall
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

  ;return $true
  if (%dbfail > 3) { dbinit | return $true }
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
