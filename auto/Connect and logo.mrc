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
alias secondchan {
  return #iDM.Staff
}

on *:DISCONNECT: { 
  unsetall
  remini status.ini currentdm
  remini login.ini login
}

alias bind {
  if (!$1) || ($1 == off) { bindip off | halt }
  if ($1 isnum 1-7) { bindip on $gettok($iplistlol,$1,58) }
  if ($1 > 7) { echo Error: No IP found with that ID. Please select a number between 1 and 7, or off to disable. | halt }
}
alias iplistlol {
  return 66.90.87.84:66.90.87.85:66.90.87.86:66.90.87.87:66.90.87.88:66.90.85.27:66.90.85.26
}
