on *:TEXT:*:#: {
  if (# == #iDM || # == #iDM.Staff) && ($me != iDM) { halt }
  tokenize 32 $remove($1-,$chr(36),$chr(37))
  if ($1 == !on) {
    if (%p2 [ $+ [ # ] ]) { notice $nick $logo(ERROR) You can't use this command while people are DMing. | halt }
    if (!$2) { notice $nick $logo(ERROR) To use !on/off, type $1 attack,attack,attack,etc. Or, you can type $1 -h (heal attacks), $1 -L (list).| halt }
    if ($2 == -L) { displayoff $nick # | halt }
    else enable $remove($2-,$chr(32)) $nick #
  }
  elseif ($1 == !off) {
    if (%p2 [ $+ [ # ] ]) { notice $nick $logo(ERROR) You can't use this command while people are DMing. | halt }
    if (!$2) { notice $nick $logo(ERROR) To use !on/off, type $1 attack,attack,attack,etc. Or, you can type $1 -h (heal attacks), $1 -L (list). | halt }
    if ($2 == -L) { displayoff $nick # | halt }
    else disable $remove($2-,$chr(32)) $nick #
  }
}
alias displayoff {
  if (!$.ini(OnOff.ini,$2,0)) {
    notice $1 $logo(DISABLED) All of the attacks for # are on. | halt 
  }
  var %a 1
  while ($.ini(OnOff.ini,$2,%a)) { var %o %o $v1 | inc %a }
  notice $1 $logo(DISABLED) These attacks are currently disabled: $replace(%o,$chr(32),$chr(44))
}
alias enable {
  if ($2 !isop $3) && (!$.readini(admins.ini,admins,$address($2,3))) { halt }
  tokenize 32 $replace($1,$chr(44),$chr(58)) $2-
  if ($1 == -h) {
    remini -n OnOff.ini $3 guth
    remini -n OnOff.ini $3 sgs
    remini -n OnOff.ini $3 blood
    remini -n OnOff.ini $3 onyx
    notice $2 $logo(ENABLE) Healing attacks are now on in $3 $+ .
    halt
  }
  if ($1 == all) { 
    remini -n OnOff.ini $3
    notice $2 $logo(ENABLE) All attacks have been turned on in $3 $+ .
    halt
  }
  var %a 1
  while ($gettok($1,%a,58)) {
    if ($attack($gettok($1,%a,58))) && ($.readini(OnOff.ini,$3,$gettok($1,%a,58))) { var %b %b $gettok($1,%a,58) | remini -n OnOff.ini $3 $gettok($1,%a,58) }
    else { var %c %c $gettok($1,%a,58) } 
    inc %a
  }
  notice $2 $logo(ENABLE $3) $iif(%b,$s1(Enabled) $+ : $replace(%b,$chr(32),$chr(44))) $iif(%c,$s1(Errors) $+ : $replace(%c,$chr(32),$chr(44)) (These are either already on, or not an attack))
}
alias disable {
  if ($2 !isop $3) && (!$.readini(admins.ini,admins,$address($2,3))) { halt }
  tokenize 32 $replace($1,$chr(44),$chr(58)) $2-
  if ($1 == -h) {
    writeini -n OnOff.ini $3 guth true
    writeini -n OnOff.ini $3 sgs true
    writeini -n OnOff.ini $3 blood true
    ;writeini -n OnOff.ini $3 onyx true
    notice $2 $logo(DISABLE) Healing attacks are now off.
    halt
  }
  var %a 1
  while ($gettok($1,%a,58)) {
    if ($attack($gettok($1,%a,58))) && (!$.readini(OnOff.ini,$3,$gettok($1,%a,58))) { var %b %b $gettok($1,%a,58) | writeini -n OnOff.ini $3 $gettok($1,%a,58) true }
    else { var %c %c $gettok($1,%a,58) } 
    inc %a
  }
  notice $2 $logo(DISABLE $3) $iif(%b,$s1(Disabled) $+ : $replace(%b,$chr(32),$chr(44))) $iif(%c,$s1(Errors) $+ : $replace(%c,$chr(32),$chr(44)) (These are either already off, or not an attack))
}
