on *:TEXT:!amsg*:*: {
  if (!$.readini(Admins.ini,Admins,$nick)) && (!$.readini(Admins.ini,Admins,$address($nick,3))) { halt }
  if (!$2) { notice $nick Syntax: !amsg 03message | halt }
  if ($+(*,$nick,*) iswm $2-) { notice $nick $logo(ERROR) Please dont add your name in the amsg since it adds your name to the amsg automatically. | halt }
  if ($me == iDM) { amsg $logo(AMSG) $2- 07[03 $+ $nick $+ 07] | halt }
  var %x = 1
  while ($chan(%x)) {
    if ($chan(%x) != #iDM && $chan(%x) != #iDM.Staff) {
      msg $chan(%x) $logo(AMSG) $2- 07[03 $+ $nick $+ 07]
    }
    inc %x 
  }
}
