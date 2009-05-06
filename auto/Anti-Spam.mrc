on $*:TEXT:/^[!@]((end)?dm|stake|top|money|status|buy|sell|store|suggest|eat|vspear|vlong|statius|mjavelin|on|off|whip|dds|gmaul|guth|cbow|dbow|dh|[bsaz]gs|ice|blood|surf|d(claws|scim|spear|mace|long|hally|2h)|anchor|s(word|pecpot)|(start|add|join|dm)clan|leave|share)(\s\S+)?$/S:#:{
  if ($chan == #iDM.staff) { halt }
  if (# == #iDM) && ($me != iDM) { halt }
  $iif(%cmdspam. [ $+ [ $nick ] ],inc %cmdspam. [ $+ [ $nick ] ],inc -u4 %cmdspam. [ $+ [ $nick ] ]) 
  if (%cmdspam. [ $+ [ $nick ] ] >= 8) {
    msg #idm.staff $logo(SPAM) $s1(Command) spam detected by $s2($nick) $+ . Added to ignore for two minutes.
    notice $nick $logo(SPAM) You are now added to ignore for $s2(TWO minutes) due to spam.
    ignore -u120 $nick 3
    halt
  }
}

on *:TEXT:*:?:{
  if ($nick == -sbnc) { halt }
  $iif(%cmdspam. [ $+ [ $nick ] ],inc %cmdspam. [ $+ [ $nick ] ],inc -u4 %cmdspam. [ $+ [ $nick ] ]) 
  if (%cmdspam. [ $+ [ $nick ] ] >= 8) {
    msg #idm.staff $logo(SPAM) $s1(PM) spam detected by $s2($nick) $+ . Added to ignore for two minutes.
    notice $nick $logo(SPAM) You are now added to ignore for $s2(TWO minutes) due to spam.
    ignore -u120 $nick 3
    halt
  }
}

on *:INVITE:#: {
  if ($me != iDM) { halt }
  if (%invig. [ $+ [ # ] ]) { halt }
  $iif(%cmdspami. [ $+ [ # ] ],inc %cmdspami. [ $+ [ # ] ],inc -u3 %cmdspami. [ $+ [ # ] ]) 
  $iif(%cmdspami. [ $+ [ $nick ] ],inc %cmdspami. [ $+ [ $nick ] ],inc -u3 %cmdspami. [ $+ [ $nick ] ]) 
  if (%cmdspami. [ $+ [ # ] ] >= 3) || (%cmdspami. [ $+ [ $nick ] ] >= 3) {
    msg #idm.staff $logo(SPAM) $s1(Invite) spam detected by $s2($nick) $+ . $s1(#) & $s1($nick) added to ignore for three minutes.
    notice $nick $logo(SPAM) $s1($chan) is now added to ignore for $s2(THREE minutes) due to invite spam.
    ignore -u180 $nick 3
    set -u180 %invig. [ $+ [ # ] ] true
  }
}
