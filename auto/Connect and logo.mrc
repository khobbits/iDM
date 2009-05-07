alias logo { return $+(07[,03,$$1-,07],) }
alias s1 { return $+($chr(3),03,$1-,) }
alias s2 { return $+($chr(3),07,$1-,) }

on *:CONNECT: {
  mode $me +pB 
  unsetall 
  remini status.ini currentdm 
  remini login.ini login
}

alias update {
  ;True if you don't want people using the store at all while updating.
  return $false
}
alias allupdate {
  ;True if you don't want people DMing while updating.
  return $false
}
