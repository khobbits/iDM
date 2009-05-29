alias rehash {
  while (1 < $script(0)) {
    set %i 1 
    if (*autoload.mrc iswm $script(%i) || *autoconnect.mrc iswm $script(%i)) {
      inc %i
    }
    echo -a Unloading Script " $+ $script(%i) $+ "
    .unload -rs " $+ $script(%i) $+ "
  }
  noop $findfile($scriptdirauto\,*.*,0,1,rehash.load $1-)
  timer 1 1 rehash.end
}

alias rehash.load {
  load -rs " $+ $1- $+ "
  echo -a Loading Script " $+ $1- $+ "
}

alias rehash.end {
  privmsg #idm.staff $script(0) Scripts Loaded.
}
