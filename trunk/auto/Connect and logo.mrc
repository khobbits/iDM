alias logo { return $+(07[,03,$$1-,07],) }
alias s1 { return $+($chr(3),03,$1-,) }
alias s2 { return $+($chr(3),07,$1-,) }

on *:CONNECT: {
  mode $me +pB
  mysql_close %db
  unsetall
  remini status.ini currentdm
  db.clear user login
  timer 1 10 msg #idm.staff Reconnected to server clearing vars, logins and currentdm list
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
  unsetall
  remini status.ini currentdm
  db.clear user login
}
