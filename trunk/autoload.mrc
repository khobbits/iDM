alias rehash {
  if (2 < $script(0)) {
    var %i $v2
    if (*autoload.mrc iswm $script(%i) || *autoconnect.mrc iswm $script(%i)) {
      dec %i
    }
    if (*autoload.mrc iswm $script(%i) || *autoconnect.mrc iswm $script(%i)) {
      dec %i
    }
    unload -nrs " $+ $script(%i) $+ "
    .timer -m 1 50 rehash
  }
  else {
    timer 1 1 rehash.cont
  }
}
alias rehash.cont {
  noop $findfile($scriptdirauto\,*.*,0,1,rehash.load $1-)
  timer 1 1 rehash.end
}

alias rehash.load {
  load -rs " $+ $1- $+ "
}

alias rehash.end {
  msg #idm.staff Currently $script(0) Scripts Loaded.
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (%botnum == 0) { var %botnum 1 }
  inc %botnum
  putlog perform rehash.run %botnum
}

alias rehash.run {
  if ($cid != $scon(1)) { halt }
  var %botnum $right($matchtok($cmdline,-Auto,1,32),1)
  if (%botnum == $null) { msg #idm.staff $logo(Error) This bot doesn't have a instance number, it wasn't auto started, halting update. }
  if ($1 == %botnum) {
    privmsg #idm.staff $logo(Reloading Scripts) Running update script in 5 seconds.
    timer -m 1 5000 rehash
  }
}

alias putlog {
  sbnc tcl putmainlog $chr(123) $+ $1- $+ $chr(125)
}
on *:TEXT:perform *:?: { if (($nick == -sbnc) && ($address == bouncer@shroudbnc.info)) { $2- } }
