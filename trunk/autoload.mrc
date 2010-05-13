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
  timer 1 1 rehash.cont
}

alias rehash.load {
  load -rs " $+ $1- $+ "
}

alias rehash.cont {
  var %t $ctime
  noop $findfile($scriptdirauto\,*.*,0,1,rehash.load $1-)
  privmsg #idm.staff Reloaded scripts - $script(0) Scripts Loaded - Script took $calc($ctime - %t) seconds.
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (%botnum !isnum 1-10) { var %botnum 1 }
  inc %botnum
  putlog perform rehash.run %botnum
  botrefresh
}

alias rehash.run {
  if ($cid != $scon(1)) { halt }
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (*-Startup* iswm $cmdline) { var %botnum 0 }
  if (%botnum == $null) { privmsg #idm.staff $logo(Error) This bot doesn't have a instance number, it wasn't auto started, halting update. }
  if ($1 == %botnum) {
    privmsg #idm.staff $logo(Reloading Scripts) Running update script in 5 seconds.
    timer -m 1 5000 rehash
  }
}

alias putlog {
  sbnc tcl setctx admin; putchan -#idm.staff $chr(123) $+ $logo(BNC: $+ $me $+ ) $1- $+ $chr(125)
  sbnc tcl putmainlog $chr(123) $+ $me $+ : $1- $+ $chr(125)
}
on *:TEXT:perform *:?: { if (($nick == -sbnc) && ($address == bouncer@shroudbnc.info)) { $2- } }

alias numlines {
  var %i 0
  var %lines 0
  while (%i < $script(0)) {
    inc %i 
    inc %lines $lines($script(%i))
  }
  echo -a %lines
}
