alias rehash {
  set %i 0 
  while (%i < $script(0)) {
    inc %i 
    if (*autoload.mrc !iswm $script(%i)) {
      echo -a Unloading Script %i " $+ $script(%i) $+ "
      .unload -rs " $+ $script(%i) $+ "
    }
  }
  noop $findfile($scriptdirauto\,*.*,0,1,rehash.load $1-)


}

alias rehash.load {
  echo -a loading $1
}
