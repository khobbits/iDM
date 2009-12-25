alias logo { return $+($s2,[,$s1,$$1-,$s2,],) }

alias c1 return 03
alias c2 return 04

alias s1 {
  if ($1 !== $null) return $c1
  return $+($c1,$1-,) 
}
alias s2 { 
  if ($1 !== $null) return $c2
  return $+($c2,$1-,) 
}

alias tag { return $iif($len($me) != 7,Hub,$mid($me,5,2)) }

on *:CONNECT: {
  mode $me +pB
  mysql_close %db
  unsetall
  db.clear user login
  db.clear user indm
  timer 1 10 msgsafe #idm.staff Reconnected to server clearing vars, logins and currentdm list
}

alias pingo {
  scon -at1 raw -q ping Anti-10053
}

on *:START:.timerAnti-10053 -o 0 60 scon -at1 raw -q ping Anti-10053
on ^*:PONG:if ($2 == Anti-10053) haltdef

alias update {
  ;True if you don't want people using the store at all while updating.
  return $false
}
alias allupdate {
  ;True if you don't want people DMing while updating.
  return $false
}
alias secondchan {
  return #idm.Staff
}

on *:DISCONNECT: {
  mysql_close %db
}

alias msgsafe {
  if (c isincs $chan($1).mode) {
    var %text $replace($2-,$s1,)
    msg $1 $strip(%text,c)
  }
  else {
    msg $1 $2-
  }
}
