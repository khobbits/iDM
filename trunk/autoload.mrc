alias rehash {
  var %t $ctime
  while (2 < $script(0)) {
    var %i $v2   
    if (*autoload.mrc iswm $script(%i) || *autoconnect.mrc iswm $script(%i)) {
      dec %i
    }
    if (*autoload.mrc iswm $script(%i) || *autoconnect.mrc iswm $script(%i)) {
      dec %i
    }
    unload -nrs " $+ $script(%i) $+ "
  }
  privmsg #idm.staff Unloaded scripts - Script took $calc($ctime - %t) seconds.
  .timer 1 1 rehash.cont
}

alias rehash.load {
  load -rs " $+ $1- $+ "
}

alias rehash.cont {
  var %t $ctime
  noop $findfile($scriptdirauto\,*.*,0,1,rehash.load $1-)
  privmsg #idm.staff Reloaded scripts - $script(0) Scripts Loaded - Script took $calc($ctime - %t) seconds.
  var %botnum $botnum
  if (%botnum !isnum 1-10) { var %botnum 1 }
  inc %botnum
  putlog perform rehash.run %botnum
  botrefresh
}

alias rehash.run {
  if ($cid != $scon(1)) { halt }
  var %botnum $botnum
  if (%botnum == $null) { privmsg #idm.staff $logo(Error) This bot doesn't have a instance number, it wasn't auto started, halting update. }
  if ($1 == %botnum) {
    privmsg #idm.staff $logo(Reloading Scripts) Running update script in 5 seconds.
    .timer -m 1 5000 rehash
  }
}

alias putlog {
  if ($1 == perform) {
    sbnc tcl putmainlog $chr(123) $+ $1- $+ $chr(125)
  }
  else {
    sbnc tcl putmainlog $chr(123) $+ $me $+ : $1- $+ $chr(125)
  }
  sbnc tcl setctx admin; putchan -#idm.staff $chr(123) $+ $logo(BNC: $+ $me $+ ) $1- $+ $chr(125)
}

on *:TEXT:perform *:?: {
  if (($nick == -sbnc) && ($address == bouncer@shroudbnc.info)) { 
    if (%dupe) { 
      echo -t $nick [DupeClient] Waiting for other client reply.
      unset %dupe
    }
    else { 
      $2-
    }
  }
}

on *:TEXT:Another client logged in*:?: { if (($nick == -sbnc) && ($address == bouncer@shroudbnc.info)) { dupeclient } }
alias dupeclient {
  if ($1 == SYN) {
    var %botnum $botnum
    if (%botnum == $null) {
      quit DupeClient ACK
    }
    else {
      set -u30 %dupe 1
      sbnc tcl putlog {perform quit DupeClient ACK}
    }
  }
  else {
    set -u30 %dupe 1
    sbnc tcl putlog {perform sbnc tcl putlog {perform dupeclient SYN}}
  }
}


alias numlines {
  var %i 0
  var %lines 0
  while (%i < $script(0)) {
    inc %i 
    inc %lines $lines($script(%i))
  }
  echo -a %lines
}
